# CCPM Optimal - Essential Commands

## Core CCPM Commands (Primary Interface)

### 1. Epic Management
```bash
# Create new epic (primary command - sets up everything)
/new epic-name "Epic description"

# Load context for existing epic
/start epic-name

# Check progress of all epics or specific epic
/status [epic-name]

# Force sync with GitHub (troubleshooting)
/sync [epic-name]

# Archive completed epic
/close epic-name
```

### 2. System Setup (One-time)
```bash
# Install CCPM automation hooks
./.claude/scripts/install-hooks.sh

# Copy CCPM template to new project
cp -r ccpm-optimal/* your-project/
```

## Standard Development Commands

### 3. Quality Gates (Expected by automation)
```bash
# Linting (ESLint + Prettier)
npm run lint
npm run lint:fix

# TypeScript validation
npm run typecheck

# Testing
npm test                    # Unit tests
npm run test:unit          # Component tests
npm run test:integration   # API/service tests
npm run test:e2e          # Playwright E2E tests

# Build verification
npm run build
npm run build:dev
```

### 4. Development Workflow
```bash
# Normal git workflow (automation handles the rest)
git add .
git commit -m "feat(component): implement user auth"
git push

# Development server (project-dependent)
npm run dev
npm run start
```

## Container Support Commands

### 5. Docker Integration (Optional)
```bash
# Execute commands in container
./.claude/scripts/container-exec.sh exec "npm run dev"
./.claude/scripts/container-exec.sh exec "npm run build"
./.claude/scripts/container-exec.sh exec "npm run lint"

# Container shortcuts
./.claude/scripts/container-exec.sh dev    # Start dev server
./.claude/scripts/container-exec.sh build  # Build project
./.claude/scripts/container-exec.sh lint   # Run linting
./.claude/scripts/container-exec.sh test   # Run tests
```

## GitHub Integration Commands

### 6. GitHub CLI (Used by automation)
```bash
# Authentication (required for CCPM)
gh auth login
gh auth status

# Manual issue/PR management (usually automatic)
gh issue list
gh pr list
gh pr create --title "feat: epic completion" --body "Description"
```

## System Utilities (macOS/Darwin)

### 7. Common Unix Commands
```bash
# File operations
ls -la              # List files with details
find . -name "*.ts" # Find files by pattern
grep -r "pattern"   # Search text in files
cat file.txt        # Display file content
head -n 20 file.txt # First 20 lines
tail -f file.log    # Follow log file

# System info
ps aux              # List processes
df -h               # Disk usage
top                 # System monitor
which command       # Find command location
```

### 8. Git Commands (Enhanced by CCMP hooks)
```bash
# Standard git workflow
git status
git add .
git commit -m "message"  # Triggers post-commit hook
git push                 # Triggers pre-push hook
git pull
git checkout -b feature/epic-name
git merge main

# CCPM-specific patterns
git commit -m "feat(auth): implement login component"
git commit -m "fix(api): resolve authentication bug"
git commit -m "test(auth): add comprehensive test coverage"
```

## Debugging and Logs

### 9. Log Investigation
```bash
# Check automation logs
tail -f .claude/logs/auto-sync.log
cat .claude/logs/github-sync.log

# Check git hook execution
ls -la .git/hooks/
cat .git/hooks/post-commit
```

## Emergency/Troubleshooting

### 10. Disable Automation (Emergency)
```bash
# Disable auto-merge (create emergency stop file)
touch .github/auto-merge-disabled
git commit -m "emergency: disable auto-merge"

# Skip git hooks (bypass automation)
git commit --no-verify -m "emergency commit"

# Manual sync recovery
./.claude/scripts/sync.sh epic-name --force
```

## Most Important Commands to Remember
1. **`/new epic-name "description"`** - Creates everything automatically
2. **`git commit`** and **`git push`** - Triggers all automation
3. **`./.claude/scripts/install-hooks.sh`** - One-time setup
4. **`npm run lint`**, **`npm run typecheck`**, **`npm run test`**, **`npm run build`** - Quality gates