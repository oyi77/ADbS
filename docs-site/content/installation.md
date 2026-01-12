---
title: "Installation"
description: "Install ADbS on Windows, macOS, Linux, or via npm"
date: 2025-01-01
weight: 20
---

# Installation

Choose your preferred installation method based on your operating system and package manager preferences.

## Quick Install

**Linux/macOS:**
```bash
curl -sSL https://raw.githubusercontent.com/oyi77/ADbS/main/distribution/install.sh | bash
```

**Windows (PowerShell):**
```powershell
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/oyi77/ADbS/main/distribution/install.ps1" -UseBasicParsing | Invoke-Expression
```

## Windows Installation

### Chocolatey (Recommended)

If you have Chocolatey installed:

```powershell
choco install adbs
```

### Winget

Using Windows Package Manager:

```powershell
winget install oyi77.ADbS
```

### PowerShell Script

Direct installation via PowerShell:

```powershell
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/oyi77/ADbS/main/distribution/install.ps1" -UseBasicParsing | Invoke-Expression
```

## Linux / macOS Installation

### Homebrew

For macOS and Linux users with Homebrew:

```bash
brew tap oyi77/adbs
brew install adbs
```

### Bash Script

Direct installation script:

```bash
curl -sSL https://raw.githubusercontent.com/oyi77/ADbS/main/distribution/install.sh | bash
```

Or using `wget`:

```bash
wget -qO- https://raw.githubusercontent.com/oyi77/ADbS/main/distribution/install.sh | bash
```

## Cross-Platform: npm/yarn

### Global Installation

Install ADbS globally using npm or yarn:

```bash
npm install -g @adbs/cli
```

Or with yarn:

```bash
yarn global add @adbs/cli
```

### Project Installation

Install as a development dependency in your project:

```bash
npm install --save-dev @adbs/cli
```

Or with yarn:

```bash
yarn add -D @adbs/cli
```

### Using npx (No Install Required)

Run ADbS without installing:

```bash
npx @adbs/cli setup
```

## Post-Installation Setup

### PATH Configuration

After installation, you may need to add ADbS to your PATH:

**Bash/Zsh (Linux/macOS):**

Add to `~/.bashrc` or `~/.zshrc`:

```bash
export PATH="$PATH:$PWD/.adbs/bin"
```

**PowerShell (Windows):**

Add to your PowerShell profile:

```powershell
$env:PATH += ";$PWD\.adbs\bin"
```

Or add permanently (requires admin):

```powershell
[Environment]::SetEnvironmentVariable('PATH', $env:PATH + ';' + (Join-Path $PWD '.adbs\bin'), 'User')
```

### Using Without PATH Setup

You can also use ADbS directly without PATH configuration:

**Linux/macOS:**
```bash
./.adbs/bin/adbs --help
```

**Windows:**
```powershell
.\.adbs\bin\adbs.ps1 --help
```

## Verify Installation

After installation, verify that ADbS is working:

```bash
adbs version
```

You should see the version number. If you get a "command not found" error:

1. Reload your shell (close and reopen terminal)
2. Check that ADbS was added to your PATH
3. Try using the direct path method above

## What Gets Installed?

The installer will:

1. **Detect your environment** - OS, architecture, and IDE/platform
2. **Create `.adbs` directory structure** - All ADbS files in one place
3. **Generate IDE-specific rules** - Automatically creates rules for your IDE
4. **Make `adbs` command available** - Automatically adds to PATH
5. **Initialize workflow** - Sets up starting state

### Directory Structure

After installation, your project will have:

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

**All ADbS files are self-contained** - your project directory stays clean!

## IDE Integration

ADbS automatically detects and integrates with your IDE during installation:

### Supported IDEs

- **Cursor**: Auto-generates `.cursor/rules`
- **Windsurf**: Native Cascade support
- **Zed**: Project-specific rules
- **VS Code**: Full integration
- **Other AI IDEs**: Universal support

### IDE Commands

After installation, ADbS commands are available in your IDE's command palette (Ctrl+Shift+P / Cmd+Shift+P):

- **ADbS: New Work** - Start new feature or fix
- **ADbS: Status** - Show current work status
- **ADbS: Done** - Mark work as complete
- **ADbS: Help** - Show help and commands
- **ADbS: Workflow** - Show workflow state
- **ADbS: Add Task** - Add a task or reminder

## First Steps

After installation, initialize ADbS in your project:

```bash
# Navigate to your project
cd your-project

# Initialize ADbS
adbs setup

# Start working on something
adbs new "user authentication"

# Check status
adbs status
```

That's it! No configuration needed.

## Troubleshooting

### Command Not Found

If `adbs` command is not found:

1. **Reload your shell** - Close and reopen your terminal
2. **Check PATH** - Verify ADbS was added to your PATH
3. **Use direct path** - Try using `./.adbs/bin/adbs` directly

### Installation Failed

If installation fails:

1. **Check permissions** - Ensure you have write permissions
2. **Check internet connection** - Installation scripts download files
3. **Try manual installation** - Clone the repo and add to PATH manually

### IDE Not Detected

If your IDE is not detected:

1. **Run setup again** - `adbs setup` will regenerate rules
2. **Check IDE support** - Verify your IDE is in the supported list
3. **Manual configuration** - See IDE-specific documentation

## Next Steps

- Read the [Usage Guide](/usage/) to learn how to use ADbS
- Check out the [Demo](/demo/) to see ADbS in action
- Explore the [Documentation](/docs/) for detailed guides

