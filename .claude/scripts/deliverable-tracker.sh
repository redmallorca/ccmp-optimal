#!/bin/bash
#
# Deliverable Tracker - Smart Detection of Epic Progress Changes
# Tracks which specific deliverables changed in each commit
#

set -euo pipefail

CCMP_DIR=".claude"
EPICS_DIR="$CCMP_DIR/epics"
LOGS_DIR="$CCMP_DIR/logs"

# Logging function
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [DELIVERABLE-TRACKER] $*" | tee -a "$LOGS_DIR/auto-sync.log"
}

# Get current epic name from branch
get_current_epic() {
    local branch=$(git rev-parse --abbrev-ref HEAD)

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

# Check if a file matches a deliverable pattern
matches_deliverable() {
    local file="$1"
    local pattern="$2"

    # Convert glob pattern to regex-like matching
    case "$pattern" in
        *"*"*)
            # Pattern contains wildcards - use pathname expansion logic
            if [[ "$file" == $pattern ]]; then
                echo "true"
            else
                echo "false"
            fi
            ;;
        *)
            # Exact match
            if [[ "$file" == "$pattern" ]]; then
                echo "true"
            else
                echo "false"
            fi
            ;;
    esac
}

# Analyze what deliverables were affected by the last commit
analyze_commit_deliverable_changes() {
    local epic_name="$1"
    local commit_hash="${2:-HEAD}"

    if [[ -z "$epic_name" ]]; then
        echo "{\"epic\": null, \"changes\": []}"
        return
    fi

    local epic_dir="$EPICS_DIR/$epic_name"
    local deliverables_file="$epic_dir/deliverables.json"

    if [[ ! -f "$deliverables_file" ]]; then
        log "Deliverables file not found: $deliverables_file"
        echo "{\"epic\": \"$epic_name\", \"changes\": []}"
        return
    fi

    # Get files changed in this commit
    local changed_files=()
    while IFS= read -r file; do
        changed_files+=("$file")
    done < <(git diff-tree --no-commit-id --name-only -r "$commit_hash" 2>/dev/null || echo "")

    if [[ ${#changed_files[@]} -eq 0 ]]; then
        echo "{\"epic\": \"$epic_name\", \"changes\": []}"
        return
    fi

    # Check each deliverable against changed files
    local deliverable_changes=()
    local commit_msg=$(git log -1 --format="%s" "$commit_hash")
    local commit_short=$(git rev-parse --short "$commit_hash")

    while IFS= read -r deliverable; do
        local pattern=$(echo "$deliverable" | jq -r '.pattern')
        local description=$(echo "$deliverable" | jq -r '.description')
        local type=$(echo "$deliverable" | jq -r '.type // "unknown"')

        # Check if any changed file matches this deliverable pattern
        for file in "${changed_files[@]}"; do
            if [[ $(matches_deliverable "$file" "$pattern") == "true" ]]; then
                # This deliverable was affected by this commit
                local change_info="{\"pattern\": \"$pattern\", \"description\": \"$description\", \"type\": \"$type\", \"matched_file\": \"$file\", \"commit\": \"$commit_short\", \"commit_msg\": \"$commit_msg\"}"
                deliverable_changes+=("$change_info")
                break
            fi
        done
    done < <(jq -c '.deliverables[]' "$deliverables_file" 2>/dev/null || echo "")

    # Build JSON result
    local changes_json="["
    for i in "${!deliverable_changes[@]}"; do
        if [[ $i -gt 0 ]]; then
            changes_json+=","
        fi
        changes_json+="${deliverable_changes[$i]}"
    done
    changes_json+="]"

    echo "{\"epic\": \"$epic_name\", \"commit\": \"$commit_short\", \"commit_msg\": \"$commit_msg\", \"changed_files\": [$(printf '"%s",' "${changed_files[@]}" | sed 's/,$//g')], \"deliverable_changes\": $changes_json}"
}

# Get deliverable change history for an epic (last N commits)
get_deliverable_history() {
    local epic_name="$1"
    local max_commits="${2:-10}"

    if [[ -z "$epic_name" ]]; then
        echo "[]"
        return
    fi

    # Get last N commits on current branch
    local commits=()
    while IFS= read -r commit; do
        commits+=("$commit")
    done < <(git log --format="%H" -n "$max_commits" 2>/dev/null || echo "")

    local history="["
    for i in "${!commits[@]}"; do
        if [[ $i -gt 0 ]]; then
            history+=","
        fi
        local commit_analysis=$(analyze_commit_deliverable_changes "$epic_name" "${commits[$i]}")
        history+="$commit_analysis"
    done
    history+="]"

    echo "$history"
}

# Check if there were any meaningful deliverable changes in the last commit
has_deliverable_changes() {
    local epic_name="$1"

    local analysis=$(analyze_commit_deliverable_changes "$epic_name")
    local changes_count=$(echo "$analysis" | jq '.deliverable_changes | length')

    if [[ "$changes_count" -gt 0 ]]; then
        echo "true"
    else
        echo "false"
    fi
}

# Generate a deliverable change summary for GitHub comment
generate_change_summary() {
    local epic_name="$1"
    local commit_hash="${2:-HEAD}"

    local analysis=$(analyze_commit_deliverable_changes "$epic_name" "$commit_hash")
    local changes=$(echo "$analysis" | jq -r '.deliverable_changes[]')

    if [[ -z "$changes" ]]; then
        echo ""
        return
    fi

    local commit_short=$(echo "$analysis" | jq -r '.commit')
    local commit_msg=$(echo "$analysis" | jq -r '.commit_msg')

    echo "### 📝 Recent Changes (Commit $commit_short)"
    echo "*$commit_msg*"
    echo ""

    echo "$analysis" | jq -r '.deliverable_changes[] | "- ✅ **\(.description)** (`\(.matched_file)`)"'
    echo ""
}

# Main command dispatcher
case "${1:-}" in
    "analyze")
        epic_name="${2:-$(get_current_epic)}"
        commit_hash="${3:-HEAD}"
        analyze_commit_deliverable_changes "$epic_name" "$commit_hash"
        ;;
    "history")
        epic_name="${2:-$(get_current_epic)}"
        max_commits="${3:-10}"
        get_deliverable_history "$epic_name" "$max_commits"
        ;;
    "has-changes")
        epic_name="${2:-$(get_current_epic)}"
        has_deliverable_changes "$epic_name"
        ;;
    "summary")
        epic_name="${2:-$(get_current_epic)}"
        commit_hash="${3:-HEAD}"
        generate_change_summary "$epic_name" "$commit_hash"
        ;;
    *)
        echo "Usage: $0 [analyze|history|has-changes|summary] [epic-name] [commit-hash]"
        echo ""
        echo "Commands:"
        echo "  analyze [epic] [commit]  - Analyze deliverable changes in specific commit"
        echo "  history [epic] [max]     - Get deliverable change history (last N commits)"
        echo "  has-changes [epic]       - Check if last commit had deliverable changes"
        echo "  summary [epic] [commit]  - Generate GitHub comment summary of changes"
        exit 1
        ;;
esac