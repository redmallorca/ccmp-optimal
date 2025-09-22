# Git Workflow Rules

Standard branch-based workflow with PR automation and auto-merge integration.

## Core Principle

**Standard git workflow enhanced with automation.** No complex worktrees, no manual commands, just normal git + smart automation.

## Branch Strategy

### Main Branches
```bash
main     # Protected, auto-merge from feature branches
stable   # Protected, manual releases from main
```

### Feature Branches
```bash
feature/epic-name           # For epics/large features
feature/issue-123          # For specific GitHub issues
hotfix/critical-fix        # For urgent production fixes
```

### Branch Naming Convention
- `feature/` - New functionality
- `hotfix/` - Critical production fixes
- `docs/` - Documentation updates
- `refactor/` - Code improvements

## Workflow Steps

### 1. Start Work
```bash
# Developer workflow (no manual PM commands needed)
git checkout main
git pull origin main
git checkout -b feature/user-authentication

# [Optional: /pm:new user-authentication for epic planning]
```

### 2. Development Loop
```bash
# Normal development cycle
git add .
git commit -m "feat(auth): implement login component

- Add LoginForm.vue component
- Integrate with auth API
- Add form validation
- Closes #123"

# [post-commit hook auto-detects progress]
# [auto-sync updates GitHub issue]
```

### 3. Ready for Review
```bash
git push origin feature/user-authentication

# [pre-push hook creates PR automatically]
# [adds auto-merge label if deliverables complete]
# [links to GitHub issues automatically]
```

### 4. Auto-Merge
```bash
# [GitHub Actions runs CI]
# [Auto-merge triggers if tests pass]
# [Feature branch auto-deleted]
# [GitHub issues auto-closed]
```

## PR Automation

### Auto-PR Creation
- Push to feature branch → PR created automatically
- PR title from branch name + recent commits
- Auto-link to GitHub issues (#123 in commits)
- Add appropriate labels based on branch type

### Auto-Merge Labels
- `auto-merge` - Enable auto-merge when CI passes
- `manual-review` - Force human review before merge
- `breaking-change` - Require additional approvals
- `hotfix` - Fast-track for critical fixes

## Commit Message Format

### Standard Format
```bash
<type>(<scope>): <description>

[optional body]

[optional footer]
```

### Examples
```bash
feat(auth): add login component
fix(ui): resolve mobile navigation issue
docs(readme): update installation instructions
refactor(api): simplify user service
test(auth): add integration tests
```

### Auto-Detection Keywords
- `Closes #123` - Auto-close GitHub issue
- `Fixes #123` - Auto-close bug report
- `Resolves #123` - Auto-close any issue type
- `Complete` - Trigger completion detection

## Merge Strategy

### Squash and Merge (Default)
- Clean commit history in main
- Single commit per feature
- Preserve meaningful commit messages
- Auto-delete feature branch

### Merge Commit (For Epics)
- Preserve feature branch history
- Use for large features/epics
- Manual decision based on PR size

## Branch Protection Rules

### Main Branch
```yaml
required_status_checks:
  strict: true
  contexts:
    - "quality-gates"
enforce_admins: false
required_pull_request_reviews:
  required_approving_review_count: 0  # Auto-merge enabled
  dismiss_stale_reviews: true
restrictions: null
```

### Stable Branch
```yaml
required_pull_request_reviews:
  required_approving_review_count: 1  # Require manual approval
  restrict_reviews_to_code_owners: true
required_status_checks:
  strict: true
  contexts:
    - "quality-gates"
    - "security-scan"
```

## Conflict Resolution

### Auto-Resolution
- Simple conflicts: Auto-rebase when possible
- Complex conflicts: Block auto-merge, require manual resolution
- Conflict detection in pre-push hook

### Manual Resolution
```bash
# When auto-merge blocked by conflicts
git checkout main
git pull origin main
git checkout feature/branch
git rebase main

# Resolve conflicts, then:
git push --force-with-lease origin feature/branch
# [Auto-merge re-enabled after CI passes]
```

## Emergency Procedures

### Disable Auto-Merge
```bash
# Create emergency stop file
touch .github/auto-merge-disabled
git add .github/auto-merge-disabled
git commit -m "emergency: disable auto-merge"
git push origin main
```

### Hotfix Process
```bash
# Critical production issue
git checkout main
git pull origin main
git checkout -b hotfix/critical-security-fix

# Fix, commit, push
git push origin hotfix/critical-security-fix
# [Auto-merge with expedited CI for hotfix branches]
```

**Keep git workflow simple and familiar. Automation enhances, never replaces, standard git practices.**