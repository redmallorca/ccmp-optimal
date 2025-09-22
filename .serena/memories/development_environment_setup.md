# Development Environment Setup

## System Requirements

### Required Tools
- **Git** - Version control (pre-installed on macOS)
- **Bash** - Shell scripting (pre-installed on macOS)
- **GitHub CLI** (`gh`) - GitHub integration ✅ Available at `/opt/homebrew/bin/gh`

### Optional Tools (Graceful Degradation)
- **Docker** - Containerization ✅ Available at `/usr/local/bin/docker`
- **Node.js** - Frontend development ✅ Available at `/opt/homebrew/bin/node`
- **npm** - Package management ✅ Available at `/opt/homebrew/bin/npm`

## Current Environment Status
- **Platform**: Darwin (macOS) 24.6.0
- **Git Repository**: ✅ Initialized and healthy
- **GitHub CLI**: ✅ Available (authentication may be required)
- **Docker**: ✅ Available and can run commands
- **Node.js/npm**: ✅ Available for frontend projects

## Initial Setup Commands

### 1. CCPM System Setup
```bash
# Copy CCMP template to your project (if needed)
cp -r ccpm-optimal/* your-project/
cd your-project

# Install automation hooks (one-time setup)
./.claude/scripts/install-hooks.sh

# Verify installation
ls .claude/scripts/hooks/
```

### 2. GitHub Integration Setup
```bash
# Authenticate with GitHub (required for auto-sync)
gh auth login

# Verify authentication
gh auth status

# Test GitHub API access
gh repo view
```

### 3. Development Environment Verification
```bash
# Check git configuration
git config --list | grep user

# Verify project structure
ls -la .claude/
ls -la .github/

# Check branch protection and CI setup
gh repo view --json defaultBranch,hasIssuesEnabled
```

## Project-Specific Setup

### For Frontend Projects (Optional)
```bash
# If package.json exists, install dependencies
[ -f package.json ] && npm install

# Check available scripts
[ -f package.json ] && npm run --silent
```

### For Docker Projects (Optional)  
```bash
# Check Docker status
docker info

# If docker-compose files exist
[ -f docker-compose.yml ] && docker-compose config

# Start development environment (if configured)
[ -f docker-compose.yml ] && docker-compose up -d
```

## Automation Setup Verification

### Git Hooks Installation
```bash
# Check if hooks are installed
ls -la .git/hooks/

# Verify post-commit hook
cat .git/hooks/post-commit

# Verify pre-push hook  
cat .git/hooks/pre-push
```

### GitHub Actions Configuration
```bash
# Check CI workflow exists
ls -la .github/workflows/

# Verify quality gates configuration
cat .github/workflows/quality-gates.yml
```

## Troubleshooting Common Issues

### GitHub CLI Authentication
```bash
# If authentication fails
gh auth logout
gh auth login --web

# Check current auth status
gh auth status --show-token
```

### Docker Issues
```bash
# If Docker daemon not running
open -a Docker

# Check Docker status
docker version
docker info
```

### Git Hook Issues
```bash
# If hooks don't execute
chmod +x .git/hooks/post-commit
chmod +x .git/hooks/pre-push

# Reinstall hooks
./.claude/scripts/install-hooks.sh --force
```

## Darwin-Specific Commands
- **File listing**: `ls -la` (standard Unix)
- **Find files**: `find . -name "pattern"` (standard Unix)
- **Text search**: `grep -r "pattern" .` (standard Unix)
- **Package management**: `brew install package` (Homebrew)
- **Process management**: `ps aux | grep process` (standard Unix)

## Ready State Verification
```bash
# Complete environment check
./.claude/scripts/onboarding.sh

# Should show:
# - Git repository: ✅ Healthy
# - GitHub CLI: ✅ Authenticated  
# - CCPM hooks: ✅ Installed
# - Project structure: ✅ Valid
```