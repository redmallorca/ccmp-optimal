#!/bin/bash

# ABOUTME: Epic status checker - implementation for status command
# Shows epic progress, deliverable status, and next actions

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
Epic Status - Implementation for status command

USAGE:
    status [epic-name]

EXAMPLES:
    status                    # Show all active epics
    status user-auth          # Show specific epic status

FEATURES:
    ✅ Progress calculation based on deliverables
    ✅ Quality gates status
    ✅ GitHub sync status
    ✅ Next actions guidance
EOF
}

# Calculate completion percentage
calculate_completion() {
    local epic_dir="$1"
    local deliverables_file="$epic_dir/deliverables.json"

    if [[ ! -f "$deliverables_file" ]]; then
        echo "0"
        return
    fi

    local total_deliverables=$(jq -r '.deliverables | length' "$deliverables_file" 2>/dev/null || echo "0")
    if [[ "$total_deliverables" -eq 0 ]]; then
        echo "0"
        return
    fi

    local completed=0
    while IFS= read -r pattern; do
        if [[ -f "$PROJECT_ROOT/$pattern" && -s "$PROJECT_ROOT/$pattern" ]]; then
            ((completed++))
        fi
    done < <(jq -r '.deliverables[].pattern' "$deliverables_file" 2>/dev/null || echo "")

    local percentage=$((completed * 100 / total_deliverables))
    echo "$percentage"
}

# Show single epic status
show_epic_status() {
    local epic_name="$1"
    local epic_dir="$EPICS_DIR/$epic_name"

    if [[ ! -d "$epic_dir" ]]; then
        echo -e "${RED}Epic '$epic_name' not found${NC}" >&2
        return 1
    fi

    local deliverables_file="$epic_dir/deliverables.json"
    local completion=$(calculate_completion "$epic_dir")
    local description=$(jq -r '.description // ("Epic: " + .epic)' "$deliverables_file" 2>/dev/null || echo "Epic: $epic_name")
    local github_issue=$(jq -r '.github_issue // "null"' "$deliverables_file" 2>/dev/null || echo "null")

    echo -e "${BLUE}## Epic Status: $epic_name${NC}"
    echo
    echo -e "${BLUE}📊 Progress:${NC} ${completion}% complete"
    echo -e "${BLUE}📝 Description:${NC} $description"

    if [[ "$github_issue" != "null" && "$github_issue" != "" ]]; then
        echo -e "${BLUE}🔗 GitHub Issue:${NC} #$github_issue"
    else
        echo -e "${YELLOW}⚠️  GitHub Issue:${NC} Not created"
    fi

    # Check git branch
    local current_branch=$(git branch --show-current 2>/dev/null || echo "unknown")
    local expected_branch="feature/epic-$epic_name"

    if [[ "$current_branch" == "$expected_branch" ]]; then
        echo -e "${GREEN}🌿 Branch:${NC} $current_branch (active)"
    else
        echo -e "${YELLOW}🌿 Branch:${NC} $expected_branch (not active, current: $current_branch)"
    fi

    echo
    echo -e "${BLUE}### Deliverable Status${NC}"
    echo

    # Show deliverables
    if [[ -f "$deliverables_file" ]]; then
        local completed_count=0
        local total_count=0

        while IFS= read -r deliverable; do
            local pattern=$(echo "$deliverable" | jq -r '.pattern')
            local required=$(echo "$deliverable" | jq -r '.required // false')
            local desc=$(echo "$deliverable" | jq -r '.description // ""')

            ((total_count++))

            if [[ -f "$PROJECT_ROOT/$pattern" && -s "$PROJECT_ROOT/$pattern" ]]; then
                ((completed_count++))
                echo -e "- ✅ $pattern ${GREEN}(completed)${NC}"
                if [[ -n "$desc" ]]; then
                    echo -e "     $desc"
                fi
            else
                local req_indicator=""
                if [[ "$required" == "true" ]]; then
                    req_indicator=" ${RED}(required)${NC}"
                else
                    req_indicator=" ${YELLOW}(optional)${NC}"
                fi
                echo -e "- 📋 $pattern ${YELLOW}(pending)${NC}$req_indicator"
                if [[ -n "$desc" ]]; then
                    echo -e "     $desc"
                fi
            fi
        done < <(jq -c '.deliverables[]' "$deliverables_file" 2>/dev/null || echo "")

        echo
        echo -e "${BLUE}📈 Summary:${NC} $completed_count/$total_count deliverables complete (${completion}%)"
    else
        echo -e "${YELLOW}No deliverables.json found${NC}"
    fi

    # Next actions
    echo
    echo -e "${BLUE}### Next Actions${NC}"
    if [[ "$completion" -eq 100 ]]; then
        echo -e "🎉 ${GREEN}Epic ready for completion!${NC}"
        echo -e "   Run: ${BLUE}close $epic_name${NC}"
    else
        echo -e "🎯 Complete remaining deliverables"
        if [[ "$github_issue" == "null" || "$github_issue" == "" ]]; then
            echo -e "⚠️  Create GitHub issue for tracking"
        fi
        if [[ "$current_branch" != "$expected_branch" ]]; then
            echo -e "🌿 Switch to epic branch: ${BLUE}git checkout $expected_branch${NC}"
        fi
    fi
}

# Show all epics overview
show_all_epics() {
    echo -e "${BLUE}## Active Epics Overview${NC}"
    echo

    if [[ ! -d "$EPICS_DIR" ]]; then
        echo -e "${YELLOW}No epics directory found${NC}"
        return 0
    fi

    local epic_count=0
    for epic_dir in "$EPICS_DIR"/*; do
        if [[ -d "$epic_dir" ]]; then
            local epic_name=$(basename "$epic_dir")
            local completion=$(calculate_completion "$epic_dir")
            local description=$(jq -r '.description // ("Epic: " + .epic)' "$epic_dir/deliverables.json" 2>/dev/null || echo "Epic: $epic_name")

            local status_color="$RED"
            if [[ "$completion" -ge 67 ]]; then
                status_color="$GREEN"
            elif [[ "$completion" -ge 34 ]]; then
                status_color="$YELLOW"
            fi

            echo -e "${status_color}### $epic_name (${completion}% complete)${NC}"
            echo -e "   $description"
            echo

            ((epic_count++))
        fi
    done

    if [[ "$epic_count" -eq 0 ]]; then
        echo -e "${YELLOW}No epics found${NC}"
        echo -e "Create one with: ${BLUE}new epic-name \"Description\"${NC}"
    else
        echo -e "${BLUE}Total active epics: $epic_count${NC}"
    fi
}

# Main function
main() {
    local epic_name="${1:-}"

    if [[ "$epic_name" == "--help" || "$epic_name" == "-h" ]]; then
        show_help
        exit 0
    fi

    if [[ -n "$epic_name" ]]; then
        show_epic_status "$epic_name"
    else
        show_all_epics
    fi
}

# Execute
main "$@"