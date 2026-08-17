# Local Readiness Audit

Date: 2026-08-17

## Review Remediation

- Confirmed overlap with `AlexenderSokolov/moonflowgraph@0.3.0` from the initial
  review notice.
- Added MoonFlowGraph as a direct Apache-2.0 dependency.
- Removed MoonDag's local Kahn topological sort and cycle-tracing code.
- Added `analyze_flow_graph` so callers pass a real upstream `FlowGraph`.
- Restricted MoonDag's owned scope to durations, CPM timing/slack/critical path,
  transitive impact/blockers, and affected rerun planning.
- Added an explicit capability matrix, upstream relationship document, public
  interface evidence, and CLI planner evidence.

## Local Evidence

- `moon fmt --check`: passed
- `moon check --target wasm-gc --warn-list -79 --deny-warn`: passed
- `moon check --target wasm --warn-list -79 --deny-warn`: passed
- `moon check --target js --warn-list -79 --deny-warn`: passed
- `moon check --target native --warn-list -79 --deny-warn`: passed
- `moon test --target wasm-gc`: 20 passed
- `moon test --target wasm`: 20 passed
- `moon test --target js`: 20 passed
- JavaScript CLI example comparisons: passed
- `moon test --target native`: blocked locally because no system C compiler is
  installed; the GitHub Actions Ubuntu runner performs native verification
- Submission Markdown strict validator: passed

Warning `0079` is disabled because it originates in the pinned MoonFlowGraph
0.3.0 source with the August 2026 compiler. `--deny-warn` still rejects every
other warning class.

## Deliverables

- MoonBit extension implementation and 20 tests: root package and `cmd/main`
- Upstream boundary: `docs/UPSTREAM_RELATION.md` and `docs/COMPARISON.md`
- Examples and expected CLI outputs: `examples/`
- README, scope, architecture, security, contribution, third-party, AI usage,
  changelog, and CI workflow
- Submission Markdown: kept outside Git to avoid publishing personal data
