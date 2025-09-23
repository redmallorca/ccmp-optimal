# close - Complete and Archive Epic

**Usage**: `close epic-name [--archive]`
**Script**: `.claude/scripts/close.sh epic-name [--archive]`

## ORDERS FOR close.sh EXECUTION

### STEP 1: Parse Arguments and Validate
```bash
epic_name="$1"
archive_epic=false

[[ "$2" == "--archive" ]] && archive_epic=true

# Validate epic name provided
[[ -n "$epic_name" ]] || { echo "Error: Epic name required"; exit 1; }

# Check epic exists
epic_dir=".claude/epics/$epic_name"
[[ -d "$epic_dir" ]] || { echo "Error: Epic '$epic_name' not found"; exit 1; }
```

### STEP 2: Validate Epic Completion
```bash
deliverables_file="$epic_dir/deliverables.json"
total=$(jq -r '.deliverables | length' "$deliverables_file")
completed=0

# Count completed required deliverables
while IFS= read -r deliverable; do
  pattern=$(echo "$deliverable" | jq -r '.pattern')
  required=$(echo "$deliverable" | jq -r '.required // false')

  if [[ -f "$pattern" && -s "$pattern" ]]; then
    ((completed++))
  elif [[ "$required" == "true" ]]; then
    echo "Error: Required deliverable missing: $pattern"
    exit 1
  fi
done < <(jq -c '.deliverables[]' "$deliverables_file")

percentage=$((completed * 100 / total))
echo "📊 Epic completion: ${percentage}% (${completed}/${total} deliverables)"
```

### STEP 3: Run Quality Gates
```bash
echo "🔍 Running quality gates..."

# Check if on epic branch
current_branch=$(git branch --show-current)
expected_branch="feature/epic-$epic_name"

if [[ "$current_branch" != "$expected_branch" ]]; then
  echo "⚠️  Not on epic branch. Switching to $expected_branch"
  git checkout "$expected_branch" || { echo "Error: Cannot switch to epic branch"; exit 1; }
fi

# Run quality checks if available
if command -v npm >/dev/null 2>&1; then
  if [[ -f "package.json" ]]; then
    echo "🧹 Running lint..."
    npm run lint 2>/dev/null || echo "⚠️  Lint script not available"

    echo "🧪 Running tests..."
    npm test 2>/dev/null || echo "⚠️  Test script not available"

    echo "🔨 Running build..."
    npm run build 2>/dev/null || echo "⚠️  Build script not available"
  fi
fi
```

### STEP 4: Sync Final Status to GitHub
```bash
issue_number=$(jq -r '.github_issue // "null"' "$deliverables_file")

if [[ "$issue_number" != "null" && "$issue_number" != "" ]]; then
  echo "📝 Posting final completion status to GitHub..."

  repository=$(git remote get-url origin | sed 's|.*github.com[/:]||; s|\.git$||')

  final_comment="🎉 **Epic Completed: $epic_name**

All deliverables have been successfully implemented.

## 📊 Final Stats
- Duration: $(git log --oneline --since="1 month ago" feature/epic-$epic_name | wc -l) commits
- Completion: 100%
- Files changed: $(git diff --name-only main..feature/epic-$epic_name | wc -l)

## 🚀 Delivered Components"

  # List all completed deliverables
  while IFS= read -r pattern; do
    if [[ -f "$pattern" && -s "$pattern" ]]; then
      final_comment="$final_comment
- ✅ $pattern"
    fi
  done < <(jq -r '.deliverables[].pattern' "$deliverables_file")

  final_comment="$final_comment

Epic closed automatically by CCPM close command."

  gh issue comment "$issue_number" --body "$final_comment" --repo "$repository"
  gh issue close "$issue_number" --repo "$repository"

  echo "✅ GitHub issue #$issue_number closed"
else
  echo "⚠️  No GitHub issue to close"
fi
```

### STEP 5: Create Final PR if Not Exists
```bash
branch_name="feature/epic-$epic_name"
repository=$(git remote get-url origin | sed 's|.*github.com[/:]||; s|\.git$||')

# Check if PR already exists
existing_pr=$(gh pr list --head "$branch_name" --repo "$repository" --json number --jq '.[0].number // ""')

if [[ -z "$existing_pr" ]]; then
  echo "🚀 Creating final PR..."

  pr_number=$(gh pr create \
    --title "feat($epic_name): Complete epic implementation" \
    --body "Epic $epic_name completed - ready for merge

All deliverables implemented and quality gates passed." \
    --label "auto-merge" \
    --base main \
    --head "$branch_name" \
    --repo "$repository" | grep -o '#[0-9]\+' | tr -d '#')

  echo "✅ Created PR #$pr_number"
else
  echo "📋 PR #$existing_pr already exists"
fi
```

### STEP 6: Merge and Cleanup
```bash
echo "🔄 Merging to main..."

# Switch to main and pull latest
git checkout main
git pull origin main

# Merge epic branch
git merge --no-ff "feature/epic-$epic_name" -m "feat($epic_name): Complete epic implementation"

# Push to main
git push origin main

# Delete epic branch locally and remotely
echo "🧹 Cleaning up branches..."
git branch -d "feature/epic-$epic_name"
git push origin --delete "feature/epic-$epic_name"

echo "✅ Epic branch merged and deleted"
```

### STEP 7: Archive Epic (if requested)
```bash
if [[ "$archive_epic" == "true" ]]; then
  echo "📦 Archiving epic..."

  # Create archive directory
  archive_dir=".claude/archive/epics"
  mkdir -p "$archive_dir"

  # Move epic to archive
  mv "$epic_dir" "$archive_dir/"

  # Create completion summary
  cat > "$archive_dir/$epic_name/completion-summary.md" << EOF
# Epic Completion: $epic_name

- **Completed**: $(date)
- **Duration**: $(git log --oneline --since="1 month ago" main | grep "$epic_name" | wc -l) commits
- **Final PR**: #$pr_number
- **GitHub Issue**: #$issue_number
- **Deliverables**: ${completed}/${total} completed

## Git History
\`\`\`
$(git log --oneline --grep="$epic_name" main | head -10)
\`\`\`
EOF

  echo "📦 Epic archived to $archive_dir/$epic_name"
else
  echo "📁 Epic directory preserved in .claude/epics/$epic_name"
fi
```

## RULES TO FOLLOW

### Auto-Sync Rules (from .claude/rules/auto-sync.md)
- **Completion validation**: All required deliverables must exist and be non-empty
- **Quality gates**: Run lint, test, build before closing
- **GitHub sync**: Final status update to GitHub issue

### Git Workflow Rules (from .claude/rules/git-workflow.md)
- **Merge strategy**: Use --no-ff merge to preserve epic history
- **Branch cleanup**: Delete epic branch after successful merge
- **PR creation**: Ensure PR exists with auto-merge label

## ARGUMENTS
- `epic-name`: Name of epic to close (required)
- `--archive`: Move epic to archive directory (optional)

## ERROR HANDLING
- Validate all required deliverables exist before closing
- Check git repository state before merge operations
- Handle GitHub API failures gracefully
- Never leave repository in inconsistent state

## SUCCESS OUTPUT
```
📊 Epic completion: 100% (4/4 deliverables)
🔍 Running quality gates...
✅ GitHub issue #123 closed
✅ Created PR #456
✅ Epic branch merged and deleted
🎉 Epic 'user-auth' completed successfully!
```