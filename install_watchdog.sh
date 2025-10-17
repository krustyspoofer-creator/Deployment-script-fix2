#!/bin/bash
# GitHub Account Watchdog Installation Script
# Makes the watchdog system operational and unkillable

set -e

echo "=========================================="
echo "GitHub Account Watchdog Installer"
echo "=========================================="
echo ""

# Check Python installation
echo "🔍 Checking Python installation..."
if ! command -v python3 &> /dev/null; then
    echo "❌ Python 3 is required but not installed."
    echo "Please install Python 3 and try again."
    exit 1
fi
echo "✅ Python 3 found: $(python3 --version)"
echo ""

# Check Git installation
echo "🔍 Checking Git installation..."
if ! command -v git &> /dev/null; then
    echo "❌ Git is required but not installed."
    exit 1
fi
echo "✅ Git found: $(git --version)"
echo ""

# Install Python dependencies if requirements.txt exists
if [ -f requirements.txt ]; then
    echo "📦 Installing Python dependencies..."
    python3 -m pip install --upgrade pip --quiet
    python3 -m pip install -r requirements.txt --quiet || true
    echo "✅ Dependencies installed"
    echo ""
fi

# Make scripts executable
echo "🔧 Making scripts executable..."
chmod +x watchdog.py 2>/dev/null || true
chmod +x resurrect_watchdog.py 2>/dev/null || true
echo "✅ Scripts are executable"
echo ""

# Create .github/workflows directory if it doesn't exist
if [ ! -d ".github/workflows" ]; then
    echo "📁 Creating workflows directory..."
    mkdir -p .github/workflows
    echo "✅ Workflows directory created"
    echo ""
fi

# Verify all components are present
echo "🔍 Verifying watchdog components..."
COMPONENTS=(
    "watchdog.py"
    "watchdog_config.json"
    "resurrect_watchdog.py"
    ".github/workflows/watchdog.yml"
)

ALL_PRESENT=true
for component in "${COMPONENTS[@]}"; do
    if [ -f "$component" ]; then
        echo "  ✅ $component"
    else
        echo "  ❌ $component (missing)"
        ALL_PRESENT=false
    fi
done
echo ""

if [ "$ALL_PRESENT" = false ]; then
    echo "⚠️  Some components are missing!"
    echo "Attempting resurrection..."
    python3 resurrect_watchdog.py
    echo ""
fi

# Test the watchdog
echo "🧪 Testing watchdog..."
timeout 15 python3 watchdog.py &> /dev/null || true
if [ -f "watchdog.log" ] && [ -f "watchdog_status.json" ]; then
    echo "✅ Watchdog test passed"
else
    echo "⚠️  Warning: Watchdog test did not complete as expected"
fi
echo ""

# Check if we're in a git repository
if [ -d ".git" ]; then
    echo "📊 Git repository status:"
    git status --short
    echo ""
    
    echo "💡 To activate the watchdog in GitHub Actions:"
    echo "   1. Commit and push these changes"
    echo "   2. The workflow will start automatically"
    echo "   3. Check the Actions tab in your GitHub repository"
    echo ""
    
    read -p "Would you like to commit and push now? (y/N) " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "📝 Committing changes..."
        git add .
        git commit -m "Install GitHub Account Watchdog system" || echo "No changes to commit"
        echo "🚀 Pushing to remote..."
        git push || echo "Push failed - you may need to push manually"
    fi
fi

echo ""
echo "=========================================="
echo "✅ Installation Complete!"
echo "=========================================="
echo ""
echo "The GitHub Account Watchdog is now installed and ready."
echo ""
echo "🎯 Next Steps:"
echo "  • Watchdog will run automatically via GitHub Actions"
echo "  • Scheduled to run every 5 minutes"
echo "  • To test locally: python3 watchdog.py"
echo "  • To view logs: cat watchdog.log"
echo "  • To resurrect if deleted: python3 resurrect_watchdog.py"
echo ""
echo "🛡️  The watchdog is now protecting your GitHub account!"
