///|
test "inspect and schedule commands expose acceptance outputs" {
  let graph = "a | 1 | -\\nb | 2 | a\\nc | 1 | a\\nd | 3 | b,c"
  let inspected = @moondag.execute(["inspect", "--graph", graph])
  assert_eq(inspected.exit_code(), 0)
  assert_true(inspected.output().contains("MOONDAG tasks=4 edges=4"))
  assert_true(inspected.output().contains("CRITICAL 6 a -> b -> d"))
  let scheduled = @moondag.execute(["schedule", "--graph", graph])
  assert_eq(scheduled.exit_code(), 0)
  assert_true(
    scheduled.output().contains("c dur=1 es=1 ef=2 ls=2 lf=3 slack=1"),
  )
}

///|
test "impact block dot and help commands are runnable" {
  let graph = "a | 1 | -\\nb | 2 | a\\nc | 1 | a\\nd | 3 | b,c"
  assert_eq(
    @moondag.execute(["impact", "--graph", graph, "--changed", "a"]).output(),
    "a\nb\nc\nd",
  )
  assert_eq(
    @moondag.execute(["block", "--graph", graph, "--target", "d"]).output(),
    "a\nb\nc",
  )
  assert_true(
    @moondag.execute(["dot", "--graph", graph])
    .output()
    .contains("\"a\" -> \"b\""),
  )
  assert_true(@moondag.execute(["--help"]).output().contains("USAGE:"))
}

///|
test "invalid cli inputs use exit code two" {
  assert_eq(@moondag.execute(["unknown"]).exit_code(), 2)
  assert_eq(@moondag.execute(["inspect"]).exit_code(), 2)
  assert_true(
    @moondag.execute(["inspect", "--graph", "bad id | 1 | -"])
    .output()
    .contains("graph.task.id"),
  )
}

///|
test "stats task plan mermaid and csv commands are runnable" {
  let graph = "a | 1 | -\\nb | 2 | a\\nc | 1 | a\\nd | 3 | b,c"
  let stats = @moondag.execute(["stats", "--graph", graph])
  assert_eq(stats.exit_code(), 0)
  assert_true(stats.output().contains("STATS tasks=4 edges=4"))
  let task = @moondag.execute(["task", "--graph", graph, "--target", "b"])
  assert_eq(task.exit_code(), 0)
  assert_true(task.output().contains("TASK b duration=2"))
  assert_true(task.output().contains("blockers: a"))
  let plan = @moondag.execute(["plan", "--graph", graph, "--changed", "b"])
  assert_eq(plan.exit_code(), 0)
  assert_true(plan.output().contains("affected_duration: 5"))
  let mermaid = @moondag.execute(["mermaid", "--graph", graph])
  assert_eq(mermaid.exit_code(), 0)
  assert_true(mermaid.output().contains("flowchart LR"))
  let csv = @moondag.execute(["csv", "--graph", graph])
  assert_eq(csv.exit_code(), 0)
  assert_true(csv.output().contains("id,duration,earliest_start"))
}

///|
test "task and plan commands expose detailed explanation output" {
  let graph = "a | 1 | -\\nb | 2 | a\\nc | 1 | a\\nd | 3 | b,c"
  let task = @moondag.execute(["task", "--graph", graph, "--target", "d"])
  assert_eq(task.exit_code(), 0)
  assert_true(task.output().contains("TASK d duration=3"))
  assert_true(task.output().contains("downstream: d"))
  let plan = @moondag.execute(["plan", "--graph", graph, "--changed", "b"])
  assert_eq(plan.exit_code(), 0)
  assert_true(plan.output().contains("affected: b d"))
  assert_true(plan.output().contains("rebuild_layers"))
}
