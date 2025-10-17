#!/usr/bin/env python3
"""
Watchdog Monitoring System
Description: Continuous monitoring and auto-healing for the deployment system
"""

import os
import sys
import time
import json
import logging
import subprocess
import signal
from datetime import datetime
from pathlib import Path

# Configuration
SCRIPT_DIR = Path(__file__).parent
CONFIG_FILE = SCRIPT_DIR / "config.json"
LOG_DIR = SCRIPT_DIR / "logs"
WATCHDOG_LOG = LOG_DIR / f"watchdog_{datetime.now().strftime('%Y%m%d')}.log"

# Create log directory if it doesn't exist
LOG_DIR.mkdir(exist_ok=True)

# Setup logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s [%(levelname)s] %(message)s',
    handlers=[
        logging.FileHandler(WATCHDOG_LOG),
        logging.StreamHandler(sys.stdout)
    ]
)

logger = logging.getLogger(__name__)

# Global flag for graceful shutdown
shutdown_flag = False


def signal_handler(signum, frame):
    """Handle shutdown signals gracefully"""
    global shutdown_flag
    logger.info(f"Received signal {signum}, initiating graceful shutdown...")
    shutdown_flag = True


def load_config():
    """Load configuration from JSON file"""
    try:
        if CONFIG_FILE.exists():
            with open(CONFIG_FILE, 'r') as f:
                config = json.load(f)
            logger.info(f"Configuration loaded from {CONFIG_FILE}")
            return config
        else:
            logger.warning(f"Configuration file not found at {CONFIG_FILE}, using defaults")
            return get_default_config()
    except Exception as e:
        logger.error(f"Error loading configuration: {e}")
        return get_default_config()


def get_default_config():
    """Return default configuration"""
    return {
        "monitoring": {
            "enabled": True,
            "check_interval_seconds": 60,
            "alert_on_failure": True
        },
        "auto_recovery": {
            "enabled": True,
            "max_recovery_attempts": 5,
            "recovery_delay_seconds": 10
        }
    }


def run_health_check():
    """Run health check script"""
    try:
        health_check_script = SCRIPT_DIR / "health-check.sh"
        if not health_check_script.exists():
            logger.warning("Health check script not found")
            return False
        
        # Make script executable
        health_check_script.chmod(0o755)
        
        # Run health check
        result = subprocess.run(
            [str(health_check_script)],
            cwd=SCRIPT_DIR,
            capture_output=True,
            text=True,
            timeout=60
        )
        
        if result.returncode == 0:
            logger.info("Health check passed ✓")
            return True
        else:
            logger.error(f"Health check failed with exit code {result.returncode}")
            if result.stdout:
                logger.debug(f"STDOUT: {result.stdout}")
            if result.stderr:
                logger.debug(f"STDERR: {result.stderr}")
            return False
            
    except subprocess.TimeoutExpired:
        logger.error("Health check timed out")
        return False
    except Exception as e:
        logger.error(f"Error running health check: {e}")
        return False


def attempt_recovery():
    """Attempt to recover from failures"""
    logger.info("Attempting automatic recovery...")
    
    try:
        # Run deployment script with recovery mode
        deploy_script = SCRIPT_DIR / "deploy.sh"
        if deploy_script.exists():
            deploy_script.chmod(0o755)
            
            result = subprocess.run(
                [str(deploy_script)],
                cwd=SCRIPT_DIR,
                capture_output=True,
                text=True,
                timeout=300
            )
            
            if result.returncode == 0:
                logger.info("Recovery successful ✓")
                return True
            else:
                logger.error(f"Recovery failed with exit code {result.returncode}")
                return False
        else:
            logger.warning("Deployment script not found")
            return False
            
    except subprocess.TimeoutExpired:
        logger.error("Recovery attempt timed out")
        return False
    except Exception as e:
        logger.error(f"Error during recovery: {e}")
        return False


def monitor_system(config):
    """Main monitoring loop"""
    logger.info("Starting system monitoring...")
    
    check_interval = config.get("monitoring", {}).get("check_interval_seconds", 60)
    auto_recovery_enabled = config.get("auto_recovery", {}).get("enabled", True)
    max_recovery_attempts = config.get("auto_recovery", {}).get("max_recovery_attempts", 5)
    recovery_delay = config.get("auto_recovery", {}).get("recovery_delay_seconds", 10)
    
    consecutive_failures = 0
    recovery_attempts = 0
    
    while not shutdown_flag:
        try:
            # Run health check
            health_status = run_health_check()
            
            if health_status:
                # Health check passed
                consecutive_failures = 0
                recovery_attempts = 0
            else:
                # Health check failed
                consecutive_failures += 1
                logger.warning(f"Consecutive failures: {consecutive_failures}")
                
                # Attempt recovery if enabled and within limits
                if auto_recovery_enabled and recovery_attempts < max_recovery_attempts:
                    logger.info(f"Initiating recovery attempt {recovery_attempts + 1}/{max_recovery_attempts}")
                    time.sleep(recovery_delay)
                    
                    if attempt_recovery():
                        consecutive_failures = 0
                        recovery_attempts = 0
                    else:
                        recovery_attempts += 1
                else:
                    if recovery_attempts >= max_recovery_attempts:
                        logger.error("Max recovery attempts reached. Manual intervention required.")
            
            # Wait for next check
            logger.info(f"Waiting {check_interval} seconds until next check...")
            for _ in range(check_interval):
                if shutdown_flag:
                    break
                time.sleep(1)
                
        except KeyboardInterrupt:
            logger.info("Received keyboard interrupt, shutting down...")
            break
        except Exception as e:
            logger.error(f"Error in monitoring loop: {e}")
            time.sleep(check_interval)
    
    logger.info("Monitoring stopped")


def main():
    """Main entry point"""
    logger.info("=" * 50)
    logger.info("Starting Watchdog Monitoring System")
    logger.info(f"Timestamp: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    logger.info("=" * 50)
    
    # Register signal handlers for graceful shutdown
    signal.signal(signal.SIGINT, signal_handler)
    signal.signal(signal.SIGTERM, signal_handler)
    
    # Load configuration
    config = load_config()
    
    # Check if monitoring is enabled
    if not config.get("monitoring", {}).get("enabled", True):
        logger.warning("Monitoring is disabled in configuration")
        sys.exit(0)
    
    try:
        # Start monitoring
        monitor_system(config)
    except Exception as e:
        logger.error(f"Fatal error: {e}")
        sys.exit(1)
    
    logger.info("=" * 50)
    logger.info("Watchdog Monitoring System Stopped")
    logger.info("=" * 50)


if __name__ == "__main__":
    main()
