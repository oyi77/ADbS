#!/usr/bin/env bats
# Unit tests for lib/validator/workflow.sh

load ../test_helper

setup() {
    setup_test_env
    export SDD_DIR="$TEMP_DIR/.sdd"
    export WORKFLOW_ENFORCER_DIR="$TEMP_DIR/.workflow-enforcer"
    mkdir -p "$SDD_DIR/plans" "$SDD_DIR/requirements" "$SDD_DIR/designs" "$SDD_DIR/tasks"
    source "$PROJECT_ROOT/lib/validator/workflow.sh"
}

teardown() {
    teardown_test_env
}

@test "validator_initWorkflow_whenCalled_createsDirectories" {
    rm -rf "$SDD_DIR" "$WORKFLOW_DIR"
    init_workflow
    [ -d "$SDD_DIR/plans" ]
    [ -d "$SDD_DIR/requirements" ]
    [ -d "$SDD_DIR/designs" ]
    [ -d "$SDD_DIR/tasks" ]
    [ -d "$WORKFLOW_DIR" ]
    [ -f "$CURRENT_STAGE_FILE" ]
}

@test "validator_getCurrentStage_whenFileExists_returnsStage" {
    echo "plan" > "$CURRENT_STAGE_FILE"
    run get_current_stage
    [ "$status" -eq 0 ]
    [ "$output" = "plan" ]
}

@test "validator_getCurrentStage_whenFileMissing_returnsExplore" {
    rm -f "$CURRENT_STAGE_FILE"
    run get_current_stage
    [ "$status" -eq 0 ]
    [ "$output" = "explore" ]
}

@test "validator_setCurrentStage_whenValid_setsStage" {
    set_current_stage "plan"
    [ "$(cat "$CURRENT_STAGE_FILE")" = "plan" ]
}

@test "validator_checkFileMinLength_whenValid_returnsSuccess" {
    local test_file="$TEMP_DIR/test.md"
    echo "This is a test file with enough words to pass validation" > "$test_file"
    
    run check_file_min_length "$test_file" 5
    [ "$status" -eq 0 ]
}

@test "validator_checkFileMinLength_whenTooShort_returnsError" {
    local test_file="$TEMP_DIR/test.md"
    echo "Short" > "$test_file"
    
    run check_file_min_length "$test_file" 100
    [ "$status" -ne 0 ]
}

@test "validator_checkFileMinLength_whenMissing_returnsError" {
    run check_file_min_length "$TEMP_DIR/nonexistent.md" 10
    [ "$status" -ne 0 ]
}

@test "validator_checkFileContains_whenContains_returnsSuccess" {
    local test_file="$TEMP_DIR/test.md"
    echo "This file contains functional_requirements and non_functional_requirements" > "$test_file"
    
    run check_file_contains "$test_file" "functional_requirements" "non_functional_requirements"
    [ "$status" -eq 0 ]
}

@test "validator_checkFileContains_whenMissing_returnsError" {
    local test_file="$TEMP_DIR/test.md"
    echo "This file does not contain the required string" > "$test_file"
    
    run check_file_contains "$test_file" "required_string"
    [ "$status" -ne 0 ]
}

@test "validator_validateExplore_whenCalled_returnsSuccess" {
    run validate_explore
    [ "$status" -eq 0 ]
}

@test "validator_validateExecution_whenTasksExist_returnsSuccess" {
    local tasks_json="$WORKFLOW_DIR/tasks.json"
    echo '{"tasks":[{"id":"task-1","status":"todo"}],"next_id":2}' > "$tasks_json"
    
    if command_exists jq || command_exists python3; then
        run validate_execution
        [ "$status" -eq 0 ]
    else
        skip "jq or python3 required"
    fi
}

@test "validator_validateExecution_whenNoTasks_returnsError" {
    local tasks_json="$WORKFLOW_DIR/tasks.json"
    echo '{"tasks":[],"next_id":1}' > "$tasks_json"
    
    if command_exists jq || command_exists python3; then
        run validate_execution
        [ "$status" -ne 0 ]
    else
        skip "jq or python3 required"
    fi
}

@test "validator_validateExecution_whenFileMissing_returnsError" {
    rm -f "$WORKFLOW_DIR/tasks.json"
    run validate_execution
    [ "$status" -ne 0 ]
    assert_contains "$output" "not found"
}
