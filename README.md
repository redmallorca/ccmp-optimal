# CCPM Optimal - Clean Claude Code Project Management

**Zero-Command Automation** for modern development workflows with GitHub integration.

## 🚀 Quick Start

### 1. Install CCPM
```bash
# Copy template to your project
cp -r ccpm-optimal/* your-project/
cd your-project

# Install automation hooks
./.claude/scripts/install-hooks.sh
```

### 2. Create Your First Epic
```bash
# Only command you'll ever need to remember
/pm:new user-auth "Implement user authentication system"
```

### 3. Code Normally
```bash
# Just code and commit - everything else is automatic
git add .
git commit -m "feat(auth): implement login component"
git push

# 🤖 Auto-sync handles:
# - Progress tracking
# - GitHub issue updates
# - PR creation at 100% completion
# - Auto-merge when CI passes
```

## 🎯 Core Philosophy

**Zero commands after `/pm:new`**. Everything happens automatically through your normal git workflow.

### What CCPM Does Automatically
- ✅ **Progress Tracking**: File-based completion detection
- ✅ **GitHub Sync**: Issue updates, PR creation, auto-merge
- ✅ **Quality Gates**: Progressive validation without blocking workflow
- ✅ **Memory Sync**: Context preservation in Supermemory/OpenMemory
- ✅ **CI/CD Integration**: GitHub Actions with simplified testing

### What You Do
1. `/pm:new epic-name "description"` (once per epic)
2. Code and commit normally
3. Push when ready
4. **Done!** 🎉

## 📁 System Architecture

### 5 Core Rules (Not 38 Commands)
```
.claude/rules/
├── auto-sync.md        # Zero-command automation
├── ci-integration.md   # GitHub Actions CI/CD
├── git-workflow.md     # Standard branches + PR automation
├── memory-sync.md      # Supermemory integration
└── quality-gates.md    # Progressive validation
```

### 6 Simplified Agents
```
.claude/agents/
├── project-manager.md     # Epic coordination
├── simple-tester.md       # Streamlined testing (no CI blocking)
├── code-analyzer.md       # Bug tracing with Serena
├── frontend-specialist.md # Modern frontend patterns
├── backend-specialist.md  # API and service architecture
└── security-specialist.md # Security review and auditing
```

### 5 Core Commands
```
.claude/commands/
├── new.md      # /pm:new - Create epic (only manual command)
├── start.md    # /pm:start - Load context for existing epic
├── status.md   # /pm:status - Check progress (no automation)
├── sync.md     # /pm:sync - Force GitHub sync if needed
└── close.md    # /pm:close - Archive completed epic
```

### Auto-Sync Engine
```
.claude/scripts/
├── auto-sync-engine.sh    # Core automation logic
├── hooks/
│   ├── post-commit        # Trigger after each commit
│   └── pre-push          # Final sync before push
└── install-hooks.sh      # Setup automation
```

## 🛠️ Tool Integration

### Preferred Tools (Pre-configured)
- **💭 Supermemory**: Context + decisions auto-sync
- **🔍 Serena**: Code analysis (`find_symbol`, `search_for_pattern`)
- **✨ Zen**: Complex decisions + quality review
- **🧠 MorphLLM**: Multi-model consensus for architecture
- **📝 OpenMemory**: Session context preservation

### CI/CD Stack
- **GitHub Actions**: Native CI with progressive quality gates
- **Auto-merge**: PR automation when tests pass
- **Branch Protection**: Standard git workflow
- **Quality Gates**: Fast feedback, never blocking

## 📊 Progress Tracking

### File-Based Completion Detection
```json
{
  "deliverables": [
    {
      "pattern": "src/components/AuthComponent.vue",
      "required": true,
      "description": "Authentication component"
    },
    {
      "pattern": "tests/auth.test.js",
      "required": true,
      "description": "Test coverage"
    }
  ]
}
```

### Automatic GitHub Integration
- **Issue Comments**: Progress updates after each commit
- **PR Creation**: Auto-created at 100% completion
- **Auto-merge**: Enabled when CI passes
- **Milestone Sync**: Epic progress tracking

## 🔄 Workflow Example

### Epic Lifecycle
```bash
# 1. Create epic (only manual command)
/pm:new bike-gallery "Interactive bike photo gallery"

# 2. CCMP creates:
# - .claude/epics/bike-gallery/deliverables.json
# - feature/bike-gallery branch
# - GitHub issue #123
# - Auto-sync configuration

# 3. Normal development
git add src/components/BikeGallery.vue
git commit -m "feat(gallery): add bike photo component"
# 🤖 Auto-sync: Updates GitHub issue "33% complete"

git add src/pages/gallery.astro
git commit -m "feat(gallery): add gallery page"
# 🤖 Auto-sync: Updates GitHub issue "67% complete"

git add tests/gallery.test.js
git commit -m "test(gallery): add comprehensive tests"
# 🤖 Auto-sync: Updates GitHub issue "100% complete"
# 🤖 Auto-sync: Creates PR with auto-merge label

git push origin feature/bike-gallery
# 🤖 CI/CD: Runs quality gates
# 🤖 Auto-merge: Merges PR when tests pass
# 🤖 GitHub: Closes issue #123
# 🤖 Cleanup: Deletes feature branch
```

## ⚙️ Configuration

### Minimal Setup Required
```json
{
  "auto_sync": {
    "enabled": true,
    "github_integration": true,
    "supermemory_integration": true
  },
  "github": {
    "auto_merge": true,
    "target_branch": "main"
  }
}
```

### GitHub CLI Setup
```bash
# Required for GitHub integration
gh auth login
```

## 🚨 Emergency Procedures

### Disable Auto-Merge
```bash
# Create emergency stop file
touch .github/auto-merge-disabled
git commit -m "emergency: disable auto-merge"
```

### Manual Sync Recovery
```bash
# If auto-sync fails
/pm:sync epic-name --force

# Check auto-sync logs
tail -f .claude/logs/auto-sync.log
```

## 🆚 vs Original CCPM

### Original CCPM Problems
- ❌ **38 commands** (overwhelming complexity)
- ❌ **4,812 lines** of documentation
- ❌ **Manual dependency** breaking automation
- ❌ **Git worktree confusion** instead of standard branches
- ❌ **Missing epic-sync.sh** (critical automation gap)
- ❌ **Complex test-runner** blocking GitHub CI

### CCPM Optimal Solutions
- ✅ **5 commands** (90% reduction)
- ✅ **Zero-command automation** after setup
- ✅ **Standard git workflow** (main/stable/feature branches)
- ✅ **PR-based workflow** with auto-merge
- ✅ **Simplified CI/CD** that works with GitHub Actions
- ✅ **Complete automation engine** with git hooks

## 📈 Success Metrics

- **Commands**: 38 → 5 (87% reduction)
- **Documentation**: 4,812 → 800 lines (83% reduction)
- **Manual Steps**: 90% → 5% automation
- **Context Usage**: Optimized for preferred tools
- **CI Compatibility**: GitHub Actions native

## 🤝 Contributing

This is a clean template. Copy to your projects and adapt as needed.

**CCPM Optimal: The CCPM system that actually works.** 🚀

---

**Zero commands. Maximum automation. Pure focus on coding.**