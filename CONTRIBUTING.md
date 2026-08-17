# Contributing

Run these checks before proposing changes:

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

Keep diagnostics stable. When changing CLI output, update the expected files in
`examples/` and explain the compatibility impact in the changelog.

Warning `0079` is disabled only because it originates in the pinned
MoonFlowGraph 0.3.0 dependency. Do not suppress additional warning classes.
