# Quality Gates Rules

Progressive quality validation that enhances development without blocking workflow.

## Core Philosophy

**Quality gates accelerate development by catching issues early.** Fast feedback, reliable results, never skip for convenience.

## Progressive Gate Levels

### Gate 1: Instant Feedback (< 30 seconds)
```bash
# Pre-commit hooks (local)
- Code formatting (Prettier)
- Import sorting
- Basic syntax validation
- Commit message format
```

### Gate 2: Fast Quality (< 2 minutes)
```bash
# CI first stage
npm run lint          # ESLint rules
npm run typecheck     # TypeScript validation
npm run format:check  # Formatting verification
```

### Gate 3: Core Testing (< 5 minutes)
```bash
# CI core stage
npm test             # Unit tests (Jest/Vitest)
npm run test:unit    # Component tests
npm run test:integration  # API/service tests
```

### Gate 4: Build Validation (< 8 minutes)
```bash
# CI build stage
npm run build        # Production build
npm run bundle:analyze   # Bundle size check
npm run perf:budget     # Performance budgets
```

### Gate 5: Extended Validation (< 15 minutes)
```bash
# CI extended stage (PR only)
npm run test:e2e     # End-to-end tests
npm run test:a11y    # Accessibility tests
npm run test:visual  # Visual regression
npm run security:scan    # Security vulnerability scan
```

## Quality Standards

### Code Quality
```javascript
// ESLint config essentials
module.exports = {
  extends: [
    '@typescript-eslint/recommended',
    'plugin:vue/vue3-recommended'
  ],
  rules: {
    // Error for common issues
    'no-console': 'error',
    'no-debugger': 'error',
    '@typescript-eslint/no-unused-vars': 'error',

    // Warn for code quality
    'complexity': ['warn', 10],
    'max-lines': ['warn', 300],
    'max-depth': ['warn', 4]
  }
}
```

### Test Coverage
```bash
# Coverage thresholds
jest.config.js:
coverageThreshold: {
  global: {
    branches: 80,
    functions: 80,
    lines: 80,
    statements: 80
  }
}
```

### Performance Budgets
```bash
# Bundle size limits
webpack-bundle-analyzer:
  maxAssetSize: 500000,    # 500KB
  maxEntrypointSize: 1000000,  # 1MB

# Core Web Vitals thresholds
lighthouse-ci:
  LCP: < 2.5s
  FID: < 100ms
  CLS: < 0.1
```

## Gate Implementation

### Pre-Commit (Local)
```bash
#!/bin/bash
# .claude/scripts/hooks/pre-commit

# Fast local validation
npm run format
npm run lint:fix
npm run typecheck

# Only commit if all pass
if [ $? -ne 0 ]; then
  echo "❌ Pre-commit checks failed"
  echo "Fix issues before committing"
  exit 1
fi
```

### CI Gates (GitHub Actions)
```yaml
# .github/workflows/quality-gates.yml
name: Quality Gates

on: [push, pull_request]

jobs:
  gate-1-format:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
      - run: npm ci
      - run: npm run lint
      - run: npm run typecheck

  gate-2-test:
    needs: gate-1-format
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
      - run: npm ci
      - run: npm test
      - run: npm run test:integration

  gate-3-build:
    needs: gate-2-test
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
      - run: npm ci
      - run: npm run build
      - run: npm run perf:check

  gate-4-extended:
    needs: gate-3-build
    if: github.event_name == 'pull_request'
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
      - run: npm ci
      - run: npm run test:e2e
      - run: npm run security:scan
```

## Auto-Merge Gates

### Required for Auto-Merge
- All quality gates pass
- No security vulnerabilities
- Performance budgets met
- Test coverage maintained
- No manual review labels

### Emergency Override
```bash
# For critical hotfixes only
git commit -m "hotfix: critical security fix

SKIP_QUALITY_GATES=true
Fixes: CVE-2024-XXXX
Approved-by: @tech-lead"
```

## Quality Metrics

### Tracking
- Gate failure rates by type
- Average gate execution time
- Developer productivity impact
- Code quality trends

### Optimization
- Parallelize independent gates
- Cache dependencies between runs
- Optimize test execution order
- Monitor and improve slow gates

## Failure Handling

### Gate Failure Response
```bash
# Clear error messages
❌ Quality Gate Failed: ESLint

   Errors found:
   - src/auth.ts:42 - 'user' is assigned but never used
   - src/api.ts:18 - Missing return type annotation

   Fix with: npm run lint:fix
   Then: git add . && git commit --amend
```

### Recovery Process
1. **Fix locally** - Never bypass quality gates
2. **Test fix** - Verify locally before pushing
3. **Incremental commits** - Small fixes, frequent validation
4. **Seek help** - Team support for persistent issues

## Gate Configuration

### Project-Specific Rules
```json
// .claude/quality-config.json
{
  "gates": {
    "lint": { "timeout": 120, "required": true },
    "test": { "timeout": 300, "required": true },
    "build": { "timeout": 600, "required": true },
    "e2e": { "timeout": 900, "required": false }
  },
  "auto_merge": {
    "require_all_gates": true,
    "allow_override": false
  }
}
```

**Quality gates exist to help developers ship confidently. Make them fast, reliable, and helpful.**