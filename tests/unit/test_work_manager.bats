#!/usr/bin/env bats
# Unit tests for lib/internal/work_manager.sh

load ../test_helper

setup() {
    setup_test_env
    export ADBS_DIR="$TEMP_DIR/.adbs"
    mkdir -p "$ADBS_DIR/work" "$ADBS_DIR/archive"
    source "$PROJECT_ROOT/lib/internal/work_manager.sh"
}

teardown() {
    teardown_test_env
}

@test "workManager_createWork_whenValidName_createsWork" {
    run create_work "test-feature"
    [ "$status" -eq 0 ]
    [ -d "$ADBS_DIR/work" ]
    local work_dirs=("$ADBS_DIR/work"/*)
    [ ${#work_dirs[@]} -gt 0 ]
}

@test "workManager_createWork_whenEmptyName_rejects" {
    run create_work ""
    [ "$status" -ne 0 ]
    assert_contains "$output" "required"
}

@test "workManager_createWork_whenPathTraversal_rejects" {
    run create_work "../etc"
    [ "$status" -ne 0 ]
    
    run create_work "/etc/passwd"
    [ "$status" -ne 0 ]
}

@test "workManager_showWork_whenExists_showsContent" {
    local work_id="2025-01-15-test-work"
    mkdir -p "$ADBS_DIR/work/$work_id"
    echo "# Test Work" > "$ADBS_DIR/work/$work_id/proposal.md"
    
    run show_work "test-work"
    [ "$status" -eq 0 ]
    assert_contains "$output" "Test Work"
}

@test "workManager_showWork_whenMissing_returnsError" {
    run show_work "nonexistent"
    [ "$status" -ne 0 ]
    assert_contains "$output" "not found"
}

@test "workManager_completeWork_whenExists_movesToArchive" {
    local work_id="2025-01-15-test-work"
    mkdir -p "$ADBS_DIR/work/$work_id"
    echo "# Test" > "$ADBS_DIR/work/$work_id/proposal.md"
    
    run complete_work "test-work" "--force"
    [ "$status" -eq 0 ]
    [ ! -d "$ADBS_DIR/work/$work_id" ]
    [ -d "$ADBS_DIR/archive/$work_id" ]
}

@test "workManager_listWork_whenEmpty_showsNone" {
    run list_work
    [ "$status" -eq 0 ]
    assert_contains "$output" "(none)"
}

@test "workManager_listWork_whenHasWork_showsList" {
    local work_id="2025-01-15-test-work"
    mkdir -p "$ADBS_DIR/work/$work_id"
    echo "# Test" > "$ADBS_DIR/work/$work_id/proposal.md"
    
    run list_work
    [ "$status" -eq 0 ]
    assert_contains "$output" "test-work"
}

@test "workManager_showStatus_whenEmpty_showsZero" {
    run show_status
    [ "$status" -eq 0 ]
    assert_contains "$output" "Active work: 0"
}

@test "workManager_showStatus_whenHasWork_showsCount" {
    local work_id="2025-01-15-test-work"
    mkdir -p "$ADBS_DIR/work/$work_id"
    
    run show_status
    [ "$status" -eq 0 ]
    assert_contains "$output" "Active work: 1"
}

