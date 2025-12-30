#!/usr/bin/env bats
# Unit tests for template processor

load ../test_helper

setup() {
    setup_test_env
    export TEMPLATE_PROCESSOR="$PROJECT_ROOT/lib/template_processor.sh"
}

teardown() {
    teardown_test_env
}

@test "templateProcessor_detectWorkflow_whenSddExists_returnsSDD" {
    # Arrange
    mkdir -p "$TEST_DIR/.sdd"
    cd "$TEST_DIR"
    
    # Act
    run bash "$TEMPLATE_PROCESSOR" detect-workflow
    
    # Assert
    [ "$status" -eq 0 ]
    [ "$output" = "SDD" ]
}

@test "templateProcessor_detectWorkflow_whenOpenSpecExists_returnsOpenSpec" {
    # Arrange
    mkdir -p "$TEST_DIR/openspec"
    cd "$TEST_DIR"
    
    # Act
    run bash "$TEMPLATE_PROCESSOR" detect-workflow
    
    # Assert
    [ "$status" -eq 0 ]
    [ "$output" = "OpenSpec" ]
}

@test "templateProcessor_detectWorkflow_whenBothExist_returnsHybrid" {
    # Arrange
    mkdir -p "$TEST_DIR/.sdd"
    mkdir -p "$TEST_DIR/openspec"
    cd "$TEST_DIR"
    
    # Act
    run bash "$TEMPLATE_PROCESSOR" detect-workflow
    
    # Assert
    [ "$status" -eq 0 ]
    [ "$output" = "Hybrid" ]
}

@test "templateProcessor_detectWorkflow_whenNoneExist_returnsNone" {
    # Arrange
    cd "$TEST_DIR"
    
    # Act
    run bash "$TEMPLATE_PROCESSOR" detect-workflow
    
    # Assert
    [ "$status" -eq 0 ]
    [ "$output" = "None" ]
}

@test "templateProcessor_processTemplate_substitutesVariables" {
    # Arrange
    local template_file="$TEST_DIR/template.txt"
    local output_file="$TEST_DIR/output.txt"
    
    echo "Project: {{PROJECT_NAME}}" > "$template_file"
    echo "Workflow: {{WORKFLOW}}" >> "$template_file"
    
    mkdir -p "$TEST_DIR/openspec"
    cd "$TEST_DIR"
    
    # Act
    run bash "$TEMPLATE_PROCESSOR" process "$template_file" "$output_file"
    
    # Assert
    [ "$status" -eq 0 ]
    [ -f "$output_file" ]
    assert_contains "$(cat "$output_file")" "Workflow: OpenSpec"
}

@test "templateProcessor_optimize_removesFrontmatter" {
    # Arrange
    local input_file="$TEST_DIR/input.md"
    local output_file="$TEST_DIR/output.md"
    
    cat > "$input_file" << 'EOF'
---
description: Test
---
# Content
Test content
EOF
    
    # Act
    run bash "$TEMPLATE_PROCESSOR" optimize "$input_file" "$output_file"
    
    # Assert
    [ "$status" -eq 0 ]
    ! grep -q "description:" "$output_file"
    grep -q "# Content" "$output_file"
}

@test "templateProcessor_optimize_removesExtraBlankLines" {
    # Arrange
    local input_file="$TEST_DIR/input.md"
    local output_file="$TEST_DIR/output.md"
    
    cat > "$input_file" << 'EOF'
Line 1


Line 2




Line 3
EOF
    
    # Act
    run bash "$TEMPLATE_PROCESSOR" optimize "$input_file" "$output_file"
    
    # Assert
    [ "$status" -eq 0 ]
    local blank_count=$(grep -c "^$" "$output_file" || true)
    [ "$blank_count" -le 4 ]  # Max 2 blanks between lines
}

@test "templateProcessor_optimize_trimsTrailingWhitespace" {
    # Arrange
    local input_file="$TEST_DIR/input.md"
    local output_file="$TEST_DIR/output.md"
    
    echo "Line with trailing spaces    " > "$input_file"
    echo "Another line  " >> "$input_file"
    
    # Act
    run bash "$TEMPLATE_PROCESSOR" optimize "$input_file" "$output_file"
    
    # Assert
    [ "$status" -eq 0 ]
    ! grep -q " $" "$output_file"
}

@test "templateProcessor_processAndOptimize_combinesBoth" {
    # Arrange
    local template_file="$TEST_DIR/template.md"
    local output_file="$TEST_DIR/output.md"
    
    cat > "$template_file" << 'EOF'
---
description: Test
---
# {{PROJECT_NAME}}

Workflow: {{WORKFLOW}}


Extra blank lines
EOF
    
    mkdir -p "$TEST_DIR/.sdd"
    cd "$TEST_DIR"
    
    # Act
    run bash "$TEMPLATE_PROCESSOR" process-optimize "$template_file" "$output_file"
    
    # Assert
    [ "$status" -eq 0 ]
    ! grep -q "description:" "$output_file"
    grep -q "Workflow: SDD" "$output_file"
}

@test "templateProcessor_getVars_showsAllVariables" {
    # Arrange
    mkdir -p "$TEST_DIR/.sdd"
    cd "$TEST_DIR"
    
    # Act
    run bash "$TEMPLATE_PROCESSOR" get-vars
    
    # Assert
    [ "$status" -eq 0 ]
    assert_contains "$output" "PROJECT_NAME="
    assert_contains "$output" "WORKFLOW=SDD"
    assert_contains "$output" "CURRENT_STAGE="
    assert_contains "$output" "HAS_BEADS="
}
