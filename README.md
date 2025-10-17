# Deployment System with Auto-Healing

A comprehensive deployment and monitoring system with automated health checks, recovery mechanisms, and CI/CD integration.

## 🚀 Features

- **Automated Deployment**: Robust deployment script with error handling and rollback capabilities
- **Health Monitoring**: Continuous health checks for system resources and application status
- **Auto-Recovery**: Automatic recovery from failures with configurable retry policies
- **CI/CD Integration**: GitHub Actions workflow for automated testing and deployment
- **Comprehensive Logging**: Detailed logs for all operations with rotation and retention
- **Backup & Rollback**: Automatic backups before deployment with easy rollback functionality
- **Security Scanning**: Built-in security checks and validation
- **Configuration Management**: JSON-based configuration with sensible defaults

## 📋 Prerequisites

- Bash 4.0 or higher
- Python 3.6 or higher
- Git
- curl
- jq (for JSON processing)

## 🔧 Installation

1. Clone the repository:
```bash
git clone https://github.com/krustyspoofer-creator/Deployment-script-fix2.git
cd Deployment-script-fix2
```

2. Make scripts executable:
```bash
chmod +x deploy.sh health-check.sh watchdog.py
```

3. Configure settings (optional):
```bash
# Edit config.json to customize deployment and monitoring settings
nano config.json
```

## 📖 Usage

### Basic Deployment

Run the deployment script:
```bash
./deploy.sh
```

### Health Check

Run a one-time health check:
```bash
./health-check.sh
```

### Continuous Monitoring (Watchdog)

Start the watchdog for continuous monitoring:
```bash
python3 watchdog.py
```

The watchdog will:
- Monitor system health continuously
- Automatically recover from failures
- Log all activities
- Send alerts on critical issues

### Manual Operations

**View deployment logs:**
```bash
ls -lh logs/
tail -f logs/deployment_*.log
```

**View health check logs:**
```bash
tail -f logs/health_check_*.log
```

**View watchdog logs:**
```bash
tail -f logs/watchdog_*.log
```

**Check backups:**
```bash
ls -lh backups/
```

**Manual rollback:**
```bash
# The deployment script automatically rolls back on failure
# For manual rollback, restore from the most recent backup
ls -t backups/ | head -n 1
```

## ⚙️ Configuration

Edit `config.json` to customize behavior:

```json
{
  "deployment": {
    "environment": "production",
    "max_retries": 3,
    "timeout_seconds": 300
  },
  "monitoring": {
    "enabled": true,
    "check_interval_seconds": 60
  },
  "auto_recovery": {
    "enabled": true,
    "max_recovery_attempts": 5
  }
}
```

### Configuration Options

- **deployment.max_retries**: Number of retry attempts for failed operations
- **deployment.timeout_seconds**: Maximum time for deployment operations
- **monitoring.check_interval_seconds**: Time between health checks
- **auto_recovery.enabled**: Enable/disable automatic recovery
- **auto_recovery.max_recovery_attempts**: Maximum recovery attempts before manual intervention
- **backup.retention_days**: How long to keep backups
- **logging.max_log_files**: Maximum number of log files to retain

## 🔄 CI/CD Pipeline

The repository includes a GitHub Actions workflow (`.github/workflows/ci-cd.yml`) that:

1. **Validates** all scripts and configuration files
2. **Runs security scans** to detect potential vulnerabilities
3. **Executes tests** to ensure functionality
4. **Deploys** to the target environment (on push to main/develop)
5. **Performs health checks** after deployment
6. **Notifies** of success or failure

The workflow runs automatically on:
- Push to main or develop branches
- Pull requests to main or develop
- Manual trigger via workflow_dispatch
- Daily at midnight UTC (for scheduled health checks)

## 🏗️ Architecture

```
Deployment-script-fix2/
├── deploy.sh              # Main deployment script
├── health-check.sh        # Health monitoring script
├── watchdog.py            # Continuous monitoring daemon
├── config.json            # Configuration file
├── README.md              # This file
├── .github/
│   └── workflows/
│       └── ci-cd.yml      # CI/CD pipeline
├── logs/                  # Log files (auto-created)
│   ├── deployment_*.log
│   ├── health_check_*.log
│   └── watchdog_*.log
└── backups/               # Backup directory (auto-created)
    └── YYYYMMDD_HHMMSS/
```

## 🛡️ Security

- No hardcoded credentials (use environment variables or secrets)
- Security scanning in CI/CD pipeline
- Validation of all inputs
- HTTPS enforcement (configurable)
- Checksum validation for critical files

## 🔍 Troubleshooting

### Deployment fails
1. Check deployment logs in `logs/deployment_*.log`
2. Verify all dependencies are installed
3. Ensure sufficient disk space and memory
4. Review the backup directory for rollback options

### Health checks fail
1. Check health check logs in `logs/health_check_*.log`
2. Verify system resources (disk, memory)
3. Check if required files are present
4. Review auto-recovery logs

### Watchdog not starting
1. Ensure Python 3.6+ is installed
2. Make sure the script is executable
3. Check watchdog logs in `logs/watchdog_*.log`
4. Verify configuration in `config.json`

## 📊 Monitoring

The system provides multiple levels of monitoring:

1. **Resource Monitoring**: Disk space, memory usage, CPU
2. **Process Monitoring**: Check for zombie processes
3. **Repository Monitoring**: Git status and remote connectivity
4. **File Integrity**: Verification of required files
5. **Service Health**: Custom health endpoints (configurable)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📝 License

This project is open source and available under the MIT License.

## 🙏 Acknowledgments

- Built with best practices for deployment automation
- Inspired by modern DevOps practices
- Designed for reliability and maintainability

## 📞 Support

For issues, questions, or contributions:
- Open an issue on GitHub
- Review existing documentation
- Check logs for detailed error messages

---

**Note**: This is a comprehensive deployment system designed to be customized for your specific needs. Modify the scripts and configuration to match your deployment requirements.
