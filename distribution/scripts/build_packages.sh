#!/usr/bin/env bash
# ADbS Distribution Build Script
# Generates packages for release

set -e

# Configuration
VERSION="0.1.0"
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../" && pwd)"
DIST_DIR="$PROJECT_ROOT/dist"
ARTIFACTS_DIR="$DIST_DIR/artifacts"

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

log() {
    echo -e "${GREEN}[BUILD]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
    exit 1
}

setup_dirs() {
    log "Setting up distribution directories..."
    rm -rf "$DIST_DIR"
    mkdir -p "$ARTIFACTS_DIR"
}

build_tarball() {
    log "Building source tarball (v$VERSION)..."
    local tarball="$ARTIFACTS_DIR/adbs-v$VERSION.tar.gz"
    
    # Exclude dev artifacts, node_modules, .git, etc
    tar --exclude='.git' \
        --exclude='node_modules' \
        --exclude='test-results' \
        --exclude='dist' \
        --exclude='.sdd' \
        --exclude='.workflow-enforcer' \
        -czf "$tarball" \
        -C "$PROJECT_ROOT" .
    
    if [ -f "$tarball" ]; then
        log "Tarball created: $tarball"
        # Calculate Checksum
        if command -v shasum >/dev/null; then
            local sha
            sha=$(shasum -a 256 "$tarball" | awk '{print $1}')
            echo "$sha" > "$tarball.sha256"
            log "Checksum: $sha"
        fi
    else
        error "Failed to create tarball"
    fi
}

build_npm_package() {
    log "Building npm package..."
    local npm_dist="$DIST_DIR/npm"
    mkdir -p "$npm_dist"
    
    # Copy source to temp build dir
    cp -r "$PROJECT_ROOT/package.json" "$npm_dist/" 2>/dev/null || cp "$PROJECT_ROOT/distribution/npm/package.json" "$npm_dist/"
    cp -r "$PROJECT_ROOT/bin" "$npm_dist/"
    cp -r "$PROJECT_ROOT/lib" "$npm_dist/"
    cp -r "$PROJECT_ROOT/README.md" "$npm_dist/"
    
    # Verify package.json exists
    if [ ! -f "$npm_dist/package.json" ]; then
        error "No package.json found for npm build"
    fi
    
    # Pack
    cd "$npm_dist"
    npm pack --pack-destination "$ARTIFACTS_DIR"
    log "npm package created in $ARTIFACTS_DIR"
}

main() {
    setup_dirs
    build_tarball
    build_npm_package
    
    log "Build Complete!"
    ls -l "$ARTIFACTS_DIR"
}

main "$@"
