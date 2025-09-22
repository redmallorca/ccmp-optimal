# Tech Stack and Architecture

## Core Technology Stack
- **Shell Scripts** (Bash) - Core automation engine
- **Git** - Version control and automation triggers
- **GitHub Actions** - CI/CD pipeline with progressive quality gates
- **GitHub CLI** (`gh`) - GitHub API integration
- **Docker** - Development environment (when available)

## System Architecture

### 5 Core Rules (Not 38 Commands)
```
.claude/rules/
├── auto-sync.md        # Zero-command automation
├── ci-integration.md   # GitHub Actions CI/CD
├── git-workflow.md     # Standard branches + PR automation
├── memory-sync.md      # Supermemory integration
└── quality-gates.md    # Progressive validation
```

### 6 Simplified Agents
```
.claude/agents/
├── project-manager.md     # Epic coordination
├── simple-tester.md       # Streamlined testing
├── code-analyzer.md       # Bug tracing with Serena
├── frontend-specialist.md # Modern frontend patterns
├── backend-specialist.md  # API and service architecture
└── security-specialist.md # Security review and auditing
```

### 5 Core Commands
```
.claude/commands/
├── new.md      # /pm:new - Create epic (only manual command)
├── start.md    # /pm:start - Load context for existing epic
├── status.md   # /pm:status - Check progress
├── sync.md     # /pm:sync - Force GitHub sync if needed
└── close.md    # /pm:close - Archive completed epic
```

### Auto-Sync Engine
```
.claude/scripts/
├── auto-sync-engine.sh    # Core automation logic
├── hooks/
│   ├── post-commit        # Trigger after each commit
│   └── pre-push          # Final sync before push
└── install-hooks.sh      # Setup automation
```

## Tool Integration
- **Supermemory**: Context + decisions auto-sync
- **Serena**: Code analysis (`find_symbol`, `search_for_pattern`)
- **Zen**: Complex decisions + quality review
- **MorphLLM**: Multi-model consensus for architecture
- **OpenMemory**: Session context preservation