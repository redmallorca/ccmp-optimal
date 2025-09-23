# status - Epic Progress Check

**Usage**: `status [epic-name]`
**Script**: `.claude/scripts/status.sh [epic-name]`

## ORDERS FOR status.sh EXECUTION

### STEP 1: Parse Arguments
```bash
epic_name="${1:-}"
if [[ "$epic_name" == "--help" || "$epic_name" == "-h" ]]; then
  show_help; exit 0
fi
```

### STEP 2: Check if Specific Epic or All Epics
```bash
if [[ -n "$epic_name" ]]; then
  show_epic_status "$epic_name"
else
  show_all_epics
fi
```

### STEP 3: Calculate Completion (for specific epic)
```bash
deliverables_file=".claude/epics/$epic_name/deliverables.json"
total_deliverables=$(jq -r '.deliverables | length' "$deliverables_file")
completed=0

# Check each deliverable file exists and non-empty
while IFS= read -r pattern; do
  if [[ -f "$pattern" && -s "$pattern" ]]; then
    ((completed++))
  fi
done < <(jq -r '.deliverables[].pattern' "$deliverables_file")

percentage=$((completed * 100 / total_deliverables))
```

### STEP 4: Display Epic Information
```bash
# Show essential epic data
echo "## Epic Status: $epic_name"
echo "📊 Progress: ${percentage}% complete"
echo "📝 Description: $(jq -r '.description' "$deliverables_file")"
echo "🔗 GitHub Issue: #$(jq -r '.github_issue' "$deliverables_file")"

# Show git branch status
current_branch=$(git branch --show-current)
expected_branch="feature/epic-$epic_name"
if [[ "$current_branch" == "$expected_branch" ]]; then
  echo "🌿 Branch: $current_branch (active)"
else
  echo "🌿 Branch: $expected_branch (not active, current: $current_branch)"
fi
```

### STEP 5: List Deliverables Status
```bash
echo "### Deliverable Status"
while IFS= read -r deliverable; do
  pattern=$(echo "$deliverable" | jq -r '.pattern')
  required=$(echo "$deliverable" | jq -r '.required // false')
  description=$(echo "$deliverable" | jq -r '.description // ""')

  if [[ -f "$pattern" && -s "$pattern" ]]; then
    echo "- ✅ $pattern (completed)"
  else
    req_text=""
    if [[ "$required" == "true" ]]; then
      req_text=" (required)"
    else
      req_text=" (optional)"
    fi
    echo "- 📋 $pattern (pending)$req_text"
  fi

  if [[ -n "$description" ]]; then
    echo "     $description"
  fi
done < <(jq -c '.deliverables[]' "$deliverables_file")
```

### STEP 6: Show Next Actions
```bash
echo "### Next Actions"
if [[ "$percentage" -eq 100 ]]; then
  echo "🎉 Epic ready for completion!"
  echo "   Run: close $epic_name"
else
  echo "🎯 Complete remaining deliverables"
  github_issue=$(jq -r '.github_issue // "null"' "$deliverables_file")
  if [[ "$github_issue" == "null" || "$github_issue" == "" ]]; then
    echo "⚠️  Create GitHub issue for tracking"
  fi
  if [[ "$current_branch" != "$expected_branch" ]]; then
    echo "🌿 Switch to epic branch: git checkout $expected_branch"
  fi
fi
```

## RULES TO FOLLOW

### Auto-Sync Rules (from .claude/rules/auto-sync.md)
- **File-based completion**: Check deliverable files exist and non-empty
- **Real-time status**: No caching, always check current file state
- **Progress calculation**: completed_files / total_files * 100

### Git Workflow Rules (from .claude/rules/git-workflow.md)
- **Branch detection**: Check if on correct `feature/epic-$epic_name` branch
- **Status indicators**: Show branch active/inactive status

## OUTPUT FORMAT

### For Single Epic
```
## Epic Status: epic-name
📊 Progress: 67% complete
📝 Description: Epic description
🔗 GitHub Issue: #123
🌿 Branch: feature/epic-epic-name (active)

### Deliverable Status
- ✅ src/component.vue (completed)
     Main component implementation
- 📋 tests/test.js (pending) (required)
     Test coverage for component

### Next Actions
🎯 Complete remaining deliverables
```

### For All Epics
```
## Active Epics Overview

### epic-1 (100% complete)
   Epic description here

### epic-2 (50% complete)
   Epic description here

Total active epics: 2
```

## ERROR HANDLING
- Check if `.claude/epics` directory exists
- Validate epic exists before showing details
- Handle missing deliverables.json gracefully
- Show clear error for non-existent epics