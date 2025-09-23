# [PROJECT] - Claude Code Project Management (CCPM)

**Repository**: https://github.com/YOUR_ORG/YOUR_PROJECT.git
**Stack**: Modern CI/CD • GitHub Actions • Auto-Merge • Zero-Command PM

> We're colleagues working together. Simple, maintainable solutions over clever complexity.

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

- **Standard Tools**: npm test, npm run lint, npm run build
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

## 🤖 **Sub-Agents for Context Optimization**

### **Core Analysis Agents**
- **file-analyzer**: Extract key info from logs, configs, verbose files
- **code-analyzer**: Code analysis, bug tracing, logic flow investigation
- **simple-tester**: Basic test execution (replaces complex test-runner)

### **Specialized Agents**
- **project-manager**: Epic planning, deliverable tracking, auto-sync coordination
- **devops-specialist**: Docker, containers, CI/CD, deployment automation
- **performance-specialist**: Core Web Vitals, optimization, monitoring
- **security-specialist**: Vulnerability scanning, secure coding practices

### **Tech Stack Specialists** (Configure per project)
Choose the appropriate specialists based on your project's technology stack:

#### **Frontend Options** (choose one):
- **frontend-daisyui-specialist**: Astro + Vite + DaisyUI  for static sites
- **frontend-primevue-specialist**: Vite + Vue 3 + PrimeVue for full-stack apps

#### **Backend Options** (choose one or multiple):
- **laravel-specialist**: Laravel 11+ with DDD, Repository Pattern, Pest testing

### **Project Configuration Examples**

#### **Astro + DaisyUI Static Site** (e.g., Marketing site, Documentation)
```markdown
## 🤖 Active Specialists for this Project
- ✅ **frontend-daisyui-specialist**: Astro + DaisyUI + Alpine.js
- ✅ **devops-specialist**: Docker deployment and CI/CD
- ✅ **performance-specialist**: Core Web Vitals optimization
- ✅ **security-specialist**: Static site security best practices
- ❌ frontend-primevue-specialist (not needed)
- ❌ laravel-specialist (static site, no backend)
```

#### **Laravel + Vue Inertia Full-Stack App** (e.g., SaaS, Admin panel)
```markdown
## 🤖 Active Specialists for this Project
- ✅ **frontend-primevue-specialist**: Vue 3 + PrimeVue + Inertia.js
- ✅ **laravel-specialist**: Laravel 11+ with DDD patterns
- ✅ **devops-specialist**: Docker deployment and CI/CD
- ✅ **performance-specialist**: Full-stack optimization
- ✅ **security-specialist**: Web application security
- ❌ frontend-daisyui-specialist (using Vue, not Astro)
```

#### **Pure Laravel API** (e.g., Mobile app backend, API service)
```markdown
## 🤖 Active Specialists for this Project
- ✅ **laravel-specialist**: Laravel 11+ API with DDD
- ✅ **devops-specialist**: API deployment and CI/CD
- ✅ **performance-specialist**: API performance optimization
- ✅ **security-specialist**: API security and authentication
- ❌ frontend-daisyui-specialist (API only, no frontend)
- ❌ frontend-primevue-specialist (API only, no frontend)
```

**Note**: Add your project's configuration to this CLAUDE.md file so AI agents know which specialists are available.

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
- `/pm:new <epic>` - Create new epic with auto-sync setup
- `/pm:status` - View project dashboard
- `/pm:sync` - Manual sync override for troubleshooting
- `/pm:close <epic>` - Force complete epic

### **Deliverable Auto-Detection**
- **File-based**: Specific files created/modified trigger completion
- **Test-based**: CI success indicates deliverable completion
- **Commit-based**: Commit messages with completion keywords
- **PR-based**: Merged PRs auto-close linked issues

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

## 📋 **Project Setup Checklist**

- [ ] Copy this CLAUDE.md to project root
- [ ] **Configure active specialists**: Add project-specific agent configuration section
- [ ] Setup GitHub Actions CI workflow
- [ ] Configure branch protection (main/stable)
- [ ] Install CCPM hooks: `npm run ccpm:init`
- [ ] Test auto-sync: make commit, verify PR creation
- [ ] Configure Supermemory integration
- [ ] Setup auto-merge rules

**Last Updated**: $(date)