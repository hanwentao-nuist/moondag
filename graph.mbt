///|
fn validate_unique_tasks(tasks : Array[TaskSpec]) -> Result[Unit, Diagnostic] {
  for index, task in tasks {
    for previous = 0; previous < index; previous = previous + 1 {
      if tasks[previous].id == task.id {
        return Err(
          Diagnostic::new(
            "graph.task.duplicate",
            "tasks[" + index.to_string() + "]",
            "task id appears more than once",
            "unique task ids",
            task.id,
          ),
        )
      }
    }
  }
  Ok(())
}

///|
fn check_references(tasks : Array[TaskSpec]) -> Result[Unit, Diagnostic] {
  for task_index, task in tasks {
    for dep_index, dep in task.deps {
      if dep == task.id {
        return Err(
          Diagnostic::new(
            "graph.dep.self",
            "tasks[" +
            task_index.to_string() +
            "].deps[" +
            dep_index.to_string() +
            "]",
            "task depends on itself",
            "another task id",
            dep,
          ),
        )
      }
      if index_of_id(tasks, dep) is None {
        return Err(
          Diagnostic::new(
            "graph.dep.missing",
            "tasks[" +
            task_index.to_string() +
            "].deps[" +
            dep_index.to_string() +
            "]",
            "dependency does not name a task in the graph",
            "declared task id",
            dep,
          ),
        )
      }
    }
  }
  Ok(())
}

///|
fn build_nodes(tasks : Array[TaskSpec]) -> Array[TaskNode] {
  let nodes = []
  for task in tasks {
    let deps = []
    for dep in task.deps {
      deps.push(index_of_id(tasks, dep).unwrap())
    }
    nodes.push({
      id: task.id,
      duration: task.duration,
      deps,
      dependents: [],
      label: task.label,
    })
  }
  for index, node in nodes {
    for dep in node.deps {
      let parent = nodes[dep]
      let dependents = parent.dependents.copy()
      dependents.push(index)
      nodes[dep] = {
        id: parent.id,
        duration: parent.duration,
        deps: parent.deps,
        dependents,
        label: parent.label,
      }
    }
  }
  nodes
}

///|
fn find_ready(indegrees : Array[Int], used : Array[Bool]) -> Int? {
  for index, value in indegrees {
    if !used[index] && value == 0 {
      return Some(index)
    }
  }
  None
}

///|
fn trace_cycle(
  nodes : Array[TaskNode],
  remaining : Array[Bool],
) -> Array[String] {
  let mut start = 0
  while start < remaining.length() && !remaining[start] {
    start = start + 1
  }
  let path = []
  let positions = []
  let mut current = start
  while true {
    for index, seen in path {
      if seen == current {
        let cycle = []
        for item = index; item < path.length(); item = item + 1 {
          cycle.push(nodes[path[item]].id)
        }
        cycle.push(nodes[current].id)
        return cycle
      }
    }
    path.push(current)
    positions.push(current)
    let mut next = current
    let mut found = false
    for dep in nodes[current].deps {
      if remaining[dep] {
        next = dep
        found = true
        break
      }
    }
    if !found {
      return ids_from_indexes(nodes, positions)
    }
    current = next
  }
  []
}

///|
fn topo_indexes_or_cycle(
  nodes : Array[TaskNode],
) -> Result[Array[Int], Diagnostic] {
  let indegrees = nodes.map(fn(node) { node.deps.length() })
  let used = nodes.map(fn(_) { false })
  let order = []
  while order.length() < nodes.length() {
    match find_ready(indegrees, used) {
      Some(index) => {
        used[index] = true
        order.push(index)
        for child in nodes[index].dependents {
          indegrees[child] = indegrees[child] - 1
        }
      }
      None => {
        let remaining = used.map(fn(value) { !value })
        let cycle = trace_cycle(nodes, remaining)
        return Err(
          Diagnostic::new(
            "graph.cycle",
            "graph",
            "dependency graph contains a cycle",
            "directed acyclic graph",
            join_strings(cycle, " -> "),
          ),
        )
      }
    }
  }
  Ok(order)
}

///|
/// Validate a parsed graph and compile dependency names to node indexes.
pub fn GraphSpec::compile(self : GraphSpec) -> Result[Dag, Diagnostic] {
  if self.tasks.length() > 4096 {
    return Err(
      Diagnostic::new(
        "graph.task.limit",
        "tasks",
        "graph exceeds the task safety limit",
        "at most 4096 tasks",
        self.tasks.length().to_string(),
      ),
    )
  }
  match validate_unique_tasks(self.tasks) {
    Ok(_) => ()
    Err(error) => return Err(error)
  }
  match check_references(self.tasks) {
    Ok(_) => ()
    Err(error) => return Err(error)
  }
  let nodes = build_nodes(self.tasks)
  match topo_indexes_or_cycle(nodes) {
    Ok(_) => Ok({ nodes, })
    Err(error) => Err(error)
  }
}

///|
pub fn compile_graph(source : String) -> Result[Dag, Diagnostic] {
  let spec = match GraphSpec::parse(source) {
    Ok(value) => value
    Err(error) => return Err(error)
  }
  spec.compile()
}
