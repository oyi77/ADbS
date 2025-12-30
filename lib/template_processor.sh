#!/bin/bash
# Template Processor for ADbS Rules Generator
# Processes templates with variable substitution

set -e

# Get project name from git or directory
get_project_name() {
    # Try git first
    if git rev-parse --git-dir > /dev/null 2>&1; then
        local repo_url=$(git config --get remote.origin.url 2>/dev/null || echo "")
        if [ -n "$repo_url" ]; then
            # Extract repo name from URL
            basename "$repo_url" .git
            return
        fi
    fi
    
    # Fallback to directory name
    basename "$(pwd)"
}

# Detect current workflow
detect_workflow() {
    if [ -d ".sdd" ] && [ -d "openspec" ]; then
        echo "Hybrid"
    elif [ -d ".sdd" ]; then
        echo "SDD"
    elif [ -d "openspec" ]; then
        echo "OpenSpec"
    else
        echo "None"
    fi
}

# Get current stage
get_current_stage() {
    local stage_file=".workflow-enforcer/current-stage"
    if [ -f "$stage_file" ]; then
        cat "$stage_file"
    else
        echo "Unknown"
    fi
}

# Check if Beads is available
check_beads() {
    local beads_binary="${BEADS_BINARY:-bin/beads/bd}"
    if [ -f "$beads_binary" ] && [ -x "$beads_binary" ]; then
        echo "true"
    else
        echo "false"
    fi
}

# Process template with variable substitution
process_template() {
    local template_file="$1"
    local output_file="$2"
    
    if [ ! -f "$template_file" ]; then
        echo "Error: Template not found: $template_file" >&2
        return 1
    fi
    
    # Gather context variables
    local project_name=$(get_project_name)
    local workflow=$(detect_workflow)
    local current_stage=$(get_current_stage)
    local has_beads=$(check_beads)
    
    # Read template content
    local content=$(cat "$template_file")
    
    # Substitute variables
    content="${content//\{\{PROJECT_NAME\}\}/$project_name}"
    content="${content//\{\{WORKFLOW\}\}/$workflow}"
    content="${content//\{\{CURRENT_STAGE\}\}/$current_stage}"
    content="${content//\{\{HAS_BEADS\}\}/$has_beads}"
    
    # Write processed content
    echo "$content" > "$output_file"
}

# Optimize rules content
optimize_rules() {
    local input_file="$1"
    local output_file="${2:-$input_file}"
    
    if [ ! -f "$input_file" ]; then
        echo "Error: Input file not found: $input_file" >&2
        return 1
    fi
    
    # Create temporary file
    local temp_file=$(mktemp)
    
    # Process the file
    awk '
    BEGIN { 
        in_frontmatter = 0
        blank_count = 0
    }
    
    # Skip YAML frontmatter
    /^---$/ {
        if (NR == 1) {
            in_frontmatter = 1
            next
        } else if (in_frontmatter) {
            in_frontmatter = 0
            next
        }
    }
    
    in_frontmatter { next }
    
    # Remove markdown comments
    /^<!--.*-->$/ { next }
    
    # Handle blank lines (max 2 consecutive)
    /^[[:space:]]*$/ {
        blank_count++
        if (blank_count <= 2) {
            print ""
        }
        next
    }
    
    # Non-blank line
    {
        blank_count = 0
        # Trim trailing whitespace
        sub(/[[:space:]]+$/, "")
        print
    }
    ' "$input_file" > "$temp_file"
    
    # Move optimized content to output
    mv "$temp_file" "$output_file"
}

# Process and optimize template in one step
process_and_optimize() {
    local template_file="$1"
    local output_file="$2"
    
    # Create temporary file for processing
    local temp_file=$(mktemp)
    
    # Process template
    process_template "$template_file" "$temp_file"
    
    # Optimize
    optimize_rules "$temp_file" "$output_file"
    
    # Clean up
    rm -f "$temp_file"
}

# Main command handler
case "${1:-}" in
    process)
        shift
        if [ $# -lt 2 ]; then
            echo "Usage: $0 process <template_file> <output_file>" >&2
            exit 1
        fi
        process_template "$1" "$2"
        ;;
    optimize)
        shift
        if [ $# -lt 1 ]; then
            echo "Usage: $0 optimize <input_file> [output_file]" >&2
            exit 1
        fi
        optimize_rules "$@"
        ;;
    process-optimize)
        shift
        if [ $# -lt 2 ]; then
            echo "Usage: $0 process-optimize <template_file> <output_file>" >&2
            exit 1
        fi
        process_and_optimize "$1" "$2"
        ;;
    detect-workflow)
        detect_workflow
        ;;
    get-vars)
        echo "PROJECT_NAME=$(get_project_name)"
        echo "WORKFLOW=$(detect_workflow)"
        echo "CURRENT_STAGE=$(get_current_stage)"
        echo "HAS_BEADS=$(check_beads)"
        ;;
    *)
        echo "Usage: $0 {process|optimize|process-optimize|detect-workflow|get-vars}" >&2
        echo "" >&2
        echo "Commands:" >&2
        echo "  process <template> <output>           - Process template with variables" >&2
        echo "  optimize <input> [output]              - Optimize rules file" >&2
        echo "  process-optimize <template> <output>   - Process and optimize in one step" >&2
        echo "  detect-workflow                        - Detect current workflow" >&2
        echo "  get-vars                               - Show all template variables" >&2
        exit 1
        ;;
esac
