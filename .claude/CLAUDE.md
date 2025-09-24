# [PROJECT] - [YOUR PROJECT NAME]

**Repository**: https://github.com/YOUR_ORG/YOUR_PROJECT.git
**Stack**: [YOUR TECH STACK] • CCPM Auto-Sync • GitHub Actions • Zero-Command PM

> ABOUTME: [Brief description of your project - 2 lines max]
> ABOUTME: [Additional context about the project purpose and scope]

### Our Collaboration Style

- 🤝 **Team mindset**: Your success = my success, push back with evidence when needed
- 💭 **Supermemory first**: Always search/add memories for context and decisions
- 🎯 **Direct communication**: Essential info only, minimal AI ↔ AI tokens
- 😄 **Work smart**: Summer work ethic - efficient to maximize vacation time

## 🛠️ **Development Approach**

### **TDD + CI/CD Native** ✨

- **Write failing test** before any code
- **Minimal code** to make test pass
- **CI/CD passes** before merge
- **Auto-merge** when quality gates pass
- **NO EXCEPTIONS**: Every feature needs tests + CI success

### **Tool Strategy** 🔧

- **💭 Primary**: Supermemory for context/decisions + auto-sync
- **🔍 Code**: Serena tools (`find_symbol`, `search_for_pattern`)
- **✨ Complex decisions**: Zen tools for quality + architecture
- **📊 General**: MorphLLM for documentation + routine tasks
- **🧠 Memory**: OpenMemory for local session memory

### **Auto-CCPM Workflow** ⚡

- **Zero Commands**: Work happens via git commits, not manual PM commands
- **Auto-Sync**: Post-commit hooks detect completion, create PRs automatically
- **CI-Native**: GitHub Actions handle testing, quality gates, auto-merge
- **PR-Based**: All merges to main via Pull Request with auto-merge labels

## 🔥 **Quality Standards**

### **Git + CI Protocol**

- **PR-Based Workflow**: All changes go through Pull Request
- **Auto-Merge**: CI success triggers automatic merge to main
- **Branch Protection**: main/stable protected, requires CI + reviews
- **Standard Branches**: feature/* (no complex worktrees)

### **Simplified Testing**

- **Standard Tools**: [npm test|cargo test|pytest|composer test], [npm run lint], [npm run build]
- **GitHub Actions**: Standard CI, no complex test abstractions
- **Progressive Gates**: lint → test → build → auto-merge
- **Real Data**: No mocks, test with actual data

### **Code Standards**

- **Evergreen naming**: No "improved", "new", "enhanced"
- **Fix root causes**: No workarounds
- **ABOUTME comments**: Start files with 2-line description
- **Simple > Clever**: Readable code over abstractions

## ✅ **Done Definition**

1. **Tests pass** (CI green)
2. **PR created** with auto-merge label
3. **CI/CD completes** successfully
4. **Auto-merge** to main branch
5. **Supermemory synced** with decisions
6. **GitHub issue** auto-closed

## 🤖 **Active Specialists for this Project**

[INSTRUCTIONS: Choose the appropriate specialists based on your project's technology stack]

### **Frontend Projects**
- ✅ **frontend-daisyui-specialist**: Astro + DaisyUI + Alpine.js for static sites
- ✅ **frontend-primevue-specialist**: Vue 3 + PrimeVue + Inertia.js for full-stack apps

### **Backend Projects**
- ✅ **laravel-specialist**: Laravel 11+ with DDD, Repository Pattern, Pest testing
- ✅ **backend-specialist**: API development and service architecture

### **Core Specialists** (Always include)
- ✅ **project-manager**: Epic planning, deliverable tracking, auto-sync coordination
- ✅ **devops-specialist**: Docker, containers, CI/CD, deployment automation
- ✅ **performance-specialist**: Optimization and monitoring
- ✅ **security-specialist**: Security review and best practices
- ✅ **simple-tester**: Test execution and quality assurance

### **Specialized Agents** (Optional)
- ✅ **code-analyzer**: Bug tracing, code analysis with Serena tools
- ✅ **file-analyzer**: Extract info from logs, configs, verbose files

## 🔄 **CCPM Auto-Workflow**

### **Zero-Command Operation**
```bash
# Developer workflow:
1. git commit -m "feat: implement user auth"
2. [post-commit hook detects completion]
3. [auto-sync creates PR with auto-merge label]
4. [GitHub Actions runs CI]
5. [auto-merge completes if tests pass]
6. [GitHub issue auto-closes]
```

### **Manual Override Commands** (rarely needed)
- `/new <epic-name> "description"` - Create new epic with auto-sync setup
- `/start <epic-name>` - Load context for existing epic
- `/status [epic-name]` - View project dashboard (all epics or specific)
- `/sync [epic-name]` - Manual sync override for troubleshooting
- `/close <epic-name>` - Complete and archive epic
- `/overview` - Show project status and health

### **Deliverable Auto-Detection**
File patterns configured in `.claude/config.json`:
```json
{
  "deliverables": {
    "patterns": [
      "src/components/*.{vue,astro,tsx,jsx}",
      "src/pages/*.{astro,tsx}",
      "src/services/*.{js,ts}",
      "tests/**/*.test.{js,ts}",
      "docs/*.md"
    ]
  }
}
```

## 🔧 **Memory Integration**

### **Supermemory Auto-Sync**
- Project decisions automatically stored
- Context preserved across sessions
- Team knowledge base maintained
- Integration with GitHub issues/PRs

### **OpenMemory Session Management**
- Local context for current work session
- Temporary decisions and notes
- Sync to Supermemory when relevant

---

## 📋 **CCPM Installation Checklist**

### **Initial Setup**
- [ ] **Copy CCPM template**: `cp -r ccpm-optimal/.claude your-project/`
- [ ] **Copy this file**: `cp ccpm-optimal/.claude/CLAUDE-TEMPLATE.md your-project/CLAUDE.md`
- [ ] **Customize CLAUDE.md**: Update project name, repository, tech stack, specialists
- [ ] **Update deliverable patterns**: Edit `.claude/config.json` for your file structure

### **GitHub Integration**
- [ ] **Setup GitHub CLI**: `gh auth login`
- [ ] **Configure branch protection**: Protect main/stable branches on GitHub
- [ ] **Setup GitHub Actions**: Copy CI workflow from template
- [ ] **Enable auto-merge**: Configure auto-merge rules

### **CCPM Activation**
- [ ] **Install hooks**: `./.claude/scripts/install-hooks.sh`
- [ ] **Test auto-sync**: Create test commit, verify automation
- [ ] **Create first epic**: `/new test-epic "Test epic for validation"`
- [ ] **Verify workflow**: Complete epic, check PR creation and auto-merge

### **Configuration Customization**
- [ ] **Update file patterns**: Edit `.claude/config.json` deliverable patterns
- [ ] **Configure quality gates**: Enable/disable lint, test, build in config
- [ ] **Setup Supermemory**: Configure project integration if available

---

## 🚀 **Quick Start Example**

### **1. Install CCPM**
```bash
# Copy CCPM to your project
cp -r ccpm-optimal/.claude your-project/
cp ccpm-optimal/.claude/CLAUDE-TEMPLATE.md your-project/CLAUDE.md
cd your-project

# Install automation
./.claude/scripts/install-hooks.sh
```

### **2. Customize Configuration**
```bash
# Edit CLAUDE.md - update project details and active specialists
# Edit .claude/config.json - update deliverable patterns for your project structure
```

### **3. Create First Epic**
```bash
# Only manual command you'll ever need
/new user-auth "Implement user authentication system"

# Code normally - everything else is automatic
git add src/components/LoginForm.vue
git commit -m "feat(auth): add login form component"
# 🤖 Auto-sync: Updates GitHub issue progress

git add tests/auth.test.js
git commit -m "test(auth): add login form tests"
# 🤖 Auto-sync: Epic complete → Creates PR → Auto-merge when CI passes
```

### **4. Zero Commands Forever**
After setup, just code and commit normally. CCPM handles all project management automatically.

**Template Version**: 2024-09-24