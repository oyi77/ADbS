#!/usr/bin/env bats
# Unit tests for lib/core/common.sh

load ../test_helper

setup() {
    setup_test_env
    source "$PROJECT_ROOT/lib/core/common.sh"
}

teardown() {
    teardown_test_env
}

@test "common_findWorkDir_whenExactMatch_returnsPath" {
    local work_dir="$TEMP_DIR/work"
    mkdir -p "$work_dir/test-work"
    
    run find_work_dir "test-work" "$work_dir"
    [ "$status" -eq 0 ]
    [ "$output" = "$work_dir/test-work" ]
}

@test "common_findWorkDir_whenDatePrefixed_returnsPath" {
    local work_dir="$TEMP_DIR/work"
    mkdir -p "$work_dir/2025-01-15-test-work"
    
    run find_work_dir "test-work" "$work_dir"
    [ "$status" -eq 0 ]
    [ "$output" = "$work_dir/2025-01-15-test-work" ]
}

@test "common_findWorkDir_whenNotFound_returnsError" {
    local work_dir="$TEMP_DIR/work"
    mkdir -p "$work_dir"
    
    run find_work_dir "nonexistent" "$work_dir"
    [ "$status" -ne 0 ]
    [ -z "$output" ]
}

@test "common_findWorkDir_whenPathTraversal_rejectsInput" {
    local work_dir="$TEMP_DIR/work"
    mkdir -p "$work_dir"
    
    run find_work_dir "../etc" "$work_dir"
    [ "$status" -ne 0 ]
    
    run find_work_dir "/etc/passwd" "$work_dir"
    [ "$status" -ne 0 ]
}

@test "common_validateJsonFile_whenValid_returnsSuccess" {
    local json_file="$TEMP_DIR/test.json"
    echo '{"key": "value"}' > "$json_file"
    
    run validate_json_file "$json_file"
    [ "$status" -eq 0 ]
}

@test "common_validateJsonFile_whenMissing_returnsError" {
    run validate_json_file "$TEMP_DIR/nonexistent.json"
    [ "$status" -ne 0 ]
}

@test "common_safeJsonGetKey_whenValid_returnsValue" {
    local json_file="$TEMP_DIR/test.json"
    echo '{"key": "value"}' > "$json_file"
    
    if command_exists jq || command_exists python3; then
        run safe_json_get_key "$json_file" "key"
        [ "$status" -eq 0 ]
        [ "$output" = "value" ]
    else
        skip "jq or python3 required"
    fi
}

@test "common_safeJsonGetKey_whenMissingKey_returnsDefault" {
    local json_file="$TEMP_DIR/test.json"
    echo '{"key": "value"}' > "$json_file"
    
    if command_exists jq || command_exists python3; then
        run safe_json_get_key "$json_file" "missing" "default"
        [ "$status" -eq 0 ]
        [ "$output" = "default" ]
    else
        skip "jq or python3 required"
    fi
}

@test "common_safeJsonWrite_whenValid_writesFile" {
    local json_file="$TEMP_DIR/test.json"
    local json_content='{"test": "data"}'
    
    if command_exists jq || command_exists python3; then
        run safe_json_write "$json_file" "$json_content"
        [ "$status" -eq 0 ]
        [ -f "$json_file" ]
    else
        skip "jq or python3 required"
    fi
}

@test "common_safeJsonWrite_whenInvalidJson_rejects" {
    local json_file="$TEMP_DIR/test.json"
    local invalid_json='{invalid json}'
    
    if command_exists jq || command_exists python3; then
        run safe_json_write "$json_file" "$invalid_json"
        [ "$status" -ne 0 ]
        [ ! -f "$json_file" ]
    else
        skip "jq or python3 required"
    fi
}

@test "common_validatePath_whenValid_returnsSuccess" {
    run validate_path "test/path"
    [ "$status" -eq 0 ]
}

@test "common_validatePath_whenPathTraversal_rejects" {
    run validate_path "../etc/passwd"
    [ "$status" -ne 0 ]
    
    run validate_path "../../../etc"
    [ "$status" -ne 0 ]
}

@test "common_ensureDirSafe_whenValid_createsDir" {
    local test_dir="$TEMP_DIR/new_dir"
    
    run ensure_dir_safe "$test_dir"
    [ "$status" -eq 0 ]
    [ -d "$test_dir" ]
}

@test "common_ensureDirSafe_whenPathTraversal_rejects" {
    run ensure_dir_safe "../../etc"
    [ "$status" -ne 0 ]
}

@test "common_commandExists_whenExists_returnsSuccess" {
    run command_exists "bash"
    [ "$status" -eq 0 ]
}

@test "common_commandExists_whenMissing_returnsError" {
    run command_exists "nonexistent_command_xyz123"
    [ "$status" -ne 0 ]
}

@test "common_getJsonProcessor_whenJqAvailable_returnsJq" {
    if command_exists jq; then
        run get_json_processor
        [ "$status" -eq 0 ]
        [ "$output" = "jq" ]
    else
        skip "jq not available"
    fi
}

@test "common_getJsonProcessor_whenPython3Available_returnsPython3" {
    if command_exists python3 && ! command_exists jq; then
        run get_json_processor
        [ "$status" -eq 0 ]
        [ "$output" = "python3" ]
    else
        skip "python3 not available or jq takes precedence"
    fi
}

