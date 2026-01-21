## 2026-01-16 - [Shell Dependency Check Overhead]
**Learning:** `lib/core/common.sh` functions like `safe_json_get_key` re-check dependencies (`command -v jq`) on every invocation. In tight loops, this adds significant overhead (~13% in micro-benchmark).
**Action:** Cache dependency checks in global variables (e.g., `_JSON_PROCESSOR_CACHE`) when the script is sourced, rather than checking inside hot functions.
## 2025-02-18 - [Bash Subshell Caching]
**Learning:** Caching detection results in a shell function (e.g. `get_json_processor`) is ineffective if the function is commonly called inside command substitution `$(...)`, as variables set in the subshell are lost.
**Action:** Detect and export the cached value at the library source time (parent shell) so subshells inherit it.
## 2024-05-23 - Shell Script Sourcing for Tests
**Learning:** Shell scripts in `lib/` often run as standalone executables but must be sourceable for unit testing. Without a guard `if [[ "${BASH_SOURCE[0]}" == "${0}" ]];`, sourcing the script triggers its main execution logic (e.g., argument parsing), causing tests to fail immediately with exit codes or usage messages.
**Action:** Always wrap the main execution logic of shell scripts in a guard block to ensure they can be safely sourced by test runners like BATS.
