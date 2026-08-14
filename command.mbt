///|
pub struct CommandResult {
  exit_code : Int
  output : String
} derive(Eq, @debug.Debug)

///|
pub fn CommandResult::exit_code(self : CommandResult) -> Int {
  self.exit_code
}

///|
pub fn CommandResult::output(self : CommandResult) -> String {
  self.output
}

///|
fn command_ok(output : String) -> CommandResult {
  { exit_code: 0, output }
}

///|
fn command_fail(output : String) -> CommandResult {
  { exit_code: 2, output }
}

///|
pub let help_text =
  #|MoonDag 0.1.0
  #|Deterministic dependency graph and task pipeline analysis.
  #|
  #|USAGE:
  #|  moondag inspect --graph TEXT
  #|  moondag order   --graph TEXT
  #|  moondag layers  --graph TEXT
  #|  moondag impact  --graph TEXT --changed ID[,ID]
  #|  moondag block   --graph TEXT --target ID
  #|  moondag schedule --graph TEXT
  #|  moondag dot      --graph TEXT
  #|  moondag demo
  #|
  #|GRAPH: lines use id | duration | dep-a,dep-b | optional label. Use \n escapes in CLI text.
  #|EXIT CODES: 0 success, 2 usage or validation error

///|
fn decode_text(value : String) -> Result[String, CommandResult] {
  let output = StringBuilder::new()
  let mut escaping = false
  for char in value {
    if escaping {
      match char {
        'n' => output.write_char('\n')
        'r' => output.write_char('\r')
        't' => output.write_char('\t')
        '\\' => output.write_char('\\')
        other =>
          return Err(command_fail("invalid escape: \\" + other.to_string()))
      }
      escaping = false
    } else if char == '\\' {
      escaping = true
    } else {
      output.write_char(char)
    }
  }
  if escaping {
    Err(command_fail("trailing escape in text"))
  } else {
    Ok(output.to_string())
  }
}

///|
fn option(args : Array[String], name : String) -> Result[String, CommandResult] {
  let mut found : String? = None
  let mut index = 1
  while index < args.length() {
    if args[index] == name {
      if found is Some(_) {
        return Err(command_fail("duplicate option " + name))
      }
      if index + 1 >= args.length() {
        return Err(command_fail("missing value for " + name))
      }
      found = Some(args[index + 1])
      index = index + 2
    } else {
      index = index + 1
    }
  }
  match found {
    Some(value) => Ok(value)
    None => Err(command_fail("missing required option " + name))
  }
}

///|
fn graph_option(args : Array[String]) -> Result[Dag, CommandResult] {
  let text = match option(args, "--graph") {
    Ok(value) =>
      match decode_text(value) {
        Ok(decoded) => decoded
        Err(error) => return Err(error)
      }
    Err(error) => return Err(error)
  }
  match compile_graph(text) {
    Ok(value) => Ok(value)
    Err(error) => Err(command_fail(error.to_text()))
  }
}

///|
fn ids_option(
  args : Array[String],
  name : String,
) -> Result[Array[String], CommandResult] {
  let source = match option(args, name) {
    Ok(value) => value
    Err(error) => return Err(error)
  }
  let ids = []
  for item in source.split(",") {
    let id = trim_text(item.to_owned())
    if id.is_empty() {
      return Err(command_fail(name + " contains an empty id"))
    }
    ids.push(id)
  }
  Ok(ids)
}

///|
fn inspect_command(args : Array[String]) -> CommandResult {
  match graph_option(args) {
    Ok(dag) => command_ok(dag.summary_text())
    Err(error) => error
  }
}

///|
fn order_command(args : Array[String]) -> CommandResult {
  match graph_option(args) {
    Ok(dag) => command_ok(join_strings(dag.topological_order(), "\n"))
    Err(error) => error
  }
}

///|
fn layers_command(args : Array[String]) -> CommandResult {
  match graph_option(args) {
    Ok(dag) => {
      let output = StringBuilder::new()
      for index, layer in dag.layers() {
        if index > 0 {
          output.write_char('\n')
        }
        output.write_string(index.to_string() + ": " + join_strings(layer, " "))
      }
      command_ok(output.to_string())
    }
    Err(error) => error
  }
}

///|
fn impact_command(args : Array[String]) -> CommandResult {
  let dag = match graph_option(args) {
    Ok(value) => value
    Err(error) => return error
  }
  let changed = match ids_option(args, "--changed") {
    Ok(value) => value
    Err(error) => return error
  }
  match dag.downstream(changed) {
    Ok(ids) => command_ok(join_strings(ids, "\n"))
    Err(error) => command_fail(error.to_text())
  }
}

///|
fn block_command(args : Array[String]) -> CommandResult {
  let dag = match graph_option(args) {
    Ok(value) => value
    Err(error) => return error
  }
  let target = match option(args, "--target") {
    Ok(value) => value
    Err(error) => return error
  }
  match dag.blockers(target) {
    Ok(ids) => command_ok(join_strings(ids, "\n"))
    Err(error) => command_fail(error.to_text())
  }
}

///|
fn schedule_command(args : Array[String]) -> CommandResult {
  match graph_option(args) {
    Ok(dag) => command_ok(dag.schedule().to_text())
    Err(error) => error
  }
}

///|
fn dot_command(args : Array[String]) -> CommandResult {
  match graph_option(args) {
    Ok(dag) => command_ok(dag.to_dot())
    Err(error) => error
  }
}

///|
pub fn demo_graph() -> String {
  (
    #|fetch | 2 | - | fetch sources
    #|schema | 1 | fetch | validate manifests
    #|compile | 5 | schema | compile packages
    #|lint | 2 | schema | static checks
    #|test | 4 | compile,lint | run test matrix
    #|package | 1 | test | prepare release
  )
}

///|
fn demo_command() -> CommandResult {
  let dag = compile_graph(demo_graph()).unwrap()
  let impact = dag.downstream(["schema"]).unwrap()
  let blockers = dag.blockers("package").unwrap()
  command_ok(
    dag.summary_text() +
    "\nIMPACT schema: " +
    join_strings(impact, " ") +
    "\nBLOCK package: " +
    join_strings(blockers, " ") +
    "\n" +
    dag.schedule().to_text(),
  )
}

///|
pub fn execute(args : Array[String]) -> CommandResult {
  if args.is_empty() {
    return command_ok(help_text)
  }
  match args[0] {
    "help" | "--help" | "-h" => command_ok(help_text)
    "inspect" => inspect_command(args)
    "order" => order_command(args)
    "layers" => layers_command(args)
    "impact" => impact_command(args)
    "block" => block_command(args)
    "schedule" => schedule_command(args)
    "dot" => dot_command(args)
    "demo" => demo_command()
    other => command_fail("unknown command: " + other + "\n\n" + help_text)
  }
}
