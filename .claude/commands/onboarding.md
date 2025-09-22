# /pm:onboarding - Project Context Initialization

**Usage**: `/pm:onboarding`

## Purpose

Provides comprehensive project context for new AI agent sessions, gathering all essential information about the current project state, configuration, and next steps.

## What It Does

### 1. Project Information Gathering
- **Project name** and technology stack from CLAUDE.md
- **Git status** (current branch, modified files, last commit)
- **GitHub integration** (open issues, PRs, sync status)
- **Development environment** (Docker, Node.js, npm availability)

### 2. CCPM System Status
- **Active specialists** configured for the project
- **Knowledge base** availability (documentation, memories)
- **Auto-sync engine** status and configuration
- **Quality gates** and CI/CD pipeline status

### 3. Context Restoration
- **Serena memories** count and recent entries
- **Supermemory integration** status
- **Recent commits** and development activity
- **Open epics** and their progress status

## Onboarding Report Format

### Project Overview
```markdown
📋 =============================================
🤖 CCPM PROJECT ONBOARDING
=============================================

📂 PROJECT: Your Project Name
🏗️ TECH STACK: Laravel TALL Stack / Astro + DaisyUI
📍 CURRENT BRANCH: main
📝 MODIFIED FILES: 5
💾 LAST COMMIT: 7c82f92 feat: Complete CCPM system
🐳 DOCKER: Available

🤖 ACTIVE SPECIALISTS:
✅ frontend-daisyui-specialist: Astro + DaisyUI + Alpine.js
✅ laravel-specialist: Laravel 11+ with DDD patterns
✅ devops-specialist: Docker deployment and CI/CD
✅ security-specialist: Security review and auditing
✅ project-manager: Epic coordination and tracking

🎯 OPEN ISSUES & EPICS:
Issue #67: PrimeVue Migration Epic (45% complete)
Issue #68: DaisyUI Implementation Epic (23% complete)
Issue #69: Security Audit Epic (12% complete)

📚 KNOWLEDGE BASE:
- Project configuration: ✅ Available (.claude/CLAUDE.md)
- Root instructions: ✅ Available (CLAUDE.md)
- Serena memories: 12 memories available
- Supermemory sync: ✅ Active

🚀 NEXT STEPS:
1. Choose an epic to work on:
   • Epic #67: PrimeVue Refactor (pending deliverables)
   • Epic #68: DaisyUI Implementation (active development)
   • Epic #69: Security Audit (planning phase)

2. Quick start options:
   ./.claude/scripts/start.sh 67     # Resume Epic #67
   ./.claude/scripts/start.sh 68     # Continue Epic #68
   /pm:new security-fixes "Security improvements"

📋 COMMANDS AVAILABLE:
/pm:status    - Check epic progress and repository health
/pm:new       - Create new epic with deliverables
/pm:start     - Load context for existing epic
/pm:sync      - Force GitHub synchronization
/pm:close     - Archive completed epic

=============================================
✅ ONBOARDING COMPLETE - Ready to code!
=============================================
```

### Development Environment Status
```bash
🔧 DEVELOPMENT ENVIRONMENT:
✅ Git repository: Initialized and healthy
✅ Docker: Available and running
✅ Node.js: v18.17.0 installed
✅ npm: 9.6.7 available
⚠️ GitHub CLI: Not authenticated (run: gh auth login)
✅ CCPM hooks: Installed and active

🏗️ PROJECT STRUCTURE:
├── 📁 .claude/          # CCPM system files
│   ├── commands/        # PM command definitions
│   ├── agents/          # Specialist agent configurations
│   └── scripts/         # Automation and utility scripts
├── 📁 .github/          # CI/CD workflows
├── 📁 .serena/          # Code analysis memories
└── 📄 CLAUDE.md         # Project instructions
```

### Memory Integration Status
```bash
🧠 MEMORY SYSTEMS:
📝 Serena Memories: 12 project memories
   - Architecture decisions (5)
   - Code patterns (4)
   - Development workflows (3)

💭 Supermemory Integration:
   - Auto-sync: ✅ Enabled
   - Last sync: 2 hours ago
   - Context preservation: Active

🔄 Session Continuity:
   - Previous session: Epic #68 (DaisyUI Implementation)
   - Context loaded: Development environment setup
   - Next action: Complete component migration
```

## Implementation Details

### Script Integration
The onboarding command executes the existing `.claude/scripts/onboarding.sh` script and formats the output for consistent command experience:

```bash
# Execute onboarding script
ONBOARDING_OUTPUT=$(./.claude/scripts/onboarding.sh 2>&1)

# Parse and format output
echo "📋 CCMP PROJECT ONBOARDING"
echo "=========================="
echo "$ONBOARDING_OUTPUT"
```

### Memory System Integration
- **Load Serena memories**: Recent project context and decisions
- **Check Supermemory**: Development history and architectural choices
- **Session restoration**: Continue previous work seamlessly

### Automation Status Check
- **Git hooks**: Verify post-commit and pre-push automation
- **GitHub sync**: Check last synchronization timestamp
- **CI/CD pipeline**: Review quality gates and auto-merge status

## Usage Examples

```bash
# Standard onboarding for new session
/pm:onboarding

# Quick context check (same as above)
/pm:onboarding

# Used automatically by other commands
/pm:start epic-name    # Includes onboarding context
```

## Integration with Other Commands

### Automatic Context Loading
- **`/pm:start`**: Includes onboarding information before epic context
- **`/pm:new`**: Shows current project status before epic creation
- **`/pm:status`**: References onboarding data for comprehensive reporting

### Memory Preservation
- **Logs completion**: Records onboarding timestamp in `.claude/.onboarding-log`
- **Updates context**: Refreshes Serena and Supermemory with current session
- **Tracks usage**: Maintains session continuity across conversations

**Perfect for starting new AI sessions with complete project context and clear next steps.**