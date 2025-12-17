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

# Generate rules files
Generate-RulesFiles -RulesDir $rulesDir

# Create SDD directory structure
New-Item -ItemType Directory -Path ".sdd\plans" -Force | Out-Null
New-Item -ItemType Directory -Path ".sdd\requirements" -Force | Out-Null
New-Item -ItemType Directory -Path ".sdd\designs" -Force | Out-Null
New-Item -ItemType Directory -Path ".sdd\tasks" -Force | Out-Null
Write-Success "Created SDD directory structure: .sdd\"

# Create workflow directory
if (-not (Test-Path ".workflow-enforcer")) {
    New-Item -ItemType Directory -Path ".workflow-enforcer" -Force | Out-Null
}
Write-Success "Created workflow directory: .workflow-enforcer"

# Initialize workflow
if (-not (Test-Path ".workflow-enforcer\current-stage")) {
    "explore" | Set-Content ".workflow-enforcer\current-stage"
    Write-Success "Initialized workflow (starting at 'explore' stage)"
}

Write-Host ""
Write-Success "Installation complete!"
Write-Host ""
Write-Info "Next steps:"
Write-Host "  1. Review rules files in: $rulesDir\rules\"
Write-Host "  2. Run: .\bin\adbs.ps1 status"
Write-Host "  3. Start with explore stage: Create .sdd\plans\explore.md"
Write-Host ""
Write-Info "For help: .\bin\adbs.ps1 help"
Write-Info "Note: 'adbs' is a shorter alias for 'workflow-enforcer'"

