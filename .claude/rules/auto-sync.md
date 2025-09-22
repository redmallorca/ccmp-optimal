# Auto-Sync Rules

Zero-command automation through git hooks and CI/CD integration.

## Core Principle

**Work happens through commits, not commands.** The system detects completion automatically and syncs to GitHub without manual intervention.

## Deliverable Detection

### File-Based Completion
```bash
# Check specific files exist and are non-empty
deliverables=(
  "src/components/UserAuth.vue"
  "src/pages/login.astro"
  "tests/auth.test.js"
)

for file in "${deliverables[@]}"; do
  [[ -f "$file" && -s "$file" ]] || completion=false
done
```

### Commit-Based Completion
```bash
# Detect completion keywords in commit messages
if git log -1 --pretty=%B | grep -q -E "(complete|finish|done|implement).*#[0-9]+"; then
  issue_number=$(git log -1 --pretty=%B | grep -o "#[0-9]*" | tr -d '#')
  trigger_auto_sync "$issue_number"
fi
```

### Test-Based Completion
```bash
# CI success indicates deliverable completion
if [[ "$CI_STATUS" == "success" && "$BRANCH" =~ ^feature/ ]]; then
  create_pr_with_automerge
fi
```

## Auto-Sync Triggers

### Post-Commit Hook
```bash
#!/bin/bash
# .claude/scripts/hooks/post-commit

# 1. Detect deliverable completion
# 2. Calculate completion percentage
# 3. Update Supermemory with progress
# 4. Create/update PR if ready
# 5. Add auto-merge label if 100% complete
```

### Pre-Push Hook
```bash
#!/bin/bash
# .claude/scripts/hooks/pre-push

# 1. Sync progress to GitHub before push
# 2. Update issue comments with status
# 3. Ensure Supermemory is current
```

## GitHub Integration

### Auto-PR Creation
- Feature branch ready → Create PR automatically
- Add auto-merge label if deliverables complete
- Link to GitHub issues automatically
- Update issue with progress comments

### Auto-Merge Criteria
- CI/CD passes (lint, test, build)
- All deliverables detected as complete
- No merge conflicts
- Branch protection rules satisfied

## Error Handling

### Failed Auto-Sync
- Log to `.claude/logs/auto-sync.log`
- Notify via GitHub issue comment
- Fall back to manual sync command
- Never leave system in inconsistent state

### Rollback Strategy
- Monitor post-merge for issues
- Auto-revert if critical metrics fail
- Emergency disable via `.claude/auto-sync-disabled`
- Human oversight for production releases

## Configuration

### Minimal Setup Required
```json
// .claude/config.json
{
  "deliverables": {
    "pattern": "src/**/*.{vue,astro,js,ts}",
    "required": ["tests", "docs"]
  },
  "auto_merge": {
    "require_ci": true,
    "require_reviews": 0,
    "target_branch": "main"
  }
}
```

Keep configuration minimal - favor convention over configuration.