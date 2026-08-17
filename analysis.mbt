///|
fn topo_indexes(dag : Dag) -> Array[Int] {
  dag.order.copy()
}

///|
pub fn Dag::topological_order(self : Dag) -> Array[String] {
  ids_from_indexes(self.nodes, topo_indexes(self))
}

///|
pub fn Dag::layers(self : Dag) -> Array[Array[String]] {
  self.layers.map(fn(layer) { ids_from_indexes(self.nodes, layer) })
}

///|
/// Identifies the upstream planner used for validation, order, and batches.
pub fn planner_backend() -> String {
  "AlexenderSokolov/moonflowgraph@0.3.0"
}

///|
pub fn Dag::downstream(
  self : Dag,
  changed : Array[String],
) -> Result[Array[String], Diagnostic] {
  let marked = self.nodes.map(fn(_) { false })
  let queue = []
  for id in changed {
    match index_of_node(self.nodes, id) {
      Some(index) =>
        if !marked[index] {
          marked[index] = true
          queue.push(index)
        }
      None =>
        return Err(
          Diagnostic::new(
            "query.task.missing", "changed", "query names a task outside the graph",
            "declared task id", id,
          ),
        )
    }
  }
  let mut cursor = 0
  while cursor < queue.length() {
    let index = queue[cursor]
    for child in self.nodes[index].dependents {
      if !marked[child] {
        marked[child] = true
        queue.push(child)
      }
    }
    cursor = cursor + 1
  }
  let result = []
  for index in topo_indexes(self) {
    if marked[index] {
      result.push(self.nodes[index].id)
    }
  }
  Ok(result)
}

///|
pub fn Dag::blockers(
  self : Dag,
  target : String,
) -> Result[Array[String], Diagnostic] {
  let target_index = match index_of_node(self.nodes, target) {
    Some(index) => index
    None =>
      return Err(
        Diagnostic::new(
          "query.task.missing", "target", "query names a task outside the graph",
          "declared task id", target,
        ),
      )
  }
  let marked = self.nodes.map(fn(_) { false })
  let queue = [target_index]
  marked[target_index] = true
  let mut cursor = 0
  while cursor < queue.length() {
    let index = queue[cursor]
    for dep in self.nodes[index].deps {
      if !marked[dep] {
        marked[dep] = true
        queue.push(dep)
      }
    }
    cursor = cursor + 1
  }
  let result = []
  for index in topo_indexes(self) {
    if marked[index] && index != target_index {
      result.push(self.nodes[index].id)
    }
  }
  Ok(result)
}

///|
pub fn Dag::critical_path(self : Dag) -> CriticalPath {
  if self.nodes.is_empty() {
    return { task_ids: [], duration: 0 }
  }
  let order = topo_indexes(self)
  let totals = self.nodes.map(fn(_) { 0 })
  let parents : Array[Int?] = self.nodes.map(fn(_) { None })
  let mut best_index = order[0]
  for index in order {
    let mut best_parent : Int? = None
    let mut best_dep_total = 0
    for dep in self.nodes[index].deps {
      if totals[dep] > best_dep_total {
        best_dep_total = totals[dep]
        best_parent = Some(dep)
      }
    }
    totals[index] = best_dep_total + self.nodes[index].duration
    parents[index] = best_parent
    if totals[index] > totals[best_index] {
      best_index = index
    }
  }
  let reverse = []
  let mut cursor : Int? = Some(best_index)
  while cursor is Some(index) {
    reverse.push(index)
    cursor = parents[index]
  }
  let ids = []
  let mut index = reverse.length()
  while index > 0 {
    index = index - 1
    ids.push(self.nodes[reverse[index]].id)
  }
  { task_ids: ids, duration: totals[best_index] }
}

///|
pub fn Dag::analyze(self : Dag) -> Analysis {
  {
    order: self.topological_order(),
    layers: self.layers(),
    critical_path: self.critical_path(),
  }
}
