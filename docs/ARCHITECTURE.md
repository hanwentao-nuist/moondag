# Architecture

MoonDag 0.2 is an analysis layer above MoonFlowGraph.

1. A caller supplies a `@moonflowgraph.FlowGraph` and duration estimates, or
   uses the compact text adapter to construct them.
2. `FlowGraph::plan` performs endpoint validation, cycle detection, topological
   sorting, and execution batching. MoonDag contains no Kahn-sort or cycle-trace
   implementation.
3. MoonDag maps the upstream `ExecutionPlan` and graph snapshots to indexed
   duration records.
4. `Dag::schedule` performs CPM forward and backward passes to derive the
   project horizon, earliest/latest times, slack, and critical tasks.
5. `Dag::critical_path`, `Dag::downstream`, `Dag::blockers`, and
   `Dag::impact_plan` derive duration and change-planning answers not exposed by
   MoonFlowGraph.
6. Schedule-aware text, DOT, CSV, and JSON exporters render those results.
7. The CLI is a convenience facade; its order/layer views only display the
   upstream plan already stored in `Dag`.

MoonFlowGraph errors are translated to stable MoonDag diagnostics while keeping
the upstream planner as the source of graph validity and execution order.
