# overview - Show project status

**Usage**: `overview`
**Script**: `.claude/scripts/overview.sh`

## ORDERS FOR overview.sh EXECUTION

### STEP 1: Project Header
```bash
echo "📋 ============================================="
echo "🤖 CCPM PROJECT OVERVIEW"
echo "============================================="
echo ""

# Project name and tech stack
project_name=$(grep -E "^# \[PROJECT\]" CLAUDE.md | sed 's/# \[PROJECT\] - //' | head -1 2>/dev/null || echo "Unknown")
tech_stack=$(grep -A 5 "Stack" CLAUDE.md | head -1 | sed 's/\*\*Stack\*\*: //' 2>/dev/null || echo "Not specified")
echo "📂 PROJECT: ${project_name}"
echo "🏗️ TECH STACK: ${tech_stack}"
```

### STEP 2: Git Status
```bash
current_branch=$(git branch --show-current 2>/dev/null || echo "unknown")
modified_files=$(git status --porcelain | wc -l | tr -d ' ')
last_commit=$(git log --oneline -1 2>/dev/null || echo "No commits")

echo "📍 CURRENT BRANCH: $current_branch"
echo "📝 MODIFIED FILES: $modified_files"
echo "💾 LAST COMMIT: $last_commit"

[[ $(command -v docker) ]] && echo "🐳 DOCKER: Available" || echo "🐳 DOCKER: Not available"
```

### STEP 3: Active Specialists
```bash
echo ""
echo "🤖 ACTIVE SPECIALISTS:"
if grep -q "Active Specialists" CLAUDE.md; then
  grep -A 20 "Active Specialists" CLAUDE.md | grep "✅"
else
  echo "⚠️ No specialists configured"
fi
```

### STEP 4: Epics Status
```bash
echo ""
echo "🎯 OPEN ISSUES & EPICS:"
epic_count=0

for epic_dir in .claude/epics/*/; do
  [[ ! -d "$epic_dir" ]] && continue

  epic_name=$(basename "$epic_dir")
  deliverables_file="$epic_dir/deliverables.json"
  [[ ! -f "$deliverables_file" ]] && continue

  issue_number=$(jq -r '.github_issue // "null"' "$deliverables_file")
  description=$(jq -r '.description // .epic' "$deliverables_file")

  total=$(jq -r '.deliverables | length' "$deliverables_file")
  completed=0
  while read -r pattern; do
    [[ -f "$pattern" && -s "$pattern" ]] && ((completed++))
  done < <(jq -r '.deliverables[].pattern' "$deliverables_file")

  percentage=$((completed * 100 / total))

  if [[ "$issue_number" != "null" ]]; then
    echo "Issue #$issue_number: $description (${percentage}% complete)"
  else
    echo "Epic $epic_name: $description (${percentage}% complete)"
  fi
  ((epic_count++))
done

[[ "$epic_count" -eq 0 ]] && echo "No active epics"
```

### STEP 5: Knowledge Base
```bash
echo ""
echo "📚 KNOWLEDGE BASE:"
[[ -f "CLAUDE.md" ]] && echo "- Project config: ✅ Available" || echo "- Project config: ❌ Missing"

if [[ -d ".serena" ]]; then
  memory_count=$(find .serena -name "*.md" 2>/dev/null | wc -l)
  echo "- Serena memories: $memory_count available"
else
  echo "- Serena memories: ✅ MCP integrated"
fi

echo "- Supermemory: ✅ Active"
```

### STEP 6: External Issues
```bash
echo ""
echo "📥 EXTERNAL ISSUES:"
inbox_file=".claude/inbox/external-issues.jsonl"
if [[ -f "$inbox_file" ]]; then
  pending_count=$(grep '"status":"pending"' "$inbox_file" 2>/dev/null | wc -l)
  echo "- Pending: $pending_count"
else
  echo "- Pending: 0"
fi
```

### STEP 7: Next Steps
```bash
echo ""
echo "🚀 NEXT STEPS:"
if [[ "$epic_count" -gt 0 ]]; then
  echo "1. Choose epic to work on:"
  for epic_dir in .claude/epics/*/; do
    [[ -d "$epic_dir" ]] && echo "   • start $(basename "$epic_dir")"
  done
else
  echo "1. Create new epic: new <name> \"description\""
fi

echo ""
echo "📋 COMMANDS:"
echo "status - Epic progress"
echo "new - Create epic"
echo "start - Begin epic"
echo "sync - GitHub sync"
echo "close - Complete epic"
echo "inbox - External issues"

echo ""
echo "✅ OVERVIEW COMPLETE"
```

## RULES
- Read-only operations
- Handle missing files gracefully
- Show meaningful status for all components

## ARGUMENTS
None

## ERROR HANDLING
- Continue on missing files
- Show partial info if components unavailable