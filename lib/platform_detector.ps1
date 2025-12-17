# Platform/IDE detector - PowerShell version
# Detects which IDE/platform is being used

function Detect-Platform {
    $platforms = @()
    
    # Check for Cursor
    if (Test-Path ".cursor" -PathType Container) { $platforms += "cursor" }
    if ($env:CURSOR) { $platforms += "cursor" }
    
    # Check for Trae
    if (Test-Path ".trae" -PathType Container) { $platforms += "trae" }
    if ($env:TRAE) { $platforms += "trae" }
    
    # Check for Gemini
    if (Test-Path ".gemini" -PathType Container) { $platforms += "gemini" }
    if ($env:GEMINI) { $platforms += "gemini" }
    
    # Check for VS Code
    if (Test-Path ".vscode" -PathType Container) { $platforms += "vscode" }
    if ($env:VSCODE -or $env:CODE) { $platforms += "vscode" }
    
    # Check for JetBrains IDEs
    if (Test-Path ".idea" -PathType Container) { $platforms += "jetbrains" }
    
    # Check for Vim/Neovim
    if (Test-Path ".vimrc" -PathType Leaf) { $platforms += "vim" }
    if (Test-Path ".config\nvim" -PathType Container) { $platforms += "vim" }
    
    # Check for Emacs
    if (Test-Path ".emacs" -PathType Leaf) { $platforms += "emacs" }
    if (Test-Path ".emacs.d" -PathType Container) { $platforms += "emacs" }

    # Check for Zed
    if (Test-Path ".zed" -PathType Container) { $platforms += "zed" }
    if ($env:ZED_TERM) { $platforms += "zed" }

    # Check for Sublime Text
    if (Get-ChildItem -Path . -Filter "*.sublime-project" -ErrorAction SilentlyContinue) { $platforms += "sublime" }

    # Check for Helix
    if (Test-Path ".helix" -PathType Container) { $platforms += "helix" }
    
    # Remove duplicates
    $platforms = $platforms | Select-Object -Unique
    
    if ($platforms.Count -eq 0) {
        return "generic"
    } elseif ($platforms.Count -eq 1) {
        return $platforms[0]
    } else {
        return ($platforms -join ",")
    }
}

function Detect-AllPlatforms {
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
        return @("generic")
    }
    
    return $platforms
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

function Get-AllRulesDirs {
    $platforms = Detect-AllPlatforms
    foreach ($platform in $platforms) {
        Get-RulesDir -Platform $platform
    }
}

function Get-RulesFile {
    return "rules"
}

# Main execution
$command = $args[0]

switch ($command) {
    "detect" {
        Detect-Platform
    }
    "detect-all" {
        Detect-AllPlatforms | ForEach-Object { Write-Output $_ }
    }
    "rules-dir" {
        Get-RulesDir -Platform $args[1]
    }
    "rules-dirs" {
        Get-AllRulesDirs
    }
    "rules-file" {
        Get-RulesFile
    }
    default {
        Write-Host "Usage: $($MyInvocation.MyCommand.Name) {detect|detect-all|rules-dir|rules-dirs|rules-file}"
        Write-Host ""
        Write-Host "Commands:"
        Write-Host "  detect        - Detect primary platform/IDE"
        Write-Host "  detect-all    - Detect all platforms/IDEs"
        Write-Host "  rules-dir     - Get rules directory for platform (or primary)"
        Write-Host "  rules-dirs    - Get rules directories for all platforms"
        Write-Host "  rules-file    - Get rules filename"
        exit 1
    }
}

