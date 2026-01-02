# ADbS PowerShell Wrapper
# Calls the bash script with proper argument forwarding

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$BashScript = Join-Path $ScriptDir "adbs"

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
    Write-Error "Bash not found. Please install Git for Windows or WSL."
    Write-Host "Download Git: https://git-scm.com/download/win"
    exit 1
}

# Convert Windows path to Unix path for bash
$UnixScriptPath = $BashScript -replace '\\', '/' -replace '^([A-Z]):', { "/$(($_.Value[0]).ToString().ToLower())" }

# Special Handling for Dashboard on Windows (if Bash is missing or just preferred?)
if ($args[0] -eq "dashboard" -and (Test-Path "lib\internal\dashboard.ps1")) {
    & "lib\internal\dashboard.ps1"
    exit $LASTEXITCODE
}
if ($args[0] -eq "dashboard" -and (Test-Path "$ScriptDir\..\internal\dashboard.ps1")) {
    # Installed location structure: .adbs/bin/adbs.ps1 -> .adbs/internal/dashboard.ps1
    & "$ScriptDir\..\internal\dashboard.ps1"
    exit $LASTEXITCODE
}

# Forward all arguments to bash script
& $BashExe -c "$UnixScriptPath $args"
exit $LASTEXITCODE
