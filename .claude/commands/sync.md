# sync - Force GitHub Synchronization

**Usage**: `sync [epic-name]`
**Script**: `.claude/scripts/sync.sh [epic-name]`

## ORDERS FOR sync.sh EXECUTION

### STEP 1: Parse Arguments
```bash
epic_name="${1:-}"
force_sync=false
validate_only=false

while [[ $# -gt 0 ]]; do
  case $1 in
    --all) sync_all=true; shift ;;
    --force) force_sync=true; shift ;;
    --validate) validate_only=true; shift ;;
    --help|-h) show_help; exit 0 ;;
    *) epic_name="$1"; shift ;;
  esac
done
```

### STEP 2: Validate Environment
```bash
# Check GitHub CLI authentication
gh auth status || { echo "Error: GitHub CLI not authenticated"; exit 1; }

# Get repository info
repository=$(git remote get-url origin | sed 's|.*github.com[/:]||; s|\.git$||')

# Check if in git repository
git rev-parse --git-dir >/dev/null 2>&1 || { echo "Error: Not in git repository"; exit 1; }
```

### STEP 3: Calculate Epic Progress
```bash
calculate_progress() {
  local epic_dir="$1"
  local deliverables_file="$epic_dir/deliverables.json"

  total=$(jq -r '.deliverables | length' "$deliverables_file")
  completed=0

  while IFS= read -r pattern; do
    if [[ -f "$pattern" && -s "$pattern" ]]; then
      ((completed++))
    fi
  done < <(jq -r '.deliverables[].pattern' "$deliverables_file")

  percentage=$((completed * 100 / total))
  echo "$completed $total $percentage"
}
```

### STEP 4: Generate Progress Comment
```bash
generate_comment() {
  local epic_name="$1"
  local completed="$2"
  local total="$3"
  local percentage="$4"

  cat << EOF
## Epic Progress Update

**Progress**: ${percentage}% complete (${completed}/${total} deliverables)
**Last Updated**: $(date)
**Branch**: feature/epic-${epic_name}

### ✅ Completed Deliverables
EOF

  # List completed deliverables
  while IFS= read -r pattern; do
    if [[ -f "$pattern" && -s "$pattern" ]]; then
      echo "- $pattern"
    fi
  done < <(jq -r '.deliverables[].pattern' "$epic_dir/deliverables.json")

  cat << EOF

### 📋 Remaining Deliverables
EOF

  # List pending deliverables
  while IFS= read -r deliverable; do
    pattern=$(echo "$deliverable" | jq -r '.pattern')
    required=$(echo "$deliverable" | jq -r '.required // false')
    if [[ ! -f "$pattern" || ! -s "$pattern" ]]; then
      req_text=""
      [[ "$required" == "true" ]] && req_text=" (required)" || req_text=" (optional)"
      echo "- $pattern$req_text"
    fi
  done < <(jq -c '.deliverables[]' "$epic_dir/deliverables.json")

  echo ""
  echo "_Auto-updated by CCPM sync system_"
}
```

### STEP 5: Update GitHub Issue
```bash
sync_epic() {
  local epic_name="$1"
  local epic_dir=".claude/epics/$epic_name"
  local deliverables_file="$epic_dir/deliverables.json"

  # Get GitHub issue number
  issue_number=$(jq -r '.github_issue // "null"' "$deliverables_file")
  if [[ "$issue_number" == "null" || "$issue_number" == "" ]]; then
    echo "⚠️  Epic $epic_name has no GitHub issue to sync"
    return 1
  fi

  # Calculate progress
  read completed total percentage < <(calculate_progress "$epic_dir")

  # Generate and post comment
  comment=$(generate_comment "$epic_name" "$completed" "$total" "$percentage")
  gh issue comment "$issue_number" --body "$comment" --repo "$repository"

  echo "✅ Synced epic $epic_name to GitHub issue #$issue_number (${percentage}% complete)"
}
```

### STEP 6: Create PR if Ready
```bash
create_pr_if_ready() {
  local epic_name="$1"
  local percentage="$2"

  if [[ "$percentage" -eq 100 ]]; then
    branch_name="feature/epic-$epic_name"

    # Check if PR already exists
    existing_pr=$(gh pr list --head "$branch_name" --repo "$repository" --json number --jq '.[0].number // ""')

    if [[ -z "$existing_pr" ]]; then
      # Create PR
      pr_number=$(gh pr create \
        --title "feat($epic_name): Complete epic implementation" \
        --body "Epic $epic_name completed - all deliverables ready" \
        --label "auto-merge" \
        --base main \
        --head "$branch_name" \
        --repo "$repository" | grep -o '#[0-9]\+' | tr -d '#')

      echo "🚀 Created PR #$pr_number for completed epic $epic_name"
    else
      echo "📋 PR #$existing_pr already exists for epic $epic_name"
    fi
  fi
}
```

### STEP 7: Execute Sync
```bash
if [[ "$sync_all" == "true" ]]; then
  # Sync all epics
  for epic_dir in .claude/epics/*; do
    if [[ -d "$epic_dir" ]]; then
      epic_name=$(basename "$epic_dir")
      sync_epic "$epic_name"
    fi
  done
elif [[ -n "$epic_name" ]]; then
  # Sync specific epic
  if [[ -d ".claude/epics/$epic_name" ]]; then
    sync_epic "$epic_name"
    read completed total percentage < <(calculate_progress ".claude/epics/$epic_name")
    create_pr_if_ready "$epic_name" "$percentage"
  else
    echo "Error: Epic '$epic_name' not found"
    exit 1
  fi
else
  echo "Error: Specify epic name or use --all"
  exit 1
fi
```

## RULES TO FOLLOW

### Auto-Sync Rules (from .claude/rules/auto-sync.md)
- **Manual override**: Manual sync doesn't interfere with auto-sync
- **Shared sync lock**: Prevent conflicts with automated syncing
- **Progress calculation**: Same logic as auto-sync for consistency

### Git Workflow Rules (from .claude/rules/git-workflow.md)
- **PR creation**: Auto-create PR when deliverables 100% complete
- **Auto-merge label**: Add label for automatic merging
- **Branch naming**: Consistent with `feature/epic-$epic_name`

## ARGUMENTS
- `epic-name`: Sync specific epic (optional)
- `--all`: Sync all active epics
- `--force`: Force sync even if no changes detected
- `--validate`: Validate sync configuration only

## ERROR HANDLING
- Check GitHub authentication before any API calls
- Validate epic exists before attempting sync
- Handle API rate limits gracefully
- Never leave GitHub state inconsistent

## SUCCESS OUTPUT
```
✅ Synced epic user-auth to GitHub issue #123 (67% complete)
🚀 Created PR #456 for completed epic user-auth
```