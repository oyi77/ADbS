$ErrorActionPreference = 'Stop'

$packageName = 'adbs'
$toolsDir = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
$url = 'https://github.com/oyi77/ADbS/archive/refs/heads/main.zip'

$packageArgs = @{
  packageName   = $packageName
  unzipLocation = $toolsDir
  url           = $url
  checksum      = ''  # Will be filled during package build
  checksumType  = 'sha256'
}

Install-ChocolateyZipPackage @packageArgs

# Find the extracted directory
$extractedDir = Get-ChildItem -Path $toolsDir -Directory | Where-Object { $_.Name -like "ADbS-*" } | Select-Object -First 1

if ($null -eq $extractedDir) {
    throw "Failed to find extracted ADbS directory"
}

$adbsRoot = $extractedDir.FullName

# Install ADbS to user's local app data
$installDir = Join-Path $env:LOCALAPPDATA "ADbS"

# Create installation directory
if (Test-Path $installDir) {
    Remove-Item -Path $installDir -Recurse -Force
}
New-Item -ItemType Directory -Path $installDir -Force | Out-Null

# Copy ADbS files
Copy-Item -Path "$adbsRoot\bin" -Destination "$installDir\bin" -Recurse -Force
Copy-Item -Path "$adbsRoot\lib" -Destination "$installDir\lib" -Recurse -Force
Copy-Item -Path "$adbsRoot\config" -Destination "$installDir\config" -Recurse -Force

if (Test-Path "$adbsRoot\VERSION") {
    Copy-Item -Path "$adbsRoot\VERSION" -Destination "$installDir\VERSION" -Force
}

# Add to PATH
$binPath = Join-Path $installDir "bin"
Install-ChocolateyPath -PathToInstall $binPath -PathType 'User'

Write-Host ""
Write-Host "ADbS installed successfully!" -ForegroundColor Green
Write-Host ""
Write-Host "To use ADbS in your project:" -ForegroundColor Blue
Write-Host "  1. Navigate to your project directory"
Write-Host "  2. Run: adbs setup"
Write-Host "  3. Start working: adbs new <name>"
Write-Host ""
Write-Host "For help: adbs --help" -ForegroundColor Blue
Write-Host ""
