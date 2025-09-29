#!/bin/bash
#
# GitHub Comment Manager - Intelligent GitHub Issue Comment Updates
# Updates existing comments instead of creating spam
#

set -euo pipefail

CCMP_DIR=".claude"
LOGS_DIR="$CCMP_DIR/logs"

# Logging function
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [GITHUB-COMMENT] $*" | tee -a "$LOGS_DIR/auto-sync.log"
}

error() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [GITHUB-COMMENT] [ERROR] $*" | tee -a "$LOGS_DIR/auto-sync.log" >&2
}

# Check if GitHub CLI is available
check_gh_cli() {
    if ! command -v gh &> /dev/null; then
        error "GitHub CLI not available, skipping comment operations"
        return 1
    fi

    if ! gh auth status &> /dev/null; then
        error "GitHub CLI not authenticated, skipping comment operations"
        return 1
    fi

    return 0
}

# Find the main auto-generated comment in an issue
find_main_comment() {
    local issue_number="$1"
    local repo="${2:-$(git remote get-url origin | sed 's|.*github.com[/:]||; s|\.git$||')}"

    if ! check_gh_cli; then
        echo ""
        return
    fi

    # Look for existing auto-generated comment with our marker
    local comment_id=$(gh issue view "$issue_number" --repo "$repo" --json comments \
        --jq '.comments[] | select(.body | contains("_Auto-updated by CCPM system_")) | .id' \
        | head -1)

    echo "$comment_id"
}

# Update or create the main progress comment
update_main_comment() {
    local issue_number="$1"
    local comment_body="$2"
    local repo="${3:-$(git remote get-url origin | sed 's|.*github.com[/:]||; s|\.git$||')}"

    if ! check_gh_cli; then
        return 1
    fi

    # Find existing main comment
    local comment_id=$(find_main_comment "$issue_number" "$repo")

    if [[ -n "$comment_id" && "$comment_id" != "null" ]]; then
        # Update existing comment
        log "Updating existing GitHub comment ID: $comment_id in issue #$issue_number"
        gh issue comment "$issue_number" --repo "$repo" --edit-body "$comment_body" --comment-id "$comment_id" || {
            error "Failed to update comment $comment_id in issue #$issue_number"
            return 1
        }
        echo "$comment_id"
    else
        # Create new comment (first time)
        log "Creating new GitHub comment in issue #$issue_number"
        local new_comment_url=$(gh issue comment "$issue_number" --repo "$repo" --body "$comment_body") || {
            error "Failed to create comment in issue #$issue_number"
            return 1
        }
        # Extract comment ID from URL
        local new_comment_id=$(echo "$new_comment_url" | grep -o '#issuecomment-[0-9]*' | sed 's/#issuecomment-//')
        echo "$new_comment_id"
    fi
}

# Add a standalone comment (for important milestones)
add_milestone_comment() {
    local issue_number="$1"
    local comment_body="$2"
    local repo="${3:-$(git remote get-url origin | sed 's|.*github.com[/:]||; s|\.git$||')}"

    if ! check_gh_cli; then
        return 1
    fi

    log "Adding milestone comment to issue #$issue_number"
    gh issue comment "$issue_number" --repo "$repo" --body "$comment_body" || {
        error "Failed to add milestone comment to issue #$issue_number"
        return 1
    }
}

# Generate intelligent comment body with deliverable changes
generate_progress_comment() {
    local epic_name="$1"
    local completion_percent="$2"
    local include_recent_changes="${3:-true}"

    local ccmp_scripts="$CCMP_DIR/scripts"
    local epic_dir="$CCMP_DIR/epics/$epic_name"
    local deliverables_file="$epic_dir/deliverables.json"

    # Get completion details
    local completion_details=""
    if [[ -f "$epic_dir/completion-details.md" ]]; then
        completion_details=$(cat "$epic_dir/completion-details.md")
    fi

    # Get recent deliverable changes if requested
    local recent_changes=""
    if [[ "$include_recent_changes" == "true" && -f "$ccmp_scripts/deliverable-tracker.sh" ]]; then
        recent_changes=$("$ccmp_scripts/deliverable-tracker.sh" summary "$epic_name" 2>/dev/null || echo "")
    fi

    # Generate comment body
    local comment_body="## 📊 Epic Progress: $epic_name

**Completion**: ${completion_percent}% • **Last Updated**: $(date) • **Branch**: $(git rev-parse --abbrev-ref HEAD)

$recent_changes### 📋 Deliverable Status
$completion_details

### 🔍 Quality Status
$(get_quality_status)

### 🎯 Next Steps
$(get_next_steps "$completion_percent")

---
*Auto-updated by CCPM system* • [View Epic Branch](https://github.com/$(git remote get-url origin | sed 's|.*github.com[/:]||; s|\.git$||')/tree/feature/epic-$epic_name)"

    echo "$comment_body"
}

# Get quality status (simplified version from auto-sync-engine)
get_quality_status() {
    # Simple quality check - can be enhanced later
    if command -v npm &> /dev/null && [[ -f "package.json" ]]; then
        echo "- ⚡ Package.json detected - Quality gates available"
    else
        echo "- 📦 No package.json - Skipping JS quality gates"
    fi
}

# Get next steps based on completion
get_next_steps() {
    local completion_percent="$1"

    if [[ "$completion_percent" -eq 100 ]]; then
        echo "🎉 **Epic Complete!** Ready for PR merge and closure."
    elif [[ "$completion_percent" -ge 80 ]]; then
        echo "🚀 **Almost there!** Complete remaining deliverables for epic closure."
    elif [[ "$completion_percent" -ge 50 ]]; then
        echo "⚡ **Making progress!** Continue implementing deliverables."
    else
        echo "📋 **Getting started!** Focus on core deliverables first."
    fi
}

# Smart update: only update if there are actual deliverable changes
smart_update() {
    local issue_number="$1"
    local epic_name="$2"
    local completion_percent="$3"
    local force_update="${4:-false}"

    local ccmp_scripts="$CCMP_DIR/scripts"

    # Check if there were deliverable changes (unless forced)
    if [[ "$force_update" != "true" ]]; then
        local has_changes="false"
        if [[ -f "$ccmp_scripts/deliverable-tracker.sh" ]]; then
            has_changes=$("$ccmp_scripts/deliverable-tracker.sh" has-changes "$epic_name" 2>/dev/null || echo "false")
        fi

        if [[ "$has_changes" != "true" ]]; then
            log "No deliverable changes detected for epic $epic_name, skipping comment update"
            return 0
        fi
    fi

    # Generate and update comment
    local comment_body=$(generate_progress_comment "$epic_name" "$completion_percent" "true")
    local comment_id=$(update_main_comment "$issue_number" "$comment_body")

    if [[ -n "$comment_id" ]]; then
        log "✅ Updated GitHub comment for epic $epic_name (${completion_percent}% complete)"
        return 0
    else
        error "Failed to update GitHub comment for epic $epic_name"
        return 1
    fi
}

# Main command dispatcher
case "${1:-}" in
    "update")
        issue_number="$2"
        epic_name="$3"
        completion_percent="$4"
        force_update="${5:-false}"
        smart_update "$issue_number" "$epic_name" "$completion_percent" "$force_update"
        ;;
    "milestone")
        issue_number="$2"
        comment_body="$3"
        add_milestone_comment "$issue_number" "$comment_body"
        ;;
    "find-main")
        issue_number="$2"
        find_main_comment "$issue_number"
        ;;
    "generate")
        epic_name="$2"
        completion_percent="$3"
        generate_progress_comment "$epic_name" "$completion_percent"
        ;;
    *)
        echo "Usage: $0 [update|milestone|find-main|generate] [issue_number] [epic_name] [completion_percent] [force]"
        echo ""
        echo "Commands:"
        echo "  update <issue> <epic> <percent> [force]  - Smart update main comment (only if changes)"
        echo "  milestone <issue> <body>                 - Add standalone milestone comment"
        echo "  find-main <issue>                        - Find ID of main auto-generated comment"
        echo "  generate <epic> <percent>                - Generate comment body (dry run)"
        exit 1
        ;;
esac