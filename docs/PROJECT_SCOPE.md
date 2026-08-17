# Project Scope

MoonDag extends MoonFlowGraph task graphs with estimated-duration and
change-impact analysis for build, release, and CI planning.

## Acceptance Flows

- Construct a real MoonFlowGraph and analyze it through `analyze_flow_graph`.
- Prove that validation, topological order, and batches come from its
  `ExecutionPlan`.
- Attach one bounded integer duration estimate to every upstream task.
- Compute earliest/latest starts and finishes, total horizon, slack, and the
  critical path.
- Compute transitive impact, blockers, affected duration, and rerun layers.
- Export schedule-aware text, DOT, CSV, and compact JSON reports.
- Reject missing, duplicate, out-of-range, and unknown estimates.
- Preserve stable diagnostics for upstream graph errors.

## Non-Goals

- No independent graph planner, cycle detector, or topological-sort algorithm.
- No replacement for MoonFlowGraph provenance, lifecycle, JSON, or reporting.
- No task execution, shell commands, LLM calls, secrets, or credentials.
- No resource leveling, worker assignment, calendars, or probabilistic timing.
