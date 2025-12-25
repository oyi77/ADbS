# ADbS Distribution Build Script (PowerShell)
# Generates packages for release on Windows

$ErrorActionPreference = "Stop"

$Version = "0.1.0"
$ProjectRoot = Resolve-Path "$PSScriptRoot\..\.."
$DistDir = Join-Path $ProjectRoot "dist"
$ArtifactsDir = Join-Path $DistDir "artifacts"

function Log-Info {
    param([string]$Message)
    Write-Host "[BUILD] $Message" -ForegroundColor Green
}

function Log-Error {
    param([string]$Message)
    Write-Host "[ERROR] $Message" -ForegroundColor Red
    exit 1
}

# Setup Directories
Log-Info "Setting up distribution directories..."
if (Test-Path $DistDir) { Remove-Item -Recurse -Force $DistDir }
New-Item -ItemType Directory -Force -Path $ArtifactsDir | Out-Null

# Build Zip Archive (Windows equivalent of Tarball)
Log-Info "Building source archive (v$Version)..."
$ZipFile = Join-Path $ArtifactsDir "adbs-v$Version.zip"

# Exclude list
$Exclude = @(".git", "node_modules", "test-results", "dist", ".sdd", ".workflow-enforcer")

# Get files to zip
$Files = Get-ChildItem -Path $ProjectRoot -Exclude $Exclude | Select-Object -ExpandProperty FullName

try {
    Compress-Archive -Path $Files -DestinationPath $ZipFile -Force
    Log-Info "Archive created: $ZipFile"
    
    # Checksum
    $Hash = Get-FileHash $ZipFile -Algorithm SHA256
    $Hash.Hash | Out-File "$ZipFile.sha256"
    Log-Info "Checksum: $($Hash.Hash)"
}
catch {
    Log-Error "Failed to create archive: $_"
}

# Build NPM Package
Log-Info "Building npm package..."
$NpmDist = Join-Path $DistDir "npm"
New-Item -ItemType Directory -Force -Path $NpmDist | Out-Null

# Copy files
Copy-Item (Join-Path $ProjectRoot "distribution\npm\package.json") -Destination $NpmDist
Copy-Item -Recurse (Join-Path $ProjectRoot "bin") -Destination $NpmDist
Copy-Item -Recurse (Join-Path $ProjectRoot "lib") -Destination $NpmDist
Copy-Item (Join-Path $ProjectRoot "README.md") -Destination $NpmDist

if (-not (Test-Path (Join-Path $NpmDist "package.json"))) {
    Log-Error "No package.json found for npm build"
}

# Run NPM Pack
Push-Location $NpmDist
try {
    npm pack --pack-destination $ArtifactsDir
    Log-Info "npm package created in $ArtifactsDir"
}
finally {
    Pop-Location
}

Log-Info "Build Complete!"
Get-ChildItem $ArtifactsDir
