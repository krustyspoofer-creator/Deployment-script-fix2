#!/usr/bin/env python3
"""
Watchdog Resurrection Script - The Phoenix Module
This script can recreate the entire watchdog system if it gets deleted.
This is the ultimate failsafe mechanism.
"""

import os
import sys
import json

def get_watchdog_template():
    """Return the watchdog code template - loads from existing file or uses built-in template"""
    # Try to use the existing watchdog.py as template (if it exists and is valid)
    if os.path.exists('watchdog.py'):
        try:
            with open('watchdog.py', 'r') as f:
                content = f.read()
                # Basic validation - check if it's a valid watchdog script
                if 'GitHubWatchdog' in content and 'def perform_health_check' in content:
                    return content
        except Exception:
            pass
    
    # Fallback: Minimal watchdog template that can bootstrap itself
    return '''#!/usr/bin/env python3
"""
GitHub Account Watchdog - Minimal Bootstrap Version
This is a minimal version that will be replaced by the full system.
"""
import os
import sys
print("Minimal watchdog bootstrap - please run full installation")
print("Visit: https://github.com/krustyspoofer-creator/Deployment-script-fix2")
sys.exit(1)
'''

def resurrect():
    """Resurrect the watchdog if it's missing"""
    print("🔥 PHOENIX MODE: Resurrecting GitHub Watchdog...")
    
    # Check if watchdog exists
    if os.path.exists('watchdog.py'):
        print("✅ Watchdog script already exists")
    else:
        print("⚠️  Watchdog script missing!")
        print("📝 Note: Full resurrection requires the complete watchdog code.")
        print("   The system will use Git to restore from repository.")
        
        # Try to restore from git
        try:
            import subprocess
            result = subprocess.run(
                ['git', 'checkout', 'HEAD', 'watchdog.py'],
                capture_output=True,
                text=True,
                timeout=10
            )
            if result.returncode == 0:
                print("✅ Watchdog restored from Git repository!")
            else:
                print("⚠️  Could not restore from Git")
                print("   Please restore manually or re-clone the repository")
        except Exception as e:
            print(f"⚠️  Git restoration failed: {e}")
    
    # Create config if missing
    if not os.path.exists('watchdog_config.json'):
        print("📝 Creating watchdog_config.json...")
        config = {
            "check_interval": 300,
            "max_restart_attempts": -1,
            "enable_auto_heal": True,
            "monitor_workflows": True,
            "monitor_repositories": True,
            "monitor_issues": True,
            "github_token": "",
            "repository": ""
        }
        with open('watchdog_config.json', 'w') as f:
            json.dump(config, f, indent=2)
        print("✅ Config file created!")
    
    # Create workflows directory if missing
    if not os.path.exists('.github/workflows'):
        print("📝 Creating workflows directory...")
        os.makedirs('.github/workflows', exist_ok=True)
        print("✅ Workflows directory created!")
        print("⚠️  Workflow files may need to be restored from Git")
    
    print("\n🎉 Resurrection attempt complete!")
    
    if os.path.exists('watchdog.py'):
        print("Run: python watchdog.py")
    else:
        print("⚠️  Watchdog script still missing. Please restore from Git:")
        print("   git checkout HEAD watchdog.py")
        print("   git checkout HEAD .github/workflows/")


if __name__ == '__main__':
    resurrect()
