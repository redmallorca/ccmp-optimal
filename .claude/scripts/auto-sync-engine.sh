#!/bin/bash
#
# Auto-Sync Engine - Core CCPM Automation (Refactored)
# Zero-command automation through git hooks
# Simplified: 150 lines, lock-protected, composition over duplication
#

set -euo pipefail

# ============================================
# CONFIGURATION
# ============================================

REPO_ROOT=$(git rev-parse --show-toplevel)
CCPM_DIR=".claude"
EPICS_DIR="$CCPM_DIR/epics"
LOGS_DIR="$CCPM_DIR/logs"
CONFIG_FILE="$CCPM_DIR/config.json"
LOCK_FILE="/tmp/ccpm-auto-sync-$(echo "$REPO_ROOT" | md5).lock"

# Ensure log directory exists
mkdir -p "$LOGS_DIR"
LOG_FILE="$LOGS_DIR/auto-sync.log"

# ============================================
# LOGGING
# ============================================

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"
}

error() {
    echo "[ERROR] $*" | tee -a "$LOG_FILE" >&2
}

# ============================================
# LOCK MANAGEMENT (prevents concurrent runs)
# ============================================

acquire_lock() {
    if [[ -f "$LOCK_FILE" ]]; then
        local pid=$(cat "$LOCK_FILE" 2>/dev/null || echo "")

        # Check if process is still alive
        if [[ -n "$pid" ]] && kill -0 "$pid" 2>/dev/null; then
            log "Auto-sync already running (PID: $pid), exiting"
            exit 0
        fi

        # Lock is stale, remove it
        log "Removing stale lock file"
        rm -f "$LOCK_FILE"
    fi

    # Create lock with current PID
    echo $$ > "$LOCK_FILE"
    log "Lock acquired (PID: $$)"
}

release_lock() {
    rm -f "$LOCK_FILE"
    log "Lock released"
}

# Ensure lock is released on exit
trap release_lock EXIT INT TERM

# ============================================
# CONFIGURATION LOADING
# ============================================

load_config() {
    # jq is required, no fallback
    if ! command -v jq &>/dev/null; then
        error "jq is required. Install: brew install jq"
        exit 1
    fi

    if [[ ! -f "$CONFIG_FILE" ]]; then
        error "Configuration file not found: $CONFIG_FILE"
        exit 1
    fi

    # Load configuration
    AUTO_MERGE=$(jq -r '.github.auto_merge // true' "$CONFIG_FILE")
    TARGET_BRANCH=$(jq -r '.github.target_branch // "main"' "$CONFIG_FILE")
    INTELLIGENT_COMMENTS=$(jq -r '.auto_sync.intelligent_comments.enabled // false' "$CONFIG_FILE")
    DELIVERABLE_TRACKING=$(jq -r '.auto_sync.deliverable_tracking.enabled // false' "$CONFIG_FILE")
}

# ============================================
# EPIC DETECTION
# ============================================

get_current_epic() {
    local branch=$(git rev-parse --abbrev-ref HEAD)

    # Extract epic name from branch (feature/epic-name -> name)
    if [[ "$branch" =~ ^feature/epic-(.+)$ ]]; then
        echo "${BASH_REMATCH[1]}"
    elif [[ "$branch" =~ ^feature/(.+)$ ]]; then
        echo "${BASH_REMATCH[1]}"
    elif [[ "$branch" =~ ^epic/(.+)$ ]]; then
        echo "${BASH_REMATCH[1]}"
    else
        echo ""
    fi
}

# ============================================
# COMPLETION CALCULATION (uses deliverable-tracker.sh)
# ============================================

calculate_completion() {
    local epic_name="$1"
    local tracker_script="$CCPM_DIR/scripts/deliverable-tracker.sh"

    # Use specialized script if available
    if [[ -f "$tracker_script" ]]; then
        "$tracker_script" completion "$epic_name" 2>/dev/null || echo "0"
    else
        # Fallback: simple file-based calculation
        local epic_dir="$EPICS_DIR/$epic_name"
        local deliverables_file="$epic_dir/deliverables.json"

        if [[ ! -f "$deliverables_file" ]]; then
            echo "0"
            return
        fi

        local total=$(jq '[.deliverables[] | select(.required == true)] | length' "$deliverables_file")
        local completed=0

        # Simple check: file exists
        while IFS= read -r pattern; do
            if ls $pattern 2>/dev/null | head -1 | grep -q .; then
                ((completed++))
            fi
        done < <(jq -r '.deliverables[] | select(.required == true) | .pattern' "$deliverables_file")

        if [[ $total -eq 0 ]]; then
            echo "0"
        else
            echo $((completed * 100 / total))
        fi
    fi
}

# ============================================
# GITHUB INTEGRATION (uses github-comment-manager.sh)
# ============================================

update_github() {
    local epic_name="$1"
    local completion="$2"
    local epic_dir="$EPICS_DIR/$epic_name"
    local deliverables_file="$epic_dir/deliverables.json"

    # gh CLI required
    if ! command -v gh &>/dev/null; then
        log "GitHub CLI not available, skipping GitHub sync"
        return
    fi

    # Get issue number
    local issue_number=$(jq -r '.github_issue // empty' "$deliverables_file" 2>/dev/null)

    if [[ -z "$issue_number" || "$issue_number" == "null" ]]; then
        log "No GitHub issue configured for epic: $epic_name"
        return
    fi

    # Use intelligent comment manager if enabled
    local comment_manager="$CCPM_DIR/scripts/github-comment-manager.sh"
    if [[ "$INTELLIGENT_COMMENTS" == "true" ]] && [[ -x "$comment_manager" ]]; then
        log "Updating GitHub issue #$issue_number (${completion}%) with intelligent comments"
        "$comment_manager" update "$issue_number" "$epic_name" "$completion" || {
            error "Failed to update GitHub issue #$issue_number"
        }
    elif [[ -f "$comment_manager" ]]; then
        log "Updating GitHub issue #$issue_number (${completion}%)"
        "$comment_manager" update "$issue_number" "$epic_name" "$completion" || {
            error "Failed to update GitHub issue #$issue_number"
        }
    else
        log "Comment manager not found, skipping GitHub update"
    fi

    # Close issue at 100%
    if [[ "$completion" -eq 100 ]]; then
        log "Epic completed, closing GitHub issue #$issue_number"
        gh issue close "$issue_number" --comment "🎉 Epic completed! All deliverables implemented." || {
            error "Failed to close GitHub issue #$issue_number"
        }
    fi
}

# ============================================
# PR CREATION (simple, minimal)
# ============================================

create_pr() {
    local epic_name="$1"
    local branch=$(git rev-parse --abbrev-ref HEAD)
    local epic_dir="$EPICS_DIR/$epic_name"

    if ! command -v gh &>/dev/null; then
        log "GitHub CLI not available, skipping PR creation"
        return
    fi

    # Check if PR already exists
    local existing_pr=$(gh pr list --head "$branch" --json number -q '.[0].number // empty' 2>/dev/null)
    if [[ -n "$existing_pr" ]]; then
        log "PR already exists for branch $branch: #$existing_pr"

        # Ensure auto-merge label is present
        gh pr edit "$existing_pr" --add-label "auto-merge" 2>/dev/null || true
        return
    fi

    # Generate PR content
    local pr_title="feat($epic_name): Complete epic"
    local pr_body="## Epic Completion: $epic_name

All deliverables have been successfully implemented.

### Deliverables ✅
$(cat "$epic_dir/completion-details.md" 2>/dev/null || echo "- All deliverables completed")

This PR completes the $epic_name epic and is ready for review.

_Auto-generated by CCPM system_"

    # Create PR
    log "Creating PR for completed epic: $epic_name"
    gh pr create \
        --title "$pr_title" \
        --body "$pr_body" \
        --label "auto-merge" \
        --base "$TARGET_BRANCH" \
        --head "$branch" || {
        error "Failed to create PR for epic: $epic_name"
    }
}

# ============================================
# MAIN AUTO-SYNC FUNCTION
# ============================================

auto_sync() {
    local epic_name=$(get_current_epic)

    # Early returns
    if [[ -z "$epic_name" ]]; then
        log "Not on an epic branch, skipping auto-sync"
        exit 0
    fi

    local epic_dir="$EPICS_DIR/$epic_name"
    if [[ ! -d "$epic_dir" ]]; then
        log "Epic directory not found: $epic_dir"
        exit 0
    fi

    log "Auto-sync triggered for epic: $epic_name"

    # Push branch to remote
    local branch=$(git rev-parse --abbrev-ref HEAD)
    log "Pushing branch $branch to remote"
    git push -u origin "$branch" 2>/dev/null || {
        log "Push failed or branch already up to date"
    }

    # Calculate completion
    local completion=$(calculate_completion "$epic_name")
    log "Epic $epic_name completion: ${completion}%"

    # Update GitHub issue
    update_github "$epic_name" "$completion"

    # Create PR if ready
    if [[ "$completion" -eq 100 ]]; then
        create_pr "$epic_name"
    fi

    log "Auto-sync complete for epic: $epic_name"
}

# ============================================
# ENTRY POINT
# ============================================

# Acquire lock first (exits if already running)
acquire_lock

# Load configuration
load_config

# Execute auto-sync
auto_sync