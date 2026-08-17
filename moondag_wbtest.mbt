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

///|
test "extend a MoonFlowGraph with duration analysis" {
  let graph = @moonflowgraph.FlowGraph::new()
  graph.add_task(@moonflowgraph.TaskNode::new("prepare", "Prepare")).unwrap()
  graph.add_task(@moonflowgraph.TaskNode::new("build", "Build")).unwrap()
  graph.add_task(@moonflowgraph.TaskNode::new("verify", "Verify")).unwrap()
  graph
  .add_dependency(
    @moonflowgraph.TaskId::new("prepare"),
    @moonflowgraph.TaskId::new("build"),
  )
  .unwrap()
  graph
  .add_dependency(
    @moonflowgraph.TaskId::new("build"),
    @moonflowgraph.TaskId::new("verify"),
  )
  .unwrap()
  let dag = analyze_flow_graph(graph, [
    TaskEstimate::new("prepare", 2),
    TaskEstimate::new("build", 5),
    TaskEstimate::new("verify", 3),
  ]).unwrap()
  assert_eq(planner_backend(), "AlexenderSokolov/moonflowgraph@0.3.0")
  assert_eq(dag.topological_order(), ["prepare", "build", "verify"])
  assert_eq(dag.schedule().duration(), 10)
  assert_eq(dag.critical_path().task_ids(), ["prepare", "build", "verify"])
}

///|
test "require one duration estimate per MoonFlowGraph task" {
  let graph = @moonflowgraph.FlowGraph::new()
  graph.add_task(@moonflowgraph.TaskNode::new("build", "Build")).unwrap()
  let result = analyze_flow_graph(graph, [])
  guard result is Err(error) else { fail("expected missing estimate") }
  assert_eq(error.code(), "estimate.missing")
}
