# ADbS Installation Script - PowerShell version

$ErrorActionPreference = "Stop"

function Write-Info {
    Write-Host "[INFO] $args" -ForegroundColor Blue
}

function Write-Success {
    Write-Host "[SUCCESS] $args" -ForegroundColor Green
}

function Write-Warning {
    Write-Host "[WARNING] $args" -ForegroundColor Yellow
}

function Write-Error {
    Write-Host "[ERROR] $args" -ForegroundColor Red
}

function Detect-OS {
    if ($IsWindows -or $env:OS -eq "Windows_NT") {
        return "windows"
    } elseif ($IsLinux) {
        return "linux"
    } elseif ($IsMacOS) {
        return "darwin"
    } else {
        return "unknown"
    }
}

function Detect-Arch {
    if ([Environment]::Is64BitOperatingSystem) {
        if ([Environment]::Is64BitProcess) {
            return "amd64"
        } else {
            return "x86"
        }
    } else {
        return "x86"
    }
}

function Detect-Platform {
    $platforms = @()
    
    if (Test-Path ".cursor") { $platforms += "cursor" }
    if ($env:CURSOR) { $platforms += "cursor" }
    if (Test-Path ".trae") { $platforms += "trae" }
    if ($env:TRAE) { $platforms += "trae" }
    if (Test-Path ".gemini") { $platforms += "gemini" }
    if ($env:GEMINI) { $platforms += "gemini" }
    if (Test-Path ".antigravity") { $platforms += "antigravity" }
    if ($env:ANTIGRAVITY) { $platforms += "antigravity" }
    if (Test-Path ".vscode") { $platforms += "vscode" }
    if ($env:VSCODE -or $env:CODE) { $platforms += "vscode" }
    
    if ($platforms.Count -eq 0) {
        return "generic"
    } elseif ($platforms.Count -eq 1) {
        return $platforms[0]
    } else {
        return $platforms[0]  # Return first detected
    }
}

function Get-RulesDir {
    param([string]$Platform)
    
    switch ($Platform) {
        "cursor" { return ".cursor" }
        "trae" { return ".trae" }
        "gemini" { return ".gemini" }
        "vscode" { return ".vscode" }
        default { return ".ai-rules" }
    }
}

function Generate-RulesFiles {
    param([string]$RulesDir)
    
    if (Test-Path "lib\rules_generator.ps1") {
        Write-Info "Generating platform-specific rules files..."
        & "lib\rules_generator.ps1" generate
        Write-Success "Generated rules files in $RulesDir\rules\"
    } else {
        Write-Warning "Rules generator not found, skipping rules generation"
    }
}

function Generate-IDECommands {
    param([string]$Platform)
    
    $commandsDir = switch ($Platform) {
        "cursor" { ".cursor\commands" }
        "gemini" { ".gemini\commands" }
        "antigravity" { ".antigravity\commands" }
        "vscode" { ".vscode\commands" }
        default { return }
    }
    
    New-Item -ItemType Directory -Path $commandsDir -Force | Out-Null
    
    # Try to copy from config\commands if available (local install)
    if (Test-Path "config\commands") {
        Copy-Item "config\commands\*.md" $commandsDir -Force -ErrorAction SilentlyContinue
        Write-Success "Generated IDE commands in $commandsDir\"
        return
    }
    
    # Otherwise create commands inline (remote install)
    @"
---
name: "ADbS: New Work"
description: "Start new feature or fix with ADbS"
---

# ADbS: New Work

Start a new work item with ADbS (AI Don't Be Stupid).

**Simple workflow:**
``````bash
adbs new "feature-name"
``````

**AI-powered workflow:**
``````bash
adbs new "feature-name" --ai-generate
``````
"@ | Set-Content "$commandsDir\adbs-new.md"

    @"
---
name: "ADbS: Status"
description: "Show current ADbS work status"
---

# ADbS: Status

Show the current status of all active work items.

``````bash
adbs status
``````
"@ | Set-Content "$commandsDir\adbs-status.md"

    @"
---
name: "ADbS: Done"
description: "Mark work as complete and archive it"
---

# ADbS: Done

Mark a work item as complete and move it to the archive.

``````bash
adbs done "feature-name"
``````
"@ | Set-Content "$commandsDir\adbs-done.md"

    @"
---
name: "ADbS: Help"
description: "Show ADbS help and available commands"
---

# ADbS: Help

Get help with ADbS (AI Don't Be Stupid) commands.

``````bash
adbs help
``````
"@ | Set-Content "$commandsDir\adbs-help.md"

    @"
---
name: "ADbS: Workflow"
description: "Show detailed workflow state"
---

# ADbS: Workflow

Show the detailed workflow state for a work item.

``````bash
adbs workflow "feature-name"
``````
"@ | Set-Content "$commandsDir\adbs-workflow.md"

    @"
---
name: "ADbS: Add Task"
description: "Add a new task or reminder"
---

# ADbS: Add Task

Add a new task or reminder to your current work.

``````bash
adbs todo "task description"
``````
"@ | Set-Content "$commandsDir\adbs-todo.md"

    Write-Success "Generated IDE commands in $commandsDir\"
}

# Main installation
Write-Info "ADbS Installation Script (PowerShell)"
Write-Info "======================================"
Write-Host ""

$os = Detect-OS
$arch = Detect-Arch
Write-Info "Detected OS: $os, Architecture: $arch"

$platform = Detect-Platform
Write-Info "Detected platform: $platform"

$rulesDir = Get-RulesDir -Platform $platform

# Create rules directory
if (-not (Test-Path $rulesDir)) {
    New-Item -ItemType Directory -Path $rulesDir -Force | Out-Null
}
Write-Success "Created rules directory: $rulesDir"

# Create ADbS directory structure (everything in .adbs)
New-Item -ItemType Directory -Path ".adbs\work" -Force | Out-Null
New-Item -ItemType Directory -Path ".adbs\archive" -Force | Out-Null
New-Item -ItemType Directory -Path ".adbs\internal" -Force | Out-Null
New-Item -ItemType Directory -Path ".adbs\bin" -Force | Out-Null
New-Item -ItemType Directory -Path ".adbs\config" -Force | Out-Null
Write-Success "Created ADbS directory structure: .adbs\"

# Generate rules files
Generate-RulesFiles -RulesDir $rulesDir

# Generate IDE commands
Generate-IDECommands -Platform $platform

# Initialize workflow state in .adbs
if (-not (Test-Path ".adbs\config\current-stage")) {
    "explore" | Set-Content ".adbs\config\current-stage"
    Write-Success "Initialized workflow (starting at 'explore' stage)"
}

# Copy adbs command to .adbs\bin for easy access
if (Test-Path "bin\adbs.ps1") {
    Copy-Item "bin\adbs.ps1" ".adbs\bin\adbs.ps1" -Force
}

# Download task manager silently (internal)
Write-Info "Setting up ADbS command..."
if (Test-Path ".adbs\internal") {
    # Silently install task manager
    try {
        $env:BEADS_INSTALL_DIR = ".adbs\internal"
        Invoke-WebRequest -Uri "https://raw.githubusercontent.com/steveyegge/beads/main/scripts/install.sh" -UseBasicParsing | Select-Object -ExpandProperty Content | bash 2>$null | Out-Null
    } catch {
        # Silent failure is OK - task manager is optional
    }
}

# Setup PATH automatically
$binPath = Join-Path (Get-Location) ".adbs\bin"
$currentPath = [Environment]::GetEnvironmentVariable("Path", "User")

if ($currentPath -notlike "*$binPath*") {
    try {
        [Environment]::SetEnvironmentVariable("Path", "$currentPath;$binPath", "User")
        Write-Success "Added ADbS to PATH"
    } catch {
        Write-Warning "Could not add to PATH automatically. Add manually: $binPath"
    }
}

# Also add to current session
$env:Path += ";$binPath"

Write-Host ""
Write-Success "Installation complete!"
Write-Host ""
Write-Info "ADbS (AI Don't Be Stupid) is now installed!"
Write-Host ""
Write-Info "Next steps:"
Write-Host "  1. Restart your terminal (or run: `$env:Path += ';$binPath')"
Write-Host "  2. Run: adbs status"
Write-Host "  3. Start with explore stage: Create .adbs\plans\explore.md"
Write-Host ""
Write-Info "For help: adbs help"

