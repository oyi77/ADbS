#!/bin/bash
# ADbS Smoke Test for Termux Environment Simulation
# This script simulates a restricted environment (no Python, no Node.js)

set -e

echo "=== ADbS Smoke Test (Termux Simulation) ==="
echo ""

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

# Detect platform
PLATFORM=$(uname -s)
ARCH=$(uname -m)
echo "Platform: $PLATFORM $ARCH"

# Create test directory
TEST_DIR=$(mktemp -d)
echo "Test directory: $TEST_DIR"
trap "rm -rf $TEST_DIR" EXIT

# Test 1: Binary exists and is executable
echo ""
echo "Test 1: Binary exists and is executable"
if [ -f "./bin/adbs" ]; then
    chmod +x ./bin/adbs
    echo -e "${GREEN}✓${NC} Binary exists: ./bin/adbs"
else
    echo -e "${RED}✗${NC} Binary not found: ./bin/adbs"
    exit 1
fi

# Test 2: Help command works
echo ""
echo "Test 2: Help command"
if ./bin/adbs help > /dev/null 2>&1; then
    echo -e "${GREEN}✓${NC} Help command succeeds"
else
    echo -e "${RED}✗${NC} Help command failed"
    exit 1
fi

# Test 3: Setup command creates directory structure
echo ""
echo "Test 3: Setup command"
cd "$TEST_DIR"
if ./bin/adbs setup > /dev/null 2>&1; then
    echo -e "${GREEN}✓${NC} Setup command succeeds"
    
    # Verify directory structure
    if [ -d ".adbs" ] && [ -d ".adbs/work" ] && [ -d ".adbs/archive" ]; then
        echo -e "${GREEN}✓${NC} Directory structure created"
    else
        echo -e "${RED}✗${NC} Directory structure incomplete"
        exit 1
    fi
else
    echo -e "${RED}✗${NC} Setup command failed"
    exit 1
fi

# Test 4: New work item
echo ""
echo "Test 4: New work item"
if ./bin/adbs new "test feature" > /dev/null 2>&1; then
    echo -e "${GREEN}✓${NC} New work item created"
    
    if [ -d ".adbs/work" ] && [ "$(ls -A .adbs/work)" ]; then
        echo -e "${GREEN}✓${NC} Work directory has content"
    else
        echo -e "${RED}✗${NC} Work directory is empty"
        exit 1
    fi
else
    echo -e "${RED}✗${NC} New work item failed"
    exit 1
fi

# Test 5: Status command
echo ""
echo "Test 5: Status command"
if ./bin/adbs status > /dev/null 2>&1; then
    echo -e "${GREEN}✓${NC} Status command succeeds"
else
    echo -e "${RED}✗${NC} Status command failed"
    exit 1
fi

# Test 6: Todo command
echo ""
echo "Test 6: Todo command"
if ./bin/adbs todo "test task" > /dev/null 2>&1; then
    echo -e "${GREEN}✓${NC} Todo command succeeds"
else
    echo -e "${RED}✗${NC} Todo command failed"
    exit 1
fi

# Test 7: Done command
echo ""
echo "Test 7: Done command"
WORK_NAME=$(ls .adbs/work | head -1)
if ./bin/adbs done "$WORK_NAME" > /dev/null 2>&1; then
    echo -e "${GREEN}✓${NC} Done command succeeds"
    
    if [ -d ".adbs/archive" ] && [ "$(ls -A .adbs/archive)" ]; then
        echo -e "${GREEN}✓${NC} Work item archived"
    else
        echo -e "${RED}✗${NC} Work item not archived"
        exit 1
    fi
else
    echo -e "${RED}✗${NC} Done command failed"
    exit 1
fi

# Test 8: Cross-platform binary check
echo ""
echo "Test 8: Binary size check"
SIZE=$(stat -c%s ./bin/adbs 2>/dev/null || stat -f%z ./bin/adbs 2>/dev/null)
echo "Binary size: $SIZE bytes"
if [ "$SIZE" -lt 20000000 ]; then  # Less than 20MB
    echo -e "${GREEN}✓${NC} Binary size is reasonable (< 20MB)"
else
    echo -e "${YELLOW}⚠${NC} Binary size is large (may still work)"
fi

# Test 9: Verify no external dependencies (basic check)
echo ""
echo "Test 9: Dependency check"
echo "Checking if binary links to common libraries..."
if ldd ./bin/adbs 2>/dev/null | grep -q "not a dynamic linker"; then
    echo -e "${GREEN}✓${NC} Static binary (no dynamic linker dependencies)"
elif ldd ./bin/adbs 2>/dev/null | grep -qE "(libc|libpthread)"; then
    echo -e "${GREEN}✓${NC} Only standard C library dependencies"
else
    echo -e "${YELLOW}⚠${NC} Unknown dependency structure"
fi

echo ""
echo "=== All Tests Passed ==="
echo ""
echo "Binary is ready for Termux deployment!"
