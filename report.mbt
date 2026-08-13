///|
pub fn Analysis::to_text(self : Analysis) -> String {
  let output = StringBuilder::new()
  output.write_string("ORDER " + join_strings(self.order, " "))
  output.write_string("\nLAYERS")
  for index, layer in self.layers {
    output.write_string(
      "\n" + index.to_string() + ": " + join_strings(layer, " "),
    )
  }
  output.write_string(
    "\nCRITICAL " +
    self.critical_path.duration.to_string() +
    " " +
    join_strings(self.critical_path.task_ids, " -> "),
  )
  output.to_string()
}

///|
pub fn Dag::summary_text(self : Dag) -> String {
  let edge_count = self.nodes.fold(init=0, fn(total, node) {
    total + node.deps.length()
  })
  let output = StringBuilder::new()
  output.write_string(
    "MOONDAG tasks=" +
    self.nodes.length().to_string() +
    " edges=" +
    edge_count.to_string(),
  )
  output.write_string("\n")
  output.write_string(self.analyze().to_text())
  output.to_string()
}
