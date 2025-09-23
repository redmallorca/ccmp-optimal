# /pm:inbox - External Issues Inbox Management

**Purpose**: Review, adopt, or ignore external GitHub issues and pull requests detected by the sync system.

## Usage

```bash
/pm:inbox [command] [options]
```

## Commands

### List Pending Issues (Default)
```bash
/pm:inbox
/pm:inbox list
```

Shows all external issues with `pending` status waiting for review.

### Show Issue Details
```bash
/pm:inbox show <issue-number>
```

Display comprehensive information about a specific external issue.

### Adopt External Issue
```bash
/pm:inbox adopt <issue-number>
```

Mark an external issue as adopted for manual integration into your development workflow.

### Ignore External Issue
```bash
/pm:inbox ignore <issue-number>
```

Mark an external issue as ignored/not relevant to current development priorities.

### Show Statistics
```bash
/pm:inbox stats
```

Display inbox statistics including total, pending, adopted, and ignored issues.

## Implementation

Executes: `.claude/scripts/inbox-manager.sh [command] [options]`

## Workflow

### 1. Detection Phase
```bash
/pm:sync  # Detect external issues via GitHub API polling
```

### 2. Review Phase
```bash
/pm:inbox  # List pending external issues
```

**Example Output**:
```
=== PENDING EXTERNAL ISSUES ===

#42 - Issue
  📝 Add dark mode toggle
  👤 By: external_user
  🏷️  Repo: myorg/myproject
  📅 Created: 2025-09-23T14:30:00Z
  🔗 https://github.com/myorg/myproject/issues/42

#43 - Pull Request
  📝 Fix typo in documentation
  👤 By: contributor
  🏷️  Repo: myorg/myproject
  📅 Created: 2025-09-23T15:15:00Z
  🔗 https://github.com/myorg/myproject/pull/43
```

### 3. Decision Phase
```bash
/pm:inbox show 42      # Review details
/pm:inbox adopt 42     # Adopt for implementation
# OR
/pm:inbox ignore 43    # Ignore as not relevant
```

### 4. Integration Phase
After adopting an external issue:

1. **Manual Epic Creation**: Create a new epic or add to existing epic
2. **GitHub Issue Link**: Include external issue URL in epic description
3. **Deliverable Planning**: Plan implementation in epic deliverables
4. **Development**: Implement using standard CCPM workflow

## Issue Status Flow

```
[DETECTED] → [PENDING] → [ADOPTED] or [IGNORED]
     ↑           ↑           ↑            ↑
  github-sync  /pm:inbox  /pm:inbox   /pm:inbox
                 list      adopt       ignore
```

## External Issue Classification

Issues are considered "external" based on GitHub `author_association`:

**External** (detected):
- `NONE` - No association with repository
- `FIRST_TIME_CONTRIBUTOR` - First contribution
- `CONTRIBUTOR` - Previous contributor, not team member

**Internal** (ignored):
- `OWNER` - Repository owner
- `MEMBER` - Organization member
- `COLLABORATOR` - Repository collaborator

## Data Storage

### External Issues Database
**File**: `.claude/inbox/external-issues.jsonl`

**Format**:
```json
{
  "repository": "myorg/myproject",
  "number": 42,
  "title": "Add dark mode toggle",
  "url": "https://github.com/myorg/myproject/issues/42",
  "author": "external_user",
  "created_at": "2025-09-23T14:30:00Z",
  "updated_at": "2025-09-23T14:30:00Z",
  "is_pull_request": false,
  "status": "pending",
  "detected_at": "2025-09-23T20:00:00Z"
}
```

### Status Values
- `pending` - Awaiting review and decision
- `adopted` - Marked for manual integration
- `ignored` - Marked as not relevant

## Interactive Features

### Adoption Confirmation
```bash
$ /pm:inbox adopt 42

=== Issue #42 ===

📝 Title: Add dark mode toggle
👤 Author: external_user
🏷️  Repository: myorg/myproject
📅 Created: 2025-09-23T14:30:00Z
🔄 Updated: 2025-09-23T14:30:00Z
🎯 Status: pending
🔗 URL: https://github.com/myorg/myproject/issues/42

This will mark issue #42 as 'adopted' for manual integration.
You should manually create a corresponding GitHub issue or epic.

Continue? (y/N): y
[SUCCESS] Issue #42 marked as adopted

[WARNING] Next steps:
1. Create GitHub issue/epic for this external request
2. Link external issue URL in your epic description
3. Plan implementation in your epic deliverables
```

### Statistics Dashboard
```bash
$ /pm:inbox stats

=== INBOX STATISTICS ===
📊 Total external issues: 5
⏳ Pending review: 2
✅ Adopted: 2
❌ Ignored: 1
```

## Integration with CCPM

### Manual Integration Required
- **No Automatic Actions**: System never automatically creates epics or issues
- **User-Driven Workflow**: All decisions require explicit user action
- **Manual Epic Creation**: Use standard `/pm:new` after adoption
- **External Reference**: Include original issue URL in epic description

### Example Integration Workflow
```bash
# 1. Detect external issues
/pm:sync

# 2. Review external request
/pm:inbox show 42

# 3. Adopt relevant issue
/pm:inbox adopt 42

# 4. Create epic for implementation
/pm:new external-dark-mode

# 5. Reference external issue in epic description
# "Implement dark mode toggle as requested in https://github.com/myorg/myproject/issues/42"

# 6. Plan deliverables for implementation
# 7. Develop using standard CCPM workflow
```

## Troubleshooting

**No external issues showing**:
- Run `/pm:sync` first to detect external issues
- Check if any issues were created by non-team members
- Verify GitHub token permissions

**Issues not updating**:
- Check `.claude/inbox/external-issues.jsonl` file permissions
- Verify JSON file is not corrupted
- Re-run detection with `/pm:sync`

**Command not found**:
- Ensure `.claude/scripts/inbox-manager.sh` exists and is executable
- Check CCPM installation

## Files Used

- `.claude/inbox/external-issues.jsonl` - External issues database
- `.claude/scripts/inbox-manager.sh` - Inbox management script
- `.claude/logs/github-sync.log` - Detection and operation logs

**User-driven external issue management. Review stakeholder requests and adopt relevant ones for implementation.**