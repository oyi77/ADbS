#!/bin/bash
# Plan ID Management System
# Manages incremental plan IDs and links artifacts to plans

set -e

SDD_DIR="${SDD_DIR:-.sdd}"
PLANS_DIR="$SDD_DIR/plans"
REQUIREMENTS_DIR="$SDD_DIR/requirements"
DESIGNS_DIR="$SDD_DIR/designs"
TASKS_DIR="$SDD_DIR/tasks"
PLAN_INDEX="$PLANS_DIR/.index.json"

# Check dependencies once
HAS_JQ=0
HAS_PYTHON3=0
if command -v jq &> /dev/null; then HAS_JQ=1; fi
if command -v python3 &> /dev/null; then HAS_PYTHON3=1; fi

# Initialize plan index
init_plan_index() {
    mkdir -p "$PLANS_DIR" "$REQUIREMENTS_DIR" "$DESIGNS_DIR" "$TASKS_DIR"
    
    if [ ! -f "$PLAN_INDEX" ]; then
        cat > "$PLAN_INDEX" <<EOF
{
  "next_id": 1,
  "plans": []
}
EOF
    fi
}

# Generate next plan ID
generate_plan_id() {
    init_plan_index
    
    local next_id
    if [ "$HAS_JQ" -eq 1 ]; then
        next_id=$(jq -r '.next_id' "$PLAN_INDEX" 2>/dev/null || echo "1")
    elif [ "$HAS_PYTHON3" -eq 1 ]; then
        next_id=$(python3 -c "import json; data=json.load(open('$PLAN_INDEX')); print(data.get('next_id', 1))" 2>/dev/null || echo "1")
    else
        # Fallback: extract from file
        next_id=$(grep -o '"next_id"[[:space:]]*:[[:space:]]*[0-9]*' "$PLAN_INDEX" 2>/dev/null | grep -o '[0-9]*' || echo "1")
    fi
    
    printf "plan-%03d" "$next_id"
}

# Get current/active plan ID
get_current_plan_id() {
    init_plan_index
    
    if [ "$HAS_JQ" -eq 1 ]; then
        jq -r '.plans[] | select(.status == "active") | .id' "$PLAN_INDEX" 2>/dev/null | head -n 1
    elif [ "$HAS_PYTHON3" -eq 1 ]; then
        python3 <<PYTHON
import json
try:
    with open("$PLAN_INDEX", "r") as f:
        data = json.load(f)
    for plan in data.get("plans", []):
        if plan.get("status") == "active":
            print(plan.get("id", ""))
            exit(0)
except:
    pass
PYTHON
    else
        grep -A 5 '"status"[[:space:]]*:[[:space:]]*"active"' "$PLAN_INDEX" 2>/dev/null | grep -o '"id"[[:space:]]*:[[:space:]]*"[^"]*"' | grep -o 'plan-[^"]*' | head -n 1
    fi
}

# Create a new plan
create_plan() {
    local plan_id=$(generate_plan_id)
    local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ" 2>/dev/null || date -u +"%Y-%m-%d %H:%M:%S")
    
    init_plan_index
    
    # Deactivate all other plans
    if [ "$HAS_JQ" -eq 1 ]; then
        jq '.plans[].status = "inactive" | .plans += [{
      "id": "'"$plan_id"'",
      "created_at": "'"$timestamp"'",
      "status": "active",
      "artifacts": {}
    }] | .next_id += 1' "$PLAN_INDEX" > "${PLAN_INDEX}.tmp" && mv "${PLAN_INDEX}.tmp" "$PLAN_INDEX"
    elif [ "$HAS_PYTHON3" -eq 1 ]; then
        python3 <<PYTHON
import json
from datetime import datetime

with open("$PLAN_INDEX", "r") as f:
    data = json.load(f)

# Deactivate all plans
for plan in data.get("plans", []):
    plan["status"] = "inactive"

# Add new plan
new_plan = {
    "id": "$plan_id",
    "created_at": "$timestamp",
    "status": "active",
    "artifacts": {}
}
data["plans"].append(new_plan)
data["next_id"] = data.get("next_id", 1) + 1

with open("$PLAN_INDEX", "w") as f:
    json.dump(data, f, indent=2)
PYTHON
    else
        echo "Error: jq or python3 required for plan management"
        return 1
    fi
    
    echo "$plan_id"
}

# Link artifact to plan
link_artifact() {
    local plan_id="$1"
    local artifact_type="$2"  # requirements, design, tasks
    local filename="$3"
    
    init_plan_index
    
    if [ "$HAS_JQ" -eq 1 ]; then
        jq --arg plan_id "$plan_id" --arg type "$artifact_type" --arg file "$filename" \
           '(.plans[] | select(.id == $plan_id) | .artifacts[$type]) = $file' \
           "$PLAN_INDEX" > "${PLAN_INDEX}.tmp" && mv "${PLAN_INDEX}.tmp" "$PLAN_INDEX"
    elif [ "$HAS_PYTHON3" -eq 1 ]; then
        python3 <<PYTHON
import json

with open("$PLAN_INDEX", "r") as f:
    data = json.load(f)

for plan in data.get("plans", []):
    if plan.get("id") == "$plan_id":
        if "artifacts" not in plan:
            plan["artifacts"] = {}
        plan["artifacts"]["$artifact_type"] = "$filename"
        break

with open("$PLAN_INDEX", "w") as f:
    json.dump(data, f, indent=2)
PYTHON
    else
        echo "Error: jq or python3 required for plan management"
        return 1
    fi
}

# Get plan artifacts
get_plan_artifacts() {
    local plan_id="$1"
    
    init_plan_index
    
    if [ "$HAS_JQ" -eq 1 ]; then
        jq -r --arg plan_id "$plan_id" '.plans[] | select(.id == $plan_id) | .artifacts' "$PLAN_INDEX" 2>/dev/null
    elif [ "$HAS_PYTHON3" -eq 1 ]; then
        python3 <<PYTHON
import json

with open("$PLAN_INDEX", "r") as f:
    data = json.load(f)

for plan in data.get("plans", []):
    if plan.get("id") == "$plan_id":
        print(json.dumps(plan.get("artifacts", {}), indent=2))
        exit(0)
PYTHON
    else
        echo "{}"
    fi
}

# List all plans
list_plans() {
    init_plan_index
    
    if [ "$HAS_JQ" -eq 1 ]; then
        jq -r '.plans[] | "\(.id) | \(.status) | \(.created_at)"' "$PLAN_INDEX" 2>/dev/null
    elif [ "$HAS_PYTHON3" -eq 1 ]; then
        python3 <<PYTHON
import json

with open("$PLAN_INDEX", "r") as f:
    data = json.load(f)

for plan in data.get("plans", []):
    print(f"{plan.get('id', '')} | {plan.get('status', '')} | {plan.get('created_at', '')}")
PYTHON
    else
        echo "Error: jq or python3 required"
        return 1
    fi
}

# Main command handler
case "${1:-}" in
    generate)
        generate_plan_id
        ;;
    current)
        get_current_plan_id
        ;;
    create)
        create_plan
        ;;
    link)
        shift
        link_artifact "$@"
        ;;
    artifacts)
        shift
        get_plan_artifacts "${1:-}"
        ;;
    list)
        list_plans
        ;;
    get)
        shift
        if [ -f "$PLANS_DIR/$1.md" ]; then
            cat "$PLANS_DIR/$1.md"
        else
            echo "Plan $1 not found"
            exit 1
        fi
        ;;
    *)
        echo "Usage: $0 {generate|current|create|link|artifacts|list|get}"
        echo ""
        echo "Commands:"
        echo "  generate              - Generate next plan ID"
        echo "  current               - Get current active plan ID"
        echo "  create                - Create new plan and return ID"
        echo "  link <id> <type> <file> - Link artifact to plan"
        echo "  artifacts <id>       - Get artifacts for a plan"
        echo "  list                  - List all plans"
        echo "  get <id>              - Get content of a plan"
        exit 1
        ;;
esac

