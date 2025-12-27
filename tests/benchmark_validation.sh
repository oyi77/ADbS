#!/bin/bash
# Benchmark validate_execution

export WORKFLOW_ENFORCER_DIR="tests/benchmark_data/.workflow-enforcer"
mkdir -p "$WORKFLOW_ENFORCER_DIR"

# Create a dummy tasks.json
cat > "$WORKFLOW_ENFORCER_DIR/tasks.json" <<EOF
{
  "tasks": [
    {"id": "1", "status": "completed"},
    {"id": "2", "status": "completed"},
    {"id": "3", "status": "in_progress"},
    {"id": "4", "status": "todo"},
    {"id": "5", "status": "todo"},
    {"id": "6", "status": "completed"},
    {"id": "7", "status": "completed"},
    {"id": "8", "status": "in_progress"},
    {"id": "9", "status": "todo"},
    {"id": "10", "status": "todo"}
  ]
}
EOF

source lib/validator/workflow.sh

# Mock return functions to avoid noise
validate_explore() { return 0; }
validate_plan() { return 0; }
validate_requirements() { return 0; }
validate_design() { return 0; }
validate_tasks() { return 0; }
validate_assign() { return 0; }

# Time the validation
START=$(date +%s%N)
# Run 50 times to see measurable difference
for i in {1..50}; do
    validate_execution > /dev/null
done
END=$(date +%s%N)
DIFF=$(( (END - START) / 1000000 ))
echo "Time taken: ${DIFF}ms"
