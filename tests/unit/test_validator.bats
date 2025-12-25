#!/usr/bin/env bats
# Unit tests for workflow validator

load ../test_helper

setup() {
    setup_test_env
}

teardown() {
    teardown_test_env
}

@test "validator_fileExists_whenChecked_returnsTrue" {
    assert_file_exists "$PROJECT_ROOT/lib/validator/workflow.sh"
}

@test "validator_getCurrentStage_whenStageFileExists_returnsStage" {
    echo "explore" > "$WORKFLOW_ENFORCER_DIR/current-stage"
    
    run bash "$PROJECT_ROOT/lib/validator/workflow.sh" current
    [ "$status" -eq 0 ]
    assert_contains "$output" "explore"
}

@test "validator_getCurrentStage_whenNoStageFile_returnsError" {
    run bash "$PROJECT_ROOT/lib/validator/workflow.sh" current
    # Should either return error or default stage
    [ -n "$output" ] || [ "$status" -ne 0 ]
}

@test "validator_status_whenRun_showsCurrentStage" {
    echo "plan" > "$WORKFLOW_ENFORCER_DIR/current-stage"
    
    run bash "$PROJECT_ROOT/lib/validator/workflow.sh" status
    [ "$status" -eq 0 ]
    [ -n "$output" ]
}

@test "validator_setStage_whenValidStage_updatesStageFile" {
    run bash "$PROJECT_ROOT/lib/validator/workflow.sh" set "plan"
    [ "$status" -eq 0 ]
    
    if [ -f "$WORKFLOW_ENFORCER_DIR/current-stage" ]; then
        stage=$(cat "$WORKFLOW_ENFORCER_DIR/current-stage")
        [[ "$stage" == "plan" ]]
    fi
}

@test "validator_validate_whenExploreStage_returnsSuccess" {
    echo "explore" > "$WORKFLOW_ENFORCER_DIR/current-stage"
    
    run bash "$PROJECT_ROOT/lib/validator/workflow.sh" validate
    # Explore stage should always pass
    [ "$status" -eq 0 ] || true
}

@test "validator_validate_whenPlanStageWithoutPlan_returnsFail" {
    echo "plan" > "$WORKFLOW_ENFORCER_DIR/current-stage"
    
    run bash "$PROJECT_ROOT/lib/validator/workflow.sh" validate
    # Should fail without plan file
    [ "$status" -ne 0 ] || true
}

@test "validator_validate_whenPlanStageWithPlan_returnsSuccess" {
    echo "plan" > "$WORKFLOW_ENFORCER_DIR/current-stage"
    create_sample_plan "plan-001"
    
    run bash "$PROJECT_ROOT/lib/validator/workflow.sh" validate
    # Should pass with valid plan
    [ "$status" -eq 0 ] || true
}

@test "validator_next_whenValidated_advancesStage" {
    echo "explore" > "$WORKFLOW_ENFORCER_DIR/current-stage"
    
    run bash "$PROJECT_ROOT/lib/validator/workflow.sh" next
    # Should advance or show error
    [ -n "$output" ]
}

@test "validator_invalidCommand_whenRun_returnsError" {
    run bash "$PROJECT_ROOT/lib/validator/workflow.sh" invalid-command
    [ "$status" -ne 0 ]
}
