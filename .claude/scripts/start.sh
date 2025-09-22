#!/bin/bash
#
# CCPM Start - Direct epic activation for experienced agents
# Quickly activates context and starts work on specific epic
#

set -euo pipefail

# Configuration
PROJECT_ROOT="$(git rev-parse --show-toplevel)"
CLAUDE_DIR="$PROJECT_ROOT/.claude"
CONTEXT_MANAGER="$CLAUDE_DIR/scripts/context-manager.sh"

# Logging
log() {
    echo "🚀 [START] $*"
}

error() {
    echo "❌ [ERROR] $*" >&2
    exit 1
}

# Usage info
show_usage() {
    echo "Usage: $0 <epic-number>"
    echo ""
    echo "Quick start script for epic activation."
    echo ""
    echo "Examples:"
    echo "  $0 67          # Start Epic #67 (PrimeVue Refactor)"
    echo "  $0 68          # Start Epic #68 (DaisyUI Refactor)"
    echo ""
    echo "Available Epics:"
    echo "  67 - PrimeVue Refactor: Transform Bikefort to Vue 3 + PrimeVue SPA"
    echo "  68 - DaisyUI Refactor: Enhance Bikefort with DaisyUI v5 + Advanced Alpine.js"
    echo ""
    exit 1
}

# Validate epic number
validate_epic() {
    local epic_number="$1"

    case "$epic_number" in
        67|68)
            return 0
            ;;
        *)
            error "Invalid epic number: $epic_number. Available: 67, 68"
            ;;
    esac
}

# Main function
main() {
    if [[ $# -eq 0 ]]; then
        show_usage
    fi

    local epic_number="$1"

    # Validate inputs
    if [[ ! "$epic_number" =~ ^[0-9]+$ ]]; then
        error "Epic number must be numeric: $epic_number"
    fi

    validate_epic "$epic_number"

    # Check if context manager exists
    if [[ ! -f "$CONTEXT_MANAGER" ]]; then
        error "Context manager not found: $CONTEXT_MANAGER"
    fi

    log "Starting Epic #$epic_number..."

    # Delegate to context manager
    "$CONTEXT_MANAGER" "$epic_number"

    log "Epic #$epic_number activated successfully!"
}

# Handle help flags
case "${1:-}" in
    -h|--help)
        show_usage
        ;;
esac

# Execute
main "$@"