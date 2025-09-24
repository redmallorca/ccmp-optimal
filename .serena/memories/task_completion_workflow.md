# CCPM Optimal - Task Completion Workflow

## Overview
CCPM Optimal uses a **zero-command automation** approach where tasks are completed through normal git workflow, with automation handling all project management tasks.

## Primary Workflow (Standard Development)

### 1. Epic Creation (One-time per epic)
```bash
# Only manual command needed
/new epic-name "Epic description with clear requirements"

# This automatically:
# - Creates .claude/epics/epic-name/ directory structure
# - Generates deliverables.json with pattern matching
# - Creates GitHub issue and links it to epic
# - Sets up feature/epic-name branch
# - Configures auto-sync for the epic
```

### 2. Development Cycle (Automated)
```bash
# Normal development workflow
git add .
git commit -m "feat(auth): implement login component"
git push

# Post-commit hook automatically:
# - Analyzes commit for completion keywords
# - Calculates epic completion percentage
# - Updates GitHub issue with progress
# - Creates PR when 100% complete
# - Adds auto-merge label to PR
```

### 3. Completion Detection (Automatic)
Epic completion is detected through:
- **File-based patterns**: Matching deliverables.json patterns
- **Commit message keywords**: "complete", "finish", "done", "implement", "fix", "feat"
- **Quality gate validation**: All tests pass, lint clean, build successful
- **Branch completion**: All deliverables present and valid

## Quality Gates (Automated Validation)

### 4. Pre-Commit Validation
```bash
# Triggered by git commit (automatic)
# - Zen validation for important commits (3+ files or critical files)
# - Merge conflict detection
# - Large file warnings
# - Debug statement warnings (console.log, debugger)
# - TODO/FIXME detection in critical files
```

### 5. Post-Commit Processing
```bash
# Triggered after every commit (automatic)
# - Epic branch detection
# - Progress calculation based on deliverables
# - GitHub issue updates with completion percentage
# - Quality status reporting (lint, test, build)
# - Supermemory sync with decisions and progress
```

### 6. CI/CD Pipeline (GitHub Actions)
```bash
# Triggered by push (automatic)
# Progressive quality gates:
1. Lint check       (npm run lint)
2. TypeScript check  (npm run typecheck)  
3. Unit tests        (npm run test)
4. Build validation  (npm run build)
5. E2E tests         (npm run test:e2e)
6. Auto-merge        (if all pass + auto-merge label)
```

## Completion Criteria

### 7. Epic Completion Requirements
An epic is considered complete when:
- **All deliverables match**: Files exist and pass validation
- **Quality gates pass**: Lint, typecheck, tests, build all successful
- **Content validation**: Files have meaningful content (not empty stubs)
- **Test coverage**: Required test patterns exist and pass

### 8. Deliverable Validation Rules
```json
{
  "deliverables": [
    {
      "pattern": "src/components/*.{vue,astro,tsx,jsx}",
      "required": true,
      "description": "Component implementation"
    },
    {
      "pattern": "tests/**/*.test.{js,ts}",
      "required": true, 
      "description": "Test coverage"
    }
  ]
}
```

File validation includes:
- **Existence**: File must exist and be readable
- **Size**: Must be non-empty (>0 bytes)
- **Content**: Must have meaningful content for file type
- **Structure**: Components must have export/template, tests must have test cases

## Manual Override Commands

### 9. Troubleshooting Commands
```bash
# Check epic status
/status epic-name

# Force GitHub sync
/sync epic-name --force  

# Manual epic closure
/close epic-name

# View system status
/overview
```

### 10. Emergency Procedures
```bash
# Disable auto-merge
touch .github/auto-merge-disabled
git commit -m "emergency: disable auto-merge"

# Skip git hooks (bypass automation)
git commit --no-verify -m "emergency commit"

# Check automation logs
tail -f .claude/logs/auto-sync.log
```

## Memory Integration Workflow

### 11. Automatic Memory Sync
- **Epic creation**: Search Supermemory for related patterns
- **Architecture decisions**: Auto-sync to memory when detected in commits
- **PR merges**: Store architectural decisions and patterns  
- **Epic completion**: Archive knowledge and patterns
- **Error resolution**: Document solutions for future reference

### 12. Session Context
- **OpenMemory**: Temporary session notes and decisions
- **Context loading**: Previous implementation patterns
- **Decision continuity**: Reference past architectural choices
- **Pattern reuse**: Identify similar components and solutions

## Done Definition

### 13. Task Considered Complete When:
1. **All deliverable patterns match** existing files
2. **Files pass content validation** (not empty, have structure)
3. **Quality gates pass**: lint, typecheck, test, build
4. **GitHub issue auto-closed** with completion comment
5. **PR created and merged** (or ready for merge)
6. **Memory updated** with decisions and patterns
7. **Epic archived** to .claude/archive/ directory

### 14. Automation Success Indicators
- ✅ GitHub issue shows "🎉 Epic completed"
- ✅ PR exists with auto-merge label
- ✅ CI pipeline shows all green checkmarks
- ✅ Epic directory moved to .claude/archive/
- ✅ Branch cleanup completed (if configured)

## Key Principles
- **Zero manual PM commands** after epic creation
- **Normal git workflow** triggers all automation
- **Progressive quality gates** don't block development
- **Automatic context preservation** through memory systems
- **Fail-safe fallbacks** for when automation fails