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

## What Happens During Installation

The installer will:

1. **Detect your environment** - OS, architecture, and IDE/platform
2. **Create `.adbs` directory structure** - All ADbS files in one place
3. **Generate IDE-specific rules** - Automatically creates rules for your IDE
4. **Make `adbs` command available** - Automatically adds to PATH
5. **Initialize workflow** - Sets up starting state

### Directory Structure

After installation:

```
your-project/
├── .adbs/                    # All ADbS files
│   ├── work/                 # Active work items
│   ├── archive/              # Completed work
│   ├── bin/                  # ADbS command
│   ├── config/               # Configuration
│   └── internal/             # Internal tools (hidden)
├── .cursor/rules/            # IDE rules (auto-generated)
└── your-code/                # Your actual project files
```

## Post-Installation

After installation completes:

1. **Reload your shell** (or restart terminal)
2. **Verify installation**: `adbs status`
3. **Get help**: `adbs help`
4. **Start working**: `adbs new "feature-name"`

The `adbs` command is now directly available - no manual PATH configuration needed!

## IDE Integration

ADbS automatically registers commands in your IDE's command palette during installation:

### Supported IDEs

- **Cursor**: Commands in `.cursor/commands/`
- **Antigravity/Gemini**: Commands in `.gemini/commands/`
- **VSCode**: Commands in `.vscode/commands/`

### Available Commands

Access these ADbS commands directly from your IDE's command palette (Ctrl+Shift+P / Cmd+Shift+P):

- **ADbS: New Work** - Start new feature or fix
- **ADbS: Status** - Show current work status
- **ADbS: Done** - Mark work as complete
- **ADbS: Help** - Show help and commands
- **ADbS: Workflow** - Show workflow state
- **ADbS: Add Task** - Add a task or reminder

### How it works

The installer automatically:
1. Detects your IDE (Cursor, Gemini, VSCode)
2. Creates the appropriate commands directory
3. Generates command files for quick access
4. Makes ADbS commands available in your IDE's command palette

No manual configuration needed!

## For Maintainers

See [Publishing Guide](../docs/PUBLISHING.md) for instructions on how to publish to each package manager.

## Notes

- Root-level `install.sh`, `install.ps1`, and `install.bat` are redirector scripts for backward compatibility
- All installation methods create the same `.adbs/` directory structure
- Installation scripts are designed to work both from repository and from remote (curl/wget)
