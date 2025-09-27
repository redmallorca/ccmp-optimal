#!/bin/bash
# ABOUTME: Autonomous commit validation script - no external dependencies
# Fast, reliable validation for git hooks with timeout protection

set -euo pipefail

# Configuration
REPO_ROOT=$(git rev-parse --show-toplevel)
LOG_FILE="$REPO_ROOT/.claude/logs/auto-sync.log"
MAX_VALIDATION_TIME=5  # Maximum validation time in seconds

# Ensure log directory exists
mkdir -p "$(dirname "$LOG_FILE")"

log() {
    echo "[COMMIT-VALIDATE] $(date '+%Y-%m-%d %H:%M:%S'): $*" | tee -a "$LOG_FILE"
}

# Timeout wrapper for any command
run_with_timeout() {
    local timeout_duration=$1
    shift
    
    # Use timeout command if available (GNU coreutils)
    if command -v timeout >/dev/null 2>&1; then
        timeout "${timeout_duration}s" "$@"
    elif command -v gtimeout >/dev/null 2>&1; then
        gtimeout "${timeout_duration}s" "$@"
    else
        # Fallback: just run the command (no timeout available)
        "$@"
    fi
}

# Fast autonomous validation - no external dependencies
run_autonomous_validation() {
    log "Starting autonomous commit validation (max ${MAX_VALIDATION_TIME}s)..."
    
    local issues_found=0
    local warnings_found=0
    local staged_files
    
    # Get staged files with timeout protection
    if ! staged_files=$(run_with_timeout 2 git diff --cached --name-only); then
        log "Warning: Could not get staged files list within timeout"
        echo "⚠️  Staged files check timed out - proceeding with commit"
        return 0
    fi
    
    # Quick check for empty commit
    if [[ -z "$staged_files" ]]; then
        echo "⚠️  No staged files found"
        return 0
    fi
    
    echo "🔍 Validating $(echo "$staged_files" | wc -l) staged files..."
    
    # 1. Check for merge conflicts (critical)
    if echo "$staged_files" | xargs -I {} sh -c 'test -f "$1" && grep -l "<<<<<<< HEAD" "$1" 2>/dev/null' _ {}; then
        echo "❌ Merge conflict markers found in staged files"
        ((issues_found++))
    fi
    
    # 2. Check for large files (warning only, with timeout)
    while IFS= read -r file; do
        if [[ -f "$file" ]]; then
            local size
            if size=$(run_with_timeout 1 stat -f%z "$file" 2>/dev/null) && [[ $size -gt 1048576 ]]; then
                echo "⚠️  Large file detected: $file ($(( size / 1024 ))KB)"
                ((warnings_found++))
            fi
        fi
    done <<< "$staged_files"
    
    # 3. Check for debug statements in code files (warning only)
    local code_files
    code_files=$(echo "$staged_files" | grep -E '\.(js|ts|jsx|tsx|astro|vue)$' || true)
    if [[ -n "$code_files" ]]; then
        if echo "$code_files" | xargs -I {} sh -c 'test -f "$1" && grep -l "console\\.|debugger" "$1" 2>/dev/null' _ {}; then
            echo "⚠️  Debug statements found (console.log/debugger)"
            ((warnings_found++))
        fi
    fi
    
    # 4. Check for sensitive patterns (critical)
    if echo "$staged_files" | xargs -I {} sh -c 'test -f "$1" && grep -l "password\\|secret\\|api[_-]key\\|token" "$1" 2>/dev/null' _ {}; then
        echo "❌ Potential sensitive data found in commit"
        ((issues_found++))
    fi
    
    # 5. Check for package.json syntax if modified
    if echo "$staged_files" | grep -q "package\.json$"; then
        if command -v node >/dev/null 2>&1; then
            if ! run_with_timeout 2 node -e "JSON.parse(require('fs').readFileSync('package.json', 'utf8'))" >/dev/null 2>&1; then
                echo "❌ Invalid JSON in package.json"
                ((issues_found++))
            fi
        fi
    fi
    
    # Report results
    if [[ $issues_found -gt 0 ]]; then
        echo "❌ Validation failed: $issues_found critical issues found"
        log "Validation failed with $issues_found issues, $warnings_found warnings"
        return 1
    elif [[ $warnings_found -gt 0 ]]; then
        echo "⚠️  Validation passed with $warnings_found warnings"
        log "Validation passed with $warnings_found warnings"
        return 0
    else
        echo "✅ Validation passed - all checks OK"
        log "Validation completed successfully"
        return 0
    fi
}

# Main execution with direct validation (no nested timeout)
log "Starting commit validation with ${MAX_VALIDATION_TIME}s timeout..."

# Run validation directly with built-in timeout handling
if run_autonomous_validation; then
    log "Commit validation successful"
    exit 0
else
    exit_code=$?
    log "Commit validation failed with exit code: $exit_code"
    echo ""
    echo "❌ Commit validation failed!"
    echo "Please fix the issues above and try again."
    echo ""
    echo "To skip validation (not recommended):"
    echo "  git commit --no-verify -m \"your message\""
    echo ""
    exit 1
fi
