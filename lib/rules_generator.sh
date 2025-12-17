#!/bin/bash
# Rules Generator - Auto-detects and generates multiple .mdc files per platform

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
PLATFORM_DETECTOR="$PROJECT_ROOT/lib/platform_detector.sh"
TEMPLATES_DIR="$PROJECT_ROOT/templates/rules"

# Get rules directory for platform
get_rules_dir_for_platform() {
    local platform="$1"
    "$PLATFORM_DETECTOR" rules-dir "$platform"
}

# Check if beads is available
check_beads_available() {
    local beads_binary="${BEADS_BINARY:-$PROJECT_ROOT/bin/beads/bd}"
    [ -f "$beads_binary" ] && [ -x "$beads_binary" ]
}

# Check if task manager is active
check_task_manager_active() {
    local tasks_file="${WORKFLOW_ENFORCER_DIR:-.workflow-enforcer}/tasks.json"
    [ -f "$tasks_file" ] || check_beads_available
}

# Generate rules file from template
generate_rules_file() {
    local output_dir="$1"
    local output_filename="$2"
    local template_path="$3"
    
    local output_file="$output_dir/$output_filename"
    
    if [ ! -f "$template_path" ]; then
        echo "Error: Template not found at $template_path"
        return 1
    fi
    
    if [ ! -d "$output_dir" ]; then
        mkdir -p "$output_dir"
    fi
    
    cp "$template_path" "$output_file"
}

# Generate rules for a platform
generate_platform_rules() {
    local platform="$1"
    local rules_dir=$(get_rules_dir_for_platform "$platform")
    local generated_files=()
    
    # Always generate core rules
    generate_rules_file "$rules_dir" "sdd.mdc" "$TEMPLATES_DIR/sdd.mdc.template" && generated_files+=("sdd.mdc")
    generate_rules_file "$rules_dir" "workflow.mdc" "$TEMPLATES_DIR/workflow.mdc.template" && generated_files+=("workflow.mdc")
    
    # Generate beads rules if available
    if check_beads_available; then
        generate_rules_file "$rules_dir" "beads.mdc" "$TEMPLATES_DIR/beads.mdc.template" && generated_files+=("beads.mdc")
    fi
    
    # Generate task manager rules if active
    if check_task_manager_active; then
        generate_rules_file "$rules_dir" "tasks.mdc" "$TEMPLATES_DIR/beads.mdc.template" && generated_files+=("tasks.mdc")
    fi
    
    # Generate OpenSpec rules if active
    if [ -d "openspec" ]; then
        generate_rules_file "$rules_dir" "openspec.mdc" "$TEMPLATES_DIR/openspec.mdc.template" && generated_files+=("openspec.mdc")
    fi
    
    # Generate platform-specific rules
    local platform_template="$TEMPLATES_DIR/platform-${platform}.mdc.template"
    if [ -f "$platform_template" ]; then
        if [ "$platform" = "cursor" ]; then
             # Cursor uses folder structure: .cursor/rules/<name>/RULE.md
             mkdir -p "$rules_dir/rules/platform"
             generate_rules_file "$rules_dir/rules/platform" "RULE.md" "$platform_template" && generated_files+=("platform/RULE.md")
        elif [ "$platform" = "windsurf" ]; then
             # Windsurf uses .windsurf/rules/*.md
             mkdir -p "$rules_dir/rules"
             generate_rules_file "$rules_dir/rules" "platform.md" "$platform_template" && generated_files+=("rules/platform.md")
        else
             generate_rules_file "$rules_dir" "${platform}.mdc" "$platform_template" && generated_files+=("${platform}.mdc")
        fi
    fi
    
    # Cursor specific handling for standard rules
    if [ "$platform" = "cursor" ]; then
         # Move previously generated flat files to folders
         for file in "${generated_files[@]}"; do
             if [[ "$file" == *.mdc ]]; then
                 local base_name=$(basename "$file" .mdc)
                 mkdir -p "$rules_dir/rules/$base_name"
                 mv "$rules_dir/rules/$file" "$rules_dir/rules/$base_name/RULE.md"
             fi
         done
         # Clear and rebuild list
         generated_files=()
         if [ -f "$rules_dir/rules/sdd/RULE.md" ]; then generated_files+=("sdd/RULE.md"); fi
         if [ -f "$rules_dir/rules/workflow/RULE.md" ]; then generated_files+=("workflow/RULE.md"); fi
         if [ -f "$rules_dir/rules/beads/RULE.md" ]; then generated_files+=("beads/RULE.md"); fi
         if [ -f "$rules_dir/rules/tasks/RULE.md" ]; then generated_files+=("tasks/RULE.md"); fi
         if [ -f "$rules_dir/rules/openspec/RULE.md" ]; then generated_files+=("openspec/RULE.md"); fi
         if [ -f "$rules_dir/rules/platform/RULE.md" ]; then generated_files+=("platform/RULE.md"); fi
    elif [ "$platform" = "windsurf" ]; then
         # Windsurf specific handling - move into rules dir and rename extension
         for file in "${generated_files[@]}"; do
             if [[ "$file" == *.mdc ]]; then
                 local base_name=$(basename "$file" .mdc)
                 mkdir -p "$rules_dir/rules"
                 mv "$rules_dir/$file" "$rules_dir/rules/$base_name.md"
             fi
         done
          # Clear and rebuild list
         generated_files=()
         if [ -f "$rules_dir/rules/sdd.md" ]; then generated_files+=("rules/sdd.md"); fi
         if [ -f "$rules_dir/rules/workflow.md" ]; then generated_files+=("rules/workflow.md"); fi
         if [ -f "$rules_dir/rules/beads.md" ]; then generated_files+=("rules/beads.md"); fi
         if [ -f "$rules_dir/rules/tasks.md" ]; then generated_files+=("rules/tasks.md"); fi
         if [ -f "$rules_dir/rules/openspec.md" ]; then generated_files+=("rules/openspec.md"); fi
         if [ -f "$rules_dir/rules/platform.md" ]; then generated_files+=("rules/platform.md"); fi
    elif [ "$platform" = "zed" ] || [ "$platform" = "trae" ]; then
        # Single file concatenation mode
        local target_file
        if [ "$platform" = "zed" ]; then
            target_file="$rules_dir/.rules"
            # .rules is at root, so rules_dir is .
        else
            mkdir -p "$rules_dir/rules"
            target_file="$rules_dir/rules/project_rules.md"
        fi
        
        echo "# Project Rules" > "$target_file"
        echo "" >> "$target_file"
        
        # Concatenate generated files
        for file in "${generated_files[@]}"; do
            if [[ -f "$rules_dir/$file" ]]; then
                echo "---" >> "$target_file"
                cat "$rules_dir/$file" >> "$target_file"
                echo "" >> "$target_file"
                rm "$rules_dir/$file" # Clean up temporary file
            fi
        done
        
        # Reset generated files list to just the single file
        generated_files=("$target_file")
    fi
    
    echo "${generated_files[@]}"
}

# Generate rules for all detected platforms
generate_all_rules() {
    local platforms
    platforms=$("$PLATFORM_DETECTOR" detect-all)
    
    local all_generated=()
    while IFS= read -r platform; do
        echo "Generating rules for platform: $platform" >&2
        local generated
        generated=$(generate_platform_rules "$platform")
        for file in $generated; do
            all_generated+=("$file")
        done
    done <<< "$platforms"
    
    printf '%s\n' "${all_generated[@]}"
}

# Main command handler
case "${1:-}" in
    generate)
        shift
        if [ -n "$1" ]; then
            # Generate for specific platform
            generate_platform_rules "$1"
        else
            # Generate for all detected platforms
            generate_all_rules
        fi
        ;;
    check)
        # Check what rules would be generated
        echo "Beads available: $(check_beads_available && echo 'yes' || echo 'no')"
        echo "Task manager active: $(check_task_manager_active && echo 'yes' || echo 'no')"
        echo "Detected platforms:"
        "$PLATFORM_DETECTOR" detect-all | while read -r platform; do
            echo "  - $platform"
        done
        ;;
    *)
        echo "Usage: $0 {generate [platform]|check}"
        echo ""
        echo "Commands:"
        echo "  generate [platform]  - Generate rules for platform (or all if not specified)"
        echo "  check                 - Check what rules would be generated"
        exit 1
        ;;
esac

