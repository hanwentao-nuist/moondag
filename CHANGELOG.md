# Changelog

## 0.2.0 - 2026-08-17

- Reframed MoonDag as an explicit MoonFlowGraph duration and impact-analysis
  extension after initial-review feedback.
- Added `AlexenderSokolov/moonflowgraph@0.3.0` as a direct dependency and added
  `analyze_flow_graph` plus `TaskEstimate` as the primary API.
- Removed the local Kahn topological sort and cycle-tracing implementation;
  graph validity, order, and batches now come from MoonFlowGraph.
- Added direct upstream integration tests and explicit planner evidence in CLI
  output.
- Documented the exact upstream/reused/added capability boundary.

## 0.1.0 - 2026-08-14

- Added graph parsing and DAG validation.
- Added topological order, execution layers, impact, blockers, critical path,
  schedule, slack, and DOT output.
- Added task explanations, graph statistics, affected rebuild plans, Mermaid,
  CSV, and compact JSON exports.
- Added CLI commands, examples, CI workflow, and project documentation.
