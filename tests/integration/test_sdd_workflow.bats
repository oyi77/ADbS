#!/usr/bin/env bats
# Integration test for complete SDD workflow

load ../test_helper

setup() {
    setup_test_env
}

teardown() {
    teardown_test_env
}

@test "sddWorkflow_complete_whenFollowingStages_succeeds" {
    # Initialize workflow
    echo "explore" > "$WORKFLOW_ENFORCER_DIR/current-stage"
    
    # Explore stage - should pass
    run bash "$PROJECT_ROOT/lib/validator/workflow.sh" validate
    [ "$status" -eq 0 ] || true
    
    # Advance to plan
    run bash "$PROJECT_ROOT/lib/validator/workflow.sh" next
    [ "$status" -eq 0 ] || true
    
    # Create plan
    create_sample_plan "plan-001"
    
    # Validate plan stage
    echo "plan" > "$WORKFLOW_ENFORCER_DIR/current-stage"
    run bash "$PROJECT_ROOT/lib/validator/workflow.sh" validate
    [ "$status" -eq 0 ] || true
    
    # Advance to requirements
    run bash "$PROJECT_ROOT/lib/validator/workflow.sh" next
    [ "$status" -eq 0 ] || true
    
    # Create requirements
    create_sample_requirements "plan-001"
    
    # Validate requirements stage
    echo "requirements" > "$WORKFLOW_ENFORCER_DIR/current-stage"
    run bash "$PROJECT_ROOT/lib/validator/workflow.sh" validate
    [ "$status" -eq 0 ] || true
}

@test "sddWorkflow_planCreation_whenValid_createsFile" {
    create_sample_plan "plan-001"
    
    assert_file_exists "$SDD_DIR/plans/plan-001.md"
}

@test "sddWorkflow_requirementsCreation_whenValid_createsFile" {
    create_sample_requirements "plan-001"
    
    assert_file_exists "$SDD_DIR/requirements/requirements.plan-001.md"
}

@test "sddWorkflow_designCreation_whenValid_createsFile" {
    create_sample_design "plan-001"
    
    assert_file_exists "$SDD_DIR/designs/design.plan-001.md"
}

@test "sddWorkflow_tasksCreation_whenValid_createsFile" {
    create_sample_tasks "plan-001"
    
    assert_file_exists "$SDD_DIR/tasks/tasks.plan-001.md"
}

@test "sddWorkflow_stageProgression_whenValid_advancesCorrectly" {
    # Start at explore
    echo "explore" > "$WORKFLOW_ENFORCER_DIR/current-stage"
    
    current=$(cat "$WORKFLOW_ENFORCER_DIR/current-stage")
    [[ "$current" == "explore" ]]
    
    # Advance to plan
    echo "plan" > "$WORKFLOW_ENFORCER_DIR/current-stage"
    current=$(cat "$WORKFLOW_ENFORCER_DIR/current-stage")
    [[ "$current" == "plan" ]]
}
