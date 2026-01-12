#!/usr/bin/env bats
# Integration tests for complete workflows

load ../test_helper

setup() {
    setup_test_env
    export ADBS_DIR="$TEMP_DIR/.adbs"
    mkdir -p "$ADBS_DIR/work" "$ADBS_DIR/archive"
    export PATH="$PROJECT_ROOT/bin:$PATH"
}

teardown() {
    teardown_test_env
}

@test "integration_newWork_whenCalled_createsWork" {
    run "$PROJECT_ROOT/bin/workflow-enforcer" new "test-feature"
    [ "$status" -eq 0 ]
    [ -d "$ADBS_DIR/work" ]
    local work_dirs=("$ADBS_DIR/work"/*)
    [ ${#work_dirs[@]} -gt 0 ]
}

@test "integration_status_whenEmpty_showsZero" {
    run "$PROJECT_ROOT/bin/workflow-enforcer" status
    [ "$status" -eq 0 ]
    assert_contains "$output" "Active work: 0"
}

@test "integration_status_whenHasWork_showsCount" {
    "$PROJECT_ROOT/bin/workflow-enforcer" new "test-feature" > /dev/null
    run "$PROJECT_ROOT/bin/workflow-enforcer" status
    [ "$status" -eq 0 ]
    assert_contains "$output" "Active work: 1"
}

@test "integration_completeWork_whenExists_archives" {
    "$PROJECT_ROOT/bin/workflow-enforcer" new "test-feature" > /dev/null
    run "$PROJECT_ROOT/bin/workflow-enforcer" done "test-feature"
    [ "$status" -eq 0 ]
    [ -d "$ADBS_DIR/archive" ]
    local archive_dirs=("$ADBS_DIR/archive"/*)
    [ ${#archive_dirs[@]} -gt 0 ]
}

@test "integration_todo_whenCalled_createsTask" {
    export WORKFLOW_ENFORCER_DIR="$TEMP_DIR/.workflow-enforcer"
    mkdir -p "$WORKFLOW_ENFORCER_DIR"
    
    if command_exists jq || command_exists python3; then
        run "$PROJECT_ROOT/bin/workflow-enforcer" todo "Test task"
        [ "$status" -eq 0 ]
        [ -f "$WORKFLOW_ENFORCER_DIR/tasks.json" ]
    else
        skip "jq or python3 required"
    fi
}

@test "integration_list_whenHasWork_showsWork" {
    "$PROJECT_ROOT/bin/workflow-enforcer" new "test-feature" > /dev/null
    run "$PROJECT_ROOT/bin/workflow-enforcer" list
    [ "$status" -eq 0 ]
    assert_contains "$output" "test-feature"
}

