# ADbS Distribution

This directory contains all distribution-related files for ADbS, including installation scripts and package manager configurations.

## Directory Structure

```
distribution/
├── install.sh              # Bash installer (Linux/macOS)
├── install.ps1             # PowerShell installer (Windows)
├── install.bat             # Batch installer (Windows)
├── chocolatey/             # Chocolatey package
│   ├── adbs.nuspec
│   └── tools/
│       ├── chocolateyinstall.ps1
│       └── chocolateyuninstall.ps1
├── winget/                 # Windows Package Manager manifests
│   ├── oyi77.ADbS.yaml
│   ├── oyi77.ADbS.locale.en-US.yaml
│   └── oyi77.ADbS.installer.yaml
├── npm/                    # npm package
│   ├── package.json
│   └── scripts/
│       └── postinstall.js
├── homebrew/               # Homebrew formula
│   └── Formula/
│       └── adbs.rb
└── scripts/                # Build and packaging scripts
    ├── build_packages.sh
    └── build_packages.ps1
```

## Installation Methods

### Direct Installation Scripts

**Bash (Linux/macOS)**:
```bash
curl -sSL https://raw.githubusercontent.com/oyi77/ADbS/main/distribution/install.sh | bash
```

**PowerShell (Windows)**:
```powershell
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/oyi77/ADbS/main/distribution/install.ps1" -UseBasicParsing | Invoke-Expression
```

### Package Managers

**Chocolatey (Windows)**:
```powershell
choco install adbs
```

**Winget (Windows)**:
```powershell
winget install oyi77.ADbS
```

**Homebrew (macOS/Linux)**:
```bash
brew tap oyi77/adbs
brew install adbs
```

**npm (Cross-platform)**:
```bash
npm install -g @adbs/cli
```

## For Maintainers

See [Publishing Guide](../docs/PUBLISHING.md) for instructions on how to publish to each package manager.

## Notes

- Root-level `install.sh`, `install.ps1`, and `install.bat` are redirector scripts for backward compatibility
- All installation methods create the same `.adbs/` directory structure
- Installation scripts are designed to work both from repository and from remote (curl/wget)
