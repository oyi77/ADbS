<#
.SYNOPSIS
    OpenSpec Implementation for ADbS (PowerShell)
    Provides native support for Fission-AI/OpenSpec workflow
#>

$SCRIPT_DIR = Split-Path -Parent $MyInvocation.MyCommand.Path
$OPENSPEC_ROOT = "openspec"

# Initialize OpenSpec directory structure
function Init-OpenSpec {
    if (Test-Path $OPENSPEC_ROOT) {
        Write-Host "OpenSpec directory already exists."
    } else {
        Write-Host "Initializing OpenSpec..."
        New-Item -ItemType Directory -Path "$OPENSPEC_ROOT\specs" -Force | Out-Null
        New-Item -ItemType Directory -Path "$OPENSPEC_ROOT\changes" -Force | Out-Null
        New-Item -ItemType Directory -Path "$OPENSPEC_ROOT\archive" -Force | Out-Null
        
        # Create project context if not exists
        if (-not (Test-Path "$OPENSPEC_ROOT\project.md")) {
            @"
# Project Context

## Overview
Describe the project here.

## Conventions
- Formatting: ...
- Tech Stack: ...
"@ | Set-Content "$OPENSPEC_ROOT\project.md"
        }
        
        Write-Host "OpenSpec initialized in .\$OPENSPEC_ROOT"
    }
}

# Create a new change proposal
function New-Proposal {
    param([string]$name)
    
    if ([string]::IsNullOrWhiteSpace($name)) {
        Write-Host "Usage: adbs openspec propose <name>"
        return
    }
    
    # Sanitize name
    $cleanName = $name.ToLower() -replace '[^a-z0-9-]', '-'
    $dateStr = Get-Date -Format "yyyy-MM-dd"
    $changeId = "$dateStr-$cleanName"
    $setPath = Join-Path "$OPENSPEC_ROOT\changes" $changeId
    
    if (Test-Path $setPath) {
        Write-Host "Error: Change '$changeId' already exists."
        return
    }
    
    New-Item -ItemType Directory -Path $setPath -Force | Out-Null
    
    # Create proposal.md
    @"
# Change Proposal: $name

## Goal
Describe the goal of this change.

## Specifications
- [ ] Spec 1...
- [ ] Spec 2...

## Tasks
- [ ] Task 1...
"@ | Set-Content (Join-Path $setPath "proposal.md")

    Write-Host "Change proposal created: $setPath\proposal.md"
}

# Archive a change
function Archive-Change {
    param([string]$id)
    
    if ([string]::IsNullOrWhiteSpace($id)) {
        Write-Host "Usage: adbs openspec archive <change-id>"
        Write-Host "Active changes:"
        Get-ChildItem "$OPENSPEC_ROOT\changes" | Select-Object -ExpandProperty Name
        return
    }
    
    $srcPath = Join-Path "$OPENSPEC_ROOT\changes" $id
    $destPath = Join-Path "$OPENSPEC_ROOT\archive" $id
    
    if (-not (Test-Path $srcPath)) {
        Write-Host "Error: Change '$id' not found in $OPENSPEC_ROOT\changes."
        return
    }
    
    Write-Host "Archiving change '$id'..."
    Move-Item -Path $srcPath -Destination $destPath
    Write-Host "Change archived to $destPath"
}

# List only specs
function Get-Specs {
    Write-Host "Current System Specifications:"
    if (Test-Path "$OPENSPEC_ROOT\specs") {
        Get-ChildItem "$OPENSPEC_ROOT\specs" | ForEach-Object { Write-Host "  - $($_.Name)" }
    } else {
        Write-Host "  (No specs found or OpenSpec not initialized)"
    }
}

# List contents
function Get-OpenSpecStatus {
    Write-Host "=== OpenSpec Status ==="
    Write-Host "Specs:"
    if (Test-Path "$OPENSPEC_ROOT\specs") {
        Get-ChildItem "$OPENSPEC_ROOT\specs" | ForEach-Object { Write-Host "  - $($_.Name)" }
    }
    Write-Host ""
    Write-Host "Active Changes:"
    if (Test-Path "$OPENSPEC_ROOT\changes") {
        Get-ChildItem "$OPENSPEC_ROOT\changes" | ForEach-Object { Write-Host "  - $($_.Name)" }
    }
}

# Main Dispatcher
$command = $args[0]
$subArgs = $args[1..($args.Length-1)]

switch ($command) {
    "init" { Init-OpenSpec }
    "propose" { New-Proposal $subArgs[0] }
    "archive" { Archive-Change $subArgs[0] }
    "specs" { Get-Specs }
    "list" { Get-OpenSpecStatus }
    default {
        Write-Host "Usage: adbs openspec {init|propose <name>|archive <id>|specs|list}"
        exit 1
    }
}
