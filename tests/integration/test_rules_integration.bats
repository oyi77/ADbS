#!/usr/bin/env bats
# Integration test for Dynamic Rules Generator

load ../test_helper

setup() {
    setup_test_env
}

teardown() {
    teardown_test_env
}

@test "rulesIntegration_generate_bash_whenNodeStack_includesNodeRules" {
    # Mock a Node project
    touch "$TEMP_DIR/package.json"
    cd "$TEMP_DIR"
    
    local output_file="$TEMP_DIR/cursor.mdc"
    
    # Run generator
    run bash "$PROJECT_ROOT/lib/rules/dynamic_generator.sh" "cursor" "$output_file" "dev"
    
    [ "$status" -eq 0 ]
    assert_file_exists "$output_file"
    run cat "$output_file"
    assert_contains "$output" "Node.js Guidelines"
}

@test "rulesIntegration_generate_powershell_whenNodeStack_includesNodeRules" {
    # Skip if powershell not available
    if ! command -v powershell >/dev/null; then
        skip "PowerShell not installed"
    fi
    
    # Mock a Node project
    touch "$TEMP_DIR/package.json"
    cd "$TEMP_DIR"
    
    local output_file="$TEMP_DIR/cursor_ps.mdc"
    
    # Run PS generator
    run powershell -File "$PROJECT_ROOT/lib/rules/dynamic_generator.ps1" -Platform "cursor" -OutputFile "$output_file" -Context "dev"
    
    [ "$status" -eq 0 ]
    assert_file_exists "$output_file"
    run cat "$output_file"
    assert_contains "$output" "Node.js Guidelines"
}

@test "rulesIntegration_context_whenQA_includesQARules" {
    cd "$TEMP_DIR"
    local output_file="$TEMP_DIR/qa.mdc"
    
    run bash "$PROJECT_ROOT/lib/rules/dynamic_generator.sh" "cursor" "$output_file" "qa"
    
    [ "$status" -eq 0 ]
    run cat "$output_file"
    assert_contains "$output" "QA Focus"
}
