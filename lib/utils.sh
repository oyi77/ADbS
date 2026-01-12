#!/bin/bash
# Common utilities for ADbS

# Source core common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "$SCRIPT_DIR/core/common.sh" ]; then
    source "$SCRIPT_DIR/core/common.sh"
fi

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Print functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check for JSON processor (jq or python3)
# Deprecated: Use get_json_processor from common.sh
check_json_processor() {
    get_json_processor
}

# Check dependencies
check_dependencies() {
    local missing=()
    for cmd in "$@"; do
        if ! command -v "$cmd" &> /dev/null; then
            missing+=("$cmd")
        fi
    done

    if [ ${#missing[@]} -gt 0 ]; then
        echo "Missing dependencies: ${missing[*]}"
        return 1
    fi
    return 0
}

# Ensure directory exists
# Deprecated: Use ensure_dir_safe from common.sh
ensure_dir() {
    ensure_dir_safe "$1"
}

# JSON helpers
# Deprecated: Use safe_json_get_key from common.sh
json_get_key() {
    safe_json_get_key "$1" "$2" ""
}
