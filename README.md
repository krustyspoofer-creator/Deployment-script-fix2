# GitHub Account Watchdog - Unkillable Auto-Healing System

An autonomous, self-healing watchdog system that monitors and automatically repairs your entire GitHub account and repositories. Designed to be **unkillable** and continuously operational.

## 🚀 Features

- **Unkillable Design**: Multiple redundancy layers ensure continuous operation
- **Auto-Healing**: Automatically detects and fixes common GitHub issues
- **Continuous Monitoring**: Runs every 5 minutes via GitHub Actions
- **Self-Repairing**: Can recreate itself if components are deleted
- **Zero Dependencies**: Uses only Python standard library for maximum reliability
- **Multi-Level Failsafes**: Backup watchdog ensures primary watchdog stays active

## 🔧 What It Monitors and Heals

The watchdog automatically monitors and fixes:

- ✅ Repository health and accessibility
- ✅ Missing critical files (README, workflows, etc.)
- ✅ GitHub Actions workflow integrity
- ✅ Repository structure and configuration
- ✅ Git repository status and access

## 📋 Components

### 1. Main Watchdog Script (`watchdog.py`)
- Core monitoring and healing logic
- Health check routines
- Auto-repair mechanisms
- Status tracking and logging

### 2. GitHub Actions Workflow (`.github/workflows/watchdog.yml`)
- Scheduled execution every 5 minutes
- Self-triggering on repository events
- Automatic commit and push of healing changes
- Backup watchdog for redundancy

### 3. Configuration (`watchdog_config.json`)
- Customizable check intervals
- Enable/disable specific monitors
- Auto-heal settings

## 🚦 Getting Started

### Automatic Setup (Recommended)
The watchdog is automatically activated once you merge this PR. No manual setup required!

### Manual Execution
To run the watchdog locally for testing:

```bash
# Run the watchdog
python watchdog.py
```

The watchdog will run continuously until stopped with Ctrl+C.

### Configuration
Edit `watchdog_config.json` to customize behavior:

```json
{
  "check_interval": 300,           // Check every 5 minutes
  "max_restart_attempts": -1,      // -1 = infinite restarts
  "enable_auto_heal": true,        // Enable automatic healing
  "monitor_workflows": true,       // Monitor GitHub Actions
  "monitor_repositories": true,    // Monitor repo health
  "monitor_issues": true           // Monitor issues
}
```

## 🛡️ Unkillable Features

The watchdog achieves "unkillable" status through:

1. **Scheduled Execution**: Runs automatically every 5 minutes via cron
2. **Event-Triggered**: Activates on push, workflow_dispatch, and repository events
3. **Self-Healing Workflow**: Can recreate missing workflow files
4. **Backup Watchdog**: Secondary failsafe validates primary watchdog
5. **Always-On Policy**: `if: always()` ensures execution even after failures
6. **Auto-Commit**: Automatically commits and pushes healing changes
7. **Multiple Triggers**: Push, schedule, manual, and repository dispatch events

## 📊 Monitoring

### View Watchdog Status
Check the Actions tab in your repository to see:
- Recent watchdog runs
- Issues found and healed
- Execution logs and status

### Logs and Artifacts
- Watchdog logs are uploaded as artifacts after each run
- `watchdog.log`: Detailed execution log
- `watchdog_status.json`: Current status and statistics

## 🔄 How Auto-Healing Works

1. **Detection**: Watchdog runs health checks on schedule
2. **Analysis**: Identifies issues in repository, workflows, and structure
3. **Healing**: Automatically applies fixes for known issues
4. **Commit**: Changes are committed and pushed back to repository
5. **Verification**: Next run verifies the healing was successful

## 🎯 Use Cases

- **Repository Resilience**: Automatically recover from accidental deletions
- **Configuration Maintenance**: Keep critical files and workflows intact
- **Continuous Operation**: Ensure GitHub Actions stay active
- **Security Monitoring**: Detect and respond to repository changes
- **Account Health**: Maintain overall GitHub account integrity

## ⚙️ Advanced Features

### Manual Trigger
Trigger the watchdog manually via GitHub Actions:
```bash
gh workflow run watchdog.yml
```

Or via the GitHub web interface: Actions → GitHub Account Watchdog → Run workflow

### Stopping the Watchdog
To temporarily disable the watchdog:
1. Go to Actions tab
2. Select "GitHub Account Watchdog" workflow
3. Click the "..." menu → Disable workflow

To permanently remove:
1. Delete `.github/workflows/watchdog.yml`
2. Delete `watchdog.py`, `watchdog_config.json`

**Note**: If auto-healing is enabled, the watchdog may recreate itself!

## 📝 Logs and Status Files

- `watchdog.log`: Detailed operation logs
- `watchdog_status.json`: Current status including:
  - Last check time
  - Issues found and healed count
  - Uptime information
  - Restart count

## 🤝 Contributing

This watchdog system is designed to be self-sufficient. However, you can extend it by:
- Adding new health check routines in `watchdog.py`
- Implementing additional healing mechanisms
- Customizing the monitoring intervals
- Adding notifications (email, Slack, etc.)

## 📄 License

This project is provided as-is for GitHub account monitoring and maintenance.

## ⚠️ Important Notes

- The watchdog requires GitHub Actions to be enabled
- Write permissions are needed for auto-healing commits
- Scheduled workflows may be disabled by GitHub after 60 days of repository inactivity
- Manual trigger or push events can reactivate disabled workflows

## 🎉 Status

🟢 **ACTIVE**: The watchdog is now protecting your GitHub account!
