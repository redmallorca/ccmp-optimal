# CI Integration Rules

GitHub Actions native integration with simplified testing and auto-merge.

## Core Philosophy

**CI enhances workflow, never blocks it.** Simple, fast, reliable quality gates that developers trust.

## Standard CI Workflow

```yaml
# .github/workflows/ci.yml
name: CI
on: [push, pull_request]

jobs:
  quality-gates:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'

      # Fast feedback first
      - name: Install dependencies
        run: npm ci

      - name: Lint (fast feedback)
        run: npm run lint

      - name: TypeScript check
        run: npm run typecheck

      - name: Unit tests
        run: npm test

      - name: Build
        run: npm run build

      # Optional: E2E tests (if fast enough)
      - name: E2E tests
        run: npm run test:e2e
        if: github.event_name == 'pull_request'

  auto-merge:
    needs: quality-gates
    if: |
      github.event_name == 'pull_request' &&
      contains(github.event.pull_request.labels.*.name, 'auto-merge') &&
      github.actor != 'dependabot[bot]'
    runs-on: ubuntu-latest
    steps:
      - uses: pascalgn/auto-merge-action@v0.15.6
        with:
          token: ${{ secrets.GITHUB_TOKEN }}
          merge_method: squash
```

## Quality Gates (Progressive)

### Level 1: Fast Feedback (< 2 minutes)
- ESLint/Prettier formatting
- TypeScript type checking
- Basic import/export validation

### Level 2: Core Quality (< 5 minutes)
- Unit tests (Jest/Vitest)
- Component tests
- Basic integration tests

### Level 3: Full Validation (< 10 minutes)
- Build verification
- Bundle size checks
- Performance budgets

### Level 4: Extended (Optional, < 15 minutes)
- E2E tests (only on PRs)
- Visual regression tests
- Accessibility audits

## Auto-Merge Rules

### Required Conditions
- All quality gates pass
- No merge conflicts
- PR has `auto-merge` label
- Branch protection rules satisfied

### Safety Measures
- Squash commits on merge
- Delete feature branch after merge
- Monitor post-merge metrics
- Auto-revert if critical issues detected

## Branch Protection

### Main Branch
- Require PR before merge
- Require status checks to pass
- Require up-to-date branches
- Restrict pushes to admins only

### Stable Branch
- Require PR from main only
- Require manual review for releases
- Additional security scanning
- Production deployment gates

## Testing Strategy

### Replace Complex Test-Runner Agent
Instead of complex abstractions, use standard tools:

```bash
# Simple, predictable test commands
npm run lint          # ESLint + Prettier
npm run typecheck     # TypeScript
npm test             # Jest/Vitest unit tests
npm run test:e2e     # Playwright E2E tests
npm run build        # Production build
```

### Test Configuration
- Keep test config simple
- Use standard test frameworks
- No custom DSLs or abstractions
- Fast, reliable, debuggable tests

## Monitoring & Alerts

### Post-Merge Monitoring
- Performance metrics
- Error rates
- User experience metrics
- Auto-revert triggers

### Alert Channels
- GitHub issue comments
- Slack/Discord notifications
- Email for critical issues
- Dashboard for metrics

## Rollback Strategy

### Automatic Rollback
- Critical error rate threshold exceeded
- Performance degradation detected
- Security vulnerability introduced
- User experience metrics fail

### Manual Override
- Emergency disable: `.github/auto-merge-disabled`
- Force manual review: Add `manual-review` label
- Skip CI: Only for hotfixes (requires admin)

Keep CI simple, fast, and trustworthy. Developers should never fear or circumvent quality gates.