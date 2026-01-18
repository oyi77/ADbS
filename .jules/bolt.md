## 2026-01-18 - [Shell Builtins vs Caching]
**Learning:** Attempted to cache `command -v` results in a variable to avoid repeated checks. However, benchmarking revealed that `command -v` (a shell builtin) is extremely fast, and the overhead of checking a variable in shell script is comparable or even slower than the builtin itself. The optimization added complexity without performance gain.
**Action:** Do not cache shell builtins like `command -v` unless inside a very tight loop with significant other overheads. Focus on avoiding external process spawns (like `jq`, `chmod`, `grep`) instead.
