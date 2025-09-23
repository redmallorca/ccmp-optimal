# /pm:new - Create New Epic

**Usage**: `/pm:new epic-name "Epic description"`

## Purpose

Initialize a new epic with automatic GitHub integration and deliverable tracking.

## What It Does

### 1. Epic Initialization
- Create epic directory structure
- Set up deliverable tracking configuration
- Initialize git branch for epic work
- Create GitHub issue/milestone

### 2. Automatic Setup
```bash
# Directory structure created
.claude/epics/epic-name/
├── deliverables.json    # Tracking configuration
├── progress.md         # Progress documentation
└── decisions.md        # Architecture decisions

# Git branch created
git checkout -b feature/epic-name
```

### 3. GitHub Integration
- Create GitHub issue with epic description
- Link to project milestone
- Set up auto-tracking labels
- Initialize progress tracking

## Configuration

### Deliverables Definition
```json
{
  "epic": "epic-name",
  "description": "Epic description",
  "deliverables": [
    {
      "type": "component",
      "pattern": "src/components/EpicComponent.vue",
      "required": true,
      "description": "Main epic component"
    },
    {
      "type": "page",
      "pattern": "src/pages/epic-page.astro",
      "required": true,
      "description": "Epic landing page"
    },
    {
      "type": "test",
      "pattern": "tests/epic.test.js",
      "required": true,
      "description": "Test coverage"
    },
    {
      "type": "documentation",
      "pattern": "docs/epic-guide.md",
      "required": false,
      "description": "User documentation"
    }
  ],
  "github_issue": null,
  "repository": "owner/repo-name",
  "auto_sync_enabled": true
}
```

### Integration Points
- **Supermemory**: Store epic decisions and patterns
- **GitHub API**: Issue and milestone management
- **Git hooks**: Auto-sync progress on commits
- **Serena**: Track deliverable files

## Example Usage

```bash
# Create new user authentication epic
/pm:new user-auth "Implement user authentication system with JWT tokens"

# Creates:
# - .claude/epics/user-auth/ directory
# - feature/user-auth git branch
# - GitHub issue #123 for tracking
# - Deliverable tracking for auth components
```

## Auto-Detection Rules

Once epic is created, progress is tracked automatically:

### File-Based Detection
- Check deliverable files exist and are non-empty
- Calculate completion percentage
- Update GitHub issue with progress

### Commit-Based Detection
- Parse commit messages for completion keywords
- Auto-update progress on each commit
- Trigger GitHub sync through post-commit hooks

### Completion Triggers
- 100% deliverables complete → Create PR with auto-merge label
- CI passes → Enable auto-merge
- PR merged → Close epic and GitHub issue

**Zero manual commands after `/pm:new`. Everything else happens automatically through git workflow.**