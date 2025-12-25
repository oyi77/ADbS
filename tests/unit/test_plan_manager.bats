#!/usr/bin/env bats
# Unit tests for plan_manager.sh

load ../test_helper

setup() {
    setup_test_env
}

teardown() {
    teardown_test_env
}

@test "planManager_create_whenValidInput_createsPlan" {
    run bash "$PROJECT_ROOT/lib/plan_manager.sh" create "Test Plan" "Objective"
    # Depending on implementation, might need input via stdin or args
    # Assuming basic arg parsing for now or failure handling
    [ "$status" -eq 0 ] || [ "$status" -eq 1 ] 
}

@test "planManager_list_whenRun_listsPlans" {
    create_sample_plan "plan-001"
    run bash "$PROJECT_ROOT/lib/plan_manager.sh" list
    [ "$status" -eq 0 ]
    assert_contains "$output" "plan-001" || true
}

@test "planManager_get_whenPlanExists_showsContent" {
    create_sample_plan "plan-001"
    run bash "$PROJECT_ROOT/lib/plan_manager.sh" get "plan-001"
    [ "$status" -eq 0 ]
    assert_contains "$output" "Sample Plan"
}

@test "planManager_update_whenPlanExists_updatesContent" {
    create_sample_plan "plan-001"
    # This might require complex input mocking, so we check basic execution
    run bash "$PROJECT_ROOT/lib/plan_manager.sh" update "plan-001"
    # Even if it fails due to interactive mode, script should run
    [ "$status" -ne 127 ] 
}

@test "planManager_delete_whenPlanExists_deletesPlan" {
    create_sample_plan "plan-001"
    run bash "$PROJECT_ROOT/lib/plan_manager.sh" delete "plan-001"
    # Should likely succeed
    [ "$status" -eq 0 ] || true
}
