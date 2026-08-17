///|
fn flow_error(error : @moonflowgraph.GraphError) -> Diagnostic {
  match error {
    DuplicateTask(id) =>
      Diagnostic::new(
        "graph.task.duplicate",
        "tasks",
        "MoonFlowGraph rejected a duplicate task id",
        "unique task ids",
        id.value(),
      )
    DuplicateDependency(edge) =>
      Diagnostic::new(
        "graph.dep.duplicate",
        "dependencies",
        "MoonFlowGraph rejected a duplicate dependency",
        "unique dependency edges",
        edge.before().value() + " -> " + edge.after().value(),
      )
    MissingTask(id) =>
      Diagnostic::new(
        "graph.task.missing",
        "tasks",
        "MoonFlowGraph could not find a task",
        "declared task id",
        id.value(),
      )
    MissingDependencyEndpoint(edge) =>
      Diagnostic::new(
        "graph.dep.missing",
        "dependencies",
        "MoonFlowGraph rejected a dependency with a missing endpoint",
        "declared task ids",
        edge.before().value() + " -> " + edge.after().value(),
      )
    CycleDetected(ids) => {
      let values = ids.map(fn(id) { id.value() })
      Diagnostic::new(
        "graph.cycle",
        "graph",
        "dependency graph contains a cycle",
        "directed acyclic graph",
        join_strings(values, " -> "),
      )
    }
  }
}

///|
fn estimate_for(
  estimates : Array[TaskEstimate],
  id : String,
) -> Result[Int, Diagnostic] {
  let mut found : Int? = None
  for estimate in estimates {
    if estimate.id == id {
      if found is Some(_) {
        return Err(
          Diagnostic::new(
            "estimate.duplicate", "estimates", "task has more than one duration estimate",
            "one estimate per MoonFlowGraph task", id,
          ),
        )
      }
      found = Some(estimate.duration)
    }
  }
  match found {
    Some(duration) =>
      if duration < 1 || duration > 1000000 {
        Err(
          Diagnostic::new(
            "estimate.duration.range",
            "estimates",
            "duration estimate is outside the supported range",
            "1..1000000",
            duration.to_string(),
          ),
        )
      } else {
        Ok(duration)
      }
    None =>
      Err(
        Diagnostic::new(
          "estimate.missing", "estimates", "MoonFlowGraph task has no duration estimate",
          "one estimate per task", id,
        ),
      )
  }
}

///|
fn indexes_from_flow_ids(
  nodes : Array[TaskNode],
  ids : Array[@moonflowgraph.TaskId],
) -> Array[Int] {
  ids.map(fn(id) { index_of_node(nodes, id.value()).unwrap() })
}

///|
fn build_nodes_from_flow(
  graph : @moonflowgraph.FlowGraph,
  estimates : Array[TaskEstimate],
) -> Result[Array[TaskNode], Diagnostic] {
  let nodes : Array[TaskNode] = []
  for task in graph.tasks() {
    let id = task.id().value()
    let duration = match estimate_for(estimates, id) {
      Ok(value) => value
      Err(error) => return Err(error)
    }
    nodes.push({ id, duration, deps: [], dependents: [], label: task.title() })
  }
  for estimate in estimates {
    if index_of_node(nodes, estimate.id) is None {
      return Err(
        Diagnostic::new(
          "estimate.task.unknown",
          "estimates",
          "duration estimate names a task outside MoonFlowGraph",
          "MoonFlowGraph task id",
          estimate.id,
        ),
      )
    }
  }
  for edge in graph.dependencies() {
    let before = index_of_node(nodes, edge.before().value()).unwrap()
    let after = index_of_node(nodes, edge.after().value()).unwrap()
    let parent = nodes[before]
    let dependents = parent.dependents.copy()
    dependents.push(after)
    nodes[before] = {
      id: parent.id,
      duration: parent.duration,
      deps: parent.deps,
      dependents,
      label: parent.label,
    }
    let child = nodes[after]
    let deps = child.deps.copy()
    deps.push(before)
    nodes[after] = {
      id: child.id,
      duration: child.duration,
      deps,
      dependents: child.dependents,
      label: child.label,
    }
  }
  Ok(nodes)
}

///|
/// Extend a validated MoonFlowGraph with duration-based CPM and impact analysis.
pub fn analyze_flow_graph(
  graph : @moonflowgraph.FlowGraph,
  estimates : Array[TaskEstimate],
) -> Result[Dag, Diagnostic] {
  if graph.task_count() > 4096 {
    return Err(
      Diagnostic::new(
        "graph.task.limit",
        "tasks",
        "graph exceeds the analysis safety limit",
        "at most 4096 tasks",
        graph.task_count().to_string(),
      ),
    )
  }
  let plan = match graph.plan() {
    Ok(value) => value
    Err(error) => return Err(flow_error(error))
  }
  let nodes = match build_nodes_from_flow(graph, estimates) {
    Ok(value) => value
    Err(error) => return Err(error)
  }
  let order = indexes_from_flow_ids(nodes, plan.order())
  let layers = plan
    .batches()
    .map(fn(batch) { indexes_from_flow_ids(nodes, batch) })
  Ok({ nodes, order, layers })
}

///|
fn flow_graph_from_spec(
  spec : GraphSpec,
) -> Result[@moonflowgraph.FlowGraph, Diagnostic] {
  let graph = @moonflowgraph.FlowGraph::new()
  for task in spec.tasks {
    let result = graph.add_task(
      @moonflowgraph.TaskNode::new(task.id, task.label),
    )
    if result is Err(error) {
      return Err(flow_error(error))
    }
  }
  for task in spec.tasks {
    for dep in task.deps {
      if dep == task.id {
        return Err(
          Diagnostic::new(
            "graph.dep.self", "dependencies", "task depends on itself", "another task id",
            dep,
          ),
        )
      }
      let result = graph.add_dependency(
        @moonflowgraph.TaskId::new(dep),
        @moonflowgraph.TaskId::new(task.id),
      )
      if result is Err(error) {
        return Err(flow_error(error))
      }
    }
  }
  Ok(graph)
}

///|
/// Convert the compact convenience format into a MoonFlowGraph, then extend it.
pub fn GraphSpec::compile(self : GraphSpec) -> Result[Dag, Diagnostic] {
  let graph = match flow_graph_from_spec(self) {
    Ok(value) => value
    Err(error) => return Err(error)
  }
  let estimates = self.tasks.map(fn(task) {
    TaskEstimate::new(task.id, task.duration)
  })
  analyze_flow_graph(graph, estimates)
}

///|
pub fn compile_graph(source : String) -> Result[Dag, Diagnostic] {
  let spec = match GraphSpec::parse(source) {
    Ok(value) => value
    Err(error) => return Err(error)
  }
  spec.compile()
}
