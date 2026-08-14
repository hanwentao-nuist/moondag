///|
test "parse compile and analyze a release pipeline" {
  let dag = @moondag.compile_graph(@moondag.demo_graph()).unwrap()
  let analysis = dag.analyze()
  assert_eq(analysis.order(), [
    "fetch", "schema", "compile", "lint", "test", "package",
  ])
  assert_eq(analysis.layers(), [
    ["fetch"],
    ["schema"],
    ["compile", "lint"],
    ["test"],
    ["package"],
  ])
  assert_eq(analysis.critical_path().duration(), 13)
  assert_eq(analysis.critical_path().task_ids(), [
    "fetch", "schema", "compile", "test", "package",
  ])
}

///|
test "downstream impact includes changed task and dependents in execution order" {
  let dag = @moondag.compile_graph(@moondag.demo_graph()).unwrap()
  assert_eq(dag.downstream(["schema"]).unwrap(), [
    "schema", "compile", "lint", "test", "package",
  ])
  assert_eq(dag.downstream(["lint"]).unwrap(), ["lint", "test", "package"])
}

///|
test "blockers explain prerequisites for a target" {
  let dag = @moondag.compile_graph(@moondag.demo_graph()).unwrap()
  assert_eq(dag.blockers("package").unwrap(), [
    "fetch", "schema", "compile", "lint", "test",
  ])
}

///|
test "command diagnostics are stable" {
  let result = @moondag.execute(["inspect", "--graph", "a | 1 | b\\nb | 1 | a"])
  assert_eq(result.exit_code(), 2)
  assert_true(result.output().contains("graph.cycle"))
}

///|
test "schedule computes slack and critical tasks" {
  let dag = @moondag.compile_graph(@moondag.demo_graph()).unwrap()
  let schedule = dag.schedule()
  assert_eq(schedule.duration(), 13)
  let entries = schedule.entries()
  assert_eq(entries[2].id(), "compile")
  assert_eq(entries[2].earliest_start(), 3)
  assert_eq(entries[2].latest_start(), 3)
  assert_true(entries[2].is_critical())
  assert_eq(entries[3].id(), "lint")
  assert_eq(entries[3].slack(), 3)
}

///|
test "dot output marks critical nodes and graph edges" {
  let dag = @moondag.compile_graph("a | 1 | -\nb | 2 | a\nc | 1 | a").unwrap()
  let dot = dag.to_dot()
  assert_true(dot.contains("digraph moondag"))
  assert_true(dot.contains("\"a\" -> \"b\""))
  assert_true(dot.contains("color=\"red\""))
}
