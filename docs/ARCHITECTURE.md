# Architecture

MoonDag is intentionally small and portable.

1. `GraphSpec::parse` reads a line-oriented task format and produces named task
   specs.
2. `GraphSpec::compile` validates uniqueness, references, self dependencies,
   task limits, and acyclicity, then compiles dependency names to indexes.
3. `Dag::topological_order` and `Dag::layers` use deterministic Kahn traversal.
4. `Dag::downstream` and `Dag::blockers` traverse dependents or dependencies
   and return results in topological order.
5. `Dag::critical_path` and `Dag::schedule` perform dynamic programming over
   the DAG.
6. `Dag::stats`, `Dag::task_info`, and `Dag::impact_plan` provide higher-level
   explanations for CI and release-planning workflows.
7. DOT, Mermaid, CSV, and compact JSON exporters render the same in-memory
   analysis without reading or writing files.
8. `execute` exposes a no-filesystem CLI facade that works on portable targets;
   `cmd/main` only adapts process arguments and exit codes.

Diagnostics are structured as `Diagnostic` values before rendering to text, so
callers can assert exact failure codes without parsing prose.
