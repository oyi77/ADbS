#!/bin/bash
# Validator - Enforces work item integrity and completion rules

check_work_integrity() {
    local work_path="$1"
    local errors=0

    # 1. Check Proposal
    if [ ! -f "$work_path/proposal.md" ]; then
        echo "✗ Missing proposal.md"
        errors=$((errors + 1))
    fi

    # 2. Check Tasks
    # If tasks.md exists, verify completion
    if [ -f "$work_path/tasks.md" ]; then
        local incomplete=$(grep -c "\- \[ \]" "$work_path/tasks.md" || echo "0")
        local in_progress=$(grep -c "\- \[/\]" "$work_path/tasks.md" || echo "0")
        
        if [ "$incomplete" -gt 0 ] || [ "$in_progress" -gt 0 ]; then
            echo "✗ Pending tasks found in tasks.md:"
            echo "  - $incomplete to do"
            echo "  - $in_progress in progress"
            errors=$((errors + 1))
        fi
    fi

    # Return result
    if [ $errors -eq 0 ]; then
        return 0
    else
        return 1
    fi
}

validate_completion() {
    local work_path="$1"
    
    echo "Validating work item..."
    
    if check_work_integrity "$work_path"; then
        echo "✓ Validation Passed"
        return 0
    else
        echo ""
        echo "Validation Failed. Please complete all tasks before marking as done."
        return 1
    fi
}
