# /pm:start - Begin Epic Work

**Usage**: `/pm:start epic-name`

## Purpose

Activate an existing epic for development with context loading and tool preparation.

## What It Does

### 1. Context Loading
- Load epic configuration and deliverables
- Search Supermemory for related patterns and decisions
- Prepare development environment
- Switch to epic branch

### 2. Tool Preparation
```bash
# Serena memory search for context
mcp__serena__search_for_pattern epic-name
mcp__serena__get_symbols_overview src/components/

# Supermemory context loading
mcp__api-supermemory-ai__search "epic-name architecture patterns"
mcp__api-supermemory-ai__search "similar component implementations"
```

### 3. Development Setup
```bash
# Git branch switching
git checkout feature/epic-name
git pull origin main  # Ensure up-to-date

# Development server (if not running)
npm run dev

# Open relevant files in editor context
```

### 4. Progress Context
- Display current completion status
- Show remaining deliverables
- List recent commits and changes
- Present related epic decisions

## Context Report

### Epic Status Overview
```markdown
## Epic: user-auth (67% complete)

### Completed Deliverables ✅
- src/components/LoginForm.vue
- src/services/AuthService.ts
- tests/auth.test.js

### Remaining Deliverables 📋
- src/pages/login.astro
- docs/auth-guide.md

### Recent Progress
- Last commit: feat(auth): add JWT token validation
- GitHub issue: #123 (auto-updated 2 hours ago)
- Next milestone: Complete login page implementation

### Related Context
- Similar auth pattern used in project-xyz (Supermemory)
- JWT security best practices documented
- Login component follows atomic design pattern
```

### Agent Preparation
- **Frontend Specialist**: Ready for Astro page development
- **Security Specialist**: JWT and auth review prepared
- **Simple Tester**: Auth test suite context loaded

## Development Workflow Activation

### Auto-Sync Verification
```bash
# Verify auto-sync is working
✅ Post-commit hook active
✅ GitHub API connection verified
✅ Supermemory sync enabled
✅ Progress tracking functional
```

### Quality Gates Status
```bash
# Check CI/CD pipeline
✅ Lint configuration current
✅ Test suite passing
✅ Build pipeline operational
✅ Auto-merge rules configured
```

## Integration Points

### Memory Systems
- **Supermemory**: Load epic-related decisions and patterns
- **OpenMemory**: Prepare session context for development
- **Serena**: File and symbol context for deliverables

### Development Tools
- **Serena**: Component analysis and navigation
- **Zen**: Available for complex decision-making
- **Context7**: Framework documentation access

### GitHub Integration
- Verify issue tracking active
- Check PR auto-creation rules
- Confirm milestone linkage
- Test auto-merge configuration

## Example Usage

```bash
# Activate user authentication epic
/pm:start user-auth

# Output:
# 🚀 Activating epic: user-auth (67% complete)
# 📋 Loading context from Supermemory...
# 🔍 Analyzing existing components with Serena...
# 🌿 Switched to branch: feature/user-auth
# 📊 Progress: 3/5 deliverables complete
# 🎯 Next: Implement src/pages/login.astro
#
# Ready for development! 🛠️
```

## Context Preservation

### Session Memory
- Current epic and branch
- Loaded context and decisions
- Active deliverables and progress
- Development environment state

### Handoff Preparation
- Document work session context
- Update progress in memory systems
- Prepare context for next session
- Ensure no work context is lost

**Seamless epic activation with full context loading. Ready to code immediately with all relevant information accessible.**