## 2024-05-23 - Shell Script Sourcing for Tests
**Learning:** Shell scripts in `lib/` often run as standalone executables but must be sourceable for unit testing. Without a guard `if [[ "${BASH_SOURCE[0]}" == "${0}" ]];`, sourcing the script triggers its main execution logic (e.g., argument parsing), causing tests to fail immediately with exit codes or usage messages.
**Action:** Always wrap the main execution logic of shell scripts in a guard block to ensure they can be safely sourced by test runners like BATS.
