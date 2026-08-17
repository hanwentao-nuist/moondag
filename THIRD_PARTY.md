# Third-Party Notices

MoonDag contains original MoonBit analysis code and depends on:

- `AlexenderSokolov/moonflowgraph@0.3.0`, Apache-2.0,
  https://github.com/AlexenderSokolov/moonflowgraph. It supplies the task graph,
  dependency validation, cycle detection, topological order, and execution
  batches that MoonDag extends with duration and impact analysis.
- `moonbitlang/x@0.4.49`, Apache-2.0, used for CLI process exit support.
- MoonBit standard library and official toolchain.

No upstream source code, images, datasets, or binary assets are copied into this
repository. Dependencies are resolved by the MoonBit package manager.
