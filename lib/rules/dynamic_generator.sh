#!/bin/bash
# Dynamic Rules Generator for ADbS
# Part of Phase 3 Optimization

# Function to detect project technology stack
detect_stack() {
    local project_root="$1"
    local stack=""
    
    if [ -f "$project_root/package.json" ]; then
        stack="$stack nodejs"
    fi
    if [ -f "$project_root/requirements.txt" ] || [ -f "$project_root/pyproject.toml" ]; then
        stack="$stack python"
    fi
    if [ -f "$project_root/Cargo.toml" ]; then
        stack="$stack rust"
    fi
    if [ -f "$project_root/go.mod" ]; then
        stack="$stack go"
    fi
    if ls "$project_root"/*.sh >/dev/null 2>&1; then
        stack="$stack bash"
    fi
    
    echo "$stack"
}

# Generate dynamic rule based on platform and context
generate_dynamic_rule() {
    local platform="$1"
    local context="$2" # e.g., "qa", "dev", "architecture"
    local output_file="$3"
    
    echo "Generating dynamic rule for $platform with context ($context)..."
    
    # 1. Start with base platform rule
    local base_rule="# ADbS Rules for $platform\n\n## Core Principles\n- Follow the SDD workflow.\n- Update status after every step.\n"
    echo -e "$base_rule" > "$output_file"
    
    # 2. Detect Stack and append specific rules
    local stack
    stack=$(detect_stack ".")
    
    for tech in $stack; do
        echo "Detected technology: $tech"
        case "$tech" in
            nodejs)
                echo -e "\n## Node.js Guidelines\n- Prefer const over let.\n- Use async/await.\n" >> "$output_file"
                ;;
            python)
                echo -e "\n## Python Guidelines\n- Follow PEP 8.\n- Type hints are required.\n" >> "$output_file"
                ;;
            bash)
                echo -e "\n## Shell Scripting\n- Use set -e.\n- Check exit codes.\n" >> "$output_file"
                ;;
        esac
    done
    
    # 3. Apply Context refinements
    case "$context" in
        "qa")
            echo -e "\n## QA Focus\n- Check edge cases.\n- Validate all inputs.\n" >> "$output_file"
            ;;
        "architecture")
            echo -e "\n## Architecture Focus\n- Consider scalability.\n- Document interfaces.\n" >> "$output_file"
            ;;
    esac
    
    echo "Rule generation complete: $output_file"
}

optimize_rule_size() {
    local rule_file="$1"
    echo "Optimizing $rule_file..."
    # Simple optimization: remove comments and extra newlines
    if [ -f "$rule_file" ]; then
        grep -v '^#' "$rule_file" | tr -s '\n' > "${rule_file}.opt"
        mv "${rule_file}.opt" "$rule_file"
        echo "Optimization complete."
    else
        echo "File $rule_file not found."
    fi
}

# Wrapper to run generation
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    if [ "$#" -lt 2 ]; then
        echo "Usage: $0 <platform> <output_file> [context]"
        exit 1
    fi
    generate_dynamic_rule "$1" "$3" "$2"
fi
