# CCPM Optimal - Project Overview

## Purpose
CCPM Optimal is a **Zero-Command Automation Template** for modern development workflows with GitHub integration. It's a project management system template that provides complete automation of development workflows after a single `/new` command.

## Core Philosophy
**"Zero commands after `/new`"** - Everything happens automatically through normal git workflows:
1. Developer runs `/new epic-name "description"` (once per epic)
2. Developer codes and commits normally
3. Developer pushes when ready
4. **System handles everything else automatically**

## What CCPM Does Automatically
- ✅ **Progress Tracking**: File-based completion detection
- ✅ **GitHub Sync**: Issue updates, PR creation, auto-merge
- ✅ **Quality Gates**: Progressive validation without blocking workflow
- ✅ **Memory Sync**: Context preservation in Supermemory/OpenMemory
- ✅ **CI/CD Integration**: GitHub Actions with simplified testing

## Key Features
- **Template System**: Copy-paste to any project
- **Git Hook Automation**: post-commit, pre-commit, pre-push hooks
- **Epic-Based Workflow**: Feature branches with automatic tracking
- **GitHub Integration**: Issues, PRs, auto-merge via GitHub CLI
- **Quality Gates**: lint → test → build → auto-merge pipeline
- **Memory Integration**: Supermemory + OpenMemory for context preservation

## Project Structure
- **5 Core Commands**: `/new`, `/start`, `/status`, `/sync`, `/close`
- **5 Core Rules**: auto-sync, ci-integration, git-workflow, memory-sync, quality-gates
- **8+ Specialized Agents**: project-manager, simple-tester, code-analyzer, etc.
- **Auto-Sync Engine**: Core automation logic in bash scripts
- **Configuration-Driven**: JSON config for deliverables, quality gates, GitHub settings

## Target Use Cases
- Modern web projects (React, Vue, Astro, Laravel, etc.)
- Teams wanting zero-friction project management
- Projects requiring GitHub integration and automation
- Development workflows needing progress tracking and quality gates