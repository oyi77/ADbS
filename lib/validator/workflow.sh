#!/bin/bash
# Workflow validator - enforces stage completion and SDD requirements

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

SDD_DIR="${SDD_DIR:-.sdd}"
WORKFLOW_DIR="${WORKFLOW_ENFORCER_DIR:-.workflow-enforcer}"
CONFIG_FILE="${CONFIG_FILE:-$PROJECT_ROOT/config/workflow.yaml}"
CURRENT_STAGE_FILE="$WORKFLOW_DIR/current-stage"
PLANS_DIR="$SDD_DIR/plans"
REQUIREMENTS_DIR="$SDD_DIR/requirements"
DESIGNS_DIR="$SDD_DIR/designs"
TASKS_DIR="$SDD_DIR/tasks"
PLAN_MANAGER="$PROJECT_ROOT/lib/plan_manager.sh"

# Initialize workflow directory
init_workflow() {
    mkdir -p "$SDD_DIR/plans" "$SDD_DIR/requirements" "$SDD_DIR/designs" "$SDD_DIR/tasks"
    mkdir -p "$WORKFLOW_DIR"
    if [ ! -f "$CURRENT_STAGE_FILE" ]; then
        echo "explore" > "$CURRENT_STAGE_FILE"
    fi
    # Initialize plan index if needed
    if [ -f "$PLAN_MANAGER" ]; then
        "$PLAN_MANAGER" generate > /dev/null 2>&1 || true
    fi
}

# Get current stage
get_current_stage() {
    if [ -f "$CURRENT_STAGE_FILE" ]; then
        cat "$CURRENT_STAGE_FILE"
    else
        echo "explore"
    fi
}

# Set current stage
set_current_stage() {
    local stage="$1"
    mkdir -p "$WORKFLOW_DIR"
    
    # Time tracking
    local old_stage="unknown"
    if [ -f "$CURRENT_STAGE_FILE" ]; then
        old_stage=$(cat "$CURRENT_STAGE_FILE")
    fi
    local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    
    # Log transition
    echo "$timestamp | $old_stage -> $stage" >> "$WORKFLOW_DIR/history.log"
    
    echo "$stage" > "$CURRENT_STAGE_FILE"
}

# Check if file exists and has minimum length
check_file_min_length() {
    local file="$1"
    local min_length="${2:-0}"
    
    if [ ! -f "$file" ]; then
        return 1
    fi
    
    local length=$(wc -w < "$file" 2>/dev/null || echo "0")
    if [ "$length" -lt "$min_length" ]; then
        return 1
    fi
    
    return 0
}

# Check if file contains required strings
check_file_contains() {
    local file="$1"
    shift
    local required_strings=("$@")
    
    if [ ! -f "$file" ]; then
        return 1
    fi
    
    for str in "${required_strings[@]}"; do
        if ! grep -qi "$str" "$file" 2>/dev/null; then
            return 1
        fi
    done
    
    return 0
}

# Validate explore stage
validate_explore() {
    # Explore stage doesn't require plan-based structure
    # Check for explore.md in plans directory or workflow directory
    local explore_file="$PLANS_DIR/explore.md"
    if [ ! -f "$explore_file" ]; then
        explore_file="$WORKFLOW_DIR/explore.md"
    fi
    
    if [ ! -f "$explore_file" ]; then
        echo "Error: Exploration notes not found"
        return 1
    fi
    
    if ! check_file_min_length "$explore_file" 100; then
        echo "Error: Exploration notes too short (minimum 100 words)"
        return 1
    fi
    
    echo "Explore stage validated"
    return 0
}

# Validate plan stage
validate_plan() {
    # Check if any plan exists in plans directory
    local plan_count=$(find "$PLANS_DIR" -maxdepth 1 -name "*.md" -type f 2>/dev/null | wc -l | tr -d ' ')
    
    if [ "$plan_count" -eq 0 ]; then
        echo "Error: No plan document found in $PLANS_DIR"
        return 1
    fi
    
    # Check if current plan has minimum length
    local current_plan_id
    if [ -f "$PLAN_MANAGER" ]; then
        current_plan_id=$("$PLAN_MANAGER" current 2>/dev/null)
    fi
    
    if [ -n "$current_plan_id" ]; then
        local plan_file="$PLANS_DIR/${current_plan_id}.md"
        if [ -f "$plan_file" ]; then
            if ! check_file_min_length "$plan_file" 200; then
                echo "Error: Plan document too short (minimum 200 words)"
                return 1
            fi
        fi
    else
        # Check any plan file
        local plan_file=$(find "$PLANS_DIR" -maxdepth 1 -name "*.md" -type f 2>/dev/null | head -n 1)
        if [ -n "$plan_file" ] && [ -f "$plan_file" ]; then
            if ! check_file_min_length "$plan_file" 200; then
                echo "Error: Plan document too short (minimum 200 words)"
                return 1
            fi
        fi
    fi
    
    echo "Plan stage validated"
    return 0
}

# Validate requirements stage
validate_requirements() {
    local current_plan_id
    if [ -f "$PLAN_MANAGER" ]; then
        current_plan_id=$("$PLAN_MANAGER" current 2>/dev/null)
    fi
    
    local req_file
    if [ -n "$current_plan_id" ]; then
        req_file="$REQUIREMENTS_DIR/requirements.${current_plan_id}.md"
    else
        # Fallback: find any requirements file
        req_file=$(find "$REQUIREMENTS_DIR" -maxdepth 1 -name "requirements.plan-*.md" -type f 2>/dev/null | head -n 1)
    fi
    
    if [ -z "$req_file" ] || [ ! -f "$req_file" ]; then
        echo "Error: Requirements document not found for current plan"
        return 1
    fi
    
    if ! check_file_min_length "$req_file" 500; then
        echo "Error: Requirements document too short (minimum 500 words)"
        return 1
    fi
    
    local required_sections=("functional" "non.functional" "requirement")
    if ! check_file_contains "$req_file" "${required_sections[@]}"; then
        echo "Error: Requirements document missing required sections (functional requirements, non-functional requirements)"
        return 1
    fi
    
    echo "Requirements stage validated"
    return 0
}

# Validate design stage
validate_design() {
    local current_plan_id
    if [ -f "$PLAN_MANAGER" ]; then
        current_plan_id=$("$PLAN_MANAGER" current 2>/dev/null)
    fi
    
    local design_file
    if [ -n "$current_plan_id" ]; then
        design_file="$DESIGNS_DIR/design.${current_plan_id}.md"
    else
        # Fallback: find any design file
        design_file=$(find "$DESIGNS_DIR" -maxdepth 1 -name "design.plan-*.md" -type f 2>/dev/null | head -n 1)
    fi
    
    if [ -z "$design_file" ] || [ ! -f "$design_file" ]; then
        echo "Error: Design document not found for current plan"
        return 1
    fi
    
    if ! check_file_min_length "$design_file" 500; then
        echo "Error: Design document too short (minimum 500 words)"
        return 1
    fi
    
    local required_sections=("architecture" "component" "data.flow")
    if ! check_file_contains "$design_file" "${required_sections[@]}"; then
        echo "Error: Design document missing required sections (architecture, components, data flow)"
        return 1
    fi
    
    echo "Design stage validated"
    return 0
}

# Validate tasks stage
validate_tasks() {
    local current_plan_id
    if [ -f "$PLAN_MANAGER" ]; then
        current_plan_id=$("$PLAN_MANAGER" current 2>/dev/null)
    fi
    
    local tasks_file
    if [ -n "$current_plan_id" ]; then
        tasks_file="$TASKS_DIR/tasks.${current_plan_id}.md"
    else
        # Fallback: find any tasks file
        tasks_file=$(find "$TASKS_DIR" -maxdepth 1 -name "tasks.plan-*.md" -type f 2>/dev/null | head -n 1)
    fi
    
    if [ -z "$tasks_file" ] || [ ! -f "$tasks_file" ]; then
        echo "Error: Tasks document not found for current plan"
        return 1
    fi
    
    # Count tasks (look for task patterns)
    local task_count=$(grep -cE "^### Task [0-9]+:" "$tasks_file" 2>/dev/null || echo "0")
    
    if [ "$task_count" -lt 3 ]; then
        echo "Error: Tasks document must contain at least 3 tasks (found $task_count)"
        return 1
    fi
    
    if ! check_file_contains "$tasks_file" "task"; then
        echo "Error: Tasks document missing task list"
        return 1
    fi
    
    echo "Tasks stage validated ($task_count tasks found)"
    return 0
}

# Validate assign stage
validate_assign() {
    local tasks_json="$WORKFLOW_DIR/tasks.json"
    
    # Check if using beads or simple task manager
    if [ -f "$tasks_json" ]; then
        # Check if tasks.json has at least one task
        if command -v jq &> /dev/null; then
            local task_count=$(jq '.tasks | length' "$tasks_json" 2>/dev/null || echo "0")
            if [ "$task_count" -lt 1 ]; then
                echo "Error: At least one task must be created in task manager"
                return 1
            fi
        elif command -v python3 &> /dev/null; then
            local task_count=$(python3 -c "import json; data=json.load(open('$tasks_json')); print(len(data.get('tasks', [])))" 2>/dev/null || echo "0")
            if [ "$task_count" -lt 1 ]; then
                echo "Error: At least one task must be created in task manager"
                return 1
            fi
        else
            # Basic check - look for task entries
            if ! grep -q "\"id\"" "$tasks_json" 2>/dev/null; then
                echo "Error: At least one task must be created in task manager"
                return 1
            fi
        fi
    else
        echo "Error: Task manager not initialized. Create at least one task."
        return 1
    fi
    
    echo "Assign stage validated"
    return 0
}

# Validate execution stage (always passes - execution is ongoing)
validate_execution() {
    echo "Execution stage - validation always passes (work in progress)"
    return 0
}

# Validate current stage
validate_current_stage() {
    init_workflow
    
    local current_stage=$(get_current_stage)
    
    case "$current_stage" in
        explore)
            validate_explore
            ;;
        plan)
            validate_plan
            ;;
        requirements)
            validate_requirements
            ;;
        design)
            validate_design
            ;;
        tasks)
            validate_tasks
            ;;
        assign)
            validate_assign
            ;;
        execution)
            validate_execution
            ;;
        *)
            echo "Error: Unknown stage: $current_stage"
            return 1
            ;;
    esac
}

# Get next stage
get_next_stage() {
    local current_stage="$1"
    
    case "$current_stage" in
        explore)
            echo "plan"
            ;;
        plan)
            echo "requirements"
            ;;
        requirements)
            echo "design"
            ;;
        design)
            echo "tasks"
            ;;
        tasks)
            echo "assign"
            ;;
        assign)
            echo "execution"
            ;;
        execution)
            echo "execution"  # Stay in execution
            ;;
        *)
            echo "explore"
            ;;
    esac
}

# Advance to next stage
advance_stage() {
    local current_stage=$(get_current_stage)
    
    if validate_current_stage; then
        local next_stage=$(get_next_stage "$current_stage")
        set_current_stage "$next_stage"
        echo "Advanced to stage: $next_stage"
        return 0
    else
        echo "Cannot advance: current stage validation failed"
        return 1
    fi
}

# Show status
show_status() {
    init_workflow
    
    local current_stage=$(get_current_stage)
    local current_plan_id
    if [ -f "$PLAN_MANAGER" ]; then
        current_plan_id=$("$PLAN_MANAGER" current 2>/dev/null)
    fi
    
    echo "Current stage: $current_stage"
    if [ -n "$current_plan_id" ]; then
        echo "Current plan: $current_plan_id"
    fi
    echo ""
    echo "SDD Artifacts:"
    echo "  Plans: $(find "$PLANS_DIR" -maxdepth 1 -name "*.md" -type f 2>/dev/null | wc -l | tr -d ' ') file(s)"
    echo "  Requirements: $(find "$REQUIREMENTS_DIR" -maxdepth 1 -name "*.md" -type f 2>/dev/null | wc -l | tr -d ' ') file(s)"
    echo "  Designs: $(find "$DESIGNS_DIR" -maxdepth 1 -name "*.md" -type f 2>/dev/null | wc -l | tr -d ' ') file(s)"
    echo "  Tasks: $(find "$TASKS_DIR" -maxdepth 1 -name "*.md" -type f 2>/dev/null | wc -l | tr -d ' ') file(s)"
    echo ""
    echo "Validation:"
    if validate_current_stage; then
        echo "  ✓ Current stage is valid"
    else
        echo "  ✗ Current stage validation failed"
    fi
}

# Main command handler
case "${1:-}" in
    validate)
        validate_current_stage
        ;;
    next)
        advance_stage
        ;;
    status)
        show_status
        ;;
    current)
        get_current_stage
        ;;
    set)
        shift
        if [ -z "$1" ]; then
            echo "Error: Stage name required"
            exit 1
        fi
        set_current_stage "$1"
        echo "Stage set to: $1"
        ;;
    *)
        echo "Usage: $0 {validate|next|status|current|set <stage>}"
        echo ""
        echo "Commands:"
        echo "  validate  - Validate current stage"
        echo "  next     - Advance to next stage (if validated)"
        echo "  status   - Show current status"
        echo "  current  - Get current stage name"
        echo "  set      - Set stage (use with caution)"
        exit 1
        ;;
esac

