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
        elif [ -d ".gemini" ] || [ -n "$GEMINI" ]; then
        echo "gemini"
    elif [ -d ".antigravity" ] || [ -n "$ANTIGRAVITY" ]; then
        echo "antigravity"
    elif [ -d ".vscode" ] || [ -n "$VSCODE" ] || [ -n "$CODE" ]; then
        echo "vscode"
    else
        echo "generic"
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
        gemini|antigravity)
            echo ".gemini"
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
        antigravity)
            commands_dir=".antigravity/commands"
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
    
    # Create adbs wrapper script in .adbs/bin
    # For remote installations, create a standalone script
    # For local installations, use the repository script
    if [ -f "bin/workflow-enforcer" ]; then
        # Local installation - copy the wrapper
        if [ -f "bin/adbs" ]; then
            cp bin/adbs .adbs/bin/adbs
            chmod +x .adbs/bin/adbs
        fi
    # Main installation logic
    
    # 1. Determine Installation Level
    local install_level="project"
    local install_dir=""
    local bin_link_dir=""
    
    # Check for requested level or auto-detect
    if [ "$EUID" -eq 0 ]; then
        # Running as root - Default to Global
        install_level="global"
        install_dir="/usr/local/share/adbs"
        bin_link_dir="/usr/local/bin"
    elif [ -n "$HOME" ] && [ -w "$HOME" ]; then
        # Running as user - Default to User
        install_level="user"
        install_dir="$HOME/.adbs_tool"
        bin_link_dir="$HOME/bin" # or ~/.local/bin
        mkdir -p "$bin_link_dir"
    else
        # Fallback to Project
        install_level="project"
        install_dir="$(pwd)/.adbs/internal"
        bin_link_dir="$(pwd)/.adbs/bin"
    fi
    
    # Allow override via env var
    if [ -n "$ADBS_INSTALL_LEVEL" ]; then
        case "$ADBS_INSTALL_LEVEL" in
            global)
                if [ "$EUID" -ne 0 ]; then
                    print_error "Global installation requires root privileges"
                    exit 1
                fi
                install_level="global"
                install_dir="/usr/local/share/adbs"
                bin_link_dir="/usr/local/bin"
                ;;
            user)
                install_level="user"
                install_dir="$HOME/.adbs_tool"
                bin_link_dir="$HOME/.local/bin"
                mkdir -p "$bin_link_dir"
                ;;
            project)
                install_level="project"
                install_dir="$(pwd)/.adbs/internal"
                bin_link_dir="$(pwd)/.adbs/bin"
                ;;
        esac
    fi
    
    print_info "Installing ADbS at $install_level level ($install_dir)..."
    
    # 2. Safety & Version Checks
    local current_version="0.0.0"
    if [ -f "$install_dir/VERSION" ]; then
        current_version=$(cat "$install_dir/VERSION")
        print_info "Found existing installation (v$current_version)"
        
        # Simple version comparison could go here
        # For now, we assume reinstall = upgrade
        print_info "Upgrading to latest version..."
        
        # Backup existing config if any
        if [ -d "$install_dir/config" ]; then
            cp -r "$install_dir/config" "$install_dir/config_backup_$(date +%s)"
        fi
    fi
    
    # 3. Prepare Directories
    mkdir -p "$install_dir/bin"
    mkdir -p "$install_dir/lib/internal"
    mkdir -p "$install_dir/lib/task_manager"
    mkdir -p "$install_dir/config"
    
    # 4. Download/Install Files
    local base_url="https://raw.githubusercontent.com/oyi77/ADbS/main"
    
    # Function to download to install_dir
    download_to_install() {
        local path="$1"
        local dest="$install_dir/$path"
        
        # Create parent dir
        mkdir -p "$(dirname "$dest")"
        
        if command -v curl &> /dev/null; then
            if ! curl -fsSL "$base_url/$path" > "$dest" 2>/dev/null; then
                 print_warning "Failed to download $path"
                 return 1
            fi
        elif command -v wget &> /dev/null; then
             if ! wget -qO "$dest" "$base_url/$path" 2>/dev/null; then
                 print_warning "Failed to download $path"
                 return 1
             fi
        fi
        chmod +x "$dest" 2>/dev/null || true
    }
    
    print_info "Downloading core scripts..."
    download_to_install "bin/workflow-enforcer"
    download_to_install "lib/platform_detector.sh"
    download_to_install "lib/rules_generator.sh"
    download_to_install "lib/ui.sh"
    download_to_install "lib/utils.sh"
    
    print_info "Downloading internal modules..."
    download_to_install "lib/internal/work_manager.sh"
    download_to_install "lib/internal/task_backend.sh"
    download_to_install "lib/internal/migrator.sh"
    download_to_install "lib/internal/state_machine.sh"
    download_to_install "lib/internal/workflow_generator.sh"
    download_to_install "lib/internal/memory.sh"
    download_to_install "lib/task_manager/beads_wrapper.sh"
    download_to_install "lib/task_manager/simple.sh"
    
    # Write Version
    echo "0.3.0" > "$install_dir/VERSION"
    
    # 5. Create ADbS Wrapper
    local wrapper_path="$bin_link_dir/adbs"
    if [ "$install_level" == "project" ]; then
        wrapper_path=".adbs/bin/adbs"
    fi
    mkdir -p "$(dirname "$wrapper_path")"
    
    cat > "$wrapper_path" <<ADBS_WRAPPER
#!/bin/bash
# ADbS - AI Don't Be Stupid
# Wrapper script (Level: $install_level)

# Install Dir
ADBS_HOME="$install_dir"

# Export Installation Directory for global config access
export ADBS_INSTALL_DIR="$install_dir"

# Current Project Root (if any)
# Traverse up to find .adbs directory
find_project_root() {
    local dir="\$(pwd)"
    while [ "\$dir" != "/" ]; do
        if [ -d "\$dir/.adbs" ]; then
            echo "\$dir"
            return
        fi
        dir="\$(dirname "\$dir")"
    done
}

PROJECT_ROOT="\$(find_project_root)"

# If running 'new' or 'setup' and no project root, use current dir
if [ -z "\$PROJECT_ROOT" ] && [[ "\$1" == "new" || "\$1" == "setup" || "\$1" == "init" ]]; then
    PROJECT_ROOT="\$(pwd)"
fi

# Execute workflow-enforcer
if [ -f "\$ADBS_HOME/bin/workflow-enforcer" ]; then
    # Pass PROJECT_ROOT as env var so enforcer knows where to work
    export ADBS_PROJECT_ROOT="\$PROJECT_ROOT"
    exec "\$ADBS_HOME/bin/workflow-enforcer" "\$@"
else
    echo "Error: ADbS installation not found at \$ADBS_HOME"
    exit 1
fi
ADBS_WRAPPER
    
    chmod +x "$wrapper_path"
    print_success "Installed adbs command to $wrapper_path"
    
    # 6. Setup PATH (if needed)
    # Only if not linking to /usr/local/bin or standard path
    if [[ ":$PATH:" != *":$bin_link_dir:"* ]]; then
        # Add to shell RC
        local bin_path="$bin_link_dir"
        local updated_rc=false
        
        # Update RCs logic (zsh, bash, fish)
        if [ -f "$HOME/.zshrc" ]; then
            if ! grep -q "$bin_path" "$HOME/.zshrc"; then
                echo "" >> "$HOME/.zshrc"
                echo "export PATH=\"\$PATH:$bin_path\" # ADbS" >> "$HOME/.zshrc"
                updated_rc=true
            fi
        fi
        if [ -f "$HOME/.bashrc" ]; then
             if ! grep -q "$bin_path" "$HOME/.bashrc"; then
                echo "" >> "$HOME/.bashrc"
                echo "export PATH=\"\$PATH:$bin_path\" # ADbS" >> "$HOME/.bashrc"
                updated_rc=true
            fi
        fi
        
        if [ "$updated_rc" = true ]; then
            print_success "Added $bin_path to PATH"
        else
            print_warning "Please ensure $bin_path is in your PATH"
        fi
    fi
    
    # 7. Generate IDE commands (Global/User level might be different, but for now typical)
    # If project level, we did it for .cursor etc. 
    # For user level, we might want to install to user's vscode/cursor settings?
    # Keeping existing logic for project-level IDE commands if we are in a project
    if [ -d ".cursor" ] || [ -d ".vscode" ]; then
        generate_ide_commands "auto"
    fi
    
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

