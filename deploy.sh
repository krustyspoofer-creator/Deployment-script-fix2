#!/bin/bash

###############################################################################
# Comprehensive Deployment Script
# Description: Automated deployment with health checks and rollback capabilities
###############################################################################

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_DIR="${SCRIPT_DIR}/logs"
CONFIG_FILE="${SCRIPT_DIR}/config.json"
DEPLOYMENT_TIMESTAMP=$(date +%Y%m%d_%H%M%S)
LOG_FILE="${LOG_DIR}/deployment_${DEPLOYMENT_TIMESTAMP}.log"

# Create log directory if it doesn't exist
mkdir -p "${LOG_DIR}"

###############################################################################
# Logging Functions
###############################################################################

log() {
    local level=$1
    shift
    local message="$*"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo -e "${timestamp} [${level}] ${message}" | tee -a "${LOG_FILE}"
}

log_info() {
    log "INFO" "${GREEN}$*${NC}"
}

log_warn() {
    log "WARN" "${YELLOW}$*${NC}"
}

log_error() {
    log "ERROR" "${RED}$*${NC}"
}

###############################################################################
# Utility Functions
###############################################################################

check_dependencies() {
    log_info "Checking dependencies..."
    local dependencies=("git" "curl" "jq")
    local missing_deps=()
    
    for dep in "${dependencies[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            missing_deps+=("$dep")
        fi
    done
    
    if [ ${#missing_deps[@]} -ne 0 ]; then
        log_error "Missing dependencies: ${missing_deps[*]}"
        log_error "Please install missing dependencies and try again."
        return 1
    fi
    
    log_info "All dependencies satisfied"
    return 0
}

load_config() {
    if [ -f "${CONFIG_FILE}" ]; then
        log_info "Loading configuration from ${CONFIG_FILE}"
        return 0
    else
        log_warn "Configuration file not found, using defaults"
        return 0
    fi
}

health_check() {
    log_info "Running health checks..."
    
    # Check disk space
    local available_space=$(df -h "${SCRIPT_DIR}" | awk 'NR==2 {print $4}')
    log_info "Available disk space: ${available_space}"
    
    # Check memory
    if command -v free &> /dev/null; then
        local available_memory=$(free -h | awk 'NR==2 {print $7}')
        log_info "Available memory: ${available_memory}"
    fi
    
    # Check Git repository status
    if [ -d .git ]; then
        log_info "Checking Git repository status..."
        git status --short | tee -a "${LOG_FILE}"
    fi
    
    log_info "Health checks completed"
    return 0
}

backup_current_state() {
    log_info "Creating backup of current state..."
    local backup_dir="${SCRIPT_DIR}/backups/${DEPLOYMENT_TIMESTAMP}"
    mkdir -p "${backup_dir}"
    
    # Backup important files (if they exist)
    if [ -f "${CONFIG_FILE}" ]; then
        cp "${CONFIG_FILE}" "${backup_dir}/"
    fi
    
    log_info "Backup created at ${backup_dir}"
    return 0
}

rollback() {
    log_error "Deployment failed! Initiating rollback..."
    
    # Find the most recent backup
    local latest_backup=$(ls -t "${SCRIPT_DIR}/backups" 2>/dev/null | head -n 1)
    
    if [ -n "${latest_backup}" ]; then
        log_info "Rolling back to ${latest_backup}"
        # Restore files from backup
        if [ -f "${SCRIPT_DIR}/backups/${latest_backup}/config.json" ]; then
            cp "${SCRIPT_DIR}/backups/${latest_backup}/config.json" "${CONFIG_FILE}"
        fi
        log_info "Rollback completed"
    else
        log_warn "No backup found, manual recovery may be required"
    fi
}

###############################################################################
# Deployment Functions
###############################################################################

pre_deployment_checks() {
    log_info "Running pre-deployment checks..."
    
    check_dependencies || return 1
    load_config || return 1
    health_check || return 1
    backup_current_state || return 1
    
    log_info "Pre-deployment checks passed"
    return 0
}

deploy_application() {
    log_info "Starting deployment..."
    
    # Add your deployment logic here
    # This is a template that can be customized for your specific needs
    
    # Example: Pull latest changes from Git
    if [ -d .git ]; then
        log_info "Pulling latest changes from repository..."
        git fetch --all || true
    fi
    
    # Example: Install/update dependencies
    if [ -f "package.json" ]; then
        log_info "Installing Node.js dependencies..."
        npm install || true
    fi
    
    if [ -f "requirements.txt" ]; then
        log_info "Installing Python dependencies..."
        pip install -r requirements.txt || true
    fi
    
    if [ -f "go.mod" ]; then
        log_info "Installing Go dependencies..."
        go mod download || true
    fi
    
    log_info "Deployment completed successfully"
    return 0
}

post_deployment_validation() {
    log_info "Running post-deployment validation..."
    
    # Run health checks again
    health_check || return 1
    
    # Additional validation checks can be added here
    
    log_info "Post-deployment validation passed"
    return 0
}

cleanup() {
    log_info "Performing cleanup..."
    
    # Keep only last 10 backups
    local backup_count=$(ls -1 "${SCRIPT_DIR}/backups" 2>/dev/null | wc -l)
    if [ "${backup_count}" -gt 10 ]; then
        log_info "Cleaning up old backups..."
        ls -t "${SCRIPT_DIR}/backups" | tail -n +11 | xargs -I {} rm -rf "${SCRIPT_DIR}/backups/{}"
    fi
    
    # Keep only last 30 log files
    local log_count=$(ls -1 "${LOG_DIR}" 2>/dev/null | wc -l)
    if [ "${log_count}" -gt 30 ]; then
        log_info "Cleaning up old logs..."
        ls -t "${LOG_DIR}" | tail -n +31 | xargs -I {} rm -f "${LOG_DIR}/{}"
    fi
    
    log_info "Cleanup completed"
}

###############################################################################
# Main Execution
###############################################################################

main() {
    log_info "=========================================="
    log_info "Starting Deployment Process"
    log_info "Timestamp: ${DEPLOYMENT_TIMESTAMP}"
    log_info "=========================================="
    
    # Trap errors and call rollback
    trap rollback ERR
    
    # Execute deployment pipeline
    pre_deployment_checks
    deploy_application
    post_deployment_validation
    cleanup
    
    log_info "=========================================="
    log_info "Deployment Completed Successfully!"
    log_info "=========================================="
    
    exit 0
}

# Run main function
main "$@"
