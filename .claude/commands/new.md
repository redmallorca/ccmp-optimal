# new - Create New Epic

**Usage**: `new epic-name "Epic description"`
**Script**: `.claude/scripts/new.sh epic-name "description"`

## ORDERS FOR new.sh EXECUTION

### STEP 1: Validate Input
```bash
# Validate epic name format: lowercase, numbers, hyphens only
[[ "$epic_name" =~ ^[a-z0-9-]+$ ]] || exit 1
# Check epic doesn't already exist
[[ ! -d ".claude/epics/$epic_name" ]] || exit 1
```

### STEP 2: Check GitHub Authentication
```bash
# Verify GitHub CLI is authenticated
gh auth status || exit 1
# Get repository info from git remote
repository=$(git remote get-url origin | sed 's|.*github.com[/:]||; s|\.git$||')
```

### STEP 3: Create Epic Directory Structure
```bash
mkdir -p ".claude/epics/$epic_name"
cat > ".claude/epics/$epic_name/deliverables.json" << EOF
{
  "epic": "$epic_name",
  "description": "$description",
  "deliverables": [
    {
      "type": "implementation",
      "pattern": "src/components/EpicComponent.vue",
      "required": true,
      "description": "Main epic implementation"
    }
  ],
  "github_issue": null,
  "repository": "$repository",
  "auto_sync_enabled": true
}
EOF
```

### STEP 4: Create GitHub Issue
```bash
# Create issue and capture issue number
issue_number=$(gh issue create \
  --title "Epic: $epic_name" \
  --body "$description" \
  --label "epic" \
  --assignee "@me" \
  --repo "$repository" | grep -o '#[0-9]\+' | tr -d '#')
```

### STEP 5: Update deliverables.json with GitHub Issue
```bash
# Update github_issue field with real issue number
jq --arg issue "$issue_number" '.github_issue = ($issue | tonumber)' \
  ".claude/epics/$epic_name/deliverables.json" > temp.json
mv temp.json ".claude/epics/$epic_name/deliverables.json"
```

### STEP 6: Create Git Branch
```bash
# Switch to main and update
git checkout main
git pull origin main
# Create and switch to epic branch
git checkout -b "feature/epic-$epic_name"
```

## RULES TO FOLLOW

### Auto-Sync Rules (from .claude/rules/auto-sync.md)
- **File-based completion**: Check deliverable files exist and non-empty
- **Post-commit hook**: Automatically triggered on every commit
- **GitHub integration**: Issues updated automatically via post-commit hook

### Git Workflow Rules (from .claude/rules/git-workflow.md)
- **Branch naming**: `feature/epic-$epic_name`
- **Commit messages**: Include issue number for auto-linking
- **Auto-merge**: Triggered when deliverables 100% complete

## ERROR HANDLING
- Exit with code 1 on any validation failure
- Print clear error messages to stderr
- Never leave epic in partially created state

## SUCCESS OUTPUT
```
✅ Epic '$epic_name' created successfully!
📁 Directory: .claude/epics/$epic_name
🔗 GitHub Issue: #$issue_number
🌿 Branch: feature/epic-$epic_name

Next: Start implementing deliverables
```