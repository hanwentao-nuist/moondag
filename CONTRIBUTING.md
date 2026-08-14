# Contributing

Run these checks before proposing changes:

```bash
moon fmt --check
moon check --target wasm-gc --deny-warn
moon check --target wasm --deny-warn
moon check --target js --deny-warn
moon test --target wasm-gc
```

Keep diagnostics stable. When changing CLI output, update the expected files in
`examples/` and explain the compatibility impact in the changelog.
