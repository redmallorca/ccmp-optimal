# Task Completion Workflow

## Done Definition
A task is considered complete when ALL of the following are met:

1. **Tests pass** (CI green)
2. **PR created** with auto-merge label  
3. **CI/CD completes** successfully
4. **Auto-merge** to main branch
5. **Supermemory synced** with decisions
6. **GitHub issue** auto-closed

## Automatic Completion Detection

### File-Based Detection
- Check deliverable files exist and are non-empty
- Calculate completion percentage based on required deliverables
- Update GitHub issue with progress automatically

### Commit-Based Detection  
- Parse commit messages for completion keywords
- Auto-update progress on each commit
- Trigger GitHub sync through post-commit hooks

### Completion Triggers
- **100% deliverables complete** → Create PR with auto-merge label
- **CI passes** → Enable auto-merge
- **PR merged** → Close epic and GitHub issue

## Quality Gates (Progressive)

### Level 1: Fast Quality (< 2 minutes)
```bash
npm run lint          # Code linting
npm run typecheck     # TypeScript validation
npm run format:check  # Code formatting (non-blocking)
```

### Level 2: Core Testing (< 5 minutes)  
```bash
npm test                    # Unit tests
npm run test:integration    # Integration tests (non-blocking)
```

### Level 3: Build Validation (< 8 minutes)
```bash
npm run build              # Project build
npm run bundle:analyze     # Bundle analysis (non-blocking)
npm run perf:budget        # Performance budget (non-blocking)
```

### Level 4: Extended Validation (PR only, < 15 minutes)
```bash
npm run test:e2e           # E2E tests
npm run test:a11y          # Accessibility tests (non-blocking)
npm audit --audit-level=high  # Security scan (non-blocking)
```

## Manual Task Completion Commands

### When Automatic Detection Fails
```bash
# Force completion status update
/pm:sync epic-name --force

# Manually close completed epic
/pm:close epic-name

# Check completion status
/pm:status epic-name
```

### Emergency Procedures
```bash
# Disable auto-merge if needed
touch .github/auto-merge-disabled
git commit -m "emergency: disable auto-merge"

# Re-enable auto-merge
rm .github/auto-merge-disabled
git commit -m "fix: re-enable auto-merge"
```

## Memory and Context Preservation

### Automatic Memory Sync
- **Supermemory**: Project decisions and architectural choices
- **Serena**: Code patterns and component relationships  
- **OpenMemory**: Session context and temporary decisions

### Manual Memory Updates
```bash
# Document important decisions during development
# This happens automatically via post-commit hooks
# No manual intervention required
```

## Success Metrics
- **Zero manual commands** after `/pm:new`
- **Progressive quality gates** provide fast feedback
- **Auto-merge** when all quality gates pass
- **Complete audit trail** in GitHub issues and Supermemory

## Key Principle
**The system tracks completion automatically.** Focus on coding and committing - the CCPM system handles all project management, quality validation, and completion tracking through the git workflow.