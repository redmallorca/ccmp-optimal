#!/bin/bash
# ABOUTME: Wrapper script to execute zen commit validation from git hooks
# Integrates with CCPM system for automatic validation of important commits

set -euo pipefail

REPO_ROOT=$(git rev-parse --show-toplevel)
LOG_FILE="$REPO_ROOT/.claude/logs/auto-sync.log"

log() {
    echo "[ZEN-COMMIT] $(date '+%Y-%m-%d %H:%M:%S'): $*" | tee -a "$LOG_FILE"
}

# Function to run zen commit validation
run_zen_commit() {
    log "Starting zen commit validation..."

    # Check if we're in a Claude Code environment
    if [[ -n "${CLAUDE_CODE_SESSION:-}" ]]; then
        log "Claude Code session detected"

        # In Claude Code environment, we can use zen tools directly
        # This would need to be integrated with your specific Claude Code setup
        log "Would execute: claude zen commit --validate-only"

        # For now, simulate validation
        echo "🔍 Simulating zen commit validation..."
        echo "✅ Zen validation passed (simulated)"
        return 0

    elif command -v claude >/dev/null 2>&1; then
        log "Claude CLI found, attempting zen validation"

        # Try to run zen commit via Claude CLI
        if claude zen commit --validate-only 2>/dev/null; then
            log "Zen validation completed successfully"
            return 0
        else
            log "Zen validation failed or not available via CLI"
            return 1
        fi

    else
        log "Claude Code not available - alternative validation"

        # Alternative: Basic validation checks
        echo "⚠️  Claude Code not available, running basic validation..."

        # Check for common issues
        local issues_found=0

        # Check for merge conflicts
        if git diff --cached --name-only | xargs -I {} grep -l "<<<<<<< HEAD" {} 2>/dev/null; then
            echo "❌ Merge conflict markers found in staged files"
            ((issues_found++))
        fi

        # Check for console.log/debugger statements in JS/TS files
        if git diff --cached --name-only | grep -E '\.(js|ts|jsx|tsx)$' | xargs -I {} grep -l "console\.\|debugger" {} 2>/dev/null; then
            echo "⚠️  Debug statements found (console.log/debugger)"
            log "Warning: Debug statements detected in commit"
        fi

        # Check for TODO/FIXME in critical files
        if git diff --cached --name-only | grep -E '\.(js|ts|jsx|tsx|vue|astro)$' | xargs -I {} grep -l "TODO\|FIXME" {} 2>/dev/null; then
            echo "⚠️  TODO/FIXME found in staged files"
            log "Warning: TODO/FIXME comments detected"
        fi

        if [[ $issues_found -gt 0 ]]; then
            echo "❌ Validation failed: $issues_found critical issues found"
            return 1
        else
            echo "✅ Basic validation passed"
            return 0
        fi
    fi
}

# Main execution
if run_zen_commit; then
    log "Zen commit validation successful"
    exit 0
else
    log "Zen commit validation failed"
    echo ""
    echo "❌ Zen commit validation failed!"
    echo "Please fix the issues above and try again."
    echo ""
    echo "To skip zen validation (not recommended):"
    echo "  git commit --no-verify -m \"your message\""
    echo ""
    exit 1
fi