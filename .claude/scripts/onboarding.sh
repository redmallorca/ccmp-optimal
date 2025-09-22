#!/bin/bash
#
# CCPM Onboarding Script
# Initialize new agent with complete project context
#

set -euo pipefail

# Configuration
PROJECT_ROOT="$(git rev-parse --show-toplevel)"
CLAUDE_DIR="$PROJECT_ROOT/.claude"
CLAUDE_CONFIG="$CLAUDE_DIR/CLAUDE.md"
ROOT_CONFIG="$PROJECT_ROOT/CLAUDE.md"

# Logging
log() {
    echo "🤖 [ONBOARDING] $*"
}

error() {
    echo "❌ [ERROR] $*" >&2
    exit 1
}

# Check if we're in a git repository
check_git_repo() {
    if ! git rev-parse --git-dir &> /dev/null; then
        error "Not in a git repository. Please run from project root."
    fi
}

# Read project configuration
get_project_info() {
    local project_name="Unknown"
    local tech_stack="Not specified"

    if [[ -f "$ROOT_CONFIG" ]]; then
        project_name=$(grep -m1 "^# " "$ROOT_CONFIG" | sed 's/^# //' | head -1 || echo "Unknown")
        tech_stack=$(grep -A1 "Stack:" "$ROOT_CONFIG" | tail -1 | sed 's/.*Stack\*\*: //' || echo "Not specified")
    fi

    echo "project_name:$project_name"
    echo "tech_stack:$tech_stack"
}

# Get active specialists
get_active_specialists() {
    if [[ -f "$CLAUDE_CONFIG" ]]; then
        grep "✅.*specialist" "$CLAUDE_CONFIG" | head -5 || echo "No specialists configured"
    else
        echo "No CCPM configuration found"
    fi
}

# Get git status
get_git_status() {
    local branch=$(git rev-parse --abbrev-ref HEAD)
    local status=$(git status --porcelain | wc -l | tr -d ' ')
    local last_commit=$(git log -1 --pretty=format:"%h %s" 2>/dev/null || echo "No commits")

    echo "branch:$branch"
    echo "modified_files:$status"
    echo "last_commit:$last_commit"
}

# Get GitHub issues
get_github_issues() {
    if command -v gh &> /dev/null; then
        local open_issues=$(gh issue list --state open --limit 10 --json number,title,labels 2>/dev/null || echo "[]")
        echo "open_issues:$open_issues"
    else
        echo "open_issues:GitHub CLI not available"
    fi
}

# Check development environment
check_dev_environment() {
    local docker_available="false"
    local node_available="false"
    local npm_available="false"

    if command -v docker &> /dev/null && docker info &> /dev/null; then
        docker_available="true"
    fi

    if command -v node &> /dev/null; then
        node_available="true"
    fi

    if command -v npm &> /dev/null; then
        npm_available="true"
    fi

    echo "docker:$docker_available"
    echo "node:$node_available"
    echo "npm:$npm_available"
}

# Check Serena memories
check_memories() {
    # This would integrate with Serena MCP when available
    # For now, check if .serena directory exists
    if [[ -d "$PROJECT_ROOT/.serena" ]]; then
        local memory_count=$(find "$PROJECT_ROOT/.serena" -name "*.md" | wc -l | tr -d ' ')
        echo "serena_memories:$memory_count"
    else
        echo "serena_memories:0"
    fi
}

# Main onboarding function
main_onboarding() {
    log "Starting CCPM onboarding..."

    # Basic checks
    check_git_repo

    # Gather information
    log "Gathering project information..."
    local project_info=$(get_project_info)
    local git_info=$(get_git_status)
    local github_info=$(get_github_issues)
    local dev_info=$(check_dev_environment)
    local memory_info=$(check_memories)

    # Parse information
    local project_name=$(echo "$project_info" | grep "project_name:" | cut -d: -f2-)
    local tech_stack=$(echo "$project_info" | grep "tech_stack:" | cut -d: -f2-)
    local branch=$(echo "$git_info" | grep "branch:" | cut -d: -f2-)
    local modified_files=$(echo "$git_info" | grep "modified_files:" | cut -d: -f2-)
    local last_commit=$(echo "$git_info" | grep "last_commit:" | cut -d: -f2-)
    local docker_status=$(echo "$dev_info" | grep "docker:" | cut -d: -f2-)

    # Display onboarding information
    echo ""
    echo "📋 ============================================="
    echo "🤖 CCMP PROJECT ONBOARDING"
    echo "============================================="
    echo ""
    echo "📂 PROJECT: $project_name"
    echo "🏗️ TECH STACK: $tech_stack"
    echo "📍 CURRENT BRANCH: $branch"
    echo "📝 MODIFIED FILES: $modified_files"
    echo "💾 LAST COMMIT: $last_commit"
    echo "🐳 DOCKER: $docker_status"
    echo ""
    echo "🤖 ACTIVE SPECIALISTS:"
    get_active_specialists
    echo ""
    echo "🎯 OPEN ISSUES & EPICS:"
    if command -v gh &> /dev/null; then
        gh issue list --state open --limit 5 | head -5 || echo "No open issues"
    else
        echo "GitHub CLI not available"
    fi
    echo ""
    echo "📚 KNOWLEDGE BASE:"
    echo "   - Project configuration: $([ -f "$CLAUDE_CONFIG" ] && echo "✅ Available" || echo "❌ Missing")"
    echo "   - Root instructions: $([ -f "$ROOT_CONFIG" ] && echo "✅ Available" || echo "❌ Missing")"
    echo "   - Serena memories: $(echo "$memory_info" | cut -d: -f2-) available"
    echo ""
    echo "🚀 NEXT STEPS:"
    echo "   1. Choose an epic or issue to work on"
    echo "   2. Review specialist documentation in .claude/agents/"
    echo "   3. Understand testing requirements"
    echo "   4. Begin implementation with TDD approach"
    echo ""
    echo "📋 COMMANDS AVAILABLE:"
    echo "   /pm:status  - View project status"
    echo "   /pm:new     - Create new epic"
    echo "   /pm:start   - Start working on issue"
    echo "   /pm:sync    - Sync with GitHub"
    echo ""
    echo "============================================="
    echo "✅ ONBOARDING COMPLETE"
    echo "============================================="

    # Store onboarding completion
    echo "$(date): Onboarding completed for agent" >> "$CLAUDE_DIR/.onboarding-log"

    log "Onboarding completed successfully!"
}

# Execute onboarding
main_onboarding "$@"