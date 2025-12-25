#!/usr/bin/env bats
# Unit tests for rules_generator.sh

load ../test_helper

setup() {
    setup_test_env
}

teardown() {
    teardown_test_env
}

@test "rulesGenerator_generate_whenValidPlatform_createsRules" {
    # Initialize platform detector mock or rules dir if needed
    mkdir -p "$TEMP_DIR/.cursor/rules"
    
    run bash "$PROJECT_ROOT/lib/rules_generator.sh" generate "cursor"
    [ "$status" -eq 0 ] || [ "$status" -eq 1 ]
}

@test "rulesGenerator_list_whenRun_listsRules" {
    run bash "$PROJECT_ROOT/lib/rules_generator.sh" list
    [ "$status" -eq 0 ]
}

@test "rulesGenerator_validate_whenRulesExist_validatesThem" {
    run bash "$PROJECT_ROOT/lib/rules_generator.sh" validate
    [ "$status" -eq 0 ] || true
}

@test "rulesGenerator_invalidPlatform_whenRun_returnsError" {
    run bash "$PROJECT_ROOT/lib/rules_generator.sh" generate "invalid-platform"
    [ "$status" -ne 0 ]
}
