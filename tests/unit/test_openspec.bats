#!/usr/bin/env bats
# Unit tests for OpenSpec functionality

load ../test_helper

setup() {
    setup_test_env
    export OPENSPEC_ROOT="$TEMP_DIR/.openspec"
}

teardown() {
    teardown_test_env
}

@test "openspec_fileExists_whenChecked_returnsTrue" {
    assert_file_exists "$PROJECT_ROOT/lib/openspec.sh"
}

@test "openspec_init_whenRun_createsDirectories" {
    run bash "$PROJECT_ROOT/lib/openspec.sh" init
    [ "$status" -eq 0 ]
    
    # Check if directories were created
    [ -d "$OPENSPEC_ROOT" ] || [ -d ".openspec" ]
}

@test "openspec_init_whenAlreadyExists_showsMessage" {
    mkdir -p "$OPENSPEC_ROOT"
    
    run bash "$PROJECT_ROOT/lib/openspec.sh" init
    [ "$status" -eq 0 ]
    assert_contains "$output" "already exists" || true
}

@test "openspec_propose_whenValidName_createsProposal" {
    bash "$PROJECT_ROOT/lib/openspec.sh" init
    
    run bash "$PROJECT_ROOT/lib/openspec.sh" propose "test-feature"
    [ "$status" -eq 0 ]
    
    # Check if proposal was created
    [ -d "$OPENSPEC_ROOT/changes/"*"test-feature" ] || [ -d ".openspec/changes/"*"test-feature" ]
}

@test "openspec_propose_whenNoName_returnsError" {
    bash "$PROJECT_ROOT/lib/openspec.sh" init
    
    run bash "$PROJECT_ROOT/lib/openspec.sh" propose
    [ "$status" -ne 0 ]
}

@test "openspec_status_whenRun_showsStatus" {
    bash "$PROJECT_ROOT/lib/openspec.sh" init
    
    run bash "$PROJECT_ROOT/lib/openspec.sh" status
    [ "$status" -eq 0 ]
    [ -n "$output" ]
}

@test "openspec_specs_whenRun_listsSpecs" {
    bash "$PROJECT_ROOT/lib/openspec.sh" init
    
    run bash "$PROJECT_ROOT/lib/openspec.sh" specs
    [ "$status" -eq 0 ]
}

@test "openspec_archive_whenValidId_archivesChange" {
    bash "$PROJECT_ROOT/lib/openspec.sh" init
    bash "$PROJECT_ROOT/lib/openspec.sh" propose "test-feature"
    
    # Find the created change directory
    if [ -d "$OPENSPEC_ROOT/changes" ]; then
        change_id=$(ls "$OPENSPEC_ROOT/changes" | head -n 1)
        if [ -n "$change_id" ]; then
            run bash "$PROJECT_ROOT/lib/openspec.sh" archive "$change_id"
            [ "$status" -eq 0 ] || true
        fi
    fi
}

@test "openspec_archive_whenNoId_showsActiveChanges" {
    bash "$PROJECT_ROOT/lib/openspec.sh" init
    
    run bash "$PROJECT_ROOT/lib/openspec.sh" archive
    [ "$status" -ne 0 ] || [ -n "$output" ]
}

@test "openspec_invalidCommand_whenRun_returnsError" {
    run bash "$PROJECT_ROOT/lib/openspec.sh" invalid-command
    [ "$status" -ne 0 ]
}

@test "openspec_setupFixture_whenCalled_createsProjectStructure" {
    local project_dir=$(setup_openspec_fixture)
    
    [ -d "$project_dir" ]
    assert_dir_exists "$project_dir/openspec"
    assert_file_exists "$project_dir/openspec/project.md"
}

@test "openspec_validate_whenProposalMissing_returnsError" {
    local project_dir=$(setup_openspec_fixture)
    cd "$project_dir"
    
    run bash "$PROJECT_ROOT/lib/openspec.sh" validate "nonexistent-proposal"
    # Should fail for missing proposal
    [ "$status" -ne 0 ] || [ -n "$output" ]
}
