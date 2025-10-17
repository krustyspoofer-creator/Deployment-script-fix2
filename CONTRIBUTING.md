# Contributing to Deployment System

Thank you for your interest in contributing! This document provides guidelines for contributing to this project.

## 🤝 How to Contribute

### Reporting Issues

1. Check if the issue already exists
2. Use the issue templates if available
3. Include detailed information:
   - Steps to reproduce
   - Expected behavior
   - Actual behavior
   - System information
   - Relevant logs

### Submitting Changes

1. **Fork the repository**
   ```bash
   git clone https://github.com/krustyspoofer-creator/Deployment-script-fix2.git
   cd Deployment-script-fix2
   ```

2. **Create a feature branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```

3. **Make your changes**
   - Follow the existing code style
   - Add comments where necessary
   - Update documentation if needed
   - Add tests if applicable

4. **Test your changes**
   ```bash
   # Run the deployment script
   ./deploy.sh
   
   # Run health checks
   ./health-check.sh
   
   # Validate scripts
   bash -n deploy.sh
   bash -n health-check.sh
   python3 -m py_compile watchdog.py
   ```

5. **Commit your changes**
   ```bash
   git add .
   git commit -m "Brief description of your changes"
   ```
   
   Follow commit message conventions:
   - Use present tense ("Add feature" not "Added feature")
   - Use imperative mood ("Move cursor to..." not "Moves cursor to...")
   - First line should be 50 characters or less
   - Reference issues and PRs when relevant

6. **Push to your fork**
   ```bash
   git push origin feature/your-feature-name
   ```

7. **Submit a Pull Request**
   - Use a clear and descriptive title
   - Reference any related issues
   - Describe your changes in detail
   - Include any breaking changes

## 📝 Code Style Guidelines

### Shell Scripts (Bash)
- Use `#!/bin/bash` shebang
- Use `set -euo pipefail` for safety
- Add comments for complex logic
- Use meaningful variable names
- Follow indentation (2 or 4 spaces)
- Use functions for reusability
- Add error handling

### Python
- Follow PEP 8 style guide
- Use type hints where appropriate
- Add docstrings for functions and classes
- Use meaningful variable names
- Keep functions focused and small
- Add error handling

### Configuration Files
- Use JSON for configuration
- Include comments in documentation
- Provide sensible defaults
- Validate configuration on load

## 🧪 Testing

Before submitting your changes:

1. **Test locally**
   - Run deployment script
   - Run health checks
   - Start watchdog and verify monitoring

2. **Check syntax**
   ```bash
   # Shell scripts
   shellcheck deploy.sh health-check.sh
   
   # Python scripts
   python3 -m py_compile watchdog.py
   
   # JSON files
   python3 -m json.tool config.json > /dev/null
   ```

3. **Test edge cases**
   - Low disk space scenarios
   - Failed deployments
   - Recovery mechanisms
   - Configuration variations

## 📋 Pull Request Checklist

Before submitting, ensure:

- [ ] Code follows the style guidelines
- [ ] Changes have been tested locally
- [ ] Documentation has been updated
- [ ] Commit messages are clear and descriptive
- [ ] No unnecessary files are included
- [ ] Configuration examples are updated if needed
- [ ] README is updated for new features
- [ ] CHANGELOG is updated (if applicable)

## 🔍 Code Review Process

1. Maintainers will review your PR
2. Address any feedback or requested changes
3. Once approved, your PR will be merged
4. Thank you for your contribution! 🎉

## 💡 Suggesting Features

We welcome feature suggestions! Please:

1. Check existing issues and PRs
2. Open a new issue with the "enhancement" label
3. Describe the feature and use case
4. Explain why it would be beneficial
5. Provide examples if possible

## 🐛 Reporting Bugs

When reporting bugs, include:

1. **Description**: Clear description of the bug
2. **Steps to Reproduce**: Detailed steps
3. **Expected Behavior**: What should happen
4. **Actual Behavior**: What actually happens
5. **Environment**: OS, versions, etc.
6. **Logs**: Relevant log excerpts
7. **Screenshots**: If applicable

## 📜 License

By contributing, you agree that your contributions will be licensed under the same license as the project.

## ❓ Questions?

If you have questions about contributing:
- Open an issue with the "question" label
- Review existing documentation
- Check the README for more information

Thank you for contributing to make this project better! 🚀
