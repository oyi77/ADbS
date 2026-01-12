#!/usr/bin/env bash
# Test helper functions for ADbS test suite

# Set up test environment
setup_test_env() {
    export TEST_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"
    export PROJECT_ROOT="$(cd "$TEST_DIR/.." && pwd)"
    export TEMP_DIR="$(mktemp -d)"
    export WORKFLOW_ENFORCER_DIR="$TEMP_DIR/.workflow-enforcer"
    export SDD_DIR="$TEMP_DIR/.sdd"
    
    # Create necessary directories
    mkdir -p "$WORKFLOW_ENFORCER_DIR"
    mkdir -p "$SDD_DIR/plans"
    mkdir -p "$SDD_DIR/requirements"
    mkdir -p "$SDD_DIR/designs"
    mkdir -p "$SDD_DIR/tasks"
}

# Clean up test environment
teardown_test_env() {
    if [ -n "$TEMP_DIR" ] && [ -d "$TEMP_DIR" ]; then
        rm -rf "$TEMP_DIR"
    fi
}

# Create a sample plan file for testing
create_sample_plan() {
    local plan_id="${1:-plan-001}"
    local plan_file="$SDD_DIR/plans/$plan_id.md"
    
    cat > "$plan_file" << 'EOF'
# Sample Plan

## Objective
This is a sample plan for testing purposes.

## Strategy
We will implement the following approach:
1. Step one
2. Step two
3. Step three

## Success Criteria
- Criterion 1
- Criterion 2
- Criterion 3

## Additional Content
This plan contains enough content to pass the minimum word count validation.
We need to ensure that the plan is comprehensive and well-documented.
The plan should outline the high-level objectives and approach for the project.
It should provide enough detail to guide the requirements and design phases.
This additional content helps meet the minimum word count requirement.
EOF
}

# Create a sample requirements file for testing
create_sample_requirements() {
    local plan_id="${1:-plan-001}"
    local req_file="$SDD_DIR/requirements/requirements.$plan_id.md"
    
    cat > "$req_file" << 'EOF'
# Requirements

## Functional Requirements

### FR-1: User Authentication
The system shall provide user authentication functionality.

**Acceptance Criteria:**
- Users can log in with username and password
- Invalid credentials are rejected
- Successful login creates a session

### FR-2: Data Management
The system shall allow users to manage their data.

**Acceptance Criteria:**
- Users can create new records
- Users can update existing records
- Users can delete records

## Non-Functional Requirements

### NFR-1: Performance
The system shall respond to user requests within 2 seconds.

### NFR-2: Security
The system shall encrypt all sensitive data.

### NFR-3: Scalability
The system shall support up to 1000 concurrent users.

## Constraints
- Must use existing authentication infrastructure
- Must comply with data protection regulations

## Assumptions
- Users have modern web browsers
- Network connectivity is reliable

This requirements document provides comprehensive coverage of the system needs.
It includes both functional and non-functional requirements with clear acceptance criteria.
The document is structured to facilitate review and validation by stakeholders.
Additional detail ensures the requirements are unambiguous and testable.
This content helps meet the minimum word count requirement for validation.
EOF
}

# Create a sample design file for testing
create_sample_design() {
    local plan_id="${1:-plan-001}"
    local design_file="$SDD_DIR/designs/design.$plan_id.md"
    
    cat > "$design_file" << 'EOF'
# Design Document

## Architecture

### System Components
1. Frontend Layer
2. API Layer
3. Database Layer

### Component Interactions
The frontend communicates with the API layer via REST endpoints.
The API layer interacts with the database for data persistence.

## Data Flow

### User Request Flow
1. User initiates action in UI
2. Frontend sends API request
3. API processes request
4. Database query/update
5. Response returned to user

## Technology Choices

### Frontend
- Framework: React
- Rationale: Component-based architecture, large ecosystem

### Backend
- Framework: Node.js/Express
- Rationale: JavaScript full-stack, async I/O

### Database
- Type: PostgreSQL
- Rationale: ACID compliance, robust feature set

## Security Considerations
- Authentication via JWT tokens
- HTTPS for all communications
- Input validation and sanitization
- SQL injection prevention

## Error Handling
- Graceful degradation
- User-friendly error messages
- Logging for debugging

This design document provides technical details for implementation.
It covers architecture, data flow, technology choices, and important considerations.
The document serves as a blueprint for the development team.
Additional detail ensures all technical decisions are documented and justified.
This content helps meet the minimum word count requirement for validation.
EOF
}

# Create a sample tasks file for testing
create_sample_tasks() {
    local plan_id="${1:-plan-001}"
    local tasks_file="$SDD_DIR/tasks/tasks.$plan_id.md"
    
    cat > "$tasks_file" << 'EOF'
# Tasks

## Phase 1: Setup
- [ ] Task 1.1: Set up development environment
- [ ] Task 1.2: Configure version control
- [ ] Task 1.3: Initialize project structure

## Phase 2: Implementation
- [ ] Task 2.1: Implement authentication
- [ ] Task 2.2: Create database schema
- [ ] Task 2.3: Build API endpoints

## Phase 3: Testing
- [ ] Task 3.1: Write unit tests
- [ ] Task 3.2: Perform integration testing
- [ ] Task 3.3: Conduct user acceptance testing
EOF
}

# Assert file exists
assert_file_exists() {
    local file="$1"
    if [ ! -f "$file" ]; then
        echo "Expected file does not exist: $file" >&2
        return 1
    fi
}

# Assert directory exists
assert_dir_exists() {
    local dir="$1"
    if [ ! -d "$dir" ]; then
        echo "Expected directory does not exist: $dir" >&2
        return 1
    fi
}

# Assert string contains substring
assert_contains() {
    local haystack="$1"
    local needle="$2"
    if [[ ! "$haystack" == *"$needle"* ]]; then
        echo "Expected '$haystack' to contain '$needle'" >&2
        return 1
    fi
}

# Load fixture file
load_fixture() {
    local fixture_path="$1"
    local full_path="$TEST_DIR/fixtures/$fixture_path"
    
    if [ ! -f "$full_path" ]; then
        echo "Fixture file not found: $full_path" >&2
        return 1
    fi
    
    cat "$full_path"
}

# Copy fixture directory to temp location
copy_fixture_dir() {
    local fixture_name="$1"
    local dest_dir="${2:-$TEMP_DIR}"
    local fixture_path="$TEST_DIR/fixtures/$fixture_name"
    
    if [ ! -d "$fixture_path" ]; then
        echo "Fixture directory not found: $fixture_path" >&2
        return 1
    fi
    
    cp -r "$fixture_path" "$dest_dir/"
    echo "$dest_dir/$(basename "$fixture_path")"
}

# Load task fixture
load_task_fixture() {
    local fixture_name="$1"
    load_fixture "tasks/${fixture_name}.json"
}

# Setup SDD project fixture
setup_sdd_fixture() {
    local project_dir="$TEMP_DIR/test_project"
    copy_fixture_dir "sample_sdd_project" "$TEMP_DIR"
    mv "$TEMP_DIR/sample_sdd_project" "$project_dir"
    echo "$project_dir"
}

# Setup OpenSpec project fixture
setup_openspec_fixture() {
    local project_dir="$TEMP_DIR/test_project"
    copy_fixture_dir "sample_openspec_project" "$TEMP_DIR"
    mv "$TEMP_DIR/sample_openspec_project" "$project_dir"
    echo "$project_dir"
}

# Mock IDE environment
mock_ide_env() {
    local ide_name="$1"
    local ide_config=$(load_fixture "ide_configs/${ide_name}.json")
    
    if [ -z "$ide_config" ]; then
        echo "IDE config not found for: $ide_name" >&2
        return 1
    fi
    
    export MOCK_IDE="$ide_name"
    export MOCK_IDE_CONFIG="$ide_config"
}

# Assert JSON contains key
assert_json_key() {
    local json="$1"
    local key="$2"
    
    if ! echo "$json" | grep -q "\"$key\""; then
        echo "Expected JSON to contain key: $key" >&2
        return 1
    fi
}

# Assert task status
assert_task_status() {
    local task_json="$1"
    local task_id="$2"
    local expected_status="$3"
    
    local actual_status=$(echo "$task_json" | grep -A 10 "\"id\": \"$task_id\"" | grep "\"status\"" | cut -d'"' -f4)
    
    if [ "$actual_status" != "$expected_status" ]; then
        echo "Expected task $task_id to have status '$expected_status', got '$actual_status'" >&2
        return 1
    fi
}
