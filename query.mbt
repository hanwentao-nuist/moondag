///|
pub fn Dag::dependencies(
  self : Dag,
  id : String,
) -> Result[Array[String], Diagnostic] {
  let index = match index_of_node(self.nodes, id) {
    Some(value) => value
    None =>
      return Err(
        Diagnostic::new(
          "query.task.missing", "dependencies", "query names a task outside the graph",
          "declared task id", id,
        ),
      )
  }
  Ok(ids_from_indexes(self.nodes, self.nodes[index].deps))
}

///|
pub fn Dag::dependents(
  self : Dag,
  id : String,
) -> Result[Array[String], Diagnostic] {
  let index = match index_of_node(self.nodes, id) {
    Some(value) => value
    None =>
      return Err(
        Diagnostic::new(
          "query.task.missing", "dependents", "query names a task outside the graph",
          "declared task id", id,
        ),
      )
  }
  Ok(ids_from_indexes(self.nodes, self.nodes[index].dependents))
}

///|
fn timing_for(schedule : Schedule, id : String) -> TaskTiming? {
  for entry in schedule.entries {
    if entry.id == id {
      return Some(entry)
    }
  }
  None
}

///|
pub fn Dag::task_info(self : Dag, id : String) -> Result[TaskInfo, Diagnostic] {
  let index = match index_of_node(self.nodes, id) {
    Some(value) => value
    None =>
      return Err(
        Diagnostic::new(
          "query.task.missing", "task", "query names a task outside the graph", "declared task id",
          id,
        ),
      )
  }
  let blockers = match self.blockers(id) {
    Ok(value) => value
    Err(error) => return Err(error)
  }
  let downstream = match self.downstream([id]) {
    Ok(value) => value
    Err(error) => return Err(error)
  }
  let timing = timing_for(self.schedule(), id).unwrap()
  Ok({
    id,
    duration: self.nodes[index].duration,
    label: self.nodes[index].label,
    dependencies: ids_from_indexes(self.nodes, self.nodes[index].deps),
    dependents: ids_from_indexes(self.nodes, self.nodes[index].dependents),
    blockers,
    downstream,
    earliest_start: timing.earliest_start,
    earliest_finish: timing.earliest_finish,
    latest_start: timing.latest_start,
    latest_finish: timing.latest_finish,
    slack: timing.slack,
    critical: timing.critical,
  })
}

///|
pub fn TaskInfo::to_text(self : TaskInfo) -> String {
  "TASK " +
  self.id +
  " duration=" +
  self.duration.to_string() +
  (if self.label.is_empty() { "" } else { " label=" + self.label }) +
  "\ndeps: " +
  join_strings(self.dependencies, " ") +
  "\ndependents: " +
  join_strings(self.dependents, " ") +
  "\nblockers: " +
  join_strings(self.blockers, " ") +
  "\ndownstream: " +
  join_strings(self.downstream, " ") +
  "\nschedule: es=" +
  self.earliest_start.to_string() +
  " ef=" +
  self.earliest_finish.to_string() +
  " ls=" +
  self.latest_start.to_string() +
  " lf=" +
  self.latest_finish.to_string() +
  " slack=" +
  self.slack.to_string() +
  " critical=" +
  self.critical.to_string()
}

///|
pub fn Dag::stats(self : Dag) -> GraphStats {
  let mut edges = 0
  let mut roots = 0
  let mut leaves = 0
  let mut total_duration = 0
  let mut max_fan_in = 0
  let mut max_fan_out = 0
  for node in self.nodes {
    edges = edges + node.deps.length()
    total_duration = total_duration + node.duration
    if node.deps.is_empty() {
      roots = roots + 1
    }
    if node.dependents.is_empty() {
      leaves = leaves + 1
    }
    if node.deps.length() > max_fan_in {
      max_fan_in = node.deps.length()
    }
    if node.dependents.length() > max_fan_out {
      max_fan_out = node.dependents.length()
    }
  }
  let layers = self.layers()
  let mut parallelism_hint = 0
  for layer in layers {
    if layer.length() > parallelism_hint {
      parallelism_hint = layer.length()
    }
  }
  {
    tasks: self.nodes.length(),
    edges,
    roots,
    leaves,
    total_duration,
    critical_duration: self.critical_path().duration,
    max_fan_in,
    max_fan_out,
    layer_count: layers.length(),
    parallelism_hint,
  }
}

///|
pub fn GraphStats::to_text(self : GraphStats) -> String {
  "STATS tasks=" +
  self.tasks.to_string() +
  " edges=" +
  self.edges.to_string() +
  " roots=" +
  self.roots.to_string() +
  " leaves=" +
  self.leaves.to_string() +
  " total_duration=" +
  self.total_duration.to_string() +
  " critical_duration=" +
  self.critical_duration.to_string() +
  " max_fan_in=" +
  self.max_fan_in.to_string() +
  " max_fan_out=" +
  self.max_fan_out.to_string() +
  " layers=" +
  self.layer_count.to_string() +
  " parallelism_hint=" +
  self.parallelism_hint.to_string()
}

///|
pub fn Dag::impact_plan(
  self : Dag,
  changed : Array[String],
) -> Result[ImpactPlan, Diagnostic] {
  let affected = match self.downstream(changed) {
    Ok(value) => value
    Err(error) => return Err(error)
  }
  let mut affected_duration = 0
  let unaffected : Array[String] = []
  for index in topo_indexes(self) {
    let id = self.nodes[index].id
    if contains_string(affected, id) {
      affected_duration = affected_duration + self.nodes[index].duration
    } else {
      unaffected.push(id)
    }
  }
  let affected_critical : Array[String] = []
  for id in self.critical_path().task_ids {
    if contains_string(affected, id) {
      affected_critical.push(id)
    }
  }
  let rebuild_layers : Array[Array[String]] = []
  for layer in self.layers() {
    let rebuild_layer : Array[String] = []
    for id in layer {
      if contains_string(affected, id) {
        rebuild_layer.push(id)
      }
    }
    if !rebuild_layer.is_empty() {
      rebuild_layers.push(rebuild_layer)
    }
  }
  Ok({
    changed: changed.copy(),
    affected,
    unaffected,
    affected_duration,
    affected_critical_tasks: affected_critical,
    rebuild_layers,
  })
}

///|
pub fn ImpactPlan::to_text(self : ImpactPlan) -> String {
  let output = StringBuilder::new()
  output.write_string("IMPACT_PLAN")
  output.write_string("\nchanged: " + join_strings(self.changed, " "))
  output.write_string("\naffected: " + join_strings(self.affected, " "))
  output.write_string("\nunaffected: " + join_strings(self.unaffected, " "))
  output.write_string(
    "\naffected_duration: " + self.affected_duration.to_string(),
  )
  output.write_string(
    "\naffected_critical: " + join_strings(self.affected_critical_tasks, " "),
  )
  output.write_string("\nrebuild_layers")
  for index, layer in self.rebuild_layers {
    output.write_string(
      "\n" + index.to_string() + ": " + join_strings(layer, " "),
    )
  }
  output.to_string()
}
