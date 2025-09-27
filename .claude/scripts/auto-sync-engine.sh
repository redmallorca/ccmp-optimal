#!/bin/bash
#
# Auto-Sync Engine - Core CCPM Automation
# Zero-command automation through git hooks and intelligent completion detection
#

set -euo pipefail

# Configuration
CCPM_DIR=".claude"
EPICS_DIR="$CCPM_DIR/epics"
LOGS_DIR="$CCPM_DIR/logs"
CONFIG_FILE="$CCPM_DIR/config.json"

# Ensure log directory exists
mkdir -p "$LOGS_DIR"
LOG_FILE="$LOGS_DIR/auto-sync.log"

# Load configuration from config.json
load_config() {
    if [[ -f "$CONFIG_FILE" ]]; then
        # Check if jq is available
        if command -v jq >/dev/null 2>&1; then
            DELIVERABLE_PATTERNS=$(jq -r '.deliverables.patterns[]' "$CONFIG_FILE" 2>/dev/null || echo "")
            QUALITY_GATES_LINT=$(jq -r '.quality_gates.lint' "$CONFIG_FILE" 2>/dev/null || echo "true")
            QUALITY_GATES_TEST=$(jq -r '.quality_gates.test' "$CONFIG_FILE" 2>/dev/null || echo "true")
            QUALITY_GATES_BUILD=$(jq -r '.quality_gates.build' "$CONFIG_FILE" 2>/dev/null || echo "true")
            AUTO_MERGE_ENABLED=$(jq -r '.github.auto_merge' "$CONFIG_FILE" 2>/dev/null || echo "true")
            TARGET_BRANCH=$(jq -r '.github.target_branch' "$CONFIG_FILE" 2>/dev/null || echo "main")
        else
            log "Warning: jq not found, using default configuration"
            DELIVERABLE_PATTERNS=""
            QUALITY_GATES_LINT="true"
            QUALITY_GATES_TEST="true"
            QUALITY_GATES_BUILD="true"
            AUTO_MERGE_ENABLED="true"
            TARGET_BRANCH="main"
        fi
    else
        log "Warning: config.json not found, using default configuration"
        DELIVERABLE_PATTERNS=""
        QUALITY_GATES_LINT="true"
        QUALITY_GATES_TEST="true"
        QUALITY_GATES_BUILD="true"
        AUTO_MERGE_ENABLED="true"
        TARGET_BRANCH="main"
    fi
}

# Logging function
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"
}

error() {
    echo "[ERROR] $*" | tee -a "$LOG_FILE" >&2
}

# Get current branch and epic name
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

# Check if deliverable file exists and is valid
check_deliverable() {
    local file="$1"

    # File must exist and be readable
    if [[ ! -f "$file" ]]; then
        echo "false"
        return
    fi

    # File must be non-empty
    if [[ ! -s "$file" ]]; then
        echo "false"
        return
    fi

    # Enhanced validation based on file type and content
    case "$file" in
        *.vue|*.astro|*.tsx|*.jsx)
            # Component files should have meaningful content
            local line_count=$(wc -l < "$file")
            if [[ $line_count -lt 5 ]]; then
                echo "false"
                return
            fi
            # Check for basic component structure
            if grep -q -E "(export|template|script|<)" "$file"; then
                echo "true"
            else
                echo "false"
            fi
            ;;
        *.test.js|*.test.ts|*.spec.js|*.spec.ts)
            # Test files should contain actual tests
            if grep -q -E "(test|it|describe|expect|assert)" "$file"; then
                # Ensure test file has meaningful content
                local test_count=$(grep -c -E "(test|it)\(" "$file")
                if [[ $test_count -gt 0 ]]; then
                    echo "true"
                else
                    echo "false"
                fi
            else
                echo "false"
            fi
            ;;
        *.md)
            # Documentation should have reasonable content and structure
            local line_count=$(wc -l < "$file")
            if [[ $line_count -lt 3 ]]; then
                echo "false"
                return
            fi
            # Check for basic markdown structure
            if grep -q -E "(^#|^\*|^-|^[0-9]+\.)" "$file"; then
                echo "true"
            else
                echo "false"
            fi
            ;;
        *.js|*.ts)
            # JavaScript/TypeScript files should have meaningful content
            local line_count=$(wc -l < "$file")
            if [[ $line_count -lt 3 ]]; then
                echo "false"
                return
            fi
            # Check for basic JS/TS structure
            if grep -q -E "(function|const|let|var|class|export|import)" "$file"; then
                echo "true"
            else
                echo "false"
            fi
            ;;
        *.json)
            # JSON files should be valid JSON
            if command -v jq >/dev/null 2>&1; then
                if jq . "$file" >/dev/null 2>&1; then
                    echo "true"
                else
                    echo "false"
                fi
            else
                # Fallback: basic JSON structure check
                if grep -q -E "^\s*[{\[]" "$file" && grep -q -E "[}\]]\s*$" "$file"; then
                    echo "true"
                else
                    echo "false"
                fi
            fi
            ;;
        *)
            # Default: file exists, non-empty, and has reasonable content
            local line_count=$(wc -l < "$file")
            if [[ $line_count -gt 0 ]]; then
                echo "true"
            else
                echo "false"
            fi
            ;;
    esac
}

# Calculate epic completion percentage
calculate_completion() {
    local epic_name="$1"
    local epic_dir="$EPICS_DIR/$epic_name"
    local deliverables_file="$epic_dir/deliverables.json"

    if [[ ! -f "$deliverables_file" ]]; then
        error "Deliverables file not found: $deliverables_file"
        echo "0"
        return
    fi

    # Parse deliverables from JSON
    local total_required=0
    local completed_required=0
    local completion_details=""

    # Use jq to parse deliverables (fallback to manual parsing if jq not available)
    if command -v jq &> /dev/null; then
        # Parse with jq
        while IFS= read -r deliverable; do
            local pattern=$(echo "$deliverable" | jq -r '.pattern')
            local required=$(echo "$deliverable" | jq -r '.required')
            local description=$(echo "$deliverable" | jq -r '.description')

            if [[ "$required" == "true" ]]; then
                ((total_required++))

                # Check if deliverable pattern matches existing files
                local found_files=()
                while IFS= read -r -d '' file; do
                    found_files+=("$file")
                done < <(find . -name "$pattern" -type f -print0 2>/dev/null)
                local deliverable_complete="false"

                if [[ ${#found_files[@]} -gt 0 ]]; then
                    for file in "${found_files[@]}"; do
                        if [[ $(check_deliverable "$file") == "true" ]]; then
                            deliverable_complete="true"
                            break
                        fi
                    done
                fi

                if [[ "$deliverable_complete" == "true" ]]; then
                    ((completed_required++))
                    completion_details+="- ✅ $description\n"
                else
                    completion_details+="- 📋 $description (pending)\n"
                fi
            fi
        done < <(jq -c '.deliverables[]' "$deliverables_file")
    else
        # Fallback manual parsing for common patterns
        local patterns=(
            "src/components/*.{vue,astro,tsx,jsx}"
            "src/pages/*.{astro,tsx}"
            "tests/**/*.test.{js,ts}"
            "src/services/*.{js,ts}"
            "src/middleware/*.{js,ts}"
        )

        total_required=${#patterns[@]}

        for pattern in "${patterns[@]}"; do
            local files=()
            while IFS= read -r -d '' file; do
                files+=("$file")
            done < <(find . -name "$pattern" -type f -print0 2>/dev/null)
            if [[ ${#files[@]} -gt 0 ]]; then
                for file in "${files[@]}"; do
                    if [[ $(check_deliverable "$file") == "true" ]]; then
                        ((completed_required++))
                        completion_details+="- ✅ $file\n"
                        break
                    fi
                done
            else
                completion_details+="- 📋 $pattern (pending)\n"
            fi
        done
    fi

    # Calculate percentage
    local completion_percent=0
    if [[ $total_required -gt 0 ]]; then
        completion_percent=$((completed_required * 100 / total_required))
    fi

    # Store completion details for GitHub sync
    echo -e "$completion_details" > "$epic_dir/completion-details.md"

    echo "$completion_percent"
}

# Update GitHub issue with progress
update_github_issue() {
    local epic_name="$1"
    local completion_percent="$2"
    local epic_dir="$EPICS_DIR/$epic_name"
    local deliverables_file="$epic_dir/deliverables.json"

    # Get GitHub issue number from deliverables config
    local issue_number=""
    if command -v jq &> /dev/null && [[ -f "$deliverables_file" ]]; then
        issue_number=$(jq -r '.github_issue // empty' "$deliverables_file")
    fi

    if [[ -z "$issue_number" || "$issue_number" == "null" ]]; then
        log "No GitHub issue configured for epic: $epic_name"
        return
    fi

    # Generate progress comment
    local completion_details=""
    if [[ -f "$epic_dir/completion-details.md" ]]; then
        completion_details=$(cat "$epic_dir/completion-details.md")
    fi

    local comment_body="## Epic Progress Update

**Progress**: ${completion_percent}% complete
**Last Updated**: $(date)
**Branch**: $(git rev-parse --abbrev-ref HEAD)

### Deliverable Status
${completion_details}

### Quality Status
$(get_quality_status)

### Next Steps
$(get_next_steps "$completion_percent")

_Auto-updated by CCPM system_"

    # Post GitHub comment using gh CLI
    if command -v gh &> /dev/null; then
        log "Updating GitHub issue #$issue_number (${completion_percent}% complete)"
        gh issue comment "$issue_number" --body "$comment_body" || {
            error "Failed to update GitHub issue #$issue_number"
        }

        # Close issue if 100% complete AND quality gates pass
        if [[ "$completion_percent" -eq 100 ]]; then
            if quality_gates_pass; then
                gh issue close "$issue_number" --comment "🎉 Epic completed! All deliverables implemented and quality gates passed." || {
                    error "Failed to close GitHub issue #$issue_number"
                }
            else
                log "Epic $epic_name at 100% but quality gates failing - keeping issue open"
                gh issue comment "$issue_number" --body "⚠️ **Epic at 100% but quality gates failing**

All deliverables are complete but quality validation failed. Issue remains open until quality gates pass.

$(get_quality_status)

Fix the failing quality checks and commit again to re-trigger validation." || {
                    error "Failed to add quality gate warning to GitHub issue #$issue_number"
                }
            fi
        fi
    else
        log "GitHub CLI not available, skipping issue update"
    fi
}

# Get quality status for GitHub comment (container-aware)
get_quality_status() {
    local status=""

    # Use container-exec script if available, fallback to direct execution
    local exec_cmd=""
    if [[ -f ".claude/scripts/container-exec.sh" ]]; then
        exec_cmd=".claude/scripts/container-exec.sh exec"
    fi

    # Check lint
    if [[ -n "$exec_cmd" ]]; then
        if $exec_cmd "npm run lint" &> /dev/null; then
            status+="- 🟢 Lint: Passing\n"
        else
            status+="- 🔴 Lint: Issues found\n"
        fi
    elif npm run lint --silent &> /dev/null; then
        status+="- 🟢 Lint: Passing\n"
    else
        status+="- 🔴 Lint: Issues found\n"
    fi

    # Check TypeScript
    if [[ -n "$exec_cmd" ]]; then
        if $exec_cmd "npm run typecheck" &> /dev/null; then
            status+="- 🟢 TypeScript: No errors\n"
        else
            status+="- 🔴 TypeScript: Errors found\n"
        fi
    elif npm run typecheck --silent &> /dev/null; then
        status+="- 🟢 TypeScript: No errors\n"
    else
        status+="- 🔴 TypeScript: Errors found\n"
    fi

    # Check tests
    if [[ -n "$exec_cmd" ]]; then
        if $exec_cmd "npm test" &> /dev/null; then
            status+="- 🟢 Tests: Passing\n"
        else
            status+="- 🔴 Tests: Failing\n"
        fi
    elif npm test --silent &> /dev/null; then
        status+="- 🟢 Tests: Passing\n"
    else
        status+="- 🔴 Tests: Failing\n"
    fi

    # Check build
    if [[ -n "$exec_cmd" ]]; then
        if $exec_cmd "npm run build" &> /dev/null; then
            status+="- 🟢 Build: Successful\n"
        else
            status+="- 🔴 Build: Failed\n"
        fi
    elif npm run build --silent &> /dev/null; then
        status+="- 🟢 Build: Successful\n"
    else
        status+="- 🔴 Build: Failed\n"
    fi

    echo -e "$status"
}

# Check if all quality gates pass (returns 0 if all pass, 1 if any fail)
quality_gates_pass() {
    local exec_cmd=""
    if [[ -f ".claude/scripts/container-exec.sh" ]]; then
        exec_cmd=".claude/scripts/container-exec.sh exec"
    fi

    # Check lint
    if [[ -n "$exec_cmd" ]]; then
        $exec_cmd "npm run lint" &> /dev/null || return 1
    else
        npm run lint --silent &> /dev/null || return 1
    fi

    # Check TypeScript
    if [[ -n "$exec_cmd" ]]; then
        $exec_cmd "npm run typecheck" &> /dev/null || return 1
    else
        npm run typecheck --silent &> /dev/null || return 1
    fi

    # Check tests
    if [[ -n "$exec_cmd" ]]; then
        $exec_cmd "npm test" &> /dev/null || return 1
    else
        npm test --silent &> /dev/null || return 1
    fi

    # Check build
    if [[ -n "$exec_cmd" ]]; then
        $exec_cmd "npm run build" &> /dev/null || return 1
    else
        npm run build --silent &> /dev/null || return 1
    fi

    return 0
}

# Get next steps based on completion percentage
get_next_steps() {
    local completion_percent="$1"

    if [[ "$completion_percent" -eq 100 ]]; then
        echo "- 🎉 Epic complete! Auto-merge will trigger shortly"
    elif [[ "$completion_percent" -ge 80 ]]; then
        echo "- 🏁 Nearly complete! Finish remaining deliverables"
    elif [[ "$completion_percent" -ge 50 ]]; then
        echo "- 🚀 Good progress! Continue with remaining components"
    else
        echo "- 📋 Getting started! Implement core deliverables first"
    fi
}

# Create PR when epic is ready
create_pr_if_ready() {
    local epic_name="$1"
    local completion_percent="$2"
    local epic_dir="$EPICS_DIR/$epic_name"

    # Only create PR at 100% completion
    if [[ "$completion_percent" -ne 100 ]]; then
        return
    fi

    # Push branch to remote if not already there
    local branch=$(git rev-parse --abbrev-ref HEAD)
    log "Pushing branch $branch to remote"
    git push -u origin "$branch" 2>/dev/null || {
        log "Branch already exists on remote or push failed"
    }

    # Check if PR already exists
    if command -v gh &> /dev/null; then
        local existing_pr=$(gh pr list --head "$branch" --json number --jq '.[0].number // empty')
        if [[ -n "$existing_pr" ]]; then
            log "PR already exists for branch $branch: #$existing_pr"

            # Add auto-merge label if not present
            gh pr edit "$existing_pr" --add-label "auto-merge" || {
                error "Failed to add auto-merge label to PR #$existing_pr"
            }
            return
        fi
    else
        log "GitHub CLI not available, skipping PR creation"
        return
    fi

    # Generate PR description
    local pr_title="feat($epic_name): Complete $epic_name epic"
    local pr_body="## Epic Completion: $epic_name

### Deliverables ✅
$(cat "$epic_dir/completion-details.md" 2>/dev/null || echo "- All deliverables completed")

### Quality Status
$(get_quality_status)

### Testing
- ✅ Unit tests passing
- ✅ Integration tests passing
- ✅ Build successful
- ✅ Lint passing

This PR completes the $epic_name epic and is ready for auto-merge.

_Generated by CCPM auto-sync system_"

    # Create PR with auto-merge label
    log "Creating PR for completed epic: $epic_name"
    gh pr create \
        --title "$pr_title" \
        --body "$pr_body" \
        --label "auto-merge" \
        --base main \
        --head "$branch" || {
        error "Failed to create PR for epic: $epic_name"
    }
}

# Main auto-sync function
auto_sync() {
    local epic_name=$(get_current_epic)

    if [[ -z "$epic_name" ]]; then
        log "Not on an epic branch, skipping auto-sync"
        return
    fi

    local epic_dir="$EPICS_DIR/$epic_name"

    if [[ ! -d "$epic_dir" ]]; then
        log "Epic directory not found: $epic_dir"
        return
    fi

    log "Auto-sync triggered for epic: $epic_name"

    # Sync local changes to remote branch
    local branch=$(git rev-parse --abbrev-ref HEAD)
    log "Syncing branch $branch to remote"
    git push -u origin "$branch" 2>/dev/null || {
        log "Failed to push or branch already up to date"
    }

    # Calculate completion
    local completion_percent=$(calculate_completion "$epic_name")
    log "Epic $epic_name completion: ${completion_percent}%"

    # Update GitHub issue
    update_github_issue "$epic_name" "$completion_percent"

    # Create PR if ready
    create_pr_if_ready "$epic_name" "$completion_percent"

    # Store completion in Supermemory if available
    if command -v mcp__api-supermemory-ai__addMemory &> /dev/null; then
        local memory_content="Epic $epic_name progress: ${completion_percent}% complete at $(date)"
        mcp__api-supermemory-ai__addMemory "$memory_content" || {
            log "Failed to update Supermemory"
        }
    fi

    log "Auto-sync complete for epic: $epic_name"
}

# Load configuration
load_config

# Command line interface
case "${1:-auto-sync}" in
    "auto-sync")
        auto_sync
        ;;
    "completion")
        epic_name="${2:-$(get_current_epic)}"
        if [[ -n "$epic_name" ]]; then
            calculate_completion "$epic_name"
        else
            echo "0"
        fi
        ;;
    "github-sync")
        epic_name="${2:-$(get_current_epic)}"
        completion_percent="${3:-$(calculate_completion "$epic_name")}"
        if [[ -n "$epic_name" ]]; then
            update_github_issue "$epic_name" "$completion_percent"
        fi
        ;;
    "create-pr")
        epic_name="${2:-$(get_current_epic)}"
        completion_percent="${3:-$(calculate_completion "$epic_name")}"
        if [[ -n "$epic_name" ]]; then
            create_pr_if_ready "$epic_name" "$completion_percent"
        fi
        ;;
    *)
        echo "Usage: $0 [auto-sync|completion|github-sync|create-pr] [epic-name] [completion-percent]"
        exit 1
        ;;
esac