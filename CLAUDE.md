# [PROJECT] - CCPM Optimal Template System

**Repository**: https://github.com/perekpp/ccpm-optimal
**Stack**: Shell Scripts • Git Hooks • GitHub Actions • Zero-Command PM Template

> ABOUTME: Clean Claude Code Project Management template with zero-command automation for any project
> ABOUTME: Template system that copies to projects providing file-based epic tracking and GitHub integration

### Our Collaboration Style

- 🤝 **Team mindset**: Your success = my success, push back with evidence when needed
- 💭 **Supermemory first**: Always search/add memories for context and decisions
- 🎯 **Direct communication**: Essential info only, minimal AI ↔ AI tokens
- 😄 **Work smart**: Summer work ethic - efficient to maximize vacation time

## 🛠️ **Development Approach**

### **Template Development** ✨

- **Shell script focused**: Pure bash automation, no language dependencies
- **Copy-first design**: Easy to copy and customize for any project
- **File-based tracking**: Epic completion via deliverables.json patterns
- **Git-native workflow**: Standard branches, hooks-driven automation
- **Zero dependencies**: Works with just git, bash, and optional GitHub CLI

### **Tool Strategy** 🔧

- **💭 Primary**: Supermemory for template evolution and project context
- **🔍 Code**: Serena tools for template development and debugging
- **✨ Complex decisions**: Zen tools for template architecture decisions
- **📊 General**: MorphLLM for documentation and routine template updates
- **🧠 Memory**: OpenMemory for development session context

### **Template Architecture** ⚡

- **5 Core Commands**: new, start, status, sync, close (vs 38 in original CCPM)
- **Auto-Sync Engine**: Post-commit hooks detect completion automatically
- **GitHub Integration**: Issue tracking, PR creation, auto-merge capabilities
- **Epic Management**: deliverables.json patterns for progress tracking

## 🔥 **Quality Standards**

### **Template Testing**

- **Shell script validation**: shellcheck linting for all bash scripts
- **Template deployment tests**: Verify copy-to-project workflow works
- **GitHub integration tests**: Test issue creation and PR automation
- **Cross-project compatibility**: Test with different tech stacks

### **Code Standards**

- **Evergreen naming**: No "improved", "new", "enhanced" in template
- **Shell script best practices**: set -euo pipefail, proper error handling
- **ABOUTME comments**: Start all scripts with 2-line description
- **Simple > Clever**: Readable shell code over complex abstractions

## ✅ **Done Definition**

1. **Template functionality tests pass**
2. **Copy-to-project workflow validated**
3. **GitHub integration working**
4. **Documentation updated**
5. **Version tagged and released**
6. **README.md reflects changes**

## 🤖 **Active Specialists for this Project**

This is the **CCPM template development project** - specialists configured for template system development:

### **Core Template Development**
- ✅ **project-manager**: Template epic coordination and release planning
- ✅ **devops-specialist**: Git hooks, shell scripts, GitHub Actions CI
- ✅ **security-specialist**: Shell script security, git workflow security
- ✅ **simple-tester**: Template testing, deployment validation

### **Documentation & Architecture**
- ✅ **code-analyzer**: Template debugging, shell script analysis
- ✅ **file-analyzer**: Log analysis, configuration file optimization

### **NOT Active** (Template System Only)
- ❌ **frontend-daisyui-specialist**: (no UI in template system)
- ❌ **frontend-primevue-specialist**: (no UI in template system)
- ❌ **laravel-specialist**: (language-agnostic template)

## 🔄 **Template Development Workflow**

### **Template Evolution Process**
```bash
# Template development workflow:
1. git commit -m "feat(template): improve auto-sync detection"
2. [validate template functionality]
3. [test copy-to-project workflow]
4. [verify GitHub integration]
5. [update documentation]
6. [tag new template version]
```

### **Template Commands**
- `/overview` - Show template development status
- `/status [epic-name]` - Check template component health (all epics or specific)
- `/new <epic-name> "description"` - Create test epic for validation
- `/start <epic-name>` - Load context for existing epic
- `/close <epic-name>` - Complete and archive epic
- `.claude/scripts/install-hooks.sh` - Install automation (for testing)

### **Template Structure**
```
.claude/
├── scripts/          # Core automation scripts
├── commands/         # Command documentation
├── agents/           # AI agent configurations
├── rules/            # System rules and workflows
├── templates/        # Configuration templates
└── CLAUDE-TEMPLATE.md # Template for projects
```

## 🎯 **Template Usage**

### **Copy to Your Project**
```bash
# Copy CCPM template to any project
cp -r ccpm-optimal/.claude your-project/
cp ccpm-optimal/.claude/CLAUDE-TEMPLATE.md your-project/CLAUDE.md

# Customize for your project
cd your-project
# Edit CLAUDE.md - update project details, tech stack, specialists
# Edit .claude/config.json - update deliverable patterns

# Install automation
./.claude/scripts/install-hooks.sh
```

### **Template Customization**
1. **Update CLAUDE.md**: Project name, repository, tech stack
2. **Configure specialists**: Enable appropriate frontend/backend specialists
3. **Set deliverable patterns**: Update .claude/config.json for your file structure
4. **GitHub setup**: gh auth login, configure branch protection
5. **Test automation**: Create epic (`/new test-epic "description"`), verify auto-sync works

## 🔧 **Memory Integration**

### **Supermemory Template Context**
- Template evolution decisions stored
- Cross-project insights preserved
- Best practices knowledge base maintained
- Template usage patterns tracked

### **OpenMemory Development Sessions**
- Template development context
- Testing notes and debugging info
- Sync to Supermemory when relevant for template improvement

---

## 📋 **Template Development Checklist**

### **Core Template Components**
- [x] Auto-sync engine (auto-sync-engine.sh)
- [x] Git hooks (post-commit, pre-commit, pre-push)
- [x] Command documentation (new, start, status, sync, close)
- [x] Agent configurations (project-manager, devops, etc.)
- [x] Installation script (install-hooks.sh)
- [x] Template CLAUDE.md for projects

### **GitHub Integration**
- [x] GitHub sync script (github-sync.sh)
- [x] Issue management (inbox-manager.sh)
- [x] PR automation and auto-merge support
- [x] GitHub Actions CI templates

### **Documentation & Usability**
- [x] README with clear copy-to-project instructions
- [x] Template usage examples
- [x] Shell script documentation
- [x] Troubleshooting guides

### **Template Testing**
- [ ] Test copy-to-project workflow
- [ ] Validate with different project types
- [ ] Test GitHub integration end-to-end
- [ ] Cross-platform compatibility (macOS/Linux)

---

## 🚀 **Template Deployment**

### **For Template Developers**
```bash
# Develop template improvements
git add .claude/scripts/enhanced-feature.sh
git commit -m "feat(template): add enhanced auto-sync detection"

# Test template deployment
cp -r .claude /tmp/test-project/
cd /tmp/test-project && ./.claude/scripts/install-hooks.sh

# Release new template version
git tag v2.1.0
git push origin v2.1.0
```

### **For Project Teams**
```bash
# Copy latest template to your project
curl -L https://github.com/perekpp/ccpm-optimal/archive/main.tar.gz | tar xz
cp -r ccpm-optimal-main/.claude your-project/
cp ccpm-optimal-main/.claude/CLAUDE-TEMPLATE.md your-project/CLAUDE.md

# Customize and activate
cd your-project
# [Edit CLAUDE.md and .claude/config.json]
./.claude/scripts/install-hooks.sh
```

**Template Version**: 2024-09-24