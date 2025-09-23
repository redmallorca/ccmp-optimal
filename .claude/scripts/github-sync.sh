#!/bin/bash
#
# GitHub Sync - Simple polling for external issues/PRs
# Detects issues created by external stakeholders for eventual incorporation
#

set -euo pipefail

# Configuration
CCPM_DIR=".claude"
INBOX_DIR="$CCPM_DIR/inbox"
CONFIG_FILE="$CCPM_DIR/config.json"
LOG_FILE="$CCPM_DIR/logs/github-sync.log"

# Ensure directories exist
mkdir -p "$INBOX_DIR"
mkdir -p "$(dirname "$LOG_FILE")"

# Logging
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"
}

# Get current repository from git remote
get_repository() {
    git remote get-url origin 2>/dev/null | \
    sed -E 's|.*github\.com[/:]([^/]+/[^/]+)\.git.*|\1|' || \
    echo ""
}

# Get GitHub token from environment or git config
get_github_token() {
    # Try environment variable first
    if [[ -n "${GITHUB_TOKEN:-}" ]]; then
        echo "$GITHUB_TOKEN"
        return
    fi

    # Try git config
    local token=$(git config --get github.token 2>/dev/null || echo "")
    if [[ -n "$token" ]]; then
        echo "$token"
        return
    fi

    log "Error: No GitHub token found. Set GITHUB_TOKEN env var or git config github.token"
    exit 1
}

# Load last sync state
load_sync_state() {
    local repo="$1"
    local state_file="$INBOX_DIR/sync-state.json"

    if [[ -f "$state_file" ]]; then
        local last_sync=$(jq -r --arg repo "$repo" '.[$repo].last_sync // "2025-01-01T00:00:00Z"' "$state_file" 2>/dev/null || echo "2025-01-01T00:00:00Z")
        local etag=$(jq -r --arg repo "$repo" '.[$repo].etag // ""' "$state_file" 2>/dev/null || echo "")
        echo "$last_sync|$etag"
    else
        echo "2025-01-01T00:00:00Z|"
    fi
}

# Save sync state
save_sync_state() {
    local repo="$1"
    local last_sync="$2"
    local etag="$3"
    local state_file="$INBOX_DIR/sync-state.json"

    # Create state file if it doesn't exist
    if [[ ! -f "$state_file" ]]; then
        echo '{}' > "$state_file"
    fi

    # Update state
    jq --arg repo "$repo" --arg sync "$last_sync" --arg etag "$etag" \
       '.[$repo] = {"last_sync": $sync, "etag": $etag}' \
       "$state_file" > "$state_file.tmp" && mv "$state_file.tmp" "$state_file"
}

# Check if issue is external (not from team members)
is_external_issue() {
    local author_association="$1"

    case "$author_association" in
        "OWNER"|"MEMBER"|"COLLABORATOR")
            return 1  # Not external
            ;;
        "NONE"|"FIRST_TIME_CONTRIBUTOR"|"CONTRIBUTOR")
            return 0  # External
            ;;
        *)
            return 0  # Default to external for safety
            ;;
    esac
}

# Fetch external issues from GitHub
fetch_external_issues() {
    local repo="$1"
    local token="$2"
    local since="$3"
    local etag="$4"

    log "Fetching issues from $repo since $since"

    # Build API request headers
    local headers=(-H "Authorization: token $token" -H "Accept: application/vnd.github.v3+json")
    if [[ -n "$etag" ]]; then
        headers+=(-H "If-None-Match: $etag")
    fi

    # API call with error handling
    local response
    local http_code

    response=$(curl -s -w "%{http_code}" \
        "${headers[@]}" \
        "https://api.github.com/repos/$repo/issues?state=all&since=$since&per_page=100&sort=updated&direction=desc" \
        2>/dev/null)

    http_code="${response: -3}"
    response="${response%???}"

    case "$http_code" in
        "200")
            # New data available
            echo "$response"
            ;;
        "304")
            # Not modified (ETag match)
            log "No new issues since last sync (ETag match)"
            echo "[]"
            ;;
        "403")
            log "Error: GitHub API rate limit exceeded or permission denied"
            echo "[]"
            ;;
        "404")
            log "Error: Repository not found or not accessible"
            echo "[]"
            ;;
        *)
            log "Error: GitHub API returned HTTP $http_code"
            echo "[]"
            ;;
    esac
}

# Process and store external issues
process_external_issues() {
    local issues_json="$1"
    local repo="$2"
    local external_file="$INBOX_DIR/external-issues.jsonl"

    if [[ "$issues_json" == "[]" ]]; then
        return
    fi

    local external_count=0

    # Process each issue
    echo "$issues_json" | jq -c '.[]' | while read -r issue; do
        local author_association=$(echo "$issue" | jq -r '.author_association')
        local issue_number=$(echo "$issue" | jq -r '.number')
        local title=$(echo "$issue" | jq -r '.title')
        local url=$(echo "$issue" | jq -r '.html_url')
        local created_at=$(echo "$issue" | jq -r '.created_at')
        local updated_at=$(echo "$issue" | jq -r '.updated_at')
        local user_login=$(echo "$issue" | jq -r '.user.login')
        local is_pr=$(echo "$issue" | jq -r '.pull_request != null')

        # Check if external
        if is_external_issue "$author_association"; then
            # Check if already processed
            if ! grep -q "\"number\":$issue_number" "$external_file" 2>/dev/null; then
                # Add to external issues
                local external_issue=$(jq -n \
                    --arg repo "$repo" \
                    --arg number "$issue_number" \
                    --arg title "$title" \
                    --arg url "$url" \
                    --arg author "$user_login" \
                    --arg created "$created_at" \
                    --arg updated "$updated_at" \
                    --arg is_pr "$is_pr" \
                    --arg status "pending" \
                    '{
                        repository: $repo,
                        number: ($number | tonumber),
                        title: $title,
                        url: $url,
                        author: $author,
                        created_at: $created,
                        updated_at: $updated,
                        is_pull_request: ($is_pr == "true"),
                        status: $status,
                        detected_at: now | strftime("%Y-%m-%dT%H:%M:%SZ")
                    }')

                echo "$external_issue" >> "$external_file"
                ((external_count++))

                log "External $(if [[ "$is_pr" == "true" ]]; then echo "PR"; else echo "issue"; fi) detected: #$issue_number \"$title\" by $user_login"
            fi
        fi
    done

    if [[ $external_count -gt 0 ]]; then
        log "Added $external_count new external issues to inbox"
    fi
}

# Main sync function
sync_github_issues() {
    local repo=$(get_repository)

    if [[ -z "$repo" ]]; then
        log "Error: Could not determine GitHub repository from git remote"
        exit 1
    fi

    local token=$(get_github_token)
    local sync_state=$(load_sync_state "$repo")
    local last_sync="${sync_state%|*}"
    local etag="${sync_state#*|}"

    log "Starting sync for repository: $repo"
    log "Last sync: $last_sync"

    # Fetch issues
    local issues_json=$(fetch_external_issues "$repo" "$token" "$last_sync" "$etag")

    # Process external issues
    process_external_issues "$issues_json" "$repo"

    # Update sync state
    local new_sync=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    local new_etag=""  # TODO: Extract ETag from response headers

    save_sync_state "$repo" "$new_sync" "$new_etag"

    log "Sync complete for repository: $repo"
}

# CLI interface
case "${1:-sync}" in
    "sync")
        sync_github_issues
        ;;
    "status")
        # Show current sync status
        repo=$(get_repository)
        state=$(load_sync_state "$repo")
        last_sync="${state%|*}"
        echo "Repository: $repo"
        echo "Last sync: $last_sync"

        if [[ -f "$INBOX_DIR/external-issues.jsonl" ]]; then
            pending_count=$(grep '"status":"pending"' "$INBOX_DIR/external-issues.jsonl" | wc -l)
            echo "Pending external issues: $pending_count"
        else
            echo "Pending external issues: 0"
        fi
        ;;
    *)
        echo "Usage: $0 [sync|status]"
        echo ""
        echo "Commands:"
        echo "  sync    - Fetch external issues from GitHub"
        echo "  status  - Show sync status and pending issues"
        exit 1
        ;;
esac