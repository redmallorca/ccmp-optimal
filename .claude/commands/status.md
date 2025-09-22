# /pm:status - Epic Progress Check

**Usage**: `/pm:status [epic-name]`

## Purpose

Display current epic progress, deliverable status, and next actions without any automation triggers.

## What It Does

### 1. Progress Analysis
- Calculate completion percentage based on file existence
- Check deliverable quality (file size, basic validation)
- Analyze recent commit activity
- Review GitHub sync status

### 2. Deliverable Status Check
```bash
# File-based completion detection
for deliverable in "${deliverables[@]}"; do
  if [[ -f "$deliverable" && -s "$deliverable" ]]; then
    echo "✅ $deliverable (completed)"
  else
    echo "📋 $deliverable (pending)"
  fi
done
```

### 3. GitHub Integration Status
- Issue tracking synchronization
- PR readiness assessment
- Auto-merge eligibility
- CI/CD pipeline status

## Status Report Format

### Epic Overview
```markdown
## Epic Status: user-auth

📊 **Progress**: 67% complete (4/6 deliverables)
🌿 **Branch**: feature/user-auth
🔗 **GitHub Issue**: #123 (last updated 2 hours ago)
⏰ **Last Activity**: 2 hours ago

### Deliverable Status

#### ✅ Completed (4/6)
- ✅ src/components/LoginForm.vue (2.1KB, 3 commits)
- ✅ src/services/AuthService.ts (1.8KB, 5 commits)
- ✅ tests/auth.test.js (3.2KB, 2 commits)
- ✅ src/middleware/auth.ts (0.9KB, 1 commit)

#### 📋 Pending (2/6)
- 📋 src/pages/login.astro (required)
- 📋 docs/auth-guide.md (optional)

### Quality Status
- 🟢 Tests: All passing (12/12)
- 🟢 Lint: No issues
- 🟢 TypeScript: No errors
- 🟢 Build: Successful

### Next Actions
1. 🎯 Create src/pages/login.astro (blocking auto-merge)
2. 📝 Add auth documentation (optional)
3. 🔄 Auto-merge will trigger at 100% completion
```

### Branch & Git Status
```bash
# Git information
Current branch: feature/user-auth
Commits ahead of main: 7
Last commit: feat(auth): add JWT token validation (2 hours ago)
Working directory: Clean

# Sync status
GitHub issue: #123 synchronized
Last progress update: 2 hours ago
Auto-sync: ✅ Active
```

### CI/CD Pipeline Status
```bash
# Quality gates
✅ Lint check: Passing
✅ TypeScript: No errors
✅ Unit tests: 12/12 passing
✅ Build: Successful
📋 E2E tests: Will run on PR creation

# Auto-merge readiness
🔄 Waiting for: src/pages/login.astro completion
✅ CI/CD: Ready
✅ Branch protection: Configured
✅ Auto-merge: Enabled when ready
```

## Multi-Epic Status

### Active Epics Overview
```bash
# When no epic specified, show all active
/pm:status

## Active Epics (3)

### 🟢 user-auth (67% complete)
- Branch: feature/user-auth
- Last activity: 2 hours ago
- Next: Complete login page

### 🟡 bike-gallery (34% complete)
- Branch: feature/bike-gallery
- Last activity: 1 day ago
- Next: Image optimization component

### 🔴 payment-integration (12% complete)
- Branch: feature/payment-integration
- Last activity: 3 days ago
- Next: Stripe API integration
```

### Repository Health
```bash
# Overall project status
Main branch: ✅ All tests passing
Dependency security: ✅ No vulnerabilities
Performance: ✅ Lighthouse score 94/100
Auto-merge: ✅ 3 PRs merged this week
```

## Integration Points

### Memory Systems
- **Supermemory**: Load epic context and decisions
- **Serena**: Analyze deliverable file quality
- **GitHub API**: Sync status and issue updates

### Analysis Tools
- **Code Analyzer**: File quality assessment
- **Simple Tester**: Test coverage analysis
- **Security Specialist**: Security deliverable review

## Example Usage

```bash
# Check specific epic
/pm:status user-auth

# Check all active epics
/pm:status

# Silent check (for automation)
/pm:status --quiet user-auth
```

## Automation Integration

### Non-Intrusive Monitoring
- Status checks don't trigger any automation
- Pure read-only operation
- Safe for frequent polling
- No side effects on git or GitHub

### Automation Hooks
- Status data used by auto-sync system
- Progress calculation for PR creation
- Completion detection for auto-merge
- Quality gate validation

**Quick, comprehensive epic status without triggering any automation. Perfect for checking progress and planning next steps.**