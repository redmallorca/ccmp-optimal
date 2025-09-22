# CCPM Optimal Project Overview

## Project Purpose
CCPM Optimal is a **Claude Code Project Management** system designed to provide zero-command automation for modern development workflows. It's a clean, simplified template that replaces the complex original CCPM system with streamlined automation.

### Core Philosophy
- **Zero commands after `/pm:new`** - Everything happens automatically through git workflow
- **Auto-sync automation** - Progress tracking, GitHub integration, PR creation, auto-merge
- **Simple > Complex** - 5 commands instead of 38, standard git workflow instead of worktrees
- **CI/CD native** - GitHub Actions with progressive quality gates

### Key Features
- **Epic Management**: File-based completion detection with automatic progress tracking
- **GitHub Integration**: Automatic issue creation, PR management, auto-merge when CI passes
- **Memory Sync**: Integration with Supermemory and Serena for context preservation
- **Progressive Quality Gates**: Fast feedback with non-blocking validation

### Project Type
This is a **project management system template** that can be copied to any development project to provide automated PM capabilities. It's not a specific application but rather a development workflow automation system.

### Current State
- Basic CCPM system implemented with onboarding command
- Git hooks for post-commit automation
- GitHub Actions CI/CD workflow configured
- Agent specialists configured for different technology stacks
- No package.json - this is a pure configuration/script system