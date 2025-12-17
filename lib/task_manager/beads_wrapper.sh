#!/bin/bash
# Beads wrapper - attempts to use beads binary, falls back to simple task manager

set -e

BEADS_BINARY="${BEADS_BINARY:-bin/beads/bd}"
SIMPLE_MANAGER="lib/task_manager/simple.sh"
WORKFLOW_DIR="${WORKFLOW_ENFORCER_DIR:-.workflow-enforcer}"

# Check if beads binary exists and is executable
check_beads() {
    if [ -f "$BEADS_BINARY" ] && [ -x "$BEADS_BINARY" ]; then
        return 0
    fi
    return 1
}

# Use beads if available, otherwise fall back to simple manager
if check_beads; then
    # Use beads binary
    exec "$BEADS_BINARY" "$@"
else
    # Fall back to simple task manager
    # Set WORKFLOW_ENFORCER_DIR for simple.sh
    export WORKFLOW_ENFORCER_DIR="$WORKFLOW_DIR"
    
    # Map beads commands to simple.sh commands
    case "${1:-}" in
        create)
            shift
            # beads: bd create "description" --priority 1
            # simple: simple.sh create "description" priority
            local description=""
            local priority="medium"
            local parent=""
            
            while [ $# -gt 0 ]; do
                case "$1" in
                    --priority)
                        shift
                        case "$1" in
                            1) priority="high" ;;
                            2) priority="medium" ;;
                            3) priority="low" ;;
                            4) priority="low" ;;
                            *) priority="$1" ;;
                        esac
                        shift
                        ;;
                    --parent)
                        shift
                        parent="$1"
                        shift
                        ;;
                    *)
                        if [ -z "$description" ]; then
                            description="$1"
                        fi
                        shift
                        ;;
                esac
            done
            
            "$SIMPLE_MANAGER" create "$description" "$priority" "$parent"
            ;;
        list)
            shift
            local status=""
            local priority=""
            
            while [ $# -gt 0 ]; do
                case "$1" in
                    --status)
                        shift
                        status="$1"
                        shift
                        ;;
                    --priority)
                        shift
                        priority="$1"
                        shift
                        ;;
                    *)
                        shift
                        ;;
                esac
            done
            
            "$SIMPLE_MANAGER" list "$status" "$priority"
            ;;
        update)
            shift
            local id="$1"
            shift
            
            local field=""
            local value=""
            
            while [ $# -gt 0 ]; do
                case "$1" in
                    --status)
                        field="status"
                        shift
                        value="$1"
                        shift
                        ;;
                    --priority)
                        field="priority"
                        shift
                        case "$1" in
                            1) value="high" ;;
                            2) value="medium" ;;
                            3) value="low" ;;
                            4) value="low" ;;
                            *) value="$1" ;;
                        esac
                        shift
                        ;;
                    --description)
                        field="description"
                        shift
                        value="$1"
                        shift
                        ;;
                    *)
                        shift
                        ;;
                esac
            done
            
            if [ -n "$field" ] && [ -n "$value" ]; then
                "$SIMPLE_MANAGER" update "$id" "$field" "$value"
            else
                echo "Error: Must specify field and value"
                exit 1
            fi
            ;;
        show|get)
            shift
            "$SIMPLE_MANAGER" get "$@"
            ;;
        delete|rm)
            shift
            "$SIMPLE_MANAGER" delete "$@"
            ;;
        export)
            shift
            "$SIMPLE_MANAGER" export "$@"
            ;;
        import)
            shift
            "$SIMPLE_MANAGER" import "$@"
            ;;
        tree)
            shift
            "$SIMPLE_MANAGER" tree "$@"
            ;;
        report)
            shift
            "$SIMPLE_MANAGER" report "$@"
            ;;
        *)
            echo "Beads wrapper - using simple task manager (beads binary not found)"
            echo ""
            echo "Usage: $0 {create|list|update|show|delete|export|import} [args]"
            echo ""
            echo "Commands:"
            echo "  create <description> [--priority 1-4] [--parent <id>]"
            echo "  list [--status <status>] [--priority <priority>]"
            echo "  update <id> [--status <status>] [--priority <priority>] [--description <desc>]"
            echo "  show <id>"
            echo "  delete <id>"
            echo "  export [file]"
            echo "  import [file]"
            exit 1
            ;;
    esac
fi

