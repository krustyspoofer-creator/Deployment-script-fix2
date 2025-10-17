#!/bin/bash

###############################################################################
# Installation Script
# Description: Setup and configure the deployment system
###############################################################################

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo -e "${BLUE}╔════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  Deployment System Installation           ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════╝${NC}"
echo ""

###############################################################################
# Check Prerequisites
###############################################################################

echo -e "${YELLOW}[1/5] Checking prerequisites...${NC}"

MISSING_DEPS=()

# Check for required commands
for cmd in bash python3 git curl; do
    if ! command -v "$cmd" &> /dev/null; then
        MISSING_DEPS+=("$cmd")
        echo -e "${RED}  ✗ $cmd not found${NC}"
    else
        version=$($cmd --version 2>&1 | head -n 1)
        echo -e "${GREEN}  ✓ $cmd found${NC}"
    fi
done

# Check for optional but recommended commands
for cmd in jq shellcheck; do
    if ! command -v "$cmd" &> /dev/null; then
        echo -e "${YELLOW}  ⚠ $cmd not found (optional)${NC}"
    else
        echo -e "${GREEN}  ✓ $cmd found${NC}"
    fi
done

if [ ${#MISSING_DEPS[@]} -ne 0 ]; then
    echo -e "\n${RED}Missing required dependencies: ${MISSING_DEPS[*]}${NC}"
    echo -e "${YELLOW}Please install them and run this script again.${NC}"
    exit 1
fi

echo -e "${GREEN}All required dependencies satisfied!${NC}\n"

###############################################################################
# Setup Directory Structure
###############################################################################

echo -e "${YELLOW}[2/5] Setting up directory structure...${NC}"

mkdir -p "${SCRIPT_DIR}/logs"
mkdir -p "${SCRIPT_DIR}/backups"

echo -e "${GREEN}  ✓ Created logs directory${NC}"
echo -e "${GREEN}  ✓ Created backups directory${NC}\n"

###############################################################################
# Make Scripts Executable
###############################################################################

echo -e "${YELLOW}[3/5] Making scripts executable...${NC}"

for script in deploy.sh health-check.sh watchdog.py; do
    if [ -f "${SCRIPT_DIR}/${script}" ]; then
        chmod +x "${SCRIPT_DIR}/${script}"
        echo -e "${GREEN}  ✓ Made ${script} executable${NC}"
    else
        echo -e "${YELLOW}  ⚠ ${script} not found${NC}"
    fi
done

echo ""

###############################################################################
# Validate Configuration
###############################################################################

echo -e "${YELLOW}[4/5] Validating configuration...${NC}"

if [ -f "${SCRIPT_DIR}/config.json" ]; then
    if python3 -m json.tool "${SCRIPT_DIR}/config.json" > /dev/null 2>&1; then
        echo -e "${GREEN}  ✓ Configuration file is valid${NC}"
    else
        echo -e "${RED}  ✗ Configuration file has syntax errors${NC}"
        exit 1
    fi
else
    echo -e "${YELLOW}  ⚠ Configuration file not found${NC}"
fi

echo ""

###############################################################################
# Test Installation
###############################################################################

echo -e "${YELLOW}[5/5] Testing installation...${NC}"

# Test deployment script syntax
if bash -n "${SCRIPT_DIR}/deploy.sh" 2>/dev/null; then
    echo -e "${GREEN}  ✓ Deployment script syntax valid${NC}"
else
    echo -e "${RED}  ✗ Deployment script has syntax errors${NC}"
    exit 1
fi

# Test health check script syntax
if bash -n "${SCRIPT_DIR}/health-check.sh" 2>/dev/null; then
    echo -e "${GREEN}  ✓ Health check script syntax valid${NC}"
else
    echo -e "${RED}  ✗ Health check script has syntax errors${NC}"
    exit 1
fi

# Test watchdog script syntax
if python3 -m py_compile "${SCRIPT_DIR}/watchdog.py" 2>/dev/null; then
    echo -e "${GREEN}  ✓ Watchdog script syntax valid${NC}"
else
    echo -e "${RED}  ✗ Watchdog script has syntax errors${NC}"
    exit 1
fi

echo ""

###############################################################################
# Installation Complete
###############################################################################

echo -e "${GREEN}╔════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║  Installation Complete!                    ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${BLUE}Next steps:${NC}"
echo -e "  1. Review and customize ${YELLOW}config.json${NC}"
echo -e "  2. Run a test deployment: ${YELLOW}./deploy.sh${NC}"
echo -e "  3. Check system health: ${YELLOW}./health-check.sh${NC}"
echo -e "  4. Start monitoring: ${YELLOW}python3 watchdog.py${NC}"
echo ""
echo -e "${BLUE}Documentation:${NC}"
echo -e "  • README.md - Complete guide"
echo -e "  • CONTRIBUTING.md - Contribution guidelines"
echo ""
echo -e "${GREEN}Happy deploying! 🚀${NC}"
