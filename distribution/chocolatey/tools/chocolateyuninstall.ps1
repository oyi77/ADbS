$ErrorActionPreference = 'Stop'

$packageName = 'adbs'
$installDir = Join-Path $env:LOCALAPPDATA "ADbS"

# Remove from PATH
$binPath = Join-Path $installDir "bin"
Uninstall-ChocolateyPath -PathToUninstall $binPath -PathType 'User'

# Remove installation directory
if (Test-Path $installDir) {
    Remove-Item -Path $installDir -Recurse -Force
}

Write-Host "ADbS uninstalled successfully!" -ForegroundColor Green
