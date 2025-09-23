# inbox - External Issues Management

**Usage**: `inbox [list|show|adopt|ignore|stats] [issue-number]`
**Script**: `.claude/scripts/inbox.sh [command] [options]`

## ORDERS FOR inbox.sh EXECUTION

### STEP 1: Parse Arguments and Validate
```bash
command="${1:-list}"
issue_number="$2"

case "$command" in
  list|show|adopt|ignore|stats) ;;
  *) echo "Error: Invalid command. Use: list, show, adopt, ignore, stats"; exit 1 ;;
esac

[[ "$command" == "show" || "$command" == "adopt" || "$command" == "ignore" ]] && [[ -z "$issue_number" ]] && {
  echo "Error: Issue number required for $command"; exit 1;
}
```

### STEP 2: Initialize Inbox Directory
```bash
inbox_dir=".claude/inbox"
issues_file="$inbox_dir/external-issues.jsonl"

mkdir -p "$inbox_dir"
[[ ! -f "$issues_file" ]] && touch "$issues_file"
```

### STEP 3: Execute Command Functions
```bash
case "$command" in
  list) list_pending_issues ;;
  show) show_issue_details "$issue_number" ;;
  adopt) adopt_issue "$issue_number" ;;
  ignore) ignore_issue "$issue_number" ;;
  stats) show_inbox_stats ;;
esac
```

### STEP 4: List Pending Issues (Default)
```bash
list_pending_issues() {
  echo "=== PENDING EXTERNAL ISSUES ==="
  echo ""

  pending_count=0
  while IFS= read -r line; do
    [[ -z "$line" ]] && continue

    status=$(echo "$line" | jq -r '.status')
    [[ "$status" != "pending" ]] && continue

    number=$(echo "$line" | jq -r '.number')
    title=$(echo "$line" | jq -r '.title')
    author=$(echo "$line" | jq -r '.author')
    created_at=$(echo "$line" | jq -r '.created_at')
    url=$(echo "$line" | jq -r '.url')
    is_pr=$(echo "$line" | jq -r '.is_pull_request')

    type_label="Issue"
    [[ "$is_pr" == "true" ]] && type_label="Pull Request"

    echo "#$number - $type_label"
    echo "  📝 $title"
    echo "  👤 By: $author"
    echo "  📅 Created: $created_at"
    echo "  🔗 $url"
    echo ""

    ((pending_count++))
  done < "$issues_file"

  [[ "$pending_count" -eq 0 ]] && echo "No pending external issues found."
  echo "Total pending: $pending_count"
}
```

### STEP 5: Show Issue Details
```bash
show_issue_details() {
  local issue_num="$1"

  while IFS= read -r line; do
    [[ -z "$line" ]] && continue

    number=$(echo "$line" | jq -r '.number')
    [[ "$number" != "$issue_num" ]] && continue

    echo "=== Issue #$issue_num ==="
    echo ""
    echo "📝 Title: $(echo "$line" | jq -r '.title')"
    echo "👤 Author: $(echo "$line" | jq -r '.author')"
    echo "📅 Created: $(echo "$line" | jq -r '.created_at')"
    echo "🔄 Updated: $(echo "$line" | jq -r '.updated_at')"
    echo "🎯 Status: $(echo "$line" | jq -r '.status')"
    echo "🔗 URL: $(echo "$line" | jq -r '.url')"

    is_pr=$(echo "$line" | jq -r '.is_pull_request')
    [[ "$is_pr" == "true" ]] && echo "📋 Type: Pull Request" || echo "📋 Type: Issue"

    return 0
  done < "$issues_file"

  echo "Error: Issue #$issue_num not found in inbox"
  exit 1
}
```

### STEP 6: Adopt or Ignore Issues
```bash
adopt_issue() {
  local issue_num="$1"
  update_issue_status "$issue_num" "adopted" "marked as adopted for manual integration"
}

ignore_issue() {
  local issue_num="$1"
  update_issue_status "$issue_num" "ignored" "marked as ignored/not relevant"
}

update_issue_status() {
  local issue_num="$1"
  local new_status="$2"
  local action_desc="$3"

  temp_file=$(mktemp)
  found=false

  while IFS= read -r line; do
    [[ -z "$line" ]] && continue

    number=$(echo "$line" | jq -r '.number')
    if [[ "$number" == "$issue_num" ]]; then
      # Update status and timestamp
      updated_line=$(echo "$line" | jq --arg status "$new_status" --arg timestamp "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
        '.status = $status | .updated_at = $timestamp')
      echo "$updated_line" >> "$temp_file"
      found=true
    else
      echo "$line" >> "$temp_file"
    fi
  done < "$issues_file"

  if [[ "$found" == "true" ]]; then
    mv "$temp_file" "$issues_file"
    echo "[SUCCESS] Issue #$issue_num $action_desc"
  else
    rm "$temp_file"
    echo "Error: Issue #$issue_num not found in inbox"
    exit 1
  fi
}
```

### STEP 7: Show Statistics
```bash
show_inbox_stats() {
  echo "=== INBOX STATISTICS ==="

  total=0
  pending=0
  adopted=0
  ignored=0

  while IFS= read -r line; do
    [[ -z "$line" ]] && continue

    status=$(echo "$line" | jq -r '.status')
    ((total++))

    case "$status" in
      pending) ((pending++)) ;;
      adopted) ((adopted++)) ;;
      ignored) ((ignored++)) ;;
    esac
  done < "$issues_file"

  echo "📊 Total external issues: $total"
  echo "⏳ Pending review: $pending"
  echo "✅ Adopted: $adopted"
  echo "❌ Ignored: $ignored"
}
```

## RULES TO FOLLOW

### Auto-Sync Rules (from .claude/rules/auto-sync.md)
- **External detection**: Issues detected by github-sync.sh based on author_association
- **No auto-actions**: Never automatically create epics or adopt issues
- **Manual decisions**: All adoptions require explicit user action

### Git Workflow Rules (from .claude/rules/git-workflow.md)
- **External reference**: Include original issue URL in epic descriptions
- **Manual integration**: Use standard /pm:new after adoption
- **Standard workflow**: Adopted issues follow normal CCPM process

## ARGUMENTS
- `command`: list, show, adopt, ignore, stats (default: list)
- `issue-number`: Required for show, adopt, ignore commands

## ERROR HANDLING
- Validate command arguments before processing
- Check if external-issues.jsonl exists and is readable
- Handle missing issue numbers gracefully
- Never leave JSONL file in corrupted state

## SUCCESS OUTPUT
```
=== PENDING EXTERNAL ISSUES ===

#42 - Issue
  📝 Add dark mode toggle
  👤 By: external_user
  📅 Created: 2025-09-23T14:30:00Z
  🔗 https://github.com/myorg/myproject/issues/42

Total pending: 1
```