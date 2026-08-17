# Capability Boundary

| Area | MoonFlowGraph 0.3.0 | MoonDag 0.2.0 |
| --- | --- | --- |
| Task and dependency model | Owns | Consumes |
| Missing endpoint and cycle validation | Owns | Translates diagnostics |
| Topological order and execution batches | Owns | Displays upstream plan |
| Provenance, task status, workflow/snapshot JSON | Owns | Out of scope |
| Duration estimate model | Not provided | Owns |
| CPM earliest/latest schedule and slack | Not provided | Owns |
| Critical path by duration | Not provided | Owns |
| Transitive changed-task impact and blockers | Not provided | Owns |
| Affected duration and rerun layers | Not provided | Owns |

MoonDag previously implemented DAG validation and topological traversal itself.
Version 0.2 removed those duplicate algorithms after initial-review feedback and
now calls the published Apache-2.0 MoonFlowGraph package directly.
