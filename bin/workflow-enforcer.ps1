# ADbS - AI Development Assistant
# PowerShell wrapper for workflow-enforcer bash script

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectRoot = Split-Path -Parent $ScriptDir
$BashScript = Join-Path $ScriptDir "workflow-enforcer"

# Find bash executable (Git Bash or WSL)
$BashExe = $null

# Try Git Bash first (most common on Windows)
$GitBashPaths = @(
    "C:\Program Files\Git\bin\bash.exe",
    "C:\Program Files (x86)\Git\bin\bash.exe",
    "$env:ProgramFiles\Git\bin\bash.exe",
    "$env:ProgramFiles(x86)\Git\bin\bash.exe"
)

foreach ($path in $GitBashPaths) {
    if (Test-Path $path) {
        $BashExe = $path
        break
    }
}

# Fallback to WSL bash
if (-not $BashExe) {
    if (Get-Command bash -ErrorAction SilentlyContinue) {
        $BashExe = "bash"
    }
}

# If no bash found, show error
if (-not $BashExe) {
    Write-Error "Bash not found. ADbS requires Git Bash or WSL."
    Write-Host ""
    Write-Host "Please install Git for Windows:"
    Write-Host "  https://git-scm.com/download/win"
    Write-Host ""
    Write-Host "Or enable WSL:"
    Write-Host "  wsl --install"
    exit 1
}

# Convert Windows path to Unix path for bash
$UnixScriptPath = $BashScript -replace '\\', '/' -replace '^([A-Z]):', { "/$(($_.Value[0]).ToString().ToLower())" }

# Properly escape and forward all arguments
$EscapedArgs = $args | ForEach-Object {
    if ($_ -match '\s') {
        "'$($_ -replace "'", "\'")'"
    } else {
        $_
    }
}

$CommandLine = "$UnixScriptPath $($EscapedArgs -join ' ')"

# Execute bash script
& $BashExe -c $CommandLine
exit $LASTEXITCODE
