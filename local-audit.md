# Local Readiness Audit

Date: 2026-08-13

## Environment

- MoonBit: `moon 0.1.20260713`, `moonc v0.10.4+2cc641edf`
- Git: `2.45.1.windows.1`
- Python: `3.8.5`
- GitHub CLI: `2.96.0`, not used for remote operations before local readiness
- GitHub network: `github.com:443` and `api.github.com:443` reachable

## Non-Duplication

MoonDag is distinct from the reserved projects because its core data is task
dependency graphs and durations, and its workflow is DAG validation plus
pipeline analysis. It does not center on performance samples, OpenAPI contract
validation, civil-calendar recurrence, unified-diff patch application, or
content-defined chunking.

## Local Evidence

- `moon fmt --check`: passed
- `moon check --target wasm-gc --deny-warn`: passed
- `moon check --target wasm --deny-warn`: passed
- `moon check --target js --deny-warn`: passed
- `moon check --target native --deny-warn`: passed
- `moon test --target wasm-gc`: 11 passed
- `moon test --target wasm`: 11 passed
- `moon test --target js`: 11 passed
- JavaScript CLI example comparisons: passed
- `moon test --target native`: blocked locally because no system C compiler is
  installed (`cl`, `cc`, `gcc`, and `clang` not found); configured for GitHub
  Actions Ubuntu runner
- Native CLI build and example comparison: blocked locally for the same C
  compiler reason; configured for GitHub Actions Ubuntu runner

## Deliverables

- MoonBit implementation and tests: root package and `cmd/main`
- Examples: `examples/*.mdag` and expected CLI outputs
- Documentation: README, scope, architecture, comparison, security,
  contribution, third-party, AI disclosure, changelog
- CI: `.github/workflows/ci.yml`
- Submission draft: kept outside Git by default
