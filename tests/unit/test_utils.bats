#!/usr/bin/env bats
# Unit tests for utils.sh

load ../test_helper

setup() {
    setup_test_env
}

teardown() {
    teardown_test_env
}

@test "utils_log_whenCalled_printsMessage" {
    source "$PROJECT_ROOT/lib/utils.sh"
    run log_info "Test Message"
    [ "$status" -eq 0 ]
    assert_contains "$output" "Test Message"
}

@test "utils_checkDeps_whenCalled_checksDependencies" {
    source "$PROJECT_ROOT/lib/utils.sh"
    run check_dependencies "bash"
    [ "$status" -eq 0 ]
}

@test "utils_ensureDir_whenCalled_createsDirectory" {
    source "$PROJECT_ROOT/lib/utils.sh"
    local new_dir="$TEMP_DIR/test_dir"
    ensure_dir "$new_dir"
    assert_dir_exists "$new_dir"
}
