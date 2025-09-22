#!/bin/bash
#
# Install Git Hooks - Set up CCPM auto-sync automation
# Run this script to enable zero-command automation
#

set -euo pipefail

# Get the directory of the git repository
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
GIT_HOOKS_DIR="$REPO_ROOT/.git/hooks"
CCPM_HOOKS_DIR="$REPO_ROOT/.claude/scripts/hooks"

echo "🔧 Installing CCPM git hooks for zero-command automation..."

# Ensure hooks directory exists
mkdir -p "$GIT_HOOKS_DIR"
mkdir -p "$CCPM_HOOKS_DIR"

# Create logs directory
mkdir -p "$REPO_ROOT/.claude/logs"

# Install post-commit hook
if [[ -f "$CCPM_HOOKS_DIR/post-commit" ]]; then
    echo "📝 Installing post-commit hook..."
    cp "$CCPM_HOOKS_DIR/post-commit" "$GIT_HOOKS_DIR/post-commit"
    chmod +x "$GIT_HOOKS_DIR/post-commit"
    echo "   ✅ Post-commit hook installed"
else
    echo "   ⚠️  Post-commit hook not found in $CCPM_HOOKS_DIR"
fi

# Install pre-push hook
if [[ -f "$CCPM_HOOKS_DIR/pre-push" ]]; then
    echo "🚀 Installing pre-push hook..."
    cp "$CCPM_HOOKS_DIR/pre-push" "$GIT_HOOKS_DIR/pre-push"
    chmod +x "$GIT_HOOKS_DIR/pre-push"
    echo "   ✅ Pre-push hook installed"
else
    echo "   ⚠️  Pre-push hook not found in $CCPM_HOOKS_DIR"
fi

# Make auto-sync engine executable
AUTO_SYNC_ENGINE="$REPO_ROOT/.claude/scripts/auto-sync-engine.sh"
if [[ -f "$AUTO_SYNC_ENGINE" ]]; then
    chmod +x "$AUTO_SYNC_ENGINE"
    echo "🤖 Auto-sync engine ready"
else
    echo "   ⚠️  Auto-sync engine not found: $AUTO_SYNC_ENGINE"
fi

# Test GitHub CLI availability
if command -v gh &> /dev/null; then
    echo "✅ GitHub CLI (gh) available"

    # Test GitHub authentication
    if gh auth status &> /dev/null; then
        echo "✅ GitHub authentication configured"
    else
        echo "⚠️  GitHub authentication needed. Run: gh auth login"
    fi
else
    echo "⚠️  GitHub CLI not installed. Auto-sync will work but GitHub integration disabled."
    echo "   Install with: brew install gh (macOS) or see https://cli.github.com/"
fi

# Test jq availability for JSON parsing
if command -v jq &> /dev/null; then
    echo "✅ jq available for JSON parsing"
else
    echo "⚠️  jq not installed. Will use fallback parsing."
    echo "   Install with: brew install jq (macOS) or apt install jq (Ubuntu)"
fi

# Create initial config if not exists
CONFIG_FILE="$REPO_ROOT/.claude/config.json"
if [[ ! -f "$CONFIG_FILE" ]]; then
    echo "📄 Creating initial CCPM configuration..."
    cat > "$CONFIG_FILE" << 'EOF'
{
  "auto_sync": {
    "enabled": true,
    "github_integration": true,
    "supermemory_integration": true
  },
  "deliverables": {
    "patterns": [
      "src/components/*.{vue,astro,tsx,jsx}",
      "src/pages/*.{astro,tsx}",
      "src/services/*.{js,ts}",
      "tests/**/*.test.{js,ts}",
      "docs/*.md"
    ]
  },
  "quality_gates": {
    "lint": true,
    "typecheck": true,
    "test": true,
    "build": true
  },
  "github": {
    "auto_merge": true,
    "require_ci": true,
    "target_branch": "main"
  }
}
EOF
    echo "   ✅ Configuration created: $CONFIG_FILE"
fi

# Test a sample auto-sync run
echo "🧪 Testing auto-sync engine..."
if "$AUTO_SYNC_ENGINE" completion 2>/dev/null; then
    echo "✅ Auto-sync engine working correctly"
else
    echo "⚠️  Auto-sync engine test failed"
fi

echo ""
echo "🎉 CCPM auto-sync installation complete!"
echo ""
echo "📋 Next steps:"
echo "   1. Create an epic: /pm:new epic-name 'Epic description'"
echo "   2. Start coding - auto-sync will handle GitHub integration"
echo "   3. Commit changes - progress automatically tracked"
echo "   4. Push to remote - PR created automatically at 100%"
echo ""
echo "🔍 Monitor auto-sync: tail -f .claude/logs/auto-sync.log"
echo "🐞 Debug issues: .claude/scripts/auto-sync-engine.sh completion epic-name"
echo ""
echo "Zero-command automation is now active! 🚀"