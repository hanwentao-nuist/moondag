///|
fn valid_id(value : String) -> Bool {
  if value.is_empty() || value.length() > 64 {
    return false
  }
  for index, char in value {
    let alpha = (char >= 'a' && char <= 'z') || (char >= 'A' && char <= 'Z')
    let digit = char >= '0' && char <= '9'
    let symbol = char == '_' || char == '-' || char == '.'
    if !(alpha || digit || symbol) {
      return false
    }
    if index == 0 && !(alpha || char == '_') {
      return false
    }
  }
  true
}

///|
fn parse_deps(
  source : String,
  field : String,
) -> Result[Array[String], Diagnostic] {
  if source == "-" || source.is_empty() {
    return Ok([])
  }
  let deps = []
  for index, piece in source.split(",") {
    let id = trim_text(piece.to_owned())
    if !valid_id(id) {
      return Err(
        Diagnostic::new(
          "graph.dep.id",
          field + "[" + index.to_string() + "]",
          "dependency id is invalid",
          "identifier matching [A-Za-z_][A-Za-z0-9_.-]*",
          id,
        ),
      )
    }
    if contains_string(deps, id) {
      return Err(
        Diagnostic::new(
          "graph.dep.duplicate", field, "dependency appears more than once", "unique dependency ids",
          id,
        ),
      )
    }
    deps.push(id)
  }
  Ok(deps)
}

///|
fn parse_task_line(
  line : String,
  line_number : Int,
) -> Result[TaskSpec, Diagnostic] {
  let fields : Array[String] = line
    .split("|")
    .map(fn(value) { trim_text(value.to_owned()) })
    .collect()
  if fields.length() < 2 || fields.length() > 4 {
    return Err(
      Diagnostic::new(
        "graph.line.shape",
        "line[" + line_number.to_string() + "]",
        "task line has the wrong number of fields",
        "id | duration | deps | optional label",
        line,
      ),
    )
  }
  let id = fields[0]
  if !valid_id(id) {
    return Err(
      Diagnostic::new(
        "graph.task.id",
        "line[" + line_number.to_string() + "].id",
        "task id is invalid",
        "identifier matching [A-Za-z_][A-Za-z0-9_.-]*",
        id,
      ),
    )
  }
  let duration = match
    parse_decimal(
      fields[1],
      "line[" + line_number.to_string() + "].duration",
      1000000,
    ) {
    Ok(value) => value
    Err(error) => return Err(error)
  }
  if duration < 1 {
    return Err(
      Diagnostic::new(
        "graph.duration.range",
        "line[" + line_number.to_string() + "].duration",
        "duration must be positive",
        "1..1000000",
        duration.to_string(),
      ),
    )
  }
  let deps = if fields.length() >= 3 {
    match parse_deps(fields[2], "line[" + line_number.to_string() + "].deps") {
      Ok(value) => value
      Err(error) => return Err(error)
    }
  } else {
    []
  }
  let label = if fields.length() == 4 { fields[3] } else { "" }
  Ok({ id, duration, deps, label })
}

///|
/// Parse a compact line-oriented graph specification.
pub fn GraphSpec::parse(source : String) -> Result[GraphSpec, Diagnostic] {
  if source.length() > 4194304 {
    return Err(
      Diagnostic::new(
        "graph.input.limit",
        "graph",
        "graph specification exceeds the safety limit",
        "at most 4194304 characters",
        source.length().to_string(),
      ),
    )
  }
  let tasks = []
  for index, view in source.split("\n") {
    let line = trim_text(view.to_owned())
    if line.is_empty() || line.has_prefix("#") {
      continue
    }
    let task = match parse_task_line(line, index + 1) {
      Ok(value) => value
      Err(error) => return Err(error)
    }
    tasks.push(task)
  }
  if tasks.is_empty() {
    return Err(
      Diagnostic::new(
        "graph.empty", "graph", "graph contains no tasks", "at least one task line",
        "empty",
      ),
    )
  }
  Ok({ tasks, })
}

///|
pub fn GraphSpec::to_text(self : GraphSpec) -> String {
  let output = StringBuilder::new()
  for index, task in self.tasks {
    if index > 0 {
      output.write_string("\n")
    }
    output.write_string(task.id)
    output.write_string(" | ")
    output.write_string(task.duration.to_string())
    output.write_string(" | ")
    output.write_string(
      if task.deps.is_empty() {
        "-"
      } else {
        join_strings(task.deps, ",")
      },
    )
    if !task.label.is_empty() {
      output.write_string(" | ")
      output.write_string(task.label)
    }
  }
  output.to_string()
}
