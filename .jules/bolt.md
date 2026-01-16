## 2026-01-16 - [Shell Dependency Check Overhead]
**Learning:** `lib/core/common.sh` functions like `safe_json_get_key` re-check dependencies (`command -v jq`) on every invocation. In tight loops, this adds significant overhead (~13% in micro-benchmark).
**Action:** Cache dependency checks in global variables (e.g., `_JSON_PROCESSOR_CACHE`) when the script is sourced, rather than checking inside hot functions.
