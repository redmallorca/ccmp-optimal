# Code Style and Conventions

## Shell Script Conventions
- **Bash scripts** use `#!/bin/bash` shebang
- **Error handling**: `set -euo pipefail` for strict error handling
- **Function naming**: snake_case for function names
- **Variables**: Use double quotes for variable expansion
- **Logging**: Consistent log/error functions with emoji prefixes

### Example Pattern
```bash
#!/bin/bash
set -euo pipefail

log() {
    echo "🤖 [SCRIPT] $*"
}

error() {
    echo "❌ [ERROR] $*" >&2
    exit 1
}
```

## Documentation Conventions
- **ABOUTME comments**: Start files with 2-line description
- **Markdown structure**: Clear headers, code blocks, examples
- **Emoji usage**: Consistent emoji prefixes for different types of content
- **Configuration examples**: Include JSON/YAML examples where relevant

## Git Commit Conventions
```bash
# Standard commit prefixes
feat: new features
fix: bug fixes  
refactor: code refactoring
style: formatting, no code change
docs: documentation changes
chore: maintenance tasks
test: adding/updating tests

# Examples
git commit -m "feat(auth): implement login component"
git commit -m "fix(sync): handle GitHub API rate limits"
git commit -m "docs(epic): update deliverable patterns"
```

## File Organization Principles
- **Evergreen naming**: No "improved", "new", "enhanced" in names
- **Purpose-based structure**: Group by function, not technology
- **Configuration separation**: Keep config files in predictable locations
- **Template patterns**: Consistent structure across similar files

## Quality Standards
- **Simple > Clever**: Readable code over abstractions
- **Fix root causes**: No workarounds or patches
- **Real data**: No mocks in testing, use actual data
- **Progressive validation**: Fast feedback, never blocking workflow

## Project Structure Conventions
```
.claude/                 # CCPM system files
├── agents/             # Specialist agent configurations
├── commands/           # PM command definitions  
├── scripts/            # Automation and utility scripts
├── rules/              # Core automation rules
└── templates/          # Project templates

.github/                # CI/CD workflows
└── workflows/          # GitHub Actions definitions

.serena/                # Code analysis memories (auto-generated)
```

## Integration Standards
- **GitHub CLI**: All GitHub integration via `gh` command
- **Docker**: Optional, graceful degradation if not available
- **Node.js/npm**: For frontend projects, check availability first
- **Git hooks**: Post-commit automation, non-intrusive