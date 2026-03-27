## 2026-01-18 - [Shell Builtins vs Caching]
**Learning:** Attempted to cache `command -v` results in a variable to avoid repeated checks. However, benchmarking revealed that `command -v` (a shell builtin) is extremely fast, and the overhead of checking a variable in shell script is comparable or even slower than the builtin itself. The optimization added complexity without performance gain.
**Action:** Do not cache shell builtins like `command -v` unless inside a very tight loop with significant other overheads. Focus on avoiding external process spawns (like `jq`, `chmod`, `grep`) instead.
## 2026-01-16 - [Shell Dependency Check Overhead]
**Learning:** `lib/core/common.sh` functions like `safe_json_get_key` re-check dependencies (`command -v jq`) on every invocation. In tight loops, this adds significant overhead (~13% in micro-benchmark).
**Action:** Cache dependency checks in global variables (e.g., `_JSON_PROCESSOR_CACHE`) when the script is sourced, rather than checking inside hot functions.
## 2025-05-22 - [Awk vs Grep Loop]
**Learning:** Attempted to replace a loop of `grep` calls (checking multiple strings in a file) with a single `awk` script using `tolower($0) ~ pattern`. Benchmarking showed `awk` was significantly slower (~3x) because `grep`'s internal text search optimization (C implementation) far outperforms `awk`'s interpreted regex matching loop, even when avoiding multiple process spawns.
**Action:** Stick to multiple `grep` calls for simple string searching unless the pattern complexity or number of patterns is very high.
## 2025-02-18 - [Bash Subshell Caching]
**Learning:** Caching detection results in a shell function (e.g. `get_json_processor`) is ineffective if the function is commonly called inside command substitution `$(...)`, as variables set in the subshell are lost.
**Action:** Detect and export the cached value at the library source time (parent shell) so subshells inherit it.
## 2024-05-23 - Shell Script Sourcing for Tests
**Learning:** Shell scripts in `lib/` often run as standalone executables but must be sourceable for unit testing. Without a guard `if [[ "${BASH_SOURCE[0]}" == "${0}" ]];`, sourcing the script triggers its main execution logic (e.g., argument parsing), causing tests to fail immediately with exit codes or usage messages.
**Action:** Always wrap the main execution logic of shell scripts in a guard block to ensure they can be safely sourced by test runners like BATS.
## 2025-05-23 - [Pure Bash Performance]
**Learning:** Replaced external process pipeline (`head | md5sum | cut`) with pure Bash array indexing for random string generation. Resulted in ~34x speedup (16ms vs 583ms for 100 iterations) by eliminating fork/exec overhead.
**Action:** Prefer shell built-ins and arrays over external utilities (sed, awk, head, cut) for simple string manipulation in tight loops or frequently called functions.
