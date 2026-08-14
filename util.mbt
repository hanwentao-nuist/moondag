///|
fn parse_decimal(
  value : String,
  field : String,
  maximum : Int,
) -> Result[Int, Diagnostic] {
  if value.is_empty() {
    return Err(
      Diagnostic::new(
        "integer.empty", field, "integer field is empty", "decimal integer", value,
      ),
    )
  }
  let mut result = 0
  for char in value {
    if char < '0' || char > '9' {
      return Err(
        Diagnostic::new(
          "integer.syntax", field, "field is not a decimal integer", "decimal integer",
          value,
        ),
      )
    }
    result = result * 10 + char.to_int() - '0'.to_int()
    if result > maximum {
      return Err(
        Diagnostic::new(
          "integer.limit",
          field,
          "integer exceeds the safety limit",
          "at most " + maximum.to_string(),
          value,
        ),
      )
    }
  }
  Ok(result)
}

///|
fn is_space(char : Char) -> Bool {
  char == ' ' || char == '\t' || char == '\r'
}

///|
fn trim_text(source : String) -> String {
  let chars = source.to_array()
  let mut start = 0
  while start < chars.length() && is_space(chars[start]) {
    start = start + 1
  }
  let mut end = chars.length()
  while end > start && is_space(chars[end - 1]) {
    end = end - 1
  }
  source[start:end].to_owned()
}

///|
fn join_strings(values : Array[String], separator : String) -> String {
  let output = StringBuilder::new()
  for index, value in values {
    if index > 0 {
      output.write_string(separator)
    }
    output.write_string(value)
  }
  output.to_string()
}

///|
fn contains_string(values : Array[String], needle : String) -> Bool {
  for value in values {
    if value == needle {
      return true
    }
  }
  false
}

///|
fn escape_json(source : String) -> String {
  let output = StringBuilder::new()
  for char in source {
    match char {
      '"' => output.write_string("\\\"")
      '\\' => output.write_string("\\\\")
      '\n' => output.write_string("\\n")
      '\r' => output.write_string("\\r")
      '\t' => output.write_string("\\t")
      other => output.write_char(other)
    }
  }
  output.to_string()
}

///|
fn quote_json(source : String) -> String {
  "\"" + escape_json(source) + "\""
}

///|
fn string_array_json(values : Array[String]) -> String {
  let output = StringBuilder::new()
  output.write_char('[')
  for index, value in values {
    if index > 0 {
      output.write_char(',')
    }
    output.write_string(quote_json(value))
  }
  output.write_char(']')
  output.to_string()
}

///|
fn csv_escape(source : String) -> String {
  let must_quote = source.contains(",") ||
    source.contains("\"") ||
    source.contains("\n") ||
    source.contains("\r")
  if !must_quote {
    return source
  }
  let output = StringBuilder::new()
  output.write_char('"')
  for char in source {
    if char == '"' {
      output.write_string("\"\"")
    } else {
      output.write_char(char)
    }
  }
  output.write_char('"')
  output.to_string()
}

///|
fn index_of_id(tasks : Array[TaskSpec], id : String) -> Int? {
  for index, task in tasks {
    if task.id == id {
      return Some(index)
    }
  }
  None
}

///|
fn index_of_node(nodes : Array[TaskNode], id : String) -> Int? {
  for index, node in nodes {
    if node.id == id {
      return Some(index)
    }
  }
  None
}

///|
fn ids_from_indexes(
  nodes : Array[TaskNode],
  indexes : Array[Int],
) -> Array[String] {
  indexes.map(fn(index) { nodes[index].id })
}
