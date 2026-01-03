# Platform/IDE detector - PowerShell version
# Wrapper around shell implementation for consistency and to eliminate redundancy

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectRoot = Split-Path -Parent $ScriptDir
$BashScript = Join-Path $ProjectRoot "lib\platform_detector.sh"

# Find bash executable
$BashExe = $null
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

if (-not $BashExe) {
    if (Get-Command bash -ErrorAction SilentlyContinue) {
        $BashExe = "bash"
    }
}

# If bash not found, fall back to native PowerShell implementation
if (-not $BashExe) {
    Write-Warning "Bash not found, using native PowerShell implementation"
    
    function Detect-Platform {
        $platforms = @()
        
        if (Test-Path ".cursor" -PathType Container) { $platforms += "cursor" }
        if ($env:CURSOR) { $platforms += "cursor" }
        if (Test-Path ".trae" -PathType Container) { $platforms += "trae" }
        if ($env:TRAE) { $platforms += "trae" }
        if (Test-Path ".gemini" -PathType Container) { $platforms += "gemini" }
        if ($env:GEMINI) { $platforms += "gemini" }
        if (Test-Path ".vscode" -PathType Container) { $platforms += "vscode" }
        if ($env:VSCODE -or $env:CODE) { $platforms += "vscode" }
        if (Test-Path ".idea" -PathType Container) { $platforms += "jetbrains" }
        if (Test-Path ".vimrc" -PathType Leaf) { $platforms += "vim" }
        if (Test-Path ".config\nvim" -PathType Container) { $platforms += "vim" }
        if (Test-Path ".emacs" -PathType Leaf) { $platforms += "emacs" }
        if (Test-Path ".emacs.d" -PathType Container) { $platforms += "emacs" }
        if (Test-Path ".zed" -PathType Container) { $platforms += "zed" }
        if ($env:ZED_TERM) { $platforms += "zed" }
        if (Get-ChildItem -Path . -Filter "*.sublime-project" -ErrorAction SilentlyContinue) { $platforms += "sublime" }
        if (Test-Path ".helix" -PathType Container) { $platforms += "helix" }
        
        $platforms = $platforms | Select-Object -Unique
        
        if ($platforms.Count -eq 0) {
            return "generic"
        } elseif ($platforms.Count -eq 1) {
            return $platforms[0]
        } else {
            return ($platforms -join ",")
        }
    }
    
    function Get-RulesDir {
        param([string]$Platform)
        
        if (-not $Platform) {
            $Platform = Detect-Platform
            if ($Platform.Contains(",")) {
                $Platform = $Platform.Split(",")[0]
            }
        }
        
        switch ($Platform) {
            "cursor" { return ".cursor" }
            "trae" { return ".trae" }
            "gemini" { return ".gemini" }
            "vscode" { return ".vscode" }
            "jetbrains" { return ".idea" }
            "zed" { return ".zed" }
            "helix" { return ".helix" }
            "sublime" { return ".sublime" }
            "vim" { return ".ai-rules" }
            "emacs" { return ".ai-rules" }
            default { return ".ai-rules" }
        }
    }
    
    # Main execution for fallback
    $command = $args[0]
    switch ($command) {
        "detect" {
            Detect-Platform
        }
        "rules-dir" {
            Get-RulesDir -Platform $args[1]
        }
        default {
            Write-Host "Usage: $($MyInvocation.MyCommand.Name) {detect|rules-dir}"
            exit 1
        }
    }
    exit 0
}

# Convert Windows path to Unix path for bash
$UnixScriptPath = $BashScript -replace '\\', '/'
if ($UnixScriptPath -match '^([A-Z]):') {
    $Drive = $Matches[1].ToLower()
    $UnixScriptPath = $UnixScriptPath -replace '^([A-Z]):', "/$Drive"
}

# If using WSL, prepend /mnt/
if ($BashExe -eq "bash" -or $BashExe -like "*System32*") {
    try {
        $Ver = & $BashExe -c "uname -r" 2>&1
        if ($Ver -like "*microsoft*") {
            $UnixScriptPath = "/mnt/$UnixScriptPath"
        }
    } catch {
        # Not WSL, continue
    }
}

# Execute bash script with all arguments
$command = $args[0]
$remainingArgs = $args[1..($args.Length - 1)]

try {
    if ($BashExe -like "*bash.exe") {
        # Git Bash
        & $BashExe -- "$UnixScriptPath" $command $remainingArgs
    } else {
        # WSL or system bash
        & $BashExe "$UnixScriptPath" $command $remainingArgs
    }
    exit $LASTEXITCODE
} catch {
    Write-Error "Failed to execute platform detector: $_"
    exit 1
}
