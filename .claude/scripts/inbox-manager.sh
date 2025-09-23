#!/bin/bash
#
# Inbox Manager - Manage external GitHub issues detected by github-sync
# Allows users to review, adopt, or ignore external issues/PRs
#

set -euo pipefail

# Configuration
CCPM_DIR=".claude"
INBOX_DIR="$CCPM_DIR/inbox"
EXTERNAL_ISSUES_FILE="$INBOX_DIR/external-issues.jsonl"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging
log() {
    echo -e "${BLUE}[$(date '+%Y-%m-%d %H:%M:%S')] $*${NC}"
}

error() {
    echo -e "${RED}[ERROR] $*${NC}" >&2
}

success() {
    echo -e "${GREEN}[SUCCESS] $*${NC}"
}

warning() {
    echo -e "${YELLOW}[WARNING] $*${NC}"
}

# List pending external issues
list_pending_issues() {
    if [[ ! -f "$EXTERNAL_ISSUES_FILE" ]]; then
        echo "No external issues detected yet."
        echo "Run: ./.claude/scripts/github-sync.sh sync"
        return
    fi

    local pending_issues=$(grep '"status":"pending"' "$EXTERNAL_ISSUES_FILE" 2>/dev/null || echo "")

    if [[ -z "$pending_issues" ]]; then
        echo "No pending external issues."
        return
    fi

    echo "=== PENDING EXTERNAL ISSUES ==="
    echo

    echo "$pending_issues" | while read -r issue; do
        local number=$(echo "$issue" | jq -r '.number')
        local title=$(echo "$issue" | jq -r '.title')
        local author=$(echo "$issue" | jq -r '.author')
        local url=$(echo "$issue" | jq -r '.url')
        local is_pr=$(echo "$issue" | jq -r '.is_pull_request')
        local created=$(echo "$issue" | jq -r '.created_at')
        local repo=$(echo "$issue" | jq -r '.repository')

        local type="Issue"
        if [[ "$is_pr" == "true" ]]; then
            type="Pull Request"
        fi

        echo -e "${YELLOW}#$number${NC} - $type"
        echo "  📝 $title"
        echo "  👤 By: $author"
        echo "  🏷️  Repo: $repo"
        echo "  📅 Created: $created"
        echo "  🔗 $url"
        echo
    done
}

# Show details of a specific issue
show_issue_details() {
    local issue_number="$1"

    if [[ ! -f "$EXTERNAL_ISSUES_FILE" ]]; then
        error "No external issues file found"
        return 1
    fi

    local issue=$(grep "\"number\":$issue_number" "$EXTERNAL_ISSUES_FILE" 2>/dev/null || echo "")

    if [[ -z "$issue" ]]; then
        error "Issue #$issue_number not found"
        return 1
    fi

    local title=$(echo "$issue" | jq -r '.title')
    local author=$(echo "$issue" | jq -r '.author')
    local url=$(echo "$issue" | jq -r '.url')
    local is_pr=$(echo "$issue" | jq -r '.is_pull_request')
    local created=$(echo "$issue" | jq -r '.created_at')
    local updated=$(echo "$issue" | jq -r '.updated_at')
    local status=$(echo "$issue" | jq -r '.status')
    local repo=$(echo "$issue" | jq -r '.repository')

    local type="Issue"
    if [[ "$is_pr" == "true" ]]; then
        type="Pull Request"
    fi

    echo "=== $type #$issue_number ==="
    echo
    echo "📝 Title: $title"
    echo "👤 Author: $author"
    echo "🏷️  Repository: $repo"
    echo "📅 Created: $created"
    echo "🔄 Updated: $updated"
    echo "🎯 Status: $status"
    echo "🔗 URL: $url"
}

# Update issue status
update_issue_status() {
    local issue_number="$1"
    local new_status="$2"

    if [[ ! -f "$EXTERNAL_ISSUES_FILE" ]]; then
        error "No external issues file found"
        return 1
    fi

    # Check if issue exists
    if ! grep -q "\"number\":$issue_number" "$EXTERNAL_ISSUES_FILE"; then
        error "Issue #$issue_number not found"
        return 1
    fi

    # Create temporary file with updated status
    local temp_file="$EXTERNAL_ISSUES_FILE.tmp"

    while read -r line; do
        if echo "$line" | grep -q "\"number\":$issue_number"; then
            # Update this line
            echo "$line" | jq --arg status "$new_status" '.status = $status'
        else
            echo "$line"
        fi
    done < "$EXTERNAL_ISSUES_FILE" > "$temp_file"

    mv "$temp_file" "$EXTERNAL_ISSUES_FILE"

    success "Issue #$issue_number marked as $new_status"
}

# Adopt external issue (mark as adopted for manual integration)
adopt_issue() {
    local issue_number="$1"

    show_issue_details "$issue_number" || return 1

    echo
    echo "This will mark issue #$issue_number as 'adopted' for manual integration."
    echo "You should manually create a corresponding GitHub issue or epic."
    echo
    read -p "Continue? (y/N): " -n 1 -r
    echo

    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Cancelled"
        return 0
    fi

    update_issue_status "$issue_number" "adopted"

    echo
    warning "Next steps:"
    echo "1. Create GitHub issue/epic for this external request"
    echo "2. Link external issue URL in your epic description"
    echo "3. Plan implementation in your epic deliverables"
}

# Ignore external issue (mark as not relevant)
ignore_issue() {
    local issue_number="$1"

    show_issue_details "$issue_number" || return 1

    echo
    echo "This will mark issue #$issue_number as 'ignored'."
    echo
    read -p "Continue? (y/N): " -n 1 -r
    echo

    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Cancelled"
        return 0
    fi

    update_issue_status "$issue_number" "ignored"
}

# Show statistics
show_stats() {
    if [[ ! -f "$EXTERNAL_ISSUES_FILE" ]]; then
        echo "No external issues detected yet."
        return
    fi

    local total=$(wc -l < "$EXTERNAL_ISSUES_FILE" 2>/dev/null || echo "0")
    local pending=$(grep -c '"status":"pending"' "$EXTERNAL_ISSUES_FILE" 2>/dev/null || echo "0")
    local adopted=$(grep -c '"status":"adopted"' "$EXTERNAL_ISSUES_FILE" 2>/dev/null || echo "0")
    local ignored=$(grep -c '"status":"ignored"' "$EXTERNAL_ISSUES_FILE" 2>/dev/null || echo "0")

    echo "=== INBOX STATISTICS ==="
    echo "📊 Total external issues: $total"
    echo "⏳ Pending review: $pending"
    echo "✅ Adopted: $adopted"
    echo "❌ Ignored: $ignored"
}

# CLI interface
case "${1:-list}" in
    "list"|"ls")
        list_pending_issues
        ;;
    "show")
        if [[ -z "${2:-}" ]]; then
            error "Usage: $0 show <issue-number>"
            exit 1
        fi
        show_issue_details "$2"
        ;;
    "adopt")
        if [[ -z "${2:-}" ]]; then
            error "Usage: $0 adopt <issue-number>"
            exit 1
        fi
        adopt_issue "$2"
        ;;
    "ignore")
        if [[ -z "${2:-}" ]]; then
            error "Usage: $0 ignore <issue-number>"
            exit 1
        fi
        ignore_issue "$2"
        ;;
    "stats")
        show_stats
        ;;
    "help"|"-h"|"--help")
        echo "Inbox Manager - Manage external GitHub issues"
        echo ""
        echo "Usage: $0 [command] [options]"
        echo ""
        echo "Commands:"
        echo "  list                    - List pending external issues (default)"
        echo "  show <issue-number>     - Show detailed information about an issue"
        echo "  adopt <issue-number>    - Mark issue as adopted for manual integration"
        echo "  ignore <issue-number>   - Mark issue as ignored/not relevant"
        echo "  stats                   - Show inbox statistics"
        echo "  help                    - Show this help message"
        echo ""
        echo "Workflow:"
        echo "1. Run github-sync.sh to detect external issues"
        echo "2. Use 'list' to see pending issues"
        echo "3. Use 'show <number>' to see details"
        echo "4. Use 'adopt <number>' to mark for manual integration"
        echo "5. Use 'ignore <number>' to mark as not relevant"
        ;;
    *)
        error "Unknown command: $1"
        echo "Use '$0 help' for usage information"
        exit 1
        ;;
esac