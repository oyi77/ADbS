#!/bin/bash
# OpenSpec Implementation for ADbS
# Provides native support for Fission-AI/OpenSpec workflow

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OPENSPEC_ROOT=".openspec"

# Initialize OpenSpec directory structure
init_openspec() {
    if [ -d "$OPENSPEC_ROOT" ]; then
        echo "OpenSpec directory already exists."
    else
        echo "Initializing OpenSpec..."
        mkdir -p "$OPENSPEC_ROOT/specs"
        mkdir -p "$OPENSPEC_ROOT/changes"
        mkdir -p "$OPENSPEC_ROOT/archive"
        
        # Create project context if not exists
        if [ ! -f "$OPENSPEC_ROOT/project.md" ]; then
            cat > "$OPENSPEC_ROOT/project.md" <<EOF
# Project Context

## Overview
Describe your project goal and vision here.

## Tech Stack
- **Language**: 
- **Framework**: 
- **Database**: 

## Coding Conventions
- Style Guide: 
- Naming: snake_case / camelCase?

## Workflow
- Use \`adbs propose <name>\` to start a task.
- Edit the generated proposal.
- When done, \`adbs archive <name>\`.
EOF
        fi
        
        echo "OpenSpec initialized in ./$OPENSPEC_ROOT"
    fi
}

# Create a new change proposal
propose_change() {
    local name="$1"
    if [ -z "$name" ]; then
        echo "Usage: adbs openspec propose <name>"
        return 1
    fi
    
    # Sanitize name
    local clean_name=$(echo "$name" | tr '[:upper:] ' '[:lower:]-' | tr -cd '[:alnum:]-')
    local date_str=$(date +%Y-%m-%d)
    local change_id="${date_str}-${clean_name}"
    local set_path="$OPENSPEC_ROOT/changes/$change_id"
    
    if [ -d "$set_path" ]; then
        echo "Error: Change '$change_id' already exists."
        return 1
    fi
    
    mkdir -p "$set_path"
    
    # Create proposal.md
    cat > "$set_path/proposal.md" <<EOF
# Change Proposal: $name

## Goal
Describe the goal of this change.

## Specifications
- [ ] Spec 1...
- [ ] Spec 2...

## Tasks
- [ ] Task 1...
EOF

    echo "Change proposal created: $set_path/proposal.md"
}

# Archive a change
archive_change() {
    local id="$1"
    if [ -z "$id" ]; then
        echo "Usage: adbs openspec archive <change-id>"
        # List active changes
        echo "Active changes:"
        ls "$OPENSPEC_ROOT/changes" 2>/dev/null
        return 1
    fi
    
    local src_path="$OPENSPEC_ROOT/changes/$id"
    local dest_path="$OPENSPEC_ROOT/archive/$id"
    
    if [ ! -d "$src_path" ]; then
        echo "Error: Change '$id' not found in $OPENSPEC_ROOT/changes."
        return 1
    fi
    
    echo "Archiving change '$id'..."
    mkdir -p "$OPENSPEC_ROOT/archive"
    mv "$src_path" "$dest_path"
    echo "Change archived to $dest_path"
}

# List only specs
list_specs() {
    echo "Current System Specifications:"
    if [ -d "$OPENSPEC_ROOT/specs" ]; then
        ls "$OPENSPEC_ROOT/specs" 2>/dev/null | sed 's/^/  - /'
    else
        echo "  (No specs found or OpenSpec not initialized)"
    fi
}

# Show status
status_openspec() {
    echo "=== OpenSpec Status ==="
    if [ ! -d "$OPENSPEC_ROOT" ]; then
        echo "OpenSpec not initialized. Run 'adbs openspec init'."
        return 0
    fi

    local spec_count=$(ls "$OPENSPEC_ROOT/specs" 2>/dev/null | wc -l | tr -d ' ')
    local change_count=$(ls "$OPENSPEC_ROOT/changes" 2>/dev/null | wc -l | tr -d ' ')
    local archive_count=$(ls "$OPENSPEC_ROOT/archive" 2>/dev/null | wc -l | tr -d ' ')

    echo "Specs: $spec_count"
    echo "Active Proposals: $change_count"
    if [ "$change_count" -gt 0 ]; then
        ls "$OPENSPEC_ROOT/changes" 2>/dev/null | sed 's/^/  - /'
    else
        echo "  (None)"
    fi
    echo "Archived: $archive_count"
}

# Command Handler
case "${1:-}" in
    init)
        init_openspec
        ;;
    propose)
        shift
        propose_change "$1"
        ;;
    archive)
        shift
        archive_change "$1"
        ;;
    specs)
        list_specs
        ;;
    status|list)
        status_openspec
        ;;
    *)
        echo "Usage: adbs openspec {init|propose <name>|archive <id>|status|specs}"
        exit 1
        ;;
esac

