#!/bin/bash

###############################################################################
# Health Check Script
# Description: Monitors system health and performs auto-recovery if needed
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
HEALTH_LOG="${LOG_DIR}/health_check_$(date +%Y%m%d).log"

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
    echo -e "${timestamp} [${level}] ${message}" | tee -a "${HEALTH_LOG}"
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
# Health Check Functions
###############################################################################

check_disk_space() {
    log_info "Checking disk space..."
    
    local usage=$(df -h "${SCRIPT_DIR}" | awk 'NR==2 {print $5}' | sed 's/%//')
    local available=$(df -h "${SCRIPT_DIR}" | awk 'NR==2 {print $4}')
    
    log_info "Disk usage: ${usage}% | Available: ${available}"
    
    if [ "${usage}" -gt 90 ]; then
        log_error "Disk usage is critically high: ${usage}%"
        return 1
    elif [ "${usage}" -gt 80 ]; then
        log_warn "Disk usage is high: ${usage}%"
    fi
    
    return 0
}

check_memory() {
    if ! command -v free &> /dev/null; then
        log_warn "Memory check skipped (free command not available)"
        return 0
    fi
    
    log_info "Checking memory..."
    
    local total=$(free -m | awk 'NR==2 {print $2}')
    local used=$(free -m | awk 'NR==2 {print $3}')
    local free=$(free -m | awk 'NR==2 {print $4}')
    local usage=$((used * 100 / total))
    
    log_info "Memory usage: ${usage}% | Used: ${used}MB | Free: ${free}MB | Total: ${total}MB"
    
    if [ "${usage}" -gt 90 ]; then
        log_error "Memory usage is critically high: ${usage}%"
        return 1
    elif [ "${usage}" -gt 80 ]; then
        log_warn "Memory usage is high: ${usage}%"
    fi
    
    return 0
}

check_git_repository() {
    if [ ! -d .git ]; then
        log_warn "Not a Git repository, skipping Git checks"
        return 0
    fi
    
    log_info "Checking Git repository status..."
    
    # Check if repository is clean
    if ! git diff-index --quiet HEAD -- 2>/dev/null; then
        log_warn "Repository has uncommitted changes"
    fi
    
    # Check if we can connect to remote
    if git remote get-url origin &> /dev/null; then
        log_info "Git remote configured: $(git remote get-url origin)"
    else
        log_warn "No Git remote configured"
    fi
    
    return 0
}

check_required_files() {
    log_info "Checking required files..."
    
    local required_files=("README.md")
    local missing_files=()
    
    for file in "${required_files[@]}"; do
        if [ ! -f "${SCRIPT_DIR}/${file}" ]; then
            missing_files+=("${file}")
        fi
    done
    
    if [ ${#missing_files[@]} -ne 0 ]; then
        log_warn "Missing files: ${missing_files[*]}"
    else
        log_info "All required files present"
    fi
    
    return 0
}

check_processes() {
    log_info "Checking running processes..."
    
    # Check for zombie processes
    local zombie_count=$(ps aux | awk '$8=="Z" {count++} END {print count+0}')
    if [ "${zombie_count}" -gt 0 ]; then
        log_warn "Found ${zombie_count} zombie processes"
    fi
    
    return 0
}

###############################################################################
# Auto-Recovery Functions
###############################################################################

attempt_recovery() {
    log_info "Attempting automatic recovery..."
    
    # Clean up temporary files
    log_info "Cleaning up temporary files..."
    find /tmp -name "deploy_*" -type f -mtime +7 -delete 2>/dev/null || true
    
    # Clean up old logs if disk space is low
    local usage=$(df "${SCRIPT_DIR}" | awk 'NR==2 {print $5}' | sed 's/%//')
    if [ "${usage}" -gt 85 ]; then
        log_info "Cleaning up old logs due to low disk space..."
        find "${LOG_DIR}" -name "*.log" -type f -mtime +7 -delete 2>/dev/null || true
    fi
    
    # Restart services if needed (placeholder for actual service management)
    # systemctl restart myservice || true
    
    log_info "Recovery attempt completed"
}

###############################################################################
# Main Execution
###############################################################################

main() {
    log_info "=========================================="
    log_info "Starting Health Check"
    log_info "Timestamp: $(date '+%Y-%m-%d %H:%M:%S')"
    log_info "=========================================="
    
    local exit_code=0
    local checks_failed=0
    
    # Run all health checks
    check_disk_space || ((checks_failed++))
    check_memory || ((checks_failed++))
    check_git_repository || ((checks_failed++))
    check_required_files || ((checks_failed++))
    check_processes || ((checks_failed++))
    
    # If checks failed, attempt recovery
    if [ "${checks_failed}" -gt 0 ]; then
        log_warn "${checks_failed} health check(s) failed"
        
        # Load auto-recovery setting from config
        local auto_recovery_enabled=true
        if [ -f "${CONFIG_FILE}" ] && command -v jq &> /dev/null; then
            auto_recovery_enabled=$(jq -r '.auto_recovery.enabled // true' "${CONFIG_FILE}")
        fi
        
        if [ "${auto_recovery_enabled}" = "true" ]; then
            attempt_recovery
        else
            log_info "Auto-recovery is disabled"
        fi
        
        exit_code=1
    fi
    
    log_info "=========================================="
    if [ "${exit_code}" -eq 0 ]; then
        log_info "Health Check Completed: ${GREEN}PASS${NC}"
    else
        log_error "Health Check Completed: ${RED}FAIL${NC}"
    fi
    log_info "=========================================="
    
    exit "${exit_code}"
}

# Run main function
main "$@"
