# ADbS Distribution Guide

This guide explains how to publish ADbS to various package managers.

## Prerequisites

- GitHub repository with releases
- Package manager accounts (Chocolatey, npm, etc.)
- Build tools installed

## Package Managers

### 1. npm (Node Package Manager)

**Location**: `distribution/npm/`

**Publishing Steps**:

1. **Prepare the package**:
   ```bash
   cd distribution/npm
   # Copy necessary files
   cp -r ../../bin ./
   cp -r ../../lib ./
   cp -r ../../config ./
   cp ../../VERSION ./
   cp ../../README.md ./
   ```

2. **Test locally**:
   ```bash
   npm pack
   npm install -g adbs-cli-0.1.0.tgz
   ```

3. **Publish to npm**:
   ```bash
   npm login
   npm publish --access public
   ```

**Update version**:
```bash
npm version patch  # or minor, major
npm publish
```

---

### 2. Chocolatey (Windows)

**Location**: `distribution/chocolatey/`

**Publishing Steps**:

1. **Build the package**:
   ```powershell
   cd distribution/chocolatey
   choco pack
   ```

2. **Test locally**:
   ```powershell
   choco install adbs -source .
   ```

3. **Publish to Chocolatey**:
   ```powershell
   choco apikey --key YOUR-API-KEY --source https://push.chocolatey.org/
   choco push adbs.0.1.0.nupkg --source https://push.chocolatey.org/
   ```

**Update checksum**:
After creating a GitHub release, update the checksum in `tools/chocolateyinstall.ps1`:
```powershell
$checksum = (Get-FileHash -Path adbs.zip -Algorithm SHA256).Hash
```

---

### 3. Winget (Windows Package Manager)

**Location**: `distribution/winget/`

**Publishing Steps**:

1. **Create a GitHub release** with a zip file

2. **Update the installer manifest** (`oyi77.ADbS.installer.yaml`):
   - Update `InstallerUrl` with the release URL
   - Update `InstallerSha256` with the file hash

3. **Submit to winget-pkgs repository**:
   ```bash
   # Fork https://github.com/microsoft/winget-pkgs
   git clone https://github.com/YOUR-USERNAME/winget-pkgs
   cd winget-pkgs
   
   # Create package directory
   mkdir -p manifests/o/oyi77/ADbS/0.1.0
   
   # Copy manifests
   cp distribution/winget/*.yaml manifests/o/oyi77/ADbS/0.1.0/
   
   # Create PR
   git checkout -b adbs-0.1.0
   git add manifests/o/oyi77/ADbS/
   git commit -m "Add ADbS version 0.1.0"
   git push origin adbs-0.1.0
   ```

4. **Create Pull Request** to microsoft/winget-pkgs

---

### 4. Homebrew (macOS/Linux)

**Location**: `distribution/homebrew/Formula/`

**Publishing Steps**:

1. **Create a GitHub release** with source tarball

2. **Update the formula** (`adbs.rb`):
   ```ruby
   url "https://github.com/oyi77/ADbS/archive/v0.1.0.tar.gz"
   sha256 "REPLACE_WITH_SHA256"
   ```

3. **Calculate SHA256**:
   ```bash
   curl -L https://github.com/oyi77/ADbS/archive/v0.1.0.tar.gz | shasum -a 256
   ```

4. **Create tap repository** (if not exists):
   ```bash
   # Create repository: homebrew-adbs
   # Add formula to Formula/adbs.rb
   ```

5. **Users install via**:
   ```bash
   brew tap oyi77/adbs
   brew install adbs
   ```

---

## Automated Release Workflow

Create `.github/workflows/release.yml`:

```yaml
name: Release

on:
  push:
    tags:
      - 'v*'

jobs:
  release:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Create Release
        uses: softprops/action-gh-release@v1
        with:
          files: |
            distribution/npm/*.tgz
            distribution/chocolatey/*.nupkg
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
      
      - name: Publish to npm
        run: |
          cd distribution/npm
          echo "//registry.npmjs.org/:_authToken=${{ secrets.NPM_TOKEN }}" > ~/.npmrc
          npm publish --access public
      
      - name: Publish to Chocolatey
        run: |
          cd distribution/chocolatey
          choco apikey --key ${{ secrets.CHOCO_API_KEY }} --source https://push.chocolatey.org/
          choco push *.nupkg --source https://push.chocolatey.org/
```

---

## Version Management

1. **Update VERSION file**:
   ```bash
   echo "0.2.0" > VERSION
   ```

2. **Update all package manifests**:
   - `distribution/npm/package.json`
   - `distribution/chocolatey/adbs.nuspec`
   - `distribution/winget/oyi77.ADbS.yaml`
   - `distribution/homebrew/Formula/adbs.rb`

3. **Create Git tag**:
   ```bash
   git tag -a v0.2.0 -m "Release version 0.2.0"
   git push origin v0.2.0
   ```

4. **Create GitHub Release** with changelog

---

## Testing Installations

### npm
```bash
npm install -g @adbs/cli
adbs --version
```

### Chocolatey
```powershell
choco install adbs
adbs --version
```

### Winget
```powershell
winget install oyi77.ADbS
adbs --version
```

### Homebrew
```bash
brew install oyi77/adbs/adbs
adbs --version
```

---

## Troubleshooting

### npm: Package not found
- Check package name: `@adbs/cli`
- Verify npm registry: `npm config get registry`

### Chocolatey: Checksum mismatch
- Recalculate checksum after creating release
- Update `chocolateyinstall.ps1`

### Winget: Validation failed
- Validate manifests: `winget validate --manifest distribution/winget/`
- Check schema version compatibility

### Homebrew: Formula error
- Test formula: `brew install --build-from-source Formula/adbs.rb`
- Verify dependencies are available
