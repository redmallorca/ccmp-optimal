#!/bin/bash
#
# Test GitHub Sync Functionality - Comprehensive test suite
# Tests github-sync.sh and inbox-manager.sh integration
#

set -euo pipefail

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"
CCPM_DIR="$PROJECT_ROOT/.claude"
GITHUB_SYNC="$CCPM_DIR/scripts/github-sync.sh"
INBOX_MANAGER="$CCPM_DIR/scripts/inbox-manager.sh"
TEST_INBOX_DIR="$CCPM_DIR/inbox-test"
TEST_ISSUES_FILE="$TEST_INBOX_DIR/external-issues.jsonl"

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Test results
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Logging
log_info() {
    echo -e "${BLUE}[INFO] $*${NC}"
}

log_success() {
    echo -e "${GREEN}[SUCCESS] $*${NC}"
}

log_error() {
    echo -e "${RED}[ERROR] $*${NC}"
}

log_warning() {
    echo -e "${YELLOW}[WARNING] $*${NC}"
}

# Test framework
test_start() {
    local test_name="$1"
    echo -e "\n${BLUE}🧪 Running test: $test_name${NC}"
    ((TESTS_RUN++))
}

test_pass() {
    local test_name="$1"
    log_success "✅ PASS: $test_name"
    ((TESTS_PASSED++))
}

test_fail() {
    local test_name="$1"
    local error_msg="$2"
    log_error "❌ FAIL: $test_name - $error_msg"
    ((TESTS_FAILED++))
}

# Setup test environment
setup_test_env() {
    log_info "Setting up test environment..."

    # Create test inbox directory
    mkdir -p "$TEST_INBOX_DIR"

    # Backup original inbox if it exists
    if [[ -d "$CCPM_DIR/inbox" ]]; then
        cp -r "$CCPM_DIR/inbox" "$CCPM_DIR/inbox-backup-$(date +%s)" 2>/dev/null || true
    fi

    # Temporarily replace inbox with test inbox
    export INBOX_DIR="$TEST_INBOX_DIR"

    log_success "Test environment ready"
}

# Cleanup test environment
cleanup_test_env() {
    log_info "Cleaning up test environment..."

    # Remove test inbox
    rm -rf "$TEST_INBOX_DIR" 2>/dev/null || true

    # Restore original inbox from backup if it exists
    local backup_dir=$(ls -1d "$CCPM_DIR/inbox-backup-"* 2>/dev/null | tail -1 || echo "")
    if [[ -n "$backup_dir" ]] && [[ -d "$backup_dir" ]]; then
        rm -rf "$CCPM_DIR/inbox" 2>/dev/null || true
        mv "$backup_dir" "$CCPM_DIR/inbox" 2>/dev/null || true
    fi

    log_success "Cleanup complete"
}

# Test script existence and permissions
test_script_existence() {
    test_start "Script existence and permissions"

    local errors=()

    # Check github-sync.sh
    if [[ ! -f "$GITHUB_SYNC" ]]; then
        errors+=("github-sync.sh not found at $GITHUB_SYNC")
    elif [[ ! -x "$GITHUB_SYNC" ]]; then
        errors+=("github-sync.sh is not executable")
    fi

    # Check inbox-manager.sh
    if [[ ! -f "$INBOX_MANAGER" ]]; then
        errors+=("inbox-manager.sh not found at $INBOX_MANAGER")
    elif [[ ! -x "$INBOX_MANAGER" ]]; then
        errors+=("inbox-manager.sh is not executable")
    fi

    if [[ ${#errors[@]} -eq 0 ]]; then
        test_pass "Script existence and permissions"
    else
        test_fail "Script existence and permissions" "${errors[*]}"
    fi
}

# Test github-sync.sh basic functionality
test_github_sync_basic() {
    test_start "GitHub sync basic functionality"

    # Test status command (should work without GitHub token)
    local output
    if output=$("$GITHUB_SYNC" status 2>&1); then
        if [[ "$output" =~ "Repository:" ]] && [[ "$output" =~ "Last sync:" ]]; then
            test_pass "GitHub sync basic functionality"
        else
            test_fail "GitHub sync basic functionality" "Unexpected status output: $output"
        fi
    else
        test_fail "GitHub sync basic functionality" "Status command failed: $output"
    fi
}

# Test inbox-manager.sh basic functionality
test_inbox_manager_basic() {
    test_start "Inbox manager basic functionality"

    # Test help command
    local output
    if output=$("$INBOX_MANAGER" help 2>&1); then
        if [[ "$output" =~ "Usage:" ]] && [[ "$output" =~ "Commands:" ]]; then
            test_pass "Inbox manager basic functionality"
        else
            test_fail "Inbox manager basic functionality" "Unexpected help output: $output"
        fi
    else
        test_fail "Inbox manager basic functionality" "Help command failed: $output"
    fi
}

# Test external issues JSON structure
test_external_issues_format() {
    test_start "External issues JSON format"

    # Create test external issues file
    cat > "$TEST_ISSUES_FILE" << 'EOF'
{"repository":"test/repo","number":1,"title":"Test Issue","url":"https://github.com/test/repo/issues/1","author":"external_user","created_at":"2025-09-23T20:00:00Z","updated_at":"2025-09-23T20:00:00Z","is_pull_request":false,"status":"pending","detected_at":"2025-09-23T20:01:00Z"}
{"repository":"test/repo","number":2,"title":"Test PR","url":"https://github.com/test/repo/pull/2","author":"contributor","created_at":"2025-09-23T19:30:00Z","updated_at":"2025-09-23T19:45:00Z","is_pull_request":true,"status":"pending","detected_at":"2025-09-23T20:01:00Z"}
EOF

    # Test if inbox manager can parse the file
    local output
    if output=$(INBOX_DIR="$TEST_INBOX_DIR" "$INBOX_MANAGER" stats 2>&1); then
        if [[ "$output" =~ "Total external issues: 2" ]] && [[ "$output" =~ "Pending review: 2" ]]; then
            test_pass "External issues JSON format"
        else
            test_fail "External issues JSON format" "Unexpected stats output: $output"
        fi
    else
        test_fail "External issues JSON format" "Stats command failed: $output"
    fi
}

# Test inbox manager show command
test_inbox_show_command() {
    test_start "Inbox manager show command"

    # Use the test file created in previous test
    local output
    if output=$(INBOX_DIR="$TEST_INBOX_DIR" "$INBOX_MANAGER" show 1 2>&1); then
        if [[ "$output" =~ "Test Issue" ]] && [[ "$output" =~ "external_user" ]]; then
            test_pass "Inbox manager show command"
        else
            test_fail "Inbox manager show command" "Unexpected show output: $output"
        fi
    else
        test_fail "Inbox manager show command" "Show command failed: $output"
    fi
}

# Test repository detection
test_repository_detection() {
    test_start "Repository detection"

    # Test with current repository
    local repo_output
    if repo_output=$("$GITHUB_SYNC" status 2>&1); then
        local repo_line=$(echo "$repo_output" | grep "Repository:" || echo "")
        if [[ -n "$repo_line" ]] && [[ ! "$repo_line" =~ "Could not determine" ]]; then
            test_pass "Repository detection"
        else
            test_fail "Repository detection" "Could not detect repository: $repo_line"
        fi
    else
        test_fail "Repository detection" "Status command failed"
    fi
}

# Test error handling for missing issues
test_error_handling() {
    test_start "Error handling for missing issues"

    # Test show command with non-existent issue
    local output
    if output=$(INBOX_DIR="$TEST_INBOX_DIR" "$INBOX_MANAGER" show 999 2>&1); then
        if [[ "$output" =~ "not found" ]]; then
            test_pass "Error handling for missing issues"
        else
            test_fail "Error handling for missing issues" "Expected error message not found: $output"
        fi
    else
        # Command should fail with error code, which is expected
        if [[ "$output" =~ "not found" ]]; then
            test_pass "Error handling for missing issues"
        else
            test_fail "Error handling for missing issues" "Unexpected error output: $output"
        fi
    fi
}

# Test CLI argument validation
test_cli_validation() {
    test_start "CLI argument validation"

    local errors=0

    # Test invalid command for github-sync
    if "$GITHUB_SYNC" invalid-command >/dev/null 2>&1; then
        ((errors++))
        log_error "github-sync should fail with invalid command"
    fi

    # Test invalid command for inbox-manager
    if "$INBOX_MANAGER" invalid-command >/dev/null 2>&1; then
        ((errors++))
        log_error "inbox-manager should fail with invalid command"
    fi

    # Test missing arguments for inbox-manager show
    if "$INBOX_MANAGER" show >/dev/null 2>&1; then
        ((errors++))
        log_error "inbox-manager show should require issue number"
    fi

    if [[ $errors -eq 0 ]]; then
        test_pass "CLI argument validation"
    else
        test_fail "CLI argument validation" "$errors validation errors"
    fi
}

# Test directory creation
test_directory_creation() {
    test_start "Directory creation"

    # Remove test directories if they exist
    rm -rf "$TEST_INBOX_DIR" 2>/dev/null || true

    # Run status command which should create directories
    if "$GITHUB_SYNC" status >/dev/null 2>&1; then
        if [[ -d "$CCPM_DIR/inbox" ]] && [[ -d "$CCPM_DIR/logs" ]]; then
            test_pass "Directory creation"
        else
            test_fail "Directory creation" "Required directories not created"
        fi
    else
        test_fail "Directory creation" "Status command failed"
    fi
}

# Run all tests
run_all_tests() {
    log_info "Starting GitHub Sync functionality tests..."
    echo "========================================"

    setup_test_env

    # Run tests
    test_script_existence
    test_github_sync_basic
    test_inbox_manager_basic
    test_external_issues_format
    test_inbox_show_command
    test_repository_detection
    test_error_handling
    test_cli_validation
    test_directory_creation

    cleanup_test_env

    # Results summary
    echo -e "\n========================================"
    echo -e "${BLUE}TEST RESULTS SUMMARY${NC}"
    echo "========================================"
    echo -e "📊 Tests run: $TESTS_RUN"
    echo -e "${GREEN}✅ Passed: $TESTS_PASSED${NC}"
    echo -e "${RED}❌ Failed: $TESTS_FAILED${NC}"

    if [[ $TESTS_FAILED -eq 0 ]]; then
        echo -e "\n${GREEN}🎉 All tests passed! GitHub sync functionality is working correctly.${NC}"
        return 0
    else
        echo -e "\n${RED}💥 Some tests failed. Please review and fix the issues above.${NC}"
        return 1
    fi
}

# Main execution
case "${1:-all}" in
    "all")
        run_all_tests
        ;;
    "setup")
        setup_test_env
        ;;
    "cleanup")
        cleanup_test_env
        ;;
    "help"|"-h"|"--help")
        echo "GitHub Sync Test Suite"
        echo ""
        echo "Usage: $0 [command]"
        echo ""
        echo "Commands:"
        echo "  all      - Run all tests (default)"
        echo "  setup    - Setup test environment only"
        echo "  cleanup  - Cleanup test environment only"
        echo "  help     - Show this help message"
        ;;
    *)
        log_error "Unknown command: $1"
        echo "Use '$0 help' for usage information"
        exit 1
        ;;
esac