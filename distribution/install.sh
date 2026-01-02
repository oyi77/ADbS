#!/bin/bash
# ADbS Installation Script
# Single-line installation: curl -sSL https://raw.githubusercontent.com/oyi77/ADbS/main/install.sh | bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Print functions
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Detect OS
detect_os() {
    case "$(uname -s)" in
        Linux*)
            echo "linux"
            ;;
        Darwin*)
            echo "darwin"
            ;;
        MINGW*|MSYS*|CYGWIN*)
            echo "windows"
            ;;
        *)
            echo "unknown"
            ;;
    esac
}

# Detect shell
detect_shell() {
    if [ -n "$PSVersionTable" ] || command -v pwsh &> /dev/null || command -v powershell &> /dev/null; then
        echo "powershell"
    elif [ -n "$BASH_VERSION" ]; then
        echo "bash"
    elif [ -n "$ZSH_VERSION" ]; then
        echo "zsh"
    else
        echo "sh"
    fi
}

# Route to appropriate installer
route_installer() {
    local os=$(detect_os)
    local shell=$(detect_shell)
    
    # On Windows, prefer PowerShell installer
    if [ "$os" = "windows" ]; then
        if command -v powershell &> /dev/null || command -v pwsh &> /dev/null; then
            if [ -f "install.ps1" ]; then
                echo "Routing to PowerShell installer..."
                if command -v pwsh &> /dev/null; then
                    pwsh -ExecutionPolicy Bypass -File install.ps1 "$@"
                else
                    powershell -ExecutionPolicy Bypass -File install.ps1 "$@"
                fi
                exit $?
            fi
        fi
        # Fallback to batch file
        if [ -f "install.bat" ]; then
            echo "Routing to batch installer..."
            cmd //c install.bat "$@"
            exit $?
        fi
    fi
    
    # On Unix-like systems, continue with bash installer
    return 0
}

# Detect architecture
detect_arch() {
    case "$(uname -m)" in
        x86_64|amd64)
            echo "amd64"
            ;;
        arm64|aarch64)
            echo "arm64"
            ;;
        *)
            echo "unknown"
            ;;
    esac
}

# Check for required commands
check_requirements() {
    local missing=()
    
    if ! command -v curl &> /dev/null && ! command -v wget &> /dev/null; then
        missing+=("curl or wget")
    fi
    
    if [ ${#missing[@]} -gt 0 ]; then
        print_error "Missing required commands: ${missing[*]}"
        return 1
    fi
    
    return 0
}

# Get download command
get_download_cmd() {
    if command -v curl &> /dev/null; then
        echo "curl -sSL"
    elif command -v wget &> /dev/null; then
        echo "wget -qO-"
    else
        return 1
    fi
}

# Detect platform/IDE (using platform_detector if available, otherwise basic detection)
detect_platform() {
    if [ -f "lib/platform_detector.sh" ] && [ -x "lib/platform_detector.sh" ]; then
        ./lib/platform_detector.sh detect
    else
        # Basic detection
        if [ -d ".cursor" ] || [ -n "${CURSOR}" ]; then
            echo "cursor"
        elif [ -d ".trae" ] || [ -n "${TRAE}" ]; then
            echo "trae"
        elif [ -d ".vscode" ] || [ -n "${VSCODE}" ]; then
            echo "vscode"
        else
            echo "generic"
        fi
    fi
}

# Get rules directory for platform
get_rules_dir() {
    local platform="$1"
    
    case "$platform" in
        cursor)
            echo ".cursor"
            ;;
        trae)
            echo ".trae"
            ;;
        vscode)
            echo ".vscode"
            ;;
        *)
            echo ".ai-rules"
            ;;
    esac
}

# Generate platform-specific rules file
generate_rules_file() {
    local rules_dir="$1"
    local rules_file="$2"
    local full_path="$rules_dir/$rules_file"
    
    if [ ! -f "config/rules-template.md" ]; then
        print_warning "Rules template not found, creating basic rules file"
        cat > "$full_path" <<'EOF'
# AI Development Workflow Enforcement Rules

This project uses SDD (Specification-Driven Development) and Beads task management.

## Workflow Stages

1. Explore - Research and understand
2. Plan - Outline objectives
3. SDD - Requirements, Design, Tasks
4. Assign - Task management
5. Execution - Implementation

See README.md for complete documentation.
EOF
    else
        cp "config/rules-template.md" "$full_path"
    fi
    
    print_success "Created rules file: $full_path"
}

# Download task manager (internal - silent)
download_task_manager() {
    # Silently install task manager in .adbs/internal
    mkdir -p ".adbs/internal/bin"
    
    # Use Beads installation script but redirect to .adbs/internal
    if command -v curl &> /dev/null; then
        export BEADS_INSTALL_DIR=".adbs/internal"
        curl -fsSL https://raw.githubusercontent.com/steveyegge/beads/main/scripts/install.sh | bash > /dev/null 2>&1 || true
    fi
    
    # Create symlink if beads was installed
    if [ -f ".adbs/internal/bin/bd" ]; then
        chmod +x ".adbs/internal/bin/bd"
    fi
    
    return 0
}

# Generate IDE commands
generate_ide_commands() {
    local platform="$1"
    local commands_dir=""
    
    case "$platform" in
        cursor)
            commands_dir=".cursor/commands"
            ;;
        gemini)
            commands_dir=".gemini/commands"
            ;;
        vscode)
            commands_dir=".vscode/commands"
            ;;
        *)
            return 0  # Skip for unknown platforms
            ;;
    esac
    
    mkdir -p "$commands_dir"
    
    # Try to copy from config/commands if available (local install)
    if [ -d "config/commands" ]; then
        cp config/commands/*.md "$commands_dir/" 2>/dev/null || true
        print_success "Generated IDE commands in $commands_dir/"
        return 0
    fi
    
    # Otherwise create commands inline (remote install)
    # Command: ADbS New
    cat > "$commands_dir/adbs-new.md" <<'EOF'
---
name: "ADbS: New Work"
description: "Start new feature or fix with ADbS"
---

# ADbS: New Work

Start a new work item with ADbS (AI Don't Be Stupid).

**Simple workflow:**
```bash
adbs new "feature-name"
```

**AI-powered workflow:**
```bash
adbs new "feature-name" --ai-generate"
```
EOF

    # Command: ADbS Status
    cat > "$commands_dir/adbs-status.md" <<'EOF'
---
name: "ADbS: Status"
description: "Show current ADbS work status"
---

# ADbS: Status

Show the current status of all active work items.

```bash
adbs status
```
EOF

    # Command: ADbS Done
    cat > "$commands_dir/adbs-done.md" <<'EOF'
---
name: "ADbS: Done"
description: "Mark work as complete and archive it"
---

# ADbS: Done

Mark a work item as complete and move it to the archive.

```bash
adbs done "feature-name"
```
EOF

    # Command: ADbS Help
    cat > "$commands_dir/adbs-help.md" <<'EOF'
---
name: "ADbS: Help"
description: "Show ADbS help and available commands"
---

# ADbS: Help

Get help with ADbS (AI Don't Be Stupid) commands.

```bash
adbs help
```
EOF

    # Command: ADbS Workflow
    cat > "$commands_dir/adbs-workflow.md" <<'EOF'
---
name: "ADbS: Workflow"
description: "Show detailed workflow state"
---

# ADbS: Workflow

Show the detailed workflow state for a work item.

```bash
adbs workflow "feature-name"
```
EOF

    # Command: ADbS Todo
    cat > "$commands_dir/adbs-todo.md" <<'EOF'
---
name: "ADbS: Add Task"
description: "Add a new task or reminder"
---

# ADbS: Add Task

Add a new task or reminder to your current work.

```bash
adbs todo "task description"
```
EOF

    print_success "Generated IDE commands in $commands_dir/"
}


# Main installation
main() {
    # Parse flags
    local force_yes=false
    for arg in "$@"; do
        case "$arg" in
            --yes|-y) force_yes=true ;;
        esac
    done
    export INSTALL_FORCE_YES="$force_yes"
    
    # Route to appropriate installer if needed
    route_installer "$@"
    
    print_info "ADbS Installation Script (Bash)"
    print_info "================================="
    echo ""
    
    # Check requirements
    if ! check_requirements; then
        exit 1
    fi
    
    # Detect OS and architecture
    local os=$(detect_os)
    local arch=$(detect_arch)
    print_info "Detected OS: $os, Architecture: $arch"
    
    # Detect platform/IDE
    local platform=$(detect_platform)
    print_info "Detected platform: $platform"
    
    # Get rules directory
    local rules_dir=$(get_rules_dir "$platform")
    local rules_file="rules"
    
    # Create rules directory
    mkdir -p "$rules_dir"
    print_success "Created rules directory: $rules_dir"
    
    # Generate rules files using rules generator
    local rules_generated=false
    if [ -f "lib/rules_generator.sh" ]; then
        print_info "Generating platform-specific rules files..."
        chmod +x lib/rules_generator.sh 2>/dev/null || true
        if lib/rules_generator.sh generate "$platform" > /dev/null 2>&1; then
            print_success "Generated rules files in $rules_dir/rules/"
            rules_generated=true
        else
            print_warning "Rules generator failed, falling back to basic rules generation"
        fi
    fi
    
    # Fallback to old single-file generation only if rules_generator didn't succeed
    if [ "$rules_generated" = "false" ]; then
        if [ ! -f "$rules_dir/$rules_file" ] && [ ! -d "$rules_dir/$rules_file" ]; then
            generate_rules_file "$rules_dir" "$rules_file"
        else
            if [ -d "$rules_dir/$rules_file" ]; then
                print_success "Rules directory already exists: $rules_dir/$rules_file/"
            else
                print_warning "Rules file already exists: $rules_dir/$rules_file"
                if [ "$INSTALL_FORCE_YES" = "true" ]; then
                    generate_rules_file "$rules_dir" "$rules_file"
                else
                    read -p "Overwrite? (y/N): " -n 1 -r
                    echo
                    if [[ $REPLY =~ ^[Yy]$ ]]; then
                        generate_rules_file "$rules_dir" "$rules_file"
                    fi
                fi
            fi
        fi
    fi
    
    # Generate IDE commands
    generate_ide_commands "$platform"
    
    # Create ADbS directory structure (everything in .adbs)
    mkdir -p ".adbs/work" ".adbs/archive" ".adbs/internal" ".adbs/bin" ".adbs/config"
    print_success "Created ADbS directory structure: .adbs/"
    
    # Initialize workflow state in .adbs
    if [ ! -f ".adbs/config/current-stage" ]; then
        echo "explore" > ".adbs/config/current-stage"
        print_success "Initialized workflow (starting at 'explore' stage)"
    fi
    
    # Make scripts executable
    print_info "Setting up ADbS command..."
    find lib -type f -name "*.sh" -exec chmod +x {} \; 2>/dev/null || true
    find bin -type f -exec chmod +x {} \; 2>/dev/null || true
    chmod +x install.sh 2>/dev/null || true
    
    # Copy adbs command to .adbs/bin for easy access
    if [ -f "bin/adbs" ]; then
        cp bin/adbs .adbs/bin/adbs
        chmod +x .adbs/bin/adbs
    fi
    
    # Download task manager silently
    download_task_manager
    
    # Setup PATH automatically
    local bin_path="$(pwd)/.adbs/bin"
    local shell_rc=""
    
    # Detect shell config file
    if [ -n "$BASH_VERSION" ]; then
        shell_rc="$HOME/.bashrc"
    elif [ -n "$ZSH_VERSION" ]; then
        shell_rc="$HOME/.zshrc"
    fi
    
    # Add to PATH if not already there
    if [ -n "$shell_rc" ] && [ -f "$shell_rc" ]; then
        if ! grep -q ".adbs/bin" "$shell_rc" 2>/dev/null; then
            echo "" >> "$shell_rc"
            echo "# ADbS - AI Don't Be Stupid" >> "$shell_rc"
            echo "export PATH=\"\$PATH:$bin_path\"" >> "$shell_rc"
            print_success "Added ADbS to PATH in $shell_rc"
        fi
    fi
    
    # Also make it available in current session
    export PATH="$PATH:$bin_path"
    
    echo ""
    print_success "Installation complete!"
    echo ""
    print_info "ADbS (AI Don't Be Stupid) is now installed!"
    echo ""
    print_info "Next steps:"
    echo "  1. Reload your shell: source ~/.bashrc (or ~/.zshrc)"
    echo "  2. Run: adbs status"
    echo "  3. Start with explore stage: Create .adbs/plans/explore.md"
    echo ""
    print_info "For help: adbs help"
}

# Run main function
main "$@"

