#!/bin/bash
# Memory System - Adaptive Preference Learning
# Handles project vs global preferences based on usage frequency

set -e

# Config Locations
# Project memory: .adbs/config/memory.conf
# Global memory: ~/.adbs_profile/memory.conf

# Ensure global profile dir exists
GLOBAL_PROFILE_DIR="$HOME/.adbs_profile"
mkdir -p "$GLOBAL_PROFILE_DIR"

PROJECT_MEMORY_FILE="${ADBS_DIR:-.adbs}/config/memory.conf"
GLOBAL_MEMORY_FILE="$GLOBAL_PROFILE_DIR/memory.conf"
PROJECT_COUNTS_FILE="${ADBS_DIR:-.adbs}/config/memory.counts"

# Get a preference value
# Priority: Global > Project
get_preference() {
    local key="$1"
    local value=""
    
    # Check Global first
    if [ -f "$GLOBAL_MEMORY_FILE" ]; then
        value=$(grep "^$key=" "$GLOBAL_MEMORY_FILE" | head -1 | cut -d'=' -f2-)
    fi
    
    # If not found, check Project
    if [ -z "$value" ] && [ -f "$PROJECT_MEMORY_FILE" ]; then
        value=$(grep "^$key=" "$PROJECT_MEMORY_FILE" | head -1 | cut -d'=' -f2-)
    fi
    
    echo "$value"
}

# Remember a preference
# Promotes to global if used > 2 times
remember_preference() {
    local key="$1"
    local value="$2"
    
    if [ -z "$key" ] || [ -z "$value" ]; then
        return 1
    fi
    
    # Ensure project config dir exists
    mkdir -p "$(dirname "$PROJECT_MEMORY_FILE")"
    touch "$PROJECT_MEMORY_FILE"
    touch "$PROJECT_COUNTS_FILE"
    
    # Check if already global
    if [ -f "$GLOBAL_MEMORY_FILE" ] && grep -q "^$key=$value" "$GLOBAL_MEMORY_FILE"; then
        # Already global, nothing to do
        return 0
    fi
    
    # Increment count in project
    local count=0
    # Read existing count
    if grep -q "^$key=" "$PROJECT_COUNTS_FILE"; then
        count=$(grep "^$key=" "$PROJECT_COUNTS_FILE" | cut -d'=' -f2)
    fi
    
    count=$((count + 1))
    
    # Update count
    if grep -q "^$key=" "$PROJECT_COUNTS_FILE"; then
        # Use sed to update (portable version tricky, using temp file)
        grep -v "^$key=" "$PROJECT_COUNTS_FILE" > "$PROJECT_COUNTS_FILE.tmp"
        echo "$key=$count" >> "$PROJECT_COUNTS_FILE.tmp"
        mv "$PROJECT_COUNTS_FILE.tmp" "$PROJECT_COUNTS_FILE"
    else
        echo "$key=$count" >> "$PROJECT_COUNTS_FILE"
    fi
    
    # Save to project memory
    if grep -q "^$key=" "$PROJECT_MEMORY_FILE"; then
        grep -v "^$key=" "$PROJECT_MEMORY_FILE" > "$PROJECT_MEMORY_FILE.tmp"
        echo "$key=$value" >> "$PROJECT_MEMORY_FILE.tmp"
        mv "$PROJECT_MEMORY_FILE.tmp" "$PROJECT_MEMORY_FILE"
    else
        echo "$key=$value" >> "$PROJECT_MEMORY_FILE"
    fi
    
    # Check promotion condition
    if [ "$count" -gt 2 ]; then
        # Promote to Global!
        mkdir -p "$GLOBAL_PROFILE_DIR"
        touch "$GLOBAL_MEMORY_FILE"
        
        if grep -q "^$key=" "$GLOBAL_MEMORY_FILE"; then
            grep -v "^$key=" "$GLOBAL_MEMORY_FILE" > "$GLOBAL_MEMORY_FILE.tmp"
            echo "$key=$value" >> "$GLOBAL_MEMORY_FILE.tmp"
            mv "$GLOBAL_MEMORY_FILE.tmp" "$GLOBAL_MEMORY_FILE"
        else
            echo "$key=$value" >> "$GLOBAL_MEMORY_FILE"
        fi
        
        echo "Information: Preference '$key' promoted to Global Memory (used >2 times)" >&2
    fi
}
# List all preferences
list_preferences() {
    local show_source="${1:-false}"
    
    # Use a temporary file to merge keys
    local temp_keys=$(mktemp)
    
    if [ -f "$GLOBAL_MEMORY_FILE" ]; then
        cut -d'=' -f1 "$GLOBAL_MEMORY_FILE" >> "$temp_keys"
    fi
    
    if [ -f "$PROJECT_MEMORY_FILE" ]; then
        cut -d'=' -f1 "$PROJECT_MEMORY_FILE" >> "$temp_keys"
    fi
    
    sort -u "$temp_keys" | while read -r key; do
        if [ -n "$key" ]; then
            val=$(get_preference "$key")
            if [ "$show_source" = "true" ]; then
                local source="Project"
                if [ -f "$GLOBAL_MEMORY_FILE" ] && grep -q "^$key=" "$GLOBAL_MEMORY_FILE"; then
                    source="Global"
                fi
                echo "$key=$val ($source)"
            else
                echo "$key=$val"
            fi
        fi
    done
    
    rm -f "$temp_keys"
}

# Main execution if called directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    case "${1:-}" in
        get|read)
            shift
            get_preference "$@"
            ;;
        remember|set|write)
            shift
            remember_preference "$@"
            ;;
        list)
            shift
            list_preferences "$@"
            ;;
        *)
            echo "Usage: $0 {get|remember|list} [args...]"
            exit 1
            ;;
    esac
fi
