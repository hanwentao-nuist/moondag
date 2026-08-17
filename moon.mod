// Learn more about moon.mod configuration:
// https://docs.moonbitlang.com/en/latest/toolchain/moon/module.html
//
// To add a dependency, run this command in your terminal:
//   moon add moonbitlang/x
//
// Or manually declare it in `import`, for example:
// import {
//   "moonbitlang/x@0.4.6",
// }

name = "hanwentao-nuist/moondag"

version = "0.2.0"

readme = "README.md"

repository = "https://github.com/hanwentao-nuist/moondag"

license = "Apache-2.0"

keywords = [ "moonflowgraph", "cpm", "impact-analysis", "critical-path" ]

preferred_target = "wasm-gc"

description = "Duration, CPM, and change-impact analysis extension for MoonFlowGraph"

import {
  "moonbitlang/x@0.4.49",
  "AlexenderSokolov/moonflowgraph@0.3.0",
}
