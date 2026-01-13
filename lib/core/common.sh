#!/bin/bash
# Common core functions for ADbS
# Shared utilities used across shell and PowerShell implementations

# Get script directory
get_script_dir() {
    local script_path="${BASH_SOURCE[0]:-$0}"
    cd "$(dirname "$script_path")" && pwd
}

# Find work directory by name (exact or date-prefixed)
# Usage: find_work_dir <name> [work_dir]
# Returns: path to work directory or empty string if not found
find_work_dir() {
    local name="$1"
    local work_dir="${2:-${ADBS_DIR:-.adbs}/work}"
    
    # Validate input
    if [ -z "$name" ]; then
        return 1
    fi
    
    # Sanitize name to prevent directory traversal
    if [[ "$name" =~ \.\. ]] || [[ "$name" =~ ^/ ]]; then
        return 1
    fi
    
    # 1. Exact match
    if [ -d "$work_dir/$name" ]; then
        echo "$work_dir/$name"
        return 0
    fi
    
    # 2. Date-prefixed match (YYYY-MM-DD-name)
    if [ -d "$work_dir" ]; then
        for path in "$work_dir"/*-"$name"; do
            if [ -d "$path" ]; then
                echo "$path"
                return 0
            fi
        done
    fi
    
    return 1
}

# Validate JSON file exists and is readable
validate_json_file() {
    local file="$1"
    
    if [ -z "$file" ]; then
        return 1
    fi
    
    if [ ! -f "$file" ]; then
        return 1
    fi
    
    if [ ! -r "$file" ]; then
        return 1
    fi
    
    return 0
}

# Safely read JSON key with error handling
safe_json_get_key() {
    local file="$1"
    local key="$2"
    local default="${3:-}"
    
    if ! validate_json_file "$file"; then
        echo "$default"
        return 1
    fi
    
    _detect_json_processor
    local processor="$_JSON_PROCESSOR_CACHE"

    if [ "$processor" = "none" ]; then
        echo "$default"
        return 1
    fi
    
    if [ "$processor" = "jq" ]; then
        local result
        result=$(jq -r ".$key // \"$default\"" "$file" 2>&1)
        if [ $? -eq 0 ] && [ "$result" != "null" ]; then
            echo "$result"
            return 0
        fi
    elif [ "$processor" = "python3" ]; then
        local result
        result=$(python3 -c "import json, sys; data=json.load(open('$file')); print(data.get('$key', '$default'))" 2>&1)
        if [ $? -eq 0 ]; then
            echo "$result"
            return 0
        fi
    fi
    
    echo "$default"
    return 1
}

# Safely write JSON with atomic operation and retry logic
safe_json_write() {
    local file="$1"
    local json_content="$2"
    local max_retries="${3:-3}"
    local retry_count=0
    
    if [ -z "$file" ] || [ -z "$json_content" ]; then
        return 1
    fi
    
    # Validate path
    if ! validate_path "$file"; then
        return 1
    fi
    
    local dir=$(dirname "$file")
    if [ ! -d "$dir" ]; then
        if ! ensure_dir_safe "$dir"; then
            return 1
        fi
    fi
    
    # Retry loop for file operations
    while [ $retry_count -lt $max_retries ]; do
        # Write to temp file first
        local temp_file="${file}.tmp.$$"
        if echo "$json_content" > "$temp_file" 2>&1; then
            # Validate JSON before moving
            local validation_failed=0
            _detect_json_processor
            local processor="$_JSON_PROCESSOR_CACHE"

            if [ "$processor" = "jq" ]; then
                if ! jq . "$temp_file" > /dev/null 2>&1; then
                    validation_failed=1
                fi
            elif [ "$processor" = "python3" ]; then
                if ! python3 -m json.tool "$temp_file" > /dev/null 2>&1; then
                    validation_failed=1
                fi
            fi
            
            if [ $validation_failed -eq 1 ]; then
                rm -f "$temp_file"
                return 1
            fi
            
            # Atomic move
            if mv "$temp_file" "$file" 2>&1; then
                return 0
            else
                rm -f "$temp_file"
                retry_count=$((retry_count + 1))
                sleep 0.1
                continue
            fi
        else
            retry_count=$((retry_count + 1))
            sleep 0.1
            continue
        fi
    done
    
    return 1
}

# Validate path to prevent directory traversal
validate_path() {
    local path="$1"
    local base_dir="${2:-}"
    
    if [ -z "$path" ]; then
        return 1
    fi
    
    # Check for directory traversal attempts
    if [[ "$path" =~ \.\. ]]; then
        return 1
    fi
    
    # If base_dir specified, ensure path is within it
    if [ -n "$base_dir" ]; then
        local resolved_path
        resolved_path=$(cd "$base_dir" && realpath "$path" 2>/dev/null)
        local resolved_base
        resolved_base=$(cd "$base_dir" && pwd)
        if [[ "$resolved_path" != "$resolved_base"/* ]]; then
            return 1
        fi
    fi
    
    return 0
}

# Ensure directory exists with error handling
ensure_dir_safe() {
    local dir="$1"
    
    if [ -z "$dir" ]; then
        return 1
    fi
    
    if ! validate_path "$dir"; then
        return 1
    fi
    
    if [ ! -d "$dir" ]; then
        mkdir -p "$dir" || return 1
    fi
    
    return 0
}

# Check if command exists
command_exists() {
    local cmd="$1"
    command -v "$cmd" &> /dev/null
}

# Detect JSON processor and set cache
_detect_json_processor() {
    if [ -n "${_JSON_PROCESSOR_CACHE:-}" ]; then
        return 0
    fi

    if command_exists jq; then
        export _JSON_PROCESSOR_CACHE="jq"
    elif command_exists python3; then
        export _JSON_PROCESSOR_CACHE="python3"
    else
        export _JSON_PROCESSOR_CACHE="none"
    fi
}

# Get JSON processor (jq, python3, or none)
get_json_processor() {
    _detect_json_processor

    if [ "$_JSON_PROCESSOR_CACHE" = "none" ]; then
        return 1
    fi
    echo "$_JSON_PROCESSOR_CACHE"
    return 0
}

# Auto-detect on source to ensure subshells inherit the cache
_detect_json_processor
