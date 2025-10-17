#!/bin/bash

###############################################################################
# System Monitor Script
# Description: Display real-time system status and metrics
###############################################################################

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_DIR="${SCRIPT_DIR}/logs"

clear

print_header() {
    local title="$1"
    echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║  $(printf '%-56s' "$title")  ║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
}

print_section() {
    local title="$1"
    echo -e "\n${CYAN}▶ $title${NC}"
    echo -e "${CYAN}──────────────────────────────────────────────────────────${NC}"
}

get_status_color() {
    local value=$1
    local warning=$2
    local critical=$3
    
    if [ "$value" -ge "$critical" ]; then
        echo "$RED"
    elif [ "$value" -ge "$warning" ]; then
        echo "$YELLOW"
    else
        echo "$GREEN"
    fi
}

show_disk_usage() {
    local usage=$(df -h "${SCRIPT_DIR}" | awk 'NR==2 {print $5}' | sed 's/%//')
    local available=$(df -h "${SCRIPT_DIR}" | awk 'NR==2 {print $4}')
    local color=$(get_status_color "$usage" 80 90)
    
    echo -e "  Disk Usage:    ${color}${usage}%${NC} (${available} available)"
}

show_memory_usage() {
    if command -v free &> /dev/null; then
        local total=$(free -h | awk 'NR==2 {print $2}')
        local used=$(free -h | awk 'NR==2 {print $3}')
        local available=$(free -h | awk 'NR==2 {print $7}')
        local usage=$(free | awk 'NR==2 {printf "%.0f", ($3/$2) * 100}')
        local color=$(get_status_color "$usage" 80 90)
        
        echo -e "  Memory:        ${color}${used}${NC} / ${total} (${available} available)"
        echo -e "  Usage:         ${color}${usage}%${NC}"
    else
        echo -e "  ${YELLOW}Memory information not available${NC}"
    fi
}

show_system_info() {
    print_section "System Information"
    
    echo -e "  Hostname:      $(hostname)"
    if [ -f /etc/os-release ]; then
        local os_name=$(grep "^PRETTY_NAME=" /etc/os-release | cut -d'"' -f2)
        echo -e "  OS:            ${os_name}"
    fi
    echo -e "  Uptime:        $(uptime -p 2>/dev/null || uptime | awk '{print $3, $4}')"
    echo -e "  Current Time:  $(date '+%Y-%m-%d %H:%M:%S')"
}

show_resource_usage() {
    print_section "Resource Usage"
    
    show_disk_usage
    show_memory_usage
    
    # CPU info
    if command -v nproc &> /dev/null; then
        echo -e "  CPU Cores:     $(nproc)"
    fi
    
    # Load average
    if [ -f /proc/loadavg ]; then
        local load=$(cat /proc/loadavg | awk '{print $1, $2, $3}')
        echo -e "  Load Average:  ${load}"
    fi
}

show_git_status() {
    print_section "Git Repository"
    
    if [ -d .git ]; then
        local branch=$(git branch --show-current 2>/dev/null || echo "unknown")
        local remote=$(git remote get-url origin 2>/dev/null || echo "none")
        local status=$(git status --short | wc -l)
        
        echo -e "  Branch:        ${GREEN}${branch}${NC}"
        echo -e "  Remote:        ${remote}"
        
        if [ "$status" -eq 0 ]; then
            echo -e "  Status:        ${GREEN}Clean${NC}"
        else
            echo -e "  Status:        ${YELLOW}${status} uncommitted changes${NC}"
        fi
        
        # Show last commit
        local last_commit=$(git log -1 --pretty=format:"%h - %s (%ar)" 2>/dev/null || echo "none")
        echo -e "  Last Commit:   ${last_commit}"
    else
        echo -e "  ${YELLOW}Not a Git repository${NC}"
    fi
}

show_recent_logs() {
    print_section "Recent Logs"
    
    if [ -d "${LOG_DIR}" ]; then
        local log_count=$(ls -1 "${LOG_DIR}" 2>/dev/null | wc -l)
        echo -e "  Total Logs:    ${log_count}"
        
        # Show most recent logs
        echo -e "\n  Recent log files:"
        ls -1t "${LOG_DIR}" 2>/dev/null | head -5 | while read -r log; do
            local size=$(ls -lh "${LOG_DIR}/${log}" | awk '{print $5}')
            local date=$(ls -l "${LOG_DIR}/${log}" | awk '{print $6, $7, $8}')
            echo -e "    • ${log} (${size}) - ${date}"
        done
    else
        echo -e "  ${YELLOW}No logs directory found${NC}"
    fi
}

show_recent_deployments() {
    print_section "Recent Deployments"
    
    if [ -d "${SCRIPT_DIR}/backups" ]; then
        local backup_count=$(ls -1 "${SCRIPT_DIR}/backups" 2>/dev/null | wc -l)
        echo -e "  Total Backups: ${backup_count}"
        
        if [ "$backup_count" -gt 0 ]; then
            echo -e "\n  Recent deployments:"
            ls -1t "${SCRIPT_DIR}/backups" 2>/dev/null | head -5 | while read -r backup; do
                echo -e "    • ${backup}"
            done
        fi
    else
        echo -e "  ${YELLOW}No backups directory found${NC}"
    fi
}

show_running_processes() {
    print_section "Deployment Processes"
    
    # Check if watchdog is running
    if pgrep -f "watchdog.py" > /dev/null; then
        echo -e "  Watchdog:      ${GREEN}Running${NC}"
    else
        echo -e "  Watchdog:      ${YELLOW}Not running${NC}"
    fi
    
    # Check for deployment processes
    if pgrep -f "deploy.sh" > /dev/null; then
        echo -e "  Deployment:    ${GREEN}In Progress${NC}"
    else
        echo -e "  Deployment:    ${YELLOW}Idle${NC}"
    fi
}

show_configuration() {
    print_section "Configuration"
    
    if [ -f "${SCRIPT_DIR}/config.json" ]; then
        echo -e "  Config File:   ${GREEN}Found${NC}"
        
        if command -v jq &> /dev/null; then
            local env=$(jq -r '.deployment.environment // "unknown"' "${SCRIPT_DIR}/config.json")
            local monitoring=$(jq -r '.monitoring.enabled // "unknown"' "${SCRIPT_DIR}/config.json")
            local recovery=$(jq -r '.auto_recovery.enabled // "unknown"' "${SCRIPT_DIR}/config.json")
            
            echo -e "  Environment:   ${env}"
            echo -e "  Monitoring:    ${monitoring}"
            echo -e "  Auto-Recovery: ${recovery}"
        fi
    else
        echo -e "  Config File:   ${YELLOW}Not found${NC}"
    fi
}

###############################################################################
# Main Display
###############################################################################

print_header "Deployment System Monitor"

show_system_info
show_resource_usage
show_git_status
show_running_processes
show_configuration
show_recent_logs
show_recent_deployments

echo -e "\n${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  Press Ctrl+C to exit  • Run './health-check.sh' for more  ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}\n"

# Instructions
echo -e "${CYAN}Commands:${NC}"
echo -e "  ${YELLOW}./deploy.sh${NC}         - Run deployment"
echo -e "  ${YELLOW}./health-check.sh${NC}   - Run health check"
echo -e "  ${YELLOW}python3 watchdog.py${NC} - Start monitoring"
echo -e "  ${YELLOW}./monitor.sh${NC}        - Show this monitor (refresh)"
echo ""
