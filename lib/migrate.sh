#!/bin/bash
# Migration utility - converts .workflow-enforcer/ to .sdd/ structure

set -e

OLD_WORKFLOW_DIR=".workflow-enforcer"
OLD_ARTIFACTS_DIR="$OLD_WORKFLOW_DIR/artifacts"
NEW_SDD_DIR=".sdd"
NEW_PLANS_DIR="$NEW_SDD_DIR/plans"
NEW_REQUIREMENTS_DIR="$NEW_SDD_DIR/requirements"
NEW_DESIGNS_DIR="$NEW_SDD_DIR/designs"
NEW_TASKS_DIR="$NEW_SDD_DIR/tasks"
PLAN_MANAGER="lib/plan_manager.sh"

# Check if migration is needed
check_migration_needed() {
    if [ ! -d "$OLD_ARTIFACTS_DIR" ]; then
        echo "No old structure found. Migration not needed."
        return 1
    fi
    
    if [ -d "$NEW_SDD_DIR" ] && [ "$(ls -A $NEW_SDD_DIR 2>/dev/null)" ]; then
        echo "New structure already exists. Migration may overwrite data."
        read -p "Continue? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            return 1
        fi
    fi
    
    return 0
}

# Create new directory structure
create_new_structure() {
    mkdir -p "$NEW_PLANS_DIR" "$NEW_REQUIREMENTS_DIR" "$NEW_DESIGNS_DIR" "$NEW_TASKS_DIR"
    echo "Created new SDD directory structure"
}

# Migrate artifacts
migrate_artifacts() {
    local plan_id
    
    # Check if plan manager exists and create a plan
    if [ -f "$PLAN_MANAGER" ]; then
        plan_id=$("$PLAN_MANAGER" create 2>/dev/null || echo "plan-001")
    else
        plan_id="plan-001"
    fi
    
    echo "Using plan ID: $plan_id"
    
    # Migrate explore.md or plan.md to plans/
    if [ -f "$OLD_ARTIFACTS_DIR/explore.md" ]; then
        cp "$OLD_ARTIFACTS_DIR/explore.md" "$NEW_PLANS_DIR/explore.md"
        echo "Migrated explore.md to $NEW_PLANS_DIR/"
    fi
    
    if [ -f "$OLD_ARTIFACTS_DIR/plan.md" ]; then
        cp "$OLD_ARTIFACTS_DIR/plan.md" "$NEW_PLANS_DIR/${plan_id}.md"
        echo "Migrated plan.md to $NEW_PLANS_DIR/${plan_id}.md"
    fi
    
    # Migrate requirements.md
    if [ -f "$OLD_ARTIFACTS_DIR/requirements.md" ]; then
        cp "$OLD_ARTIFACTS_DIR/requirements.md" "$NEW_REQUIREMENTS_DIR/requirements.${plan_id}.md"
        if [ -f "$PLAN_MANAGER" ]; then
            "$PLAN_MANAGER" link "$plan_id" "requirements" "requirements.${plan_id}.md" 2>/dev/null || true
        fi
        echo "Migrated requirements.md to $NEW_REQUIREMENTS_DIR/requirements.${plan_id}.md"
    fi
    
    # Migrate design.md
    if [ -f "$OLD_ARTIFACTS_DIR/design.md" ]; then
        cp "$OLD_ARTIFACTS_DIR/design.md" "$NEW_DESIGNS_DIR/design.${plan_id}.md"
        if [ -f "$PLAN_MANAGER" ]; then
            "$PLAN_MANAGER" link "$plan_id" "design" "design.${plan_id}.md" 2>/dev/null || true
        fi
        echo "Migrated design.md to $NEW_DESIGNS_DIR/design.${plan_id}.md"
    fi
    
    # Migrate tasks.md
    if [ -f "$OLD_ARTIFACTS_DIR/tasks.md" ]; then
        cp "$OLD_ARTIFACTS_DIR/tasks.md" "$NEW_TASKS_DIR/tasks.${plan_id}.md"
        if [ -f "$PLAN_MANAGER" ]; then
            "$PLAN_MANAGER" link "$plan_id" "tasks" "tasks.${plan_id}.md" 2>/dev/null || true
        fi
        echo "Migrated tasks.md to $NEW_TASKS_DIR/tasks.${plan_id}.md"
    fi
    
    # Migrate tasks.json if it exists
    if [ -f "$OLD_WORKFLOW_DIR/tasks.json" ]; then
        cp "$OLD_WORKFLOW_DIR/tasks.json" "$OLD_WORKFLOW_DIR/tasks.json.backup"
        echo "Backed up tasks.json"
    fi
}

# Main migration
main() {
    echo "ADbS Migration Utility"
    echo "======================"
    echo ""
    
    if ! check_migration_needed; then
        exit 0
    fi
    
    echo "Starting migration..."
    echo ""
    
    create_new_structure
    migrate_artifacts
    
    echo ""
    echo "Migration complete!"
    echo ""
    echo "Old artifacts are preserved in: $OLD_ARTIFACTS_DIR"
    echo "New structure is in: $NEW_SDD_DIR"
    echo ""
    echo "You can safely remove $OLD_ARTIFACTS_DIR after verifying the migration."
}

main "$@"

