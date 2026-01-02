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

# Download beads binary (optional)
download_beads() {
    local os="$1"
    local arch="$2"
    local beads_dir="bin/beads"
    
    print_info "Checking for Beads binary availability..."
    
    # Beads release URL (adjust based on actual releases)
    local beads_version="v0.30.0"
    local beads_url="https://github.com/steveyegge/beads/releases/download/${beads_version}/bd-${os}-${arch}"
    
    mkdir -p "$beads_dir"
    
    local download_cmd=$(get_download_cmd)
    if [ -z "$download_cmd" ]; then
        print_warning "Cannot download Beads (no curl/wget)"
        return 1
    fi
    
    print_info "Attempting to download Beads binary..."
    if $download_cmd "$beads_url" > "$beads_dir/bd" 2>/dev/null; then
        chmod +x "$beads_dir/bd"
        if "$beads_dir/bd" --version &> /dev/null; then
            print_success "Beads binary downloaded and verified"
            return 0
        else
            print_warning "Downloaded file is not a valid Beads binary"
            rm -f "$beads_dir/bd"
            return 1
        fi
    else
        print_warning "Beads binary not available for $os/$arch (will use alternative task manager)"
        rm -f "$beads_dir/bd"
        return 1
    fi
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
    if [ -f "lib/rules_generator.sh" ]; then
        print_info "Generating platform-specific rules files..."
        chmod +x lib/rules_generator.sh 2>/dev/null || true
        lib/rules_generator.sh generate "$platform" > /dev/null 2>&1 || true
        print_success "Generated rules files in $rules_dir/rules/"
    else
        # Fallback to old single-file generation
        if [ ! -f "$rules_dir/$rules_file" ]; then
            generate_rules_file "$rules_dir" "$rules_file"
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
    
    # Create ADbS directory structure
    mkdir -p ".adbs/work" ".adbs/archive" ".adbs/internal"
    print_success "Created ADbS directory structure: .adbs/"
    
    # Initialize workflow
    if [ ! -f ".workflow-enforcer/current-stage" ]; then
        echo "explore" > ".workflow-enforcer/current-stage"
        print_success "Initialized workflow (starting at 'explore' stage)"
    fi
    
    # Make scripts executable
    print_info "Making scripts executable..."
    find lib -type f -name "*.sh" -exec chmod +x {} \; 2>/dev/null || true
    find bin -type f -exec chmod +x {} \; 2>/dev/null || true
    chmod +x install.sh 2>/dev/null || true
    print_success "Scripts are executable"
    
    # Try to download Beads (optional)
    if [ "$os" != "unknown" ] && [ "$arch" != "unknown" ]; then
        download_beads "$os" "$arch" || true
    else
        print_warning "Cannot determine OS/arch for Beads download"
    fi
    
    # Setup PATH (optional - user can add manually)
    local bin_path="$(pwd)/bin"
    if [[ ":$PATH:" != *":$bin_path:"* ]]; then
        print_info "To use 'adbs' command, add to PATH:"
        echo "  export PATH=\"\$PATH:$bin_path\""
        echo ""
        print_info "Or use directly:"
        echo "  $bin_path/adbs --help"
        echo ""
        print_info "Note: 'adbs' is a shorter alias for 'workflow-enforcer'"
    fi
    
    echo ""
    print_success "Installation complete!"
    echo ""
    print_info "Next steps:"
    echo "  1. Review rules files in: $rules_dir/rules/"
    echo "  2. Run: ./bin/adbs status"
    echo "  3. Start with explore stage: Create .sdd/plans/explore.md"
    echo ""
    print_info "For help: ./bin/adbs help"
    print_info "Note: 'adbs' is a shorter alias for 'workflow-enforcer'"
}

# Run main function
main "$@"

