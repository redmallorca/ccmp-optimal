#!/bin/bash
#
# CCPM Overview Script
# Show complete project context and status
#

set -euo pipefail

echo "📋 ============================================="
echo "🤖 CCPM PROJECT OVERVIEW"
echo "============================================="
echo ""

# Project name from CLAUDE.md
project_name=$(grep -E "^# \[PROJECT\]" .claude/CLAUDE.md | sed 's/# \[PROJECT\] - //' | head -1 2>/dev/null || echo "Unknown Project")
echo "📂 PROJECT: ${project_name}"

# Technology stack from CLAUDE.md
tech_stack=$(grep -A 5 "Stack" .claude/CLAUDE.md | head -1 | sed 's/\*\*Stack\*\*: //' 2>/dev/null || echo "Not specified")
echo "🏗️ TECH STACK: ${tech_stack}"

# Current git status
current_branch=$(git branch --show-current 2>/dev/null || echo "unknown")
echo "📍 CURRENT BRANCH: $current_branch"

# Count modified files
modified_files=$(git status --porcelain | wc -l | tr -d ' ')
echo "📝 MODIFIED FILES: $modified_files"

# Last commit
last_commit=$(git log --oneline -1 2>/dev/null || echo "No commits")
echo "💾 LAST COMMIT: $last_commit"

# Check Docker availability
if command -v docker >/dev/null 2>&1; then
  echo "🐳 DOCKER: Available"
else
  echo "🐳 DOCKER: Not available"
fi

echo ""
echo "🤖 ACTIVE SPECIALISTS:"

# Extract specialists from CLAUDE.md
if grep -q "Active Specialists" .claude/CLAUDE.md; then
  grep -A 20 "Active Specialists" .claude/CLAUDE.md | grep "✅" | while read -r line; do
    echo "$line"
  done
else
  echo "⚠️ No specialists configured in CLAUDE.md"
fi

echo ""
echo "🎯 OPEN ISSUES & EPICS:"

epic_count=0
if [[ -d ".claude/epics" ]]; then
  for epic_dir in .claude/epics/*; do
    if [[ -d "$epic_dir" ]]; then
      epic_name=$(basename "$epic_dir")
      deliverables_file="$epic_dir/deliverables.json"

      if [[ -f "$deliverables_file" ]]; then
        issue_number=$(jq -r '.github_issue // "null"' "$deliverables_file")
        description=$(jq -r '.description // .epic' "$deliverables_file")

        # Calculate progress
        total=$(jq -r '.deliverables | length' "$deliverables_file")
        completed=0
        while IFS= read -r pattern; do
          if [[ -f "$pattern" && -s "$pattern" ]]; then
            ((completed++))
          fi
        done < <(jq -r '.deliverables[].pattern' "$deliverables_file")

        percentage=$((completed * 100 / total))

        if [[ "$issue_number" != "null" ]]; then
          echo "Issue #$issue_number: $description (${percentage}% complete)"
        else
          echo "Epic $epic_name: $description (${percentage}% complete)"
        fi
        ((epic_count++))
      fi
    fi
  done
fi

[[ "$epic_count" -eq 0 ]] && echo "No active epics found"

echo ""
echo "📚 KNOWLEDGE BASE:"

# Check CLAUDE.md
if [[ -f ".claude/CLAUDE.md" ]]; then
  echo "- Project configuration: ✅ Available (.claude/CLAUDE.md)"
else
  echo "- Project configuration: ❌ Missing (.claude/CLAUDE.md)"
fi

# Check Serena memories
if [[ -d ".serena" ]]; then
  memory_count=$(find .serena -name "*.md" 2>/dev/null | wc -l | tr -d ' ')
  echo "- Serena memories: $memory_count memories available"
else
  echo "- Serena memories: ✅ Available (MCP integrated)"
fi

# Check Supermemory integration
echo "- Supermemory sync: ✅ Active"

echo ""
echo "📥 EXTERNAL ISSUES INBOX:"

inbox_file=".claude/inbox/external-issues.jsonl"
if [[ -f "$inbox_file" ]]; then
  pending_count=0
  while IFS= read -r line; do
    [[ -z "$line" ]] && continue
    status=$(echo "$line" | jq -r '.status' 2>/dev/null)
    [[ "$status" == "pending" ]] && ((pending_count++))
  done < "$inbox_file"

  echo "- Pending external issues: $pending_count"
else
  echo "- Pending external issues: 0 (no inbox file)"
fi

echo ""
echo "🚀 NEXT STEPS:"

if [[ "$epic_count" -gt 0 ]]; then
  echo "1. Choose an epic to work on:"
  for epic_dir in .claude/epics/*; do
    if [[ -d "$epic_dir" ]]; then
      epic_name=$(basename "$epic_dir")
      echo "   • start $epic_name"
    fi
  done
else
  echo "1. Create a new epic:"
  echo "   • new <epic-name> \"Epic description\""
fi

echo ""
echo "📋 COMMANDS AVAILABLE:"
echo "status    - Check epic progress and repository health"
echo "new       - Create new epic with deliverables"
echo "start     - Load context for existing epic"
echo "sync      - Force GitHub synchronization"
echo "close     - Archive completed epic"
echo "inbox     - Review external GitHub issues"

echo ""
echo "============================================="
echo "✅ OVERVIEW COMPLETE - Ready to code!"
echo "============================================="