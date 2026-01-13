## 2025-02-18 - [Bash Subshell Caching]
**Learning:** Caching detection results in a shell function (e.g. `get_json_processor`) is ineffective if the function is commonly called inside command substitution `$(...)`, as variables set in the subshell are lost.
**Action:** Detect and export the cached value at the library source time (parent shell) so subshells inherit it.
