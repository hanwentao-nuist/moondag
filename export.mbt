///|
pub fn TaskInfo::to_json(self : TaskInfo) -> String {
  "{" +
  "\"id\":" +
  quote_json(self.id) +
  ",\"duration\":" +
  self.duration.to_string() +
  ",\"label\":" +
  quote_json(self.label) +
  ",\"dependencies\":" +
  string_array_json(self.dependencies) +
  ",\"dependents\":" +
  string_array_json(self.dependents) +
  ",\"blockers\":" +
  string_array_json(self.blockers) +
  ",\"downstream\":" +
  string_array_json(self.downstream) +
  ",\"earliest_start\":" +
  self.earliest_start.to_string() +
  ",\"earliest_finish\":" +
  self.earliest_finish.to_string() +
  ",\"latest_start\":" +
  self.latest_start.to_string() +
  ",\"latest_finish\":" +
  self.latest_finish.to_string() +
  ",\"slack\":" +
  self.slack.to_string() +
  ",\"critical\":" +
  self.critical.to_string() +
  "}"
}

///|
pub fn GraphStats::to_json(self : GraphStats) -> String {
  "{" +
  "\"tasks\":" +
  self.tasks.to_string() +
  ",\"edges\":" +
  self.edges.to_string() +
  ",\"roots\":" +
  self.roots.to_string() +
  ",\"leaves\":" +
  self.leaves.to_string() +
  ",\"total_duration\":" +
  self.total_duration.to_string() +
  ",\"critical_duration\":" +
  self.critical_duration.to_string() +
  ",\"max_fan_in\":" +
  self.max_fan_in.to_string() +
  ",\"max_fan_out\":" +
  self.max_fan_out.to_string() +
  ",\"layer_count\":" +
  self.layer_count.to_string() +
  ",\"parallelism_hint\":" +
  self.parallelism_hint.to_string() +
  "}"
}

///|
pub fn ImpactPlan::to_json(self : ImpactPlan) -> String {
  let layers = StringBuilder::new()
  layers.write_char('[')
  for index, layer in self.rebuild_layers {
    if index > 0 {
      layers.write_char(',')
    }
    layers.write_string(string_array_json(layer))
  }
  layers.write_char(']')
  "{" +
  "\"changed\":" +
  string_array_json(self.changed) +
  ",\"affected\":" +
  string_array_json(self.affected) +
  ",\"unaffected\":" +
  string_array_json(self.unaffected) +
  ",\"affected_duration\":" +
  self.affected_duration.to_string() +
  ",\"affected_critical_tasks\":" +
  string_array_json(self.affected_critical_tasks) +
  ",\"rebuild_layers\":" +
  layers.to_string() +
  "}"
}

///|
pub fn Schedule::to_csv(self : Schedule) -> String {
  let output = StringBuilder::new()
  output.write_string(
    "id,duration,earliest_start,earliest_finish,latest_start,latest_finish,slack,critical",
  )
  for entry in self.entries {
    output.write_string(
      "\n" +
      csv_escape(entry.id) +
      "," +
      entry.duration.to_string() +
      "," +
      entry.earliest_start.to_string() +
      "," +
      entry.earliest_finish.to_string() +
      "," +
      entry.latest_start.to_string() +
      "," +
      entry.latest_finish.to_string() +
      "," +
      entry.slack.to_string() +
      "," +
      entry.critical.to_string(),
    )
  }
  output.to_string()
}

///|
fn mermaid_id(id : String) -> String {
  let output = StringBuilder::new()
  output.write_string("n_")
  for char in id {
    let alpha = (char >= 'a' && char <= 'z') || (char >= 'A' && char <= 'Z')
    let digit = char >= '0' && char <= '9'
    if alpha || digit {
      output.write_char(char)
    } else {
      output.write_char('_')
    }
  }
  output.to_string()
}

///|
pub fn Dag::to_mermaid(self : Dag) -> String {
  let output = StringBuilder::new()
  output.write_string("flowchart LR\n")
  for node in self.nodes {
    output.write_string(
      "  " +
      mermaid_id(node.id) +
      "[\"" +
      escape_json(node.id + " (" + node.duration.to_string() + ")") +
      "\"]\n",
    )
  }
  for node in self.nodes {
    for dep in node.deps {
      output.write_string(
        "  " +
        mermaid_id(self.nodes[dep].id) +
        " --> " +
        mermaid_id(node.id) +
        "\n",
      )
    }
  }
  output.to_string()
}
