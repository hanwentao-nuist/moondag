///|
test "normalize graph text after parsing" {
  let spec = GraphSpec::parse(
    (
      #|# comment
      #|build | 3 | setup, lint | compile app
      #|setup | 1 | -
      #|lint | 2 | setup
    ),
  ).unwrap()
  assert_eq(
    spec.to_text(),
    "build | 3 | setup,lint | compile app\nsetup | 1 | -\nlint | 2 | setup",
  )
}

///|
test "reject duplicate and missing dependencies before analysis" {
  let duplicate = GraphSpec::parse("a | 1 | -\na | 2 | -").unwrap().compile()
  guard duplicate is Err(duplicate_error) else {
    fail("expected duplicate error")
  }
  assert_eq(duplicate_error.code(), "graph.task.duplicate")
  let missing = GraphSpec::parse("a | 1 | b").unwrap().compile()
  guard missing is Err(missing_error) else {
    fail("expected missing dependency")
  }
  assert_eq(missing_error.code(), "graph.dep.missing")
}
