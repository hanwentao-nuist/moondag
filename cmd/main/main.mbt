///|
fn main {
  let raw_args = @env.args()
  let mut command_index = raw_args.length()
  for index, value in raw_args {
    if command_index == raw_args.length() &&
      (
        value == "inspect" ||
        value == "order" ||
        value == "layers" ||
        value == "impact" ||
        value == "block" ||
        value == "schedule" ||
        value == "dot" ||
        value == "stats" ||
        value == "task" ||
        value == "plan" ||
        value == "mermaid" ||
        value == "csv" ||
        value == "demo" ||
        value == "help" ||
        value == "--help" ||
        value == "-h"
      ) {
      command_index = index
    }
  }
  let args = if command_index < raw_args.length() {
    raw_args[command_index:].to_owned()
  } else {
    []
  }
  let result = @lib.execute(args)
  if !result.output.is_empty() {
    println(result.output)
  }
  @sys.exit(result.exit_code)
}
