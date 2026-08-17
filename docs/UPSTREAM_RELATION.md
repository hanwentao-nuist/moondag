# MoonFlowGraph Extension Relationship

## Upstream

- Project: MoonFlowGraph
- Version: `AlexenderSokolov/moonflowgraph@0.3.0`
- GitHub: https://github.com/AlexenderSokolov/moonflowgraph
- Mooncakes documentation: https://mooncakes.io/docs/AlexenderSokolov/moonflowgraph
- License: Apache-2.0

## Reused Contract

MoonDag calls `FlowGraph::add_task`, `FlowGraph::add_dependency`, and
`FlowGraph::plan`. The returned `ExecutionPlan::order` and
`ExecutionPlan::batches` are the sole source of topological ordering and layers.
Upstream `GraphError` values are translated to stable MoonDag diagnostics.

## Added Contract

MoonDag accepts one `TaskEstimate` for each upstream task and computes:

- CPM forward and backward passes;
- earliest/latest start and finish;
- schedule slack and critical tasks;
- duration-weighted critical path and project horizon;
- transitive changed-task impact and target blockers;
- affected duration, unaffected tasks, and rerun layers;
- schedule-aware reports and exports.

No MoonFlowGraph source is copied or vendored. The compact MoonDag text parser
is an optional adapter that constructs a public `FlowGraph` before invoking the
same analysis entry point.
