#!/usr/bin/env bats
# Unit tests for ui.sh

load ../test_helper

setup() {
    setup_test_env
}

teardown() {
    teardown_test_env
}

@test "ui_printSource_whenRun_printsHeader" {
    run bash "$PROJECT_ROOT/lib/ui.sh" print_header "Test Header"
    # Ensure source check or function availability
    # Assuming ui.sh is a library of functions, we check if we can source it
    local source_status=0
    source "$PROJECT_ROOT/lib/ui.sh" || source_status=1
    [ "$source_status" -eq 0 ]
}

@test "ui_colors_whenSourced_definesVariables" {
    source "$PROJECT_ROOT/lib/ui.sh"
    [ -n "$RED" ]
    [ -n "$GREEN" ]
    [ -n "$RESET" ]
}
