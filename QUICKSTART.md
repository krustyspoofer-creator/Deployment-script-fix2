# Quick Start Guide

Get started with the Deployment System in 5 minutes! ⚡

## 🚀 Installation (1 minute)

1. **Clone the repository:**
```bash
git clone https://github.com/krustyspoofer-creator/Deployment-script-fix2.git
cd Deployment-script-fix2
```

2. **Run the installer:**
```bash
chmod +x install.sh
./install.sh
```

That's it! The installer will check prerequisites and set everything up.

## 📊 Check System Status (30 seconds)

View your system status at a glance:

```bash
./monitor.sh
```

This shows:
- System resources (disk, memory, CPU)
- Git repository status
- Recent deployments
- Configuration settings
- Running processes

## 🏃 First Deployment (1 minute)

Run your first deployment:

```bash
./deploy.sh
```

The script will:
- ✓ Check dependencies
- ✓ Create backup
- ✓ Run health checks
- ✓ Deploy your application
- ✓ Validate deployment
- ✓ Clean up old files

## 🩺 Health Check (30 seconds)

Check if everything is healthy:

```bash
./health-check.sh
```

This monitors:
- Disk space
- Memory usage
- Git repository status
- Required files
- Running processes

## 👁️ Start Continuous Monitoring (30 seconds)

Start the watchdog for 24/7 monitoring:

```bash
python3 watchdog.py
```

The watchdog will:
- Run health checks every 60 seconds
- Auto-recover from failures
- Log all activities
- Alert on critical issues

To run in background:
```bash
nohup python3 watchdog.py > /dev/null 2>&1 &
```

## ⚙️ Customize Configuration (2 minutes)

Edit `config.json` to customize behavior:

```bash
nano config.json
```

Key settings:
```json
{
  "monitoring": {
    "check_interval_seconds": 60    // How often to check
  },
  "auto_recovery": {
    "enabled": true,                // Enable auto-recovery
    "max_recovery_attempts": 5      // Max recovery tries
  },
  "backup": {
    "retention_days": 30            // How long to keep backups
  }
}
```

## 📋 Common Commands

| Command | Description |
|---------|-------------|
| `./deploy.sh` | Run deployment |
| `./health-check.sh` | Check system health |
| `./monitor.sh` | View system status |
| `./install.sh` | Reinstall/repair system |
| `python3 watchdog.py` | Start monitoring |

## 📂 Directory Structure

```
.
├── deploy.sh              # Main deployment script
├── health-check.sh        # Health monitoring
├── watchdog.py            # Continuous monitoring
├── monitor.sh             # System status viewer
├── install.sh             # Installation script
├── config.json            # Configuration
├── logs/                  # All log files
└── backups/               # Deployment backups
```

## 🔍 View Logs

**Deployment logs:**
```bash
tail -f logs/deployment_*.log
```

**Health check logs:**
```bash
tail -f logs/health_check_*.log
```

**Watchdog logs:**
```bash
tail -f logs/watchdog_*.log
```

**All logs:**
```bash
ls -lh logs/
```

## 🔄 CI/CD Integration

The repository includes GitHub Actions workflows:

- **CI/CD Pipeline** (`.github/workflows/ci-cd.yml`):
  - Runs on push to main/develop
  - Validates, tests, and deploys

- **Watchdog Monitor** (`.github/workflows/watchdog.yml`):
  - Runs every 30 minutes
  - Auto-heals on failures

Workflows run automatically - no setup needed!

## ⚡ Quick Tips

1. **Check status anytime:** `./monitor.sh`
2. **View recent logs:** `ls -lt logs/ | head`
3. **Check backups:** `ls -lt backups/`
4. **Validate config:** `python3 -m json.tool config.json`
5. **Test scripts:** `bash -n deploy.sh`

## 🆘 Troubleshooting

**Deployment fails?**
```bash
# Check logs
tail -50 logs/deployment_*.log

# Verify dependencies
./install.sh

# Check disk space
df -h
```

**Health check fails?**
```bash
# View details
./health-check.sh

# Check resources
./monitor.sh
```

**Need to rollback?**
```bash
# List backups
ls -lt backups/

# Restore manually from most recent backup
# Files are in: backups/YYYYMMDD_HHMMSS/
```

## 📚 Next Steps

1. **Read the full documentation:** [README.md](README.md)
2. **Learn to contribute:** [CONTRIBUTING.md](CONTRIBUTING.md)
3. **Check changelog:** [CHANGELOG.md](CHANGELOG.md)
4. **Customize for your needs:** Edit scripts and config

## 🎯 Use Cases

- **Development:** Test deployments locally
- **Staging:** Validate before production
- **Production:** Reliable deployment with auto-recovery
- **Monitoring:** 24/7 health checks
- **CI/CD:** Automated testing and deployment

## 🤝 Get Help

- **Documentation:** Check README.md
- **Issues:** Open a GitHub issue
- **Logs:** Always check logs first
- **Status:** Run `./monitor.sh`

---

**Ready to deploy?** Run `./deploy.sh` and you're good to go! 🚀
