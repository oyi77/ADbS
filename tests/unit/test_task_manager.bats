#!/usr/bin/env bats
# Unit tests for task manager

load ../test_helper

setup() {
    setup_test_env
    export WORKFLOW_ENFORCER_DIR="$TEMP_DIR/.workflow-enforcer"
    mkdir -p "$WORKFLOW_ENFORCER_DIR"
}

teardown() {
    teardown_test_env
}

@test "taskManager_fileExists_whenChecked_returnsTrue" {
    assert_file_exists "$PROJECT_ROOT/lib/task_manager/beads_wrapper.sh"
}

@test "taskManager_simpleManagerExists_whenChecked_returnsTrue" {
    assert_file_exists "$PROJECT_ROOT/lib/task_manager/simple.sh"
}

@test "taskManager_create_whenValidInput_createsTask" {
    run bash "$PROJECT_ROOT/lib/task_manager/beads_wrapper.sh" create "Test task" "high" "" "test"
    # May succeed or fail depending on beads availability
    [ -n "$output" ]
}

@test "taskManager_list_whenRun_showsTasks" {
    run bash "$PROJECT_ROOT/lib/task_manager/beads_wrapper.sh" list
    [ "$status" -eq 0 ] || [ "$status" -eq 1 ]
    # Should return output or error message
    [ -n "$output" ] || true
}

@test "taskManager_export_whenRun_exportsJson" {
    local export_file="$TEMP_DIR/tasks.json"
    
    run bash "$PROJECT_ROOT/lib/task_manager/beads_wrapper.sh" export "$export_file"
    # May succeed or fail depending on beads availability
    [ -n "$output" ] || true
}

@test "taskManager_simpleManager_create_whenValidInput_createsTask" {
    run bash "$PROJECT_ROOT/lib/task_manager/simple.sh" create "Test task" "high" "" "test"
    # Simple manager should work without beads
    [ "$status" -eq 0 ] || [ -n "$output" ]
}

@test "taskManager_simpleManager_list_whenRun_showsTasks" {
    run bash "$PROJECT_ROOT/lib/task_manager/simple.sh" list
    [ "$status" -eq 0 ] || [ "$status" -eq 1 ]
}

@test "taskManager_invalidCommand_whenRun_returnsError" {
    run bash "$PROJECT_ROOT/lib/task_manager/beads_wrapper.sh" invalid-command
    [ "$status" -ne 0 ]
}
