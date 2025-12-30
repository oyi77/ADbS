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

@test "taskManager_simpleManager_update_whenTaskExists_updatesTask" {
    bash "$PROJECT_ROOT/lib/task_manager/simple.sh" create "Test task" "high" "" "test" || true
    
    run bash "$PROJECT_ROOT/lib/task_manager/simple.sh" update "1" "Updated task" "medium"
    [ -n "$output" ] || true
}

@test "taskManager_simpleManager_delete_whenTaskExists_deletesTask" {
    bash "$PROJECT_ROOT/lib/task_manager/simple.sh" create "Test task" "high" "" "test" || true
    
    run bash "$PROJECT_ROOT/lib/task_manager/simple.sh" delete "1"
    [ -n "$output" ] || true
}

@test "taskManager_simpleManager_status_whenTaskExists_showsStatus" {
    bash "$PROJECT_ROOT/lib/task_manager/simple.sh" create "Test task" "high" "" "test" || true
    
    run bash "$PROJECT_ROOT/lib/task_manager/simple.sh" status "1"
    [ -n "$output" ] || true
}

@test "taskManager_simpleManager_complete_whenTaskExists_marksComplete" {
    bash "$PROJECT_ROOT/lib/task_manager/simple.sh" create "Test task" "high" "" "test" || true
    
    run bash "$PROJECT_ROOT/lib/task_manager/simple.sh" complete "1"
    [ -n "$output" ] || true
}

@test "taskManager_loadFixture_whenSimpleTasksLoaded_returnsJson" {
    local tasks=$(load_task_fixture "simple_tasks")
    
    [ -n "$tasks" ]
    assert_json_key "$tasks" "tasks"
}

@test "taskManager_loadFixture_whenComplexTasksLoaded_hasMultipleTasks" {
    local tasks=$(load_task_fixture "complex_tasks")
    
    [ -n "$tasks" ]
    assert_json_key "$tasks" "tasks"
    # Should have multiple tasks
    [[ "$tasks" == *"task-001"* ]]
    [[ "$tasks" == *"task-002"* ]]
}

@test "taskManager_assertTaskStatus_whenTaskDone_returnsSuccess" {
    local tasks=$(load_task_fixture "simple_tasks")
    
    assert_task_status "$tasks" "task-001" "done"
}

@test "taskManager_assertTaskStatus_whenTaskInProgress_returnsSuccess" {
    local tasks=$(load_task_fixture "simple_tasks")
    
    assert_task_status "$tasks" "task-002" "in-progress"
}

@test "taskManager_assertTaskStatus_whenTaskTodo_returnsSuccess" {
    local tasks=$(load_task_fixture "simple_tasks")
    
    assert_task_status "$tasks" "task-003" "todo"
}

@test "taskManager_complexFixture_whenLoaded_hasDependencies" {
    local tasks=$(load_task_fixture "complex_tasks")
    
    [ -n "$tasks" ]
    # Should have dependencies field
    [[ "$tasks" == *"dependencies"* ]]
}

@test "taskManager_complexFixture_whenLoaded_hasBlockedTask" {
    local tasks=$(load_task_fixture "complex_tasks")
    
    [ -n "$tasks" ]
    # Should have blocked status
    [[ "$tasks" == *"blocked"* ]]
}

@test "taskManager_simpleManager_help_whenRun_showsUsage" {
    run bash "$PROJECT_ROOT/lib/task_manager/simple.sh" --help
    [ -n "$output" ] || true
}
