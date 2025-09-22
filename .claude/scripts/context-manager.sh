#!/bin/bash
#
# CCPM Context Manager - Intelligent context loading for epics
# Prepares development environment and loads context for specific work
#

set -euo pipefail

# Configuration
PROJECT_ROOT="$(git rev-parse --show-toplevel)"
CLAUDE_DIR="$PROJECT_ROOT/.claude"
LOGS_DIR="$CLAUDE_DIR/logs"

# Logging
log() {
    echo "🧠 [CONTEXT] $*"
}

error() {
    echo "❌ [ERROR] $*" >&2
    exit 1
}

# Ensure logs directory exists
mkdir -p "$LOGS_DIR"

# Usage info
show_usage() {
    echo "Usage: $0 [epic-number|auto]"
    echo ""
    echo "Examples:"
    echo "  $0 67          # Load context for Epic #67"
    echo "  $0 auto        # Auto-detect epic from current branch"
    echo ""
    exit 1
}

# Parse epic number from branch name
parse_epic_from_branch() {
    local branch="$1"
    local epic_number=""

    # Match patterns: epic/67-*, feature/epic-67-*, etc.
    if [[ "$branch" =~ epic/([0-9]+) ]]; then
        epic_number="${BASH_REMATCH[1]}"
    elif [[ "$branch" =~ epic-([0-9]+) ]]; then
        epic_number="${BASH_REMATCH[1]}"
    fi

    echo "$epic_number"
}

# Load project context from Supermemory
load_project_context() {
    local epic_number="$1"

    log "Loading project context for Epic #$epic_number..."

    # Search for epic-specific context
    local epic_context=""
    if command -v mcp__api-supermemory-ai__search &> /dev/null; then
        epic_context=$(mcp__api-supermemory-ai__search "bikefort epic-$epic_number context decisions architecture" 2>/dev/null || true)
        if [[ -n "$epic_context" ]]; then
            log "✅ Epic-specific context loaded from Supermemory"
        else
            log "ℹ️ No specific context found for Epic #$epic_number"
        fi
    else
        log "⚠️ Supermemory not available, continuing without context"
    fi

    # Search for general project context
    if command -v mcp__api-supermemory-ai__search &> /dev/null; then
        local project_context=$(mcp__api-supermemory-ai__search "bikefort architecture patterns decisions" 2>/dev/null || true)
        if [[ -n "$project_context" ]]; then
            log "✅ General project context loaded"
        fi
    fi
}

# Determine specialist for epic
get_epic_specialist() {
    local epic_number="$1"

    case "$epic_number" in
        67)
            echo "frontend-primevue-specialist"
            ;;
        68)
            echo "frontend-daisyui-specialist"
            ;;
        *)
            # Default to DaisyUI since it's the main Bikefort stack
            echo "frontend-daisyui-specialist"
            ;;
    esac
}

# Get epic information
get_epic_info() {
    local epic_number="$1"

    case "$epic_number" in
        67)
            echo "PrimeVue Refactor - Transform Bikefort to Vue 3 + PrimeVue SPA"
            ;;
        68)
            echo "DaisyUI Refactor - Enhance Bikefort with DaisyUI v5 + Advanced Alpine.js"
            ;;
        *)
            echo "Epic #$epic_number"
            ;;
    esac
}

# Prepare development tools
prepare_tools() {
    local epic_number="$1"
    local specialist="$2"

    log "Preparing development tools for $specialist..."

    # Prepare Serena tools for epic-specific files
    if command -v mcp__serena__search_for_pattern &> /dev/null; then
        case "$epic_number" in
            67)
                # PrimeVue: Search for Vue files
                log "🔍 Analyzing Vue components with Serena..."
                mcp__serena__search_for_pattern --substring_pattern="\.vue$" --relative_path="src" 2>/dev/null || true
                ;;
            68)
                # DaisyUI: Search for Astro components
                log "🔍 Analyzing Astro components with Serena..."
                mcp__serena__search_for_pattern --substring_pattern="\.astro$" --relative_path="src" 2>/dev/null || true
                ;;
        esac
    fi

    # Check if Context7 is available for documentation
    if command -v mcp__context7__resolve-library-id &> /dev/null; then
        case "$epic_number" in
            67)
                log "📚 Preparing PrimeVue documentation access..."
                ;;
            68)
                log "📚 Preparing DaisyUI documentation access..."
                ;;
        esac
    fi
}

# Check and setup development environment
setup_environment() {
    local epic_number="$1"

    log "Setting up development environment..."

    # Check if dev server is running
    if ! curl -s http://localhost:4321 &> /dev/null; then
        log "🚀 Starting development server..."
        # Check if npm run dev is already running in background
        if ! pgrep -f "npm run dev" &> /dev/null; then
            log "ℹ️ Development server not running. Start it with: npm run dev"
        fi
    else
        log "✅ Development server is running"
    fi

    # Check Docker services
    if command -v docker &> /dev/null && docker info &> /dev/null; then
        log "✅ Docker is available"
    else
        log "ℹ️ Docker not available or not running"
    fi

    # Ensure we're in the right directory
    cd "$PROJECT_ROOT"
}

# Switch to epic branch
switch_to_epic_branch() {
    local epic_number="$1"
    local branch_name="epic/${epic_number}-$(echo "$(get_epic_info "$epic_number")" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g' | sed 's/--*/-/g' | sed 's/^-\|-$//g')"

    # Simplify branch name for readability
    case "$epic_number" in
        67) branch_name="epic/67-primevue-refactor" ;;
        68) branch_name="epic/68-daisyui-refactor" ;;
    esac

    local current_branch=$(git rev-parse --abbrev-ref HEAD)

    if [[ "$current_branch" == "$branch_name" ]]; then
        log "✅ Already on branch: $branch_name"
    else
        log "🌿 Switching to branch: $branch_name"

        # Check if branch exists
        if git show-ref --verify --quiet "refs/heads/$branch_name"; then
            git checkout "$branch_name"
        else
            log "📝 Creating new branch: $branch_name"
            git checkout -b "$branch_name"
        fi

        log "✅ Switched to branch: $branch_name"
    fi
}

# Save context state for session persistence
save_context_state() {
    local epic_number="$1"
    local specialist="$2"
    local branch_name="$3"

    local state_file="$LOGS_DIR/context-state.json"

    cat > "$state_file" << EOF
{
    "last_updated": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
    "epic_number": "$epic_number",
    "specialist": "$specialist",
    "branch": "$branch_name",
    "project_root": "$PROJECT_ROOT"
}
EOF

    log "💾 Context state saved"
}

# Load context for epic
load_epic_context() {
    local epic_number="$1"

    if [[ -z "$epic_number" ]]; then
        error "Epic number is required"
    fi

    local epic_info=$(get_epic_info "$epic_number")
    local specialist=$(get_epic_specialist "$epic_number")

    log "🎯 Activating context for Epic #$epic_number"
    log "📋 $epic_info"
    log "🤖 Specialist: $specialist"

    # Load context from memory systems
    load_project_context "$epic_number"

    # Prepare development tools
    prepare_tools "$epic_number" "$specialist"

    # Setup environment
    setup_environment "$epic_number"

    # Switch to epic branch
    switch_to_epic_branch "$epic_number"

    local current_branch=$(git rev-parse --abbrev-ref HEAD)

    # Save context state
    save_context_state "$epic_number" "$specialist" "$current_branch"

    echo ""
    echo "🎉 ============================================="
    echo "✅ CONTEXT ACTIVATED FOR EPIC #$epic_number"
    echo "============================================="
    echo ""
    echo "📂 PROJECT: BIKEFORT - Astro + Alpine.js"
    echo "🎯 EPIC: $epic_info"
    echo "🤖 SPECIALIST: $specialist"
    echo "🌿 BRANCH: $current_branch"
    echo "📍 READY TO CODE!"
    echo ""
    echo "🚀 NEXT STEPS:"
    echo "   • Start implementing features for this epic"
    echo "   • Use git commit -m \"feat(epic-$epic_number): description\""
    echo "   • Auto-sync will update GitHub Issue #$epic_number"
    echo ""
    echo "============================================="
}

# Auto-detect epic from current branch
auto_detect_epic() {
    local current_branch=$(git rev-parse --abbrev-ref HEAD)
    local epic_number=$(parse_epic_from_branch "$current_branch")

    if [[ -n "$epic_number" ]]; then
        log "🔍 Auto-detected Epic #$epic_number from branch: $current_branch"
        load_epic_context "$epic_number"
    else
        error "Could not detect epic number from branch: $current_branch"
    fi
}

# Main function
main() {
    if [[ $# -eq 0 ]]; then
        show_usage
    fi

    local command="$1"

    case "$command" in
        auto)
            auto_detect_epic
            ;;
        [0-9]*)
            load_epic_context "$command"
            ;;
        -h|--help)
            show_usage
            ;;
        *)
            error "Invalid command: $command"
            ;;
    esac
}

# Execute
main "$@"