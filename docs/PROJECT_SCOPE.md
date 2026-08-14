# Project Scope

MoonDag solves a dependency graph analysis problem for task pipelines. It helps
tool authors and release engineers answer: what can run first, what can run in
parallel, what is affected by a change, what blocks a target, and which tasks
control the total duration.

## Acceptance Flows

- Parse and inspect a valid multi-node graph.
- Compute deterministic topological order and parallel layers.
- Compute downstream impact from `schema` and blockers for `package`.
- Compute earliest/latest schedule, slack, and critical path.
- Export Graphviz DOT text.
- Explain one task with direct and transitive relationships.
- Build affected-task plans from changed tasks.
- Export Mermaid, CSV, and compact JSON strings.
- Reject duplicate tasks, missing dependencies, self dependencies, invalid ids,
  invalid durations, empty input, and cycles with stable diagnostics.
- Run the library tests and JavaScript/native CLI flows.

## Non-Goals

- No timing sample collection, benchmark comparison, or performance gates.
- No OpenAPI, HTTP contract, mock server, or case replay behavior.
- No calendar recurrence, recurring event expansion, or date scheduling.
- No content-defined chunking, manifests, deduplicated transfer planning, or
  byte reconstruction.
- No unified-diff parsing or patch application.
