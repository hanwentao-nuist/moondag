///|
test "stats summarize graph shape and schedule pressure" {
  let dag = @moondag.compile_graph(@moondag.demo_graph()).unwrap()
  let stats = dag.stats()
  assert_eq(stats.tasks(), 6)
  assert_eq(stats.edges(), 6)
  assert_eq(stats.roots(), 1)
  assert_eq(stats.leaves(), 1)
  assert_eq(stats.total_duration(), 15)
  assert_eq(stats.critical_duration(), 13)
  assert_eq(stats.max_fan_in(), 2)
  assert_eq(stats.max_fan_out(), 2)
  assert_eq(stats.layer_count(), 5)
  assert_eq(stats.parallelism_hint(), 2)
  assert_true(stats.to_text().contains("parallelism_hint=2"))
}

///|
test "task info explains local and transitive graph relationships" {
  let dag = @moondag.compile_graph(@moondag.demo_graph()).unwrap()
  let info = dag.task_info("test").unwrap()
  assert_eq(info.id(), "test")
  assert_eq(info.dependencies(), ["compile", "lint"])
  assert_eq(info.dependents(), ["package"])
  assert_eq(info.blockers(), ["fetch", "schema", "compile", "lint"])
  assert_eq(info.downstream(), ["test", "package"])
  assert_eq(info.earliest_start(), 8)
  assert_eq(info.latest_start(), 8)
  assert_true(info.is_critical())
  assert_true(info.to_text().contains("schedule: es=8 ef=12"))
}

///|
test "impact plan separates affected tasks from unaffected tasks" {
  let dag = @moondag.compile_graph(@moondag.demo_graph()).unwrap()
  let plan = dag.impact_plan(["lint"]).unwrap()
  assert_eq(plan.changed(), ["lint"])
  assert_eq(plan.affected(), ["lint", "test", "package"])
  assert_eq(plan.unaffected(), ["fetch", "schema", "compile"])
  assert_eq(plan.affected_duration(), 7)
  assert_eq(plan.affected_critical_tasks(), ["test", "package"])
  assert_eq(plan.rebuild_layers(), [["lint"], ["test"], ["package"]])
  assert_true(plan.to_json().contains("\"affected_duration\":7"))
}

///|
test "exports schedule csv mermaid and JSON safely" {
  let dag = @moondag.compile_graph("a | 1 | -\nb | 2 | a\nc | 1 | a").unwrap()
  let csv = dag.schedule().to_csv()
  assert_true(csv.contains("id,duration,earliest_start"))
  assert_true(csv.contains("b,2,1,3"))
  let mermaid = dag.to_mermaid()
  assert_true(mermaid.contains("flowchart LR"))
  assert_true(mermaid.contains("n_a --> n_b"))
  assert_true(dag.stats().to_json().contains("\"tasks\":3"))
  assert_true(
    dag.task_info("b").unwrap().to_json().contains("\"dependencies\":[\"a\"]"),
  )
}

///|
test "query methods report missing task diagnostics" {
  let dag = @moondag.compile_graph(@moondag.demo_graph()).unwrap()
  guard dag.task_info("deploy") is Err(error) else {
    fail("expected missing task")
  }
  assert_eq(error.code(), "query.task.missing")
  guard dag.dependencies("deploy") is Err(deps_error) else {
    fail("expected missing dependencies task")
  }
  assert_eq(deps_error.field(), "dependencies")
}
