#!/bin/bash

# ABOUTME: Epic creator with GitHub integration - implementation for new command
# Creates epics with proper GitHub issue creation and deliverables setup

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
EPICS_DIR="$PROJECT_ROOT/.claude/epics"

# Help function
show_help() {
    cat << EOF
Epic Creator - Implementation for /pm:new command

USAGE:
    $0 <epic-name> [description]

EXAMPLES:
    $0 user-auth
    $0 user-auth "Implement user authentication system"

FEATURES:
    ✅ Creates epic directory structure
    ✅ Creates GitHub issue automatically
    ✅ Links epic to GitHub issue
    ✅ Creates git branch
    ✅ Sets up deliverables.json template
    ✅ Enables auto-sync

NOTES:
    - Requires GitHub CLI (gh) to be authenticated
    - Auto-detects repository from git remote
    - Creates feature branch: feature/epic-<name>
EOF
}

# Validation functions
validate_epic_name() {
    local epic_name="$1"

    if [[ ! "$epic_name" =~ ^[a-z0-9-]+$ ]]; then
        echo -e "${RED}Error: Epic name must contain only lowercase letters, numbers, and hyphens${NC}" >&2
        return 1
    fi

    if [[ ${#epic_name} -lt 3 ]]; then
        echo -e "${RED}Error: Epic name must be at least 3 characters${NC}" >&2
        return 1
    fi

    if [[ -d "$EPICS_DIR/$epic_name" ]]; then
        echo -e "${RED}Error: Epic '$epic_name' already exists${NC}" >&2
        return 1
    fi
}

# Get repository info from git remote
get_repository_info() {
    local remote_url
    remote_url="$(git config --get remote.origin.url 2>/dev/null)" || {
        echo -e "${RED}Error: Not in a git repository or no origin remote configured${NC}" >&2
        return 1
    }

    # Extract owner/repo from various URL formats
    if [[ "$remote_url" =~ github\.com[:/]([^/]+)/([^/]+)(\.git)?$ ]]; then
        echo "${BASH_REMATCH[1]}/${BASH_REMATCH[2]%.git}"
    else
        echo -e "${RED}Error: Could not parse GitHub repository from remote URL: $remote_url${NC}" >&2
        return 1
    fi
}

# Check GitHub CLI authentication
check_github_auth() {
    if ! command -v gh >/dev/null 2>&1; then
        echo -e "${RED}Error: GitHub CLI (gh) is not installed${NC}" >&2
        echo "Install with: brew install gh" >&2
        return 1
    fi

    if ! gh auth status >/dev/null 2>&1; then
        echo -e "${RED}Error: GitHub CLI is not authenticated${NC}" >&2
        echo "Run: gh auth login" >&2
        return 1
    fi
}

# Create GitHub issue
create_github_issue() {
    local epic_name="$1"
    local description="$2"
    local repository="$3"

    echo -e "${BLUE}Creating GitHub issue...${NC}"

    local issue_title="Epic: $epic_name"
    local issue_body="## Epic: $epic_name

$description

**Status**: In Progress
**Auto-sync**: Enabled

## Deliverables
TBD - Will be updated automatically by auto-sync system

---
*This issue was created by manual-epic-creator.sh as a workaround for broken /pm:new command*"

    local issue_url
    issue_url="$(gh issue create \
        --title "$issue_title" \
        --body "$issue_body" \
        --label "epic" \
        --assignee "@me" \
        --repo "$repository")" || {
        echo -e "${RED}Error: Failed to create GitHub issue${NC}" >&2
        return 1
    }

    # Extract issue number from URL
    local issue_number
    issue_number="$(echo "$issue_url" | grep -o '[0-9]\+$')"

    echo -e "${GREEN}✅ Created GitHub issue #$issue_number${NC}"
    echo "$issue_number"
}

# Create epic directory structure
create_epic_structure() {
    local epic_name="$1"
    local description="$2"
    local repository="$3"
    local issue_number="$4"

    local epic_dir="$EPICS_DIR/$epic_name"

    echo -e "${BLUE}Creating epic directory structure...${NC}"

    # Create epic directory
    mkdir -p "$epic_dir"

    # Create deliverables.json
    cat > "$epic_dir/deliverables.json" << EOF
{
  "epic": "$epic_name",
  "description": "$description",
  "deliverables": [
    {
      "type": "investigation",
      "pattern": ".claude/epics/$epic_name/investigation.md",
      "required": false,
      "description": "Investigation and analysis phase"
    },
    {
      "type": "implementation",
      "pattern": ".claude/epics/$epic_name/implementation.md",
      "required": false,
      "description": "Implementation details and progress"
    },
    {
      "type": "documentation",
      "pattern": ".claude/epics/$epic_name/completion.md",
      "required": false,
      "description": "Completion summary and lessons learned"
    }
  ],
  "github_issue": $issue_number,
  "repository": "$repository",
  "auto_sync_enabled": true
}
EOF

    # Create basic README
    cat > "$epic_dir/README.md" << EOF
# Epic: $epic_name

$description

**GitHub Issue**: #$issue_number
**Status**: In Progress

## Overview
TBD

## Progress
- [ ] Investigation phase
- [ ] Implementation phase
- [ ] Documentation phase

---
*Created by manual-epic-creator.sh*
EOF

    echo -e "${GREEN}✅ Created epic directory structure${NC}"
}

# Create git branch
create_git_branch() {
    local epic_name="$1"
    local branch_name="feature/epic-$epic_name"

    echo -e "${BLUE}Creating git branch: $branch_name${NC}"

    # Ensure we're on main/master
    local main_branch
    if git show-ref --verify --quiet refs/heads/main; then
        main_branch="main"
    elif git show-ref --verify --quiet refs/heads/master; then
        main_branch="master"
    else
        echo -e "${RED}Error: Could not find main or master branch${NC}" >&2
        return 1
    fi

    git checkout "$main_branch" >/dev/null 2>&1
    git pull origin "$main_branch" >/dev/null 2>&1

    # Create and checkout new branch
    git checkout -b "$branch_name" >/dev/null 2>&1

    echo -e "${GREEN}✅ Created and switched to branch: $branch_name${NC}"
}

# Main function
main() {
    # Parse arguments
    if [[ $# -eq 0 ]] || [[ "$1" == "-h" ]] || [[ "$1" == "--help" ]]; then
        show_help
        exit 0
    fi

    local epic_name="$1"
    local description="${2:-Epic: $epic_name}"

    echo -e "${YELLOW}Epic Creator - CCPM /pm:new Implementation${NC}"
    echo

    # Validations
    validate_epic_name "$epic_name"
    check_github_auth

    # Get repository info
    local repository
    repository="$(get_repository_info)"
    echo -e "${BLUE}Repository: $repository${NC}"
    echo -e "${BLUE}Epic: $epic_name${NC}"
    echo -e "${BLUE}Description: $description${NC}"
    echo

    # Create GitHub issue
    local issue_number
    issue_number="$(create_github_issue "$epic_name" "$description" "$repository")"

    # Create epic structure
    create_epic_structure "$epic_name" "$description" "$repository" "$issue_number"

    # Create git branch
    create_git_branch "$epic_name"

    echo
    echo -e "${GREEN}🎉 Epic '$epic_name' created successfully!${NC}"
    echo
    echo -e "${BLUE}Next steps:${NC}"
    echo "1. Add specific deliverables to deliverables.json"
    echo "2. Start working on the epic"
    echo "3. Commit changes to trigger auto-sync"
    echo "4. Review GitHub issue: https://github.com/$repository/issues/$issue_number"
    echo
    echo -e "${YELLOW}Note: This is a temporary workaround. The /pm:new command needs to be fixed.${NC}"
}

# Run main function
main "$@"