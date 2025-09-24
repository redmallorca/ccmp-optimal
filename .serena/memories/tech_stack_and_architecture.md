# CCPM Optimal - Tech Stack and Architecture

## Core Technology Stack
- **Shell Scripts (Bash)**: Primary automation engine
- **JSON Configuration**: `.claude/config.json` for system settings
- **GitHub CLI (gh)**: GitHub API integration
- **Git Hooks**: post-commit, pre-commit, pre-push automation
- **Markdown**: Documentation and rule definitions

## Architecture Components

### Scripts (`.claude/scripts/`)
```
├── auto-sync-engine.sh    # Core automation logic
├── install-hooks.sh       # Setup automation
├── new.sh                 # Epic creation
├── start.sh               # Context loading
├── status.sh              # Progress checking
├── sync.sh                # Manual GitHub sync
├── context-manager.sh     # Context management
├── github-sync.sh         # GitHub API integration
├── zen-commit-wrapper.sh  # Zen validation wrapper
├── container-exec.sh      # Docker container execution
└── hooks/
    ├── post-commit        # Trigger after each commit
    ├── pre-commit         # Zen validation
    └── pre-push          # Final sync before push
```

### Rules (`.claude/rules/`)
```
├── auto-sync.md        # Zero-command automation
├── ci-integration.md   # GitHub Actions CI/CD
├── git-workflow.md     # Standard branches + PR automation
├── memory-sync.md      # Supermemory integration
└── quality-gates.md    # Progressive validation
```

### Commands (`.claude/commands/`)
```
├── new.md      # /new - Create epic (only manual command)
├── start.md    # /start - Load context for existing epic
├── status.md   # /status - Check progress (no automation)
├── sync.md     # /sync - Force GitHub sync if needed
└── close.md    # /close - Archive completed epic
```

### Agents (`.claude/agents/`)
```
├── project-manager.md       # Epic coordination
├── simple-tester.md         # Streamlined testing
├── code-analyzer.md         # Bug tracing with Serena
├── devops-specialist.md     # Docker, CI/CD, deployment
├── security-specialist.md   # Security review
├── frontend-daisyui-specialist.md    # Astro + DaisyUI
├── frontend-primevue-specialist.md   # Vue 3 + PrimeVue
├── backend-specialist.md    # API and service architecture
└── laravel-specialist.md    # Laravel 11+ with DDD
```

## Expected Frontend Tech Stacks
Based on configuration and templates:
- **Node.js 20+** with npm/yarn/pnpm
- **TypeScript**: Quality gates expect `npm run typecheck`
- **Frontend Frameworks**: Astro, Vue 3, React (configurable)
- **CSS Frameworks**: DaisyUI, PrimeVue, Tailwind
- **Build Tools**: Vite, Webpack, or framework-specific bundlers
- **Testing**: Playwright for E2E, Vitest/Jest for unit tests

## System Dependencies (macOS/Darwin)
- **git**: Version control and repository management
- **gh**: GitHub CLI for API integration  
- **jq**: JSON parsing in shell scripts
- **curl**: HTTP requests for API calls
- **bash**: Shell scripting environment
- **Docker** (optional): Container execution support

## Configuration System
- **`.claude/config.json`**: Central configuration
- **Epic deliverables**: JSON-based pattern matching
- **Quality gates**: Configurable lint/test/build steps
- **GitHub integration**: Auto-merge, target branches, CI requirements
- **Zen commit**: Validation rules and triggers