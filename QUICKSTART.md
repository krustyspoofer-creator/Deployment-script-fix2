# Quick Start Guide - GitHub Account Watchdog

Get your unkillable GitHub watchdog up and running in 60 seconds!

## 🚀 Installation

### Option 1: Automatic Installation (Recommended)
```bash
chmod +x install_watchdog.sh
./install_watchdog.sh
```

### Option 2: Manual Setup
```bash
# Make scripts executable
chmod +x watchdog.py resurrect_watchdog.py

# Install dependencies (optional)
pip install -r requirements.txt

# Run the watchdog locally
python3 watchdog.py
```

## ✅ Verification

After installation, verify the watchdog is working:

```bash
# Check if watchdog is running
python3 watchdog.py &
sleep 10
kill %1

# View logs
cat watchdog.log

# View status
cat watchdog_status.json
```

## 🔄 GitHub Actions Setup

The watchdog automatically runs via GitHub Actions:

1. **Commit and push** all files to your repository
2. **Go to Actions tab** in GitHub
3. **Verify** "GitHub Account Watchdog" workflow appears
4. **Manual trigger** (optional): Actions → GitHub Account Watchdog → Run workflow

## 📊 Monitoring

### View Watchdog Status
- **GitHub Actions**: Check the Actions tab for workflow runs
- **Logs**: Download artifacts from completed workflow runs
- **Local Status**: `cat watchdog_status.json`

### What It Monitors
- ✅ Repository accessibility
- ✅ Critical files (README, workflows)
- ✅ GitHub Actions workflows
- ✅ Repository structure

### Auto-Healing Capabilities
The watchdog automatically fixes:
- Missing README.md
- Missing .github/workflows directory
- Broken workflow files
- Repository configuration issues

## 🛡️ Unkillable Features

### Multiple Redundancy Layers:
1. **Main Watchdog**: Runs every 5 minutes
2. **Backup Watchdog**: Verifies main watchdog in each run
3. **Self-Healing Workflow**: Runs every 6 hours to resurrect missing components
4. **Phoenix Script**: Can manually resurrect the entire system

### If Components Get Deleted:
```bash
# Use the resurrection script
python3 resurrect_watchdog.py
```

### If Everything Gets Deleted:
The self-healing workflow will automatically recreate the system within 6 hours.

## ⚙️ Configuration

Edit `watchdog_config.json` to customize:

```json
{
  "check_interval": 300,           // Seconds between checks (5 min)
  "enable_auto_heal": true,        // Auto-fix issues
  "monitor_workflows": true,       // Watch GitHub Actions
  "monitor_repositories": true     // Watch repo health
}
```

## 🔧 Commands

| Command | Description |
|---------|-------------|
| `python3 watchdog.py` | Run watchdog locally |
| `python3 resurrect_watchdog.py` | Resurrect deleted watchdog |
| `./install_watchdog.sh` | Complete installation |
| `cat watchdog.log` | View operation logs |
| `cat watchdog_status.json` | Check current status |

## 🚨 Troubleshooting

### Watchdog Not Running in GitHub Actions?
- Ensure workflows are enabled: Settings → Actions → Allow all actions
- Check if scheduled workflows are active: Actions tab → select workflow
- Manually trigger: Actions → GitHub Account Watchdog → Run workflow

### Local Execution Issues?
```bash
# Check Python version (3.7+ required)
python3 --version

# Check dependencies
pip list

# Run with verbose output
python3 watchdog.py
```

### Watchdog Was Deleted?
```bash
# Resurrect it
python3 resurrect_watchdog.py

# Or wait up to 6 hours for self-healing workflow
```

## 📖 More Information

For complete documentation, see [README.md](README.md)

## 🎉 You're All Set!

The watchdog is now protecting your GitHub account with:
- ⏰ Continuous monitoring every 5 minutes
- 🔧 Automatic healing of common issues  
- 🛡️ Multiple failsafe mechanisms
- ♾️ Unkillable design with auto-resurrection

**Status: 🟢 ACTIVE**
