# MoonDag

MoonDag is a MoonBit library and CLI for deterministic dependency graph analysis.
It parses compact task pipeline specs, validates them as DAGs, and reports
execution order, parallel layers, downstream impact, blockers, schedules,
critical paths, graph statistics, affected rebuild plans, and portable exports.

## Scope

Supported:

- line-oriented graph specs: `id | duration | dep-a,dep-b | optional label`
- duplicate, missing, self-dependency, cycle, identifier, and duration diagnostics
- stable topological order using declaration order as the tie breaker
- execution layers for parallel scheduling
- downstream impact from one or more changed tasks
- blocker discovery for a target task
- earliest/latest schedule, slack, critical task marking, and Graphviz DOT export
- task explanation, graph statistics, affected rebuild plans, Mermaid, CSV, and
  compact JSON exports

Partial:

- durations are integer units and intentionally do not model calendars, time zones, or resources
- DOT output is textual and does not render images

Unsupported:

- cyclic workflow execution
- resource leveling, worker assignment, probabilistic estimates, benchmark timing, or CI performance regression gates
- calendar recurrence or date expansion

## Quick Start

```bash
moon test --target wasm-gc
moon run cmd/main --target js -- demo
```

Example graph:

```text
fetch | 2 | - | fetch sources
schema | 1 | fetch | validate manifests
compile | 5 | schema | compile packages
lint | 2 | schema | static checks
test | 4 | compile,lint | run test matrix
package | 1 | test | prepare release
```

Inspect a small pipeline:

```bash
moon run cmd/main --target js -- inspect --graph 'a | 1 | -\nb | 2 | a\nc | 1 | a\nd | 3 | b,c'
```

Expected summary:

```text
MOONDAG tasks=4 edges=4
ORDER a b c d
LAYERS
0: a
1: b c
2: d
CRITICAL 6 a -> b -> d
```

## CLI

```text
moondag inspect --graph TEXT
moondag order   --graph TEXT
moondag layers  --graph TEXT
moondag impact  --graph TEXT --changed ID[,ID]
moondag block   --graph TEXT --target ID
moondag schedule --graph TEXT
moondag dot      --graph TEXT
moondag stats    --graph TEXT
moondag task     --graph TEXT --target ID
moondag plan     --graph TEXT --changed ID[,ID]
moondag mermaid  --graph TEXT
moondag csv      --graph TEXT
moondag demo
```

CLI text decodes `\n`, `\r`, `\t`, and `\\`. Success exits with code `0`;
usage and validation errors exit with code `2` and include stable diagnostic
codes such as `graph.cycle` or `graph.dep.missing`.

## Library API

```moonbit
let dag = @moondag.compile_graph("a | 1 | -\nb | 2 | a").unwrap()
let order = dag.topological_order()
let layers = dag.layers()
let impact = dag.downstream(["a"]).unwrap()
let blockers = dag.blockers("b").unwrap()
let schedule = dag.schedule()
let stats = dag.stats()
let plan = dag.impact_plan(["a"]).unwrap()
let dot = dag.to_dot()
let mermaid = dag.to_mermaid()
```

Public interfaces are generated in `pkg.generated.mbti`.

## Verification

```bash
moon fmt --check
moon check --target wasm-gc --deny-warn
moon check --target wasm --deny-warn
moon check --target js --deny-warn
moon check --target native --deny-warn
moon test --target wasm-gc
moon test --target wasm
moon test --target js
moon test --target native
```

The GitHub Actions workflow reproduces these checks and compares CLI output
against files in `examples/`.

## License

MoonDag is released under the Apache License 2.0. See `LICENSE`.
