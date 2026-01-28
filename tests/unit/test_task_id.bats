#!/usr/bin/env bats
# Unit tests for ID generation in lib/task_manager/simple.sh

load ../test_helper

setup() {
    setup_test_env
    # Source the library
    source "$PROJECT_ROOT/lib/task_manager/simple.sh"
}

teardown() {
    teardown_test_env
}

@test "generate_id_returns_6_char_string" {
    run generate_id
    [ "$status" -eq 0 ]
    # Debug output if it fails
    echo "Output: $output"
    [ "${#output}" -eq 6 ]
}

@test "generate_id_returns_alphanumeric_string" {
    run generate_id
    [ "$status" -eq 0 ]
    echo "Output: $output"
    # Check regex match for alphanumeric (a-z0-9)
    [[ "$output" =~ ^[a-z0-9]{6}$ ]]
}

@test "generate_hierarchical_id_without_parent" {
    run generate_hierarchical_id ""
    [ "$status" -eq 0 ]
    [[ "$output" =~ ^task-[a-z0-9]{6}$ ]]
}

@test "generate_hierarchical_id_with_parent" {
    init_tasks

    local parent="task-123456"
    run generate_hierarchical_id "$parent"
    [ "$status" -eq 0 ]
    # Expect .1 for the first child
    [ "$output" = "${parent}.1" ]
}

@test "generate_id_is_somewhat_random" {
    # Check that calling it twice produces different results
    local id1=$(generate_id)
    local id2=$(generate_id)
    [ "$id1" != "$id2" ]
}
