# Essential Commands for CCPM Optimal

## Primary Project Management Commands

### Core CCPM Commands
```bash
# Only manual command needed - creates epic with auto-sync
/pm:new epic-name "Epic description"

# Load context for existing epic
/pm:start epic-name

# Check project status and progress
/pm:status

# Force GitHub sync if needed (rarely required)
/pm:sync epic-name --force

# Archive completed epic
/pm:close epic-name
```

## Git Workflow (Standard)
```bash
# Normal development - everything else is automatic
git add .
git commit -m "feat(feature): implement component"
git push

# Auto-sync handles:
# - Progress tracking updates
# - GitHub issue updates  
# - PR creation at 100% completion
# - Auto-merge when CI passes
```

## System Setup Commands
```bash
# Install CCPM automation hooks (one-time setup)
./.claude/scripts/install-hooks.sh

# Run onboarding for new AI sessions
./.claude/scripts/onboarding.sh

# Quick start specific epic (context loading)
./.claude/scripts/start.sh 67     # Start Epic #67
./.claude/scripts/start.sh 68     # Start Epic #68
```

## Development Environment
```bash
# GitHub CLI authentication (required for auto-sync)
gh auth login

# Check if Docker is running (optional)
docker info

# Node.js/npm available for frontend projects
node --version
npm --version
```

## Emergency Procedures
```bash
# Disable auto-merge in emergency
touch .github/auto-merge-disabled
git commit -m "emergency: disable auto-merge"

# Check auto-sync logs for troubleshooting
tail -f .claude/logs/auto-sync.log

# Manual sync recovery
/pm:sync epic-name --force
```

## System Information Commands
```bash
# Check git status
git status
git log --oneline -5

# List project structure
ls -la
find .claude -name "*.md" | head -10

# Check available agents
ls .claude/agents/

# View GitHub issues (if gh CLI available)
gh issue list --state open
```

## Key Principle
**After `/pm:new`, everything is automatic.** Just code and commit normally - the system handles all project management automatically through git workflow.