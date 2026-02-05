#!/bin/bash
# ADbS Installation Script for Termux (Android)
# Install: curl -sSL https://raw.githubusercontent.com/oyi77/ADbS/main/distribution/install-termux.sh | bash

set -e

# Detect Termux environment
if [ ! -d "$HOME/.termux" ]; then
    echo "[ERROR] This script is designed for Termux on Android."
    echo "Please install Termux from F-Droid: https://f-droid.org/packages/com.termux/"
    exit 1
fi

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
print_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Variables
TERMUX_PREFIX="${PREFIX:-"$HOME/.termux/proc-self/rootfs"}"
INSTALL_DIR="$HOME/.local/bin"
ADBS_REPO="oyi77/ADbS"
ADBS_VERSION="latest"

print_info "Installing ADbS for Termux..."

# Detect architecture
ARCH=$(uname -m)
case "$ARCH" in
    aarch64)
        PLATFORM="linux-arm64"
        ;;
    armv7l|armhf)
        PLATFORM="linux-arm"
        ;;
    i686|i386)
        PLATFORM="linux-386"
        ;;
    x86_64)
        PLATFORM="linux-amd64"
        ;;
    *)
        print_error "Unsupported architecture: $ARCH"
        exit 1
        ;;
esac

print_info "Detected platform: $PLATFORM"

# Create installation directory
mkdir -p "$INSTALL_DIR"

# Get latest release version
if [ "$ADBS_VERSION" = "latest" ]; then
    print_info "Fetching latest version..."
    ADBS_VERSION=$(curl -sSL "https://api.github.com/repos/$ADBS_REPO/releases/latest" | grep '"tag_name"' | cut -d'"' -f4)
fi

print_info "Installing ADbS version: $ADBS_VERSION"

# Download binary
BINARY_URL="https://github.com/$ADBS_REPO/releases/download/$ADBS_VERSION/adbs-$PLATFORM"
print_info "Downloading from: $BINARY_URL"

curl -sSL "$BINARY_URL" -o "$INSTALL_DIR/adbs"
chmod +x "$INSTALL_DIR/adbs"

# Add to PATH if not already present
TERMUX_PROFILE="$HOME/.termux/bashrc"
if ! grep -q "export PATH.*ADbS" "$TERMUX_PROFILE" 2>/dev/null; then
    echo "" >> "$TERMUX_PROFILE"
    echo "# ADbS" >> "$TERMUX_PROFILE"
    echo "export PATH=\"\$HOME/.local/bin:\$PATH\"" >> "$TERMUX_PROFILE"
    print_info "Added ADbS to PATH in $TERMUX_PROFILE"
fi

# Initialize ADbS
print_info "Initializing ADbS..."
"$INSTALL_DIR/adbs" setup

print_success "ADbS installed successfully!"
print_info "To start using ADbS, restart Termux or run:"
print_info "  source $TERMUX_PROFILE"
print_info ""
print_info "Commands:"
print_info "  adbs new \"feature-name\"  - Start new work"
print_info "  adbs status             - Check status"
print_info "  adbs help              - Show help"
