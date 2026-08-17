# Security Notes

MoonDag analyzes caller-provided MoonFlowGraph values or plain text convenience
specifications. It does not execute tasks, open network connections, read
arbitrary files, or run shell commands from graph content.

Safety limits:

- graph text is limited to 4,194,304 characters
- compiled graphs are limited to 4,096 tasks
- task durations are positive integers up to 1,000,000
- task identifiers are restricted to `[A-Za-z_][A-Za-z0-9_.-]*`

Report issues through the public GitHub repository.
