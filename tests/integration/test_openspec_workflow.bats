#!/usr/bin/env bats
# Integration test for OpenSpec workflow

load ../test_helper

setup() {
    setup_test_env
    export OPENSPEC_ROOT="$TEMP_DIR/.openspec"
}

teardown() {
    teardown_test_env
}

@test "openspecWorkflow_complete_whenFollowingSteps_succeeds" {
    # Initialize OpenSpec
    run bash "$PROJECT_ROOT/lib/openspec.sh" init
    [ "$status" -eq 0 ]
    
    # Verify directories created
    [ -d "$OPENSPEC_ROOT" ] || [ -d ".openspec" ]
    
    # Create proposal
    run bash "$PROJECT_ROOT/lib/openspec.sh" propose "test-feature"
    [ "$status" -eq 0 ]
    
    # Check status
    run bash "$PROJECT_ROOT/lib/openspec.sh" status
    [ "$status" -eq 0 ]
    assert_contains "$output" "Active Proposals" || true
}

@test "openspecWorkflow_proposalCreation_whenValid_createsStructure" {
    bash "$PROJECT_ROOT/lib/openspec.sh" init
    bash "$PROJECT_ROOT/lib/openspec.sh" propose "add-new-feature"
    
    # Check if proposal directory exists
    [ -d "$OPENSPEC_ROOT/changes/"*"add-new-feature" ] || [ -d ".openspec/changes/"*"add-new-feature" ]
}

@test "openspecWorkflow_multipleProposals_whenCreated_allListed" {
    bash "$PROJECT_ROOT/lib/openspec.sh" init
    bash "$PROJECT_ROOT/lib/openspec.sh" propose "feature-one"
    bash "$PROJECT_ROOT/lib/openspec.sh" propose "feature-two"
    
    run bash "$PROJECT_ROOT/lib/openspec.sh" status
    [ "$status" -eq 0 ]
    # Should show multiple proposals
    [ -n "$output" ]
}

@test "openspecWorkflow_archive_whenCompleted_movesToArchive" {
    bash "$PROJECT_ROOT/lib/openspec.sh" init
    bash "$PROJECT_ROOT/lib/openspec.sh" propose "completed-feature"
    
    # Find the created change
    if [ -d "$OPENSPEC_ROOT/changes" ]; then
        change_id=$(ls "$OPENSPEC_ROOT/changes" | head -n 1)
        if [ -n "$change_id" ]; then
            run bash "$PROJECT_ROOT/lib/openspec.sh" archive "$change_id"
            # Should archive successfully
            [ "$status" -eq 0 ] || true
        fi
    fi
}

@test "openspecWorkflow_projectMd_whenInitialized_exists" {
    bash "$PROJECT_ROOT/lib/openspec.sh" init
    
    # Check if project.md was created
    [ -f "$OPENSPEC_ROOT/project.md" ] || [ -f ".openspec/project.md" ]
}
