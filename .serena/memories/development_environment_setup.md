# CCPM Optimal - Development Environment Setup

## Prerequisites (macOS/Darwin)

### 1. Core Dependencies
```bash
# Git (usually pre-installed on macOS)
git --version  # Should be 2.30+

# GitHub CLI (required for automation)
brew install gh
gh auth login  # Required for CCPM integration

# jq for JSON parsing in scripts
brew install jq

# Node.js and npm (for frontend projects)
brew install node@20  # Node.js 20+ recommended
```

### 2. Optional but Recommended
```bash
# Docker (for container support)
brew install docker
brew install docker-compose

# Modern terminal (better debugging experience)
brew install iterm2
brew install oh-my-zsh
```

## CCPM Installation

### 3. Template Setup (Copy to new project)
```bash
# Method 1: Copy template to your project
cp -r ccmp-optimal/* your-new-project/
cd your-new-project

# Method 2: Clone and adapt
git clone https://github.com/your-org/ccpm-optimal.git
cd ccpm-optimal
# Customize for your project needs
```

### 4. Initial Configuration
```bash
# Install git hooks (enables automation)
./.claude/scripts/install-hooks.sh

# Verify hooks installed
ls -la .git/hooks/
# Should show: post-commit, pre-commit, pre-push

# Create logs directory
mkdir -p .claude/logs

# Verify GitHub CLI authentication
gh auth status
```

### 5. Project-Specific Setup
```bash
# Edit configuration for your project
vim .claude/config.json

# Key settings to customize:
# - deliverables.patterns: File patterns for your tech stack
# - github.target_branch: main/master/develop
# - quality_gates: Which checks to enable
# - zen_commit.critical_files: Files that trigger validation
```

## Frontend Project Setup

### 6. Node.js Projects (Recommended patterns)
```bash
# Typical package.json scripts expected by CCPM
{
  "scripts": {
    "dev": "vite dev",           # Development server
    "build": "vite build",       # Production build
    "lint": "eslint src/",       # Code linting
    "lint:fix": "eslint src/ --fix",
    "typecheck": "tsc --noEmit", # TypeScript validation
    "test": "vitest",            # Unit tests
    "test:e2e": "playwright test", # E2E tests
    "format": "prettier --write src/",
    "preview": "vite preview"
  }
}
```

### 7. Tech Stack Configurations

#### Astro + DaisyUI (Static sites)
```bash
npm create astro@latest
npm run astro add tailwind
npm run astro add alpinejs

# Install DaisyUI
npm install -D daisyui
```

#### Vue 3 + PrimeVue (Full-stack apps)
```bash
npm create vue@latest
npm install primevue primeicons
npm install @vueuse/core
```

#### React + TypeScript
```bash
npx create-react-app@latest . --template typescript
npm install -D eslint prettier @types/node
```

## Docker Environment (Optional)

### 8. Container Development
```bash
# Use provided Docker templates
cp .claude/templates/docker-compose.yml .
cp .claude/templates/docker-compose.dev.yml .

# Container development commands
./.claude/scripts/container-exec.sh dev     # Start dev server
./.claude/scripts/container-exec.sh build   # Build project
./.claude/scripts/container-exec.sh lint    # Run linting
./.claude/scripts/container-exec.sh test    # Run tests
```

## IDE and Editor Setup

### 9. VS Code (Recommended)
```json
// .vscode/settings.json
{
  "editor.formatOnSave": true,
  "editor.codeActionsOnSave": {
    "source.fixAll.eslint": true
  },
  "typescript.preferences.importModuleSpecifier": "relative",
  "emmet.includeLanguages": {
    "vue": "html",
    "astro": "html"
  }
}

// .vscode/extensions.json  
{
  "recommendations": [
    "esbenp.prettier-vscode",
    "dbaeumer.vscode-eslint", 
    "bradlc.vscode-tailwindcss",
    "astro-build.astro-vscode",
    "vue.volar"
  ]
}
```

### 10. Git Configuration
```bash
# Set up user info (required for commits)
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"

# Optional: Set up GitHub token in git config
git config --global github.token "your_github_token"

# Verify CCPM hooks are executable
chmod +x .git/hooks/*
```

## Project Initialization

### 11. First Epic Creation
```bash
# Test the system with your first epic
/new test-epic "Test epic to validate CCPM setup"

# This should:
# - Create .claude/epics/test-epic/ directory
# - Create GitHub issue
# - Set up feature/test-epic branch
# - Show success message

# Verify epic creation
/status test-epic
```

### 12. Validation Checklist
```bash
# Verify all components work:
✅ Git hooks installed (.git/hooks/ populated)
✅ GitHub CLI authenticated (gh auth status)
✅ jq available (jq --version)
✅ Node.js setup (npm --version)
✅ CCPM scripts executable (ls -la .claude/scripts/)
✅ First epic created successfully
✅ Quality gates working (npm run lint/test/build)
```

## Troubleshooting Common Issues

### 13. Permission Issues
```bash
# Fix script permissions
find .claude/scripts -name "*.sh" -exec chmod +x {} \;

# Fix git hooks
chmod +x .git/hooks/*
```

### 14. GitHub Integration Issues
```bash
# Re-authenticate GitHub CLI
gh auth logout
gh auth login

# Check repository URL format
git remote -v
# Should show: git@github.com:user/repo.git or https://github.com/user/repo.git

# Test GitHub API access
gh issue list
```

### 15. Node.js Issues
```bash
# Clear npm cache
npm cache clean --force

# Reinstall dependencies  
rm -rf node_modules package-lock.json
npm install

# Check Node.js version compatibility
node --version  # Should be 18+ or 20+
```

## Development Workflow Setup

### 16. Daily Development Environment
```bash
# Start development session
/start epic-name  # Load context for existing epic
npm run dev       # Start dev server

# Normal development cycle
git add .
git commit -m "feat(component): implement feature"
git push

# Check progress
/status epic-name
```

### 17. Team Setup
```bash
# Share CCPM configuration with team
git add .claude/config.json
git add .claude/CLAUDE.md
git commit -m "docs: add CCPM configuration"

# Team members setup
./.claude/scripts/install-hooks.sh  # Each developer runs this
gh auth login                        # Each developer needs GitHub auth
```