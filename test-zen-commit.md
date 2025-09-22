# Test Zen Commit Integration

This file tests the zen commit integration with git hooks.

## Features Added

- Pre-commit hook with zen validation
- Configuration-driven validation triggers
- Critical file pattern detection
- Automatic validation for important commits

## Test Scenarios

1. Large commits (>3 files) trigger zen validation
2. Critical files (.claude/scripts/*, *.json, etc.) trigger validation
3. Simple commits skip validation

This should trigger zen validation since it's a .md file and we're modifying multiple files.