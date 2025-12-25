# Dynamic Rules Generator for ADbS (PowerShell)
# Part of Phase 3 Optimization

param(
    [string]$Platform,
    [string]$Context,
    [string]$OutputFile
)

function Get-TechStack {
    param([string]$Path)
    $Stack = @()
    if (Test-Path (Join-Path $Path "package.json")) { $Stack += "nodejs" }
    if ((Test-Path (Join-Path $Path "requirements.txt")) -or (Test-Path (Join-Path $Path "pyproject.toml"))) { $Stack += "python" }
    if (Test-Path (Join-Path $Path "Cargo.toml")) { $Stack += "rust" }
    if (Test-Path (Join-Path $Path "go.mod")) { $Stack += "go" }
    if (Get-ChildItem $Path -Filter "*.ps1" -Recurse -ErrorAction SilentlyContinue) { $Stack += "powershell" }
    return $Stack
}

Write-Host "Generating dynamic rule for $Platform with context ($Context)..."

# 1. Base Rule
$BaseRule = "# ADbS Rules for $Platform`n`n## Core Principles`n- Follow the SDD workflow.`n- Update status after every step.`n"
$BaseRule | Out-File -FilePath $OutputFile -Encoding UTF8

# 2. Tech Stack
$Stack = Get-TechStack -Path .
foreach ($Tech in $Stack) {
    Write-Host "Detected technology: $Tech"
    switch ($Tech) {
        "nodejs" { 
            "`n## Node.js Guidelines`n- Prefer const over let.`n- Use async/await.`n" | Out-File -FilePath $OutputFile -Append -Encoding UTF8
        }
        "python" {
            "`n## Python Guidelines`n- Follow PEP 8.`n- Type hints are required.`n" | Out-File -FilePath $OutputFile -Append -Encoding UTF8
        }
        "powershell" {
            "`n## PowerShell Guidelines`n- Use camelCase for variables.`n- Use Verb-Noun for functions.`n" | Out-File -FilePath $OutputFile -Append -Encoding UTF8
        }
    }
}

# 3. Context
switch ($Context) {
    "qa" {
        "`n## QA Focus`n- Check edge cases.`n- Validate all inputs.`n" | Out-File -FilePath $OutputFile -Append -Encoding UTF8
    }
    "architecture" {
        "`n## Architecture Focus`n- Consider scalability.`n- Document interfaces.`n" | Out-File -FilePath $OutputFile -Append -Encoding UTF8
    }
}

Write-Host "Rule generation complete: $OutputFile"
