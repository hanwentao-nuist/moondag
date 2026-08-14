# Non-Duplication Matrix

| Candidate | Domain | Core Data | Primary Workflow | Registry Overlap | Decision |
| --- | --- | --- | --- | --- | --- |
| MoonDag | Dependency graph and task pipeline analysis | Task ids, directed dependency edges, durations, graph layers | Parse graph, validate DAG, derive order/layers/impact/blockers/critical path | Does not use benchmark samples, OpenAPI schemas, recurrence dates, unified diffs, or byte chunks | Selected |
| MoonQuota | Static quota and budget policy checks | Quota rules, resource counters, policy violations | Parse limits, evaluate requests, emit policy diagnostics | Distinct, but lower MoonBit ecosystem value for this round | Rejected |
| MoonTraceMap | Event trace normalization | Timestamped events and spans | Parse trace logs, normalize spans, summarize causal chains | Too close to timing/performance-adjacent workflows if centered on latency | Rejected |

The selected project shares ordinary engineering surfaces such as CLI, tests,
Markdown documentation, and CI with earlier entries, but its identity is the
DAG problem loop: dependency graph validation and deterministic pipeline
analysis.
