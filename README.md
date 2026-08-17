# MoonDag

MoonDag is a duration, critical-path, and change-impact analysis extension for
[MoonFlowGraph](https://github.com/AlexenderSokolov/moonflowgraph). It does not
implement an independent task-graph planner: graph validation, cycle detection,
topological order, and execution batches come from
`AlexenderSokolov/moonflowgraph@0.3.0`.

MoonDag adds the analysis layer that MoonFlowGraph deliberately does not cover:
integer duration estimates, CPM forward/backward passes, earliest/latest times,
slack, critical paths, transitive change impact, target blockers, and affected
rerun plans.

## Upstream Relationship

| Capability | Owner |
| --- | --- |
| Task nodes, dependency edges, missing-endpoint checks, cycle detection | MoonFlowGraph |
| Topological order and parallel execution batches | MoonFlowGraph `ExecutionPlan` |
| Duration estimates and schedule horizon | MoonDag |
| Earliest/latest start and finish, slack, critical path | MoonDag |
| Transitive impact, blockers, affected duration, rerun layers | MoonDag |

The public `analyze_flow_graph` API accepts a real MoonFlowGraph `FlowGraph`.
The compact text format is only a convenience adapter: it builds a
MoonFlowGraph and then calls the same extension API. See
[`docs/UPSTREAM_RELATION.md`](docs/UPSTREAM_RELATION.md) for the exact boundary.

## Scope

Supported:

- direct analysis of a MoonFlowGraph with one `TaskEstimate` per task
- integer duration units from 1 to 1,000,000
- CPM earliest/latest schedule, slack, critical task marking, and critical path
- downstream change impact, target blockers, and affected rerun plans
- schedule-aware DOT, CSV, compact JSON, task explanations, and statistics
- a line-oriented convenience format: `id | duration | dep-a,dep-b | label`
- stable diagnostics translated from MoonFlowGraph errors

Not provided by MoonDag:

- independent DAG validation, cycle detection, or topological sorting
- provenance traces, task lifecycle state, workflow JSON, or execution; those
  remain MoonFlowGraph responsibilities
- resource leveling, worker assignment, calendars, probabilistic estimates,
  benchmark sampling, or performance regression gates

## Quick Start

```bash
moon test --target wasm-gc
moon run cmd/main --target js -- demo
```

Inspect the convenience format:

```bash
moon run cmd/main --target js -- inspect --graph 'a | 1 | -\nb | 2 | a\nc | 1 | a\nd | 3 | b,c'
```

The output names the planner explicitly:

```text
MOONDAG tasks=4 edges=4
PLANNER AlexenderSokolov/moonflowgraph@0.3.0
ORDER a b c d
LAYERS
0: a
1: b c
2: d
CRITICAL 6 a -> b -> d
```

## Direct Extension API

```moonbit
let graph = @moonflowgraph.FlowGraph::new()
graph.add_task(@moonflowgraph.TaskNode::new("prepare", "Prepare")).unwrap()
graph.add_task(@moonflowgraph.TaskNode::new("build", "Build")).unwrap()
graph.add_dependency(
  @moonflowgraph.TaskId::new("prepare"),
  @moonflowgraph.TaskId::new("build"),
).unwrap()

let analysis = @moondag.analyze_flow_graph(graph, [
  @moondag.TaskEstimate::new("prepare", 2),
  @moondag.TaskEstimate::new("build", 5),
]).unwrap()

let schedule = analysis.schedule()
let impact = analysis.impact_plan(["prepare"]).unwrap()
```

Consumers import both `AlexenderSokolov/moonflowgraph` and
`hanwentao-nuist/moondag`. Public interfaces are generated in
`pkg.generated.mbti`.

## CLI

```text
moondag inspect  --graph TEXT
moondag schedule --graph TEXT
moondag impact   --graph TEXT --changed ID[,ID]
moondag block    --graph TEXT --target ID
moondag plan     --graph TEXT --changed ID[,ID]
moondag task     --graph TEXT --target ID
moondag stats    --graph TEXT
moondag dot      --graph TEXT
moondag csv      --graph TEXT
moondag order|layers|mermaid --graph TEXT
moondag demo
```

`order`, `layers`, and `mermaid` are compatibility views over upstream-derived
graph data, not separate planner implementations. Success exits with `0`;
usage and validation errors exit with `2`.

## Verification

MoonFlowGraph 0.3.0 emits compiler warning `0079` with the August 2026
toolchain. The checks disable only that upstream warning; all other warnings are
still errors.

```bash
moon fmt --check
moon check --target wasm-gc --warn-list -79 --deny-warn
moon check --target wasm --warn-list -79 --deny-warn
moon check --target js --warn-list -79 --deny-warn
moon check --target native --warn-list -79 --deny-warn
moon test --target wasm-gc
moon test --target wasm
moon test --target js
moon test --target native
```

## License

MoonDag is Apache-2.0. MoonFlowGraph is also Apache-2.0 and remains an external
dependency; see `THIRD_PARTY.md`.
