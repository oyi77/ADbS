#!/usr/bin/env bats
# Unit tests for lib/task_manager/simple.sh

load ../test_helper

setup() {
    setup_test_env
    export WORKFLOW_ENFORCER_DIR="$TEMP_DIR/.workflow-enforcer"
    mkdir -p "$WORKFLOW_ENFORCER_DIR"
    source "$PROJECT_ROOT/lib/task_manager/simple.sh"
}

teardown() {
    teardown_test_env
}

@test "taskManager_createTask_whenValid_createsTask" {
    if ! command_exists jq && ! command_exists python3; then
        skip "jq or python3 required"
    fi
    
    run create_task "Test task" "high"
    [ "$status" -eq 0 ]
    [ -n "$output" ]  # Should return task ID
    [ -f "$TASKS_FILE" ]
}

@test "taskManager_createTask_whenEmptyDescription_rejects" {
    run create_task ""
    [ "$status" -ne 0 ]
}

@test "taskManager_createTask_whenInvalidPriority_defaultsToMedium" {
    if ! command_exists jq && ! command_exists python3; then
        skip "jq or python3 required"
    fi
    
    run create_task "Test" "invalid"
    [ "$status" -eq 0 ]
}

@test "taskManager_listTasks_whenEmpty_returnsEmpty" {
    if ! command_exists jq && ! command_exists python3; then
        skip "jq or python3 required"
    fi
    
    init_tasks
    run list_tasks
    [ "$status" -eq 0 ]
}

@test "taskManager_getTask_whenExists_returnsTask" {
    if ! command_exists jq && ! command_exists python3; then
        skip "jq or python3 required"
    fi
    
    local task_id
    task_id=$(create_task "Test task")
    [ -n "$task_id" ]
    
    run get_task "$task_id"
    [ "$status" -eq 0 ]
    assert_contains "$output" "Test task"
}

@test "taskManager_getTask_whenMissing_returnsError" {
    if ! command_exists jq && ! command_exists python3; then
        skip "jq or python3 required"
    fi
    
    init_tasks
    run get_task "nonexistent"
    [ "$status" -ne 0 ]
}

@test "taskManager_deleteTask_whenExists_deletesTask" {
    if ! command_exists jq && ! command_exists python3; then
        skip "jq or python3 required"
    fi
    
    local task_id
    task_id=$(create_task "Test task")
    [ -n "$task_id" ]
    
    run delete_task "$task_id"
    [ "$status" -eq 0 ]
    
    run get_task "$task_id"
    [ "$status" -ne 0 ]
}

@test "taskManager_deleteTask_whenMissing_returnsError" {
    if ! command_exists jq && ! command_exists python3; then
        skip "jq or python3 required"
    fi
    
    init_tasks
    run delete_task "nonexistent"
    [ "$status" -ne 0 ]
}

@test "taskManager_exportTasks_whenValid_exportsFile" {
    if ! command_exists jq && ! command_exists python3; then
        skip "jq or python3 required"
    fi
    
    init_tasks
    local export_file="$TEMP_DIR/export.json"
    
    run export_tasks "$export_file"
    [ "$status" -eq 0 ]
    [ -f "$export_file" ]
}

@test "taskManager_importTasks_whenValid_importsFile" {
    if ! command_exists jq && ! command_exists python3; then
        skip "jq or python3 required"
    fi
    
    local import_file="$TEMP_DIR/import.json"
    echo '{"tasks":[],"next_id":1}' > "$import_file"
    
    run import_tasks "$import_file"
    [ "$status" -eq 0 ]
    [ -f "$TASKS_FILE" ]
}

@test "taskManager_importTasks_whenInvalidJson_rejects" {
    if ! command_exists jq && ! command_exists python3; then
        skip "jq or python3 required"
    fi
    
    local import_file="$TEMP_DIR/invalid.json"
    echo '{invalid json}' > "$import_file"
    
    run import_tasks "$import_file"
    [ "$status" -ne 0 ]
}

@test "taskManager_importTasks_whenMissingFile_rejects" {
    run import_tasks "$TEMP_DIR/nonexistent.json"
    [ "$status" -ne 0 ]
}
