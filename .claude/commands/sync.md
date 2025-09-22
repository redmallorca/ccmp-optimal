# /pm:sync - Force GitHub Synchronization

**Usage**: `/pm:sync [epic-name]`

## Purpose

Manually trigger GitHub synchronization when auto-sync fails or immediate update is needed.

## What It Does

### 1. Progress Calculation
- Recalculate deliverable completion percentage
- Validate file existence and quality
- Update internal progress tracking
- Prepare sync payload

### 2. GitHub API Sync
```bash
# Issue update with progress
POST /repos/owner/repo/issues/{issue_number}/comments
{
  "body": "## Epic Progress Update\n\n**Progress**: 67% complete (4/6 deliverables)\n\n### Completed ✅\n- LoginForm component\n- AuthService implementation\n- Test coverage\n- Auth middleware\n\n### Remaining 📋\n- Login page\n- Documentation\n\n_Auto-updated by CCPM system_"
}
```

### 3. Milestone Sync
- Update milestone progress
- Sync due dates if configured
- Link related issues
- Update project boards

### 4. PR Management
- Create PR if deliverables complete
- Update PR description with progress
- Add/remove auto-merge labels
- Sync branch protection status

## Sync Operations

### Issue Comment Updates
```markdown
## Epic Progress Update

**Progress**: 67% complete (4/6 deliverables)
**Last Updated**: $(date)
**Branch**: feature/user-auth

### ✅ Completed Deliverables
- src/components/LoginForm.vue
- src/services/AuthService.ts
- tests/auth.test.js
- src/middleware/auth.ts

### 📋 Remaining Deliverables
- src/pages/login.astro (required)
- docs/auth-guide.md (optional)

### Quality Status
- 🟢 Tests: All passing (12/12)
- 🟢 Lint: No issues
- 🟢 Build: Successful

### Next Steps
- Complete login page implementation
- Auto-merge will trigger at 100% completion

_Auto-updated by CCPM system_
```

### PR Auto-Creation
```bash
# When deliverables reach 100%
gh pr create \
  --title "feat(user-auth): Complete user authentication system" \
  --body "$(generate_pr_description)" \
  --label "auto-merge" \
  --base main \
  --head feature/user-auth
```

### Label Management
```bash
# Dynamic label assignment
labels=("auto-merge")

if [[ $completion_percent -eq 100 ]]; then
  labels+=("ready-for-merge")
fi

if [[ $has_breaking_changes == "true" ]]; then
  labels+=("breaking-change")
  # Remove auto-merge for manual review
  labels=("${labels[@]/auto-merge}")
fi

gh issue edit $issue_number --add-label "${labels[*]}"
```

## Sync Validation

### Pre-Sync Checks
```bash
# Validate sync prerequisites
✅ GitHub API token valid
✅ Issue exists and accessible
✅ Repository permissions sufficient
✅ Branch exists and pushed
✅ No merge conflicts
```

### Post-Sync Verification
```bash
# Confirm sync success
✅ Issue comment posted
✅ Progress updated
✅ Labels synchronized
✅ Milestone linked
✅ PR created (if applicable)
```

### Error Handling
```bash
# Common sync failures
❌ GitHub API rate limit → Retry with backoff
❌ Network timeout → Retry operation
❌ Permission denied → Log error, continue
❌ Issue not found → Recreate issue link
❌ Branch conflicts → Block auto-merge
```

## Manual Sync Triggers

### When to Use Manual Sync
- Auto-sync appears stuck or delayed
- Immediate GitHub update needed
- Testing sync configuration
- Recovering from sync failures
- Demonstrating progress to stakeholders

### Bulk Sync Operations
```bash
# Sync all active epics
/pm:sync --all

# Sync specific project epics
/pm:sync --project bike-app

# Force sync with validation
/pm:sync epic-name --force --validate
```

## Integration Points

### Auto-Sync Coordination
- Manual sync doesn't interfere with auto-sync
- Shared sync lock prevents conflicts
- Updates auto-sync state after manual sync
- Preserves auto-sync schedule

### Quality Gates
- Sync includes quality gate status
- CI/CD pipeline status reported
- Test results included in sync
- Security scan results attached

### Memory Systems
- **Supermemory**: Store sync decisions and patterns
- **Serena**: Analyze files for sync validation
- **GitHub**: Issue and PR state management

## Example Usage

```bash
# Sync specific epic
/pm:sync user-auth

# Output:
# 🔄 Syncing epic: user-auth
# 📊 Progress: 67% complete (4/6 deliverables)
# 📝 Updating GitHub issue #123...
# ✅ Issue comment posted
# 🏷️ Labels updated: auto-merge (pending completion)
# 📋 PR creation: Waiting for 100% completion
#
# Sync complete! ✅

# Force sync all epics
/pm:sync --all --force

# Validate sync configuration
/pm:sync --validate
```

## Automation Recovery

### Sync Failure Recovery
- Manual sync can recover from auto-sync failures
- Clears sync error states
- Re-establishes GitHub API connections
- Validates and repairs sync configuration

### Consistency Maintenance
- Ensures GitHub state matches local state
- Reconciles differences between systems
- Updates stale progress tracking
- Repairs broken auto-sync triggers

**Reliable manual override for GitHub synchronization. Use when auto-sync needs assistance or immediate updates are required.**