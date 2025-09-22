# /pm:close - Complete and Archive Epic

**Usage**: `/pm:close epic-name [--archive]`

## Purpose

Finalize epic completion, ensure all deliverables are met, sync final status, and optionally archive epic materials.

## What It Does

### 1. Completion Validation
- Verify 100% deliverable completion
- Run final quality gates
- Ensure PR is merged to main
- Validate GitHub issue closure

### 2. Final Sync Operations
```bash
# Final GitHub sync
- Update issue with completion status
- Close GitHub issue
- Update milestone progress
- Archive project board cards
- Tag completion in repository
```

### 3. Knowledge Preservation
```bash
# Supermemory archival
- Store epic decisions and patterns
- Document architecture choices
- Save performance insights
- Archive team learnings
```

### 4. Branch Cleanup
```bash
# Git cleanup operations
git checkout main
git pull origin main
git branch -d feature/epic-name
git push origin --delete feature/epic-name
```

## Completion Checklist

### Pre-Close Validation
```bash
# Epic completion requirements
✅ All required deliverables exist and valid
✅ Quality gates passed (lint, test, build)
✅ PR merged to main branch
✅ GitHub issue resolved
✅ No blocking merge conflicts
✅ Documentation complete (if required)
```

### Quality Verification
```bash
# Final quality checks
npm run lint          # No linting errors
npm run typecheck     # No TypeScript errors
npm test             # All tests passing
npm run build        # Production build successful
npm run test:e2e     # E2E tests passing
```

### GitHub Status Verification
```bash
# GitHub integration checks
✅ Issue #123 closed
✅ PR #456 merged to main
✅ Milestone updated
✅ Project board cards archived
✅ Branch deleted remotely
```

## Knowledge Archival

### Supermemory Documentation
```bash
# Store epic completion knowledge
memory_content="
Epic Completed: $epic_name

Architecture Decisions:
- JWT authentication with refresh tokens
- Middleware-based route protection
- Component-based login forms

Performance Insights:
- Login page LCP: 1.2s (target: <2.5s)
- Auth API response: 180ms average
- Bundle size impact: +12KB gzipped

Patterns Established:
- Auth service follows singleton pattern
- Login components use Vue Composition API
- Test coverage: 94% (above 80% threshold)

Team Learnings:
- JWT secret rotation strategy needed
- Remember me checkbox UX positive
- Auth middleware simplifies route protection
"

mcp__api-supermemory-ai__addMemory "$memory_content"
```

### Decision Documentation
```markdown
# Epic: user-auth - Completion Summary

## Delivered Components
- LoginForm.vue: Reactive login form with validation
- AuthService.ts: JWT token management service
- auth.middleware.ts: Route protection middleware
- login.astro: Authentication landing page
- auth.test.js: Comprehensive test suite

## Architecture Decisions
1. **JWT Strategy**: Short-lived access tokens (15min) + long-lived refresh tokens (7days)
2. **State Management**: Pinia store for user authentication state
3. **Route Protection**: Middleware-based with automatic redirects
4. **Security**: CSRF protection, secure cookie settings, input validation

## Performance Results
- Login page Lighthouse score: 96/100
- First Contentful Paint: 1.1s
- Largest Contentful Paint: 1.2s
- Bundle size impact: +12KB gzipped

## Lessons Learned
- Component composition pattern worked well for auth forms
- Middleware approach simplified route protection implementation
- Test-driven development caught 3 security issues early
- JWT refresh strategy needs documentation for team
```

## Archive Operations

### Optional Archival (`--archive` flag)
```bash
# Archive epic materials
mkdir -p .claude/archive/epics/
mv .claude/epics/epic-name .claude/archive/epics/

# Create completion summary
cat > .claude/archive/epics/epic-name/completion-summary.md << EOF
# Epic Completion: $epic_name
- Completed: $(date)
- Duration: $duration days
- Commits: $commit_count
- Final PR: #$pr_number
- GitHub Issue: #$issue_number
EOF
```

### Git History Preservation
```bash
# Tag epic completion
git tag -a epic/user-auth-complete -m "Completed user authentication epic"
git push origin epic/user-auth-complete

# Preserve branch history in notes
git notes add -m "Epic: user-auth completed $(date)" HEAD
```

## Integration Points

### CI/CD Completion
- Verify production deployment successful
- Monitor post-merge metrics
- Ensure no regression in other features
- Validate performance budgets maintained

### Team Notification
```bash
# GitHub issue closing comment
final_comment="
🎉 **Epic Completed: User Authentication**

All deliverables have been successfully implemented and merged to main.

## 📊 Final Stats
- Duration: 5 days
- Commits: 12
- Files changed: 8
- Test coverage: 94%

## 🚀 Delivered Features
- ✅ Secure JWT authentication
- ✅ Login/logout functionality
- ✅ Route protection middleware
- ✅ Responsive login page
- ✅ Comprehensive test suite

## 📈 Performance
- Lighthouse score: 96/100
- Bundle size: +12KB gzipped
- Login API: 180ms average response

Thanks to all contributors! 🙏

_Epic auto-closed by CCPM system_
"

gh issue comment $issue_number --body "$final_comment"
gh issue close $issue_number
```

## Example Usage

```bash
# Standard epic completion
/pm:close user-auth

# Output:
# 🔍 Validating epic completion...
# ✅ All deliverables complete (6/6)
# ✅ Quality gates passed
# ✅ PR #456 merged to main
# 📝 Storing completion knowledge...
# 🧹 Cleaning up branches...
# 🎉 Epic 'user-auth' completed successfully!
#
# Summary:
# - Duration: 5 days
# - Commits: 12
# - GitHub issue #123 closed
# - Knowledge stored in Supermemory
# - Branch feature/user-auth deleted

# Complete with archival
/pm:close user-auth --archive

# Force close (skip validation)
/pm:close user-auth --force
```

## Error Recovery

### Incomplete Epic Handling
```bash
# If deliverables not 100% complete
❌ Cannot close epic: Missing deliverables
   - src/pages/login.astro (required)

   Complete missing deliverables or use --force flag
   Use /pm:status user-auth for details
```

### Sync Failure Recovery
```bash
# If GitHub sync fails during close
⚠️ Epic completed locally, GitHub sync failed
   - Local branches cleaned up
   - Knowledge stored in Supermemory
   - Manual GitHub cleanup needed

   Run /pm:sync user-auth --force to retry
```

**Clean epic completion with knowledge preservation. Ensures nothing is lost and future epics benefit from accumulated wisdom.**