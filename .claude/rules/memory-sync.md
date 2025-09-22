# Memory Sync Rules

Automatic integration with Supermemory and OpenMemory for context preservation.

## Core Principle

**Context never lost.** All project decisions, patterns, and knowledge automatically preserved and accessible.

## Supermemory Integration

### Auto-Sync Triggers
```bash
# When these events occur, sync to Supermemory:
- Epic created (/pm:new)
- Major decision made (architecture, tech choice)
- PR merged to main
- Issue completed
- Performance milestone reached
- Error pattern identified
```

### What Gets Stored
```bash
# Project decisions
"Decided to use Vue 3 Composition API for better TypeScript integration in user authentication components"

# Architecture patterns
"Authentication flow: LoginForm.vue → AuthService.ts → JWT validation → user state in Pinia store"

# Performance insights
"Login page LCP improved from 2.1s to 1.3s by lazy-loading profile components"

# Error solutions
"Fixed 'Cannot read property of undefined' in UserProfile by adding null checks in computed properties"

# Team patterns
"UI components follow atomic design: atoms in /components/base/, molecules in /components/ui/"
```

### Memory Search Integration
```bash
# In CLAUDE.md workflows:
1. Always search Supermemory first for context
2. Add new decisions to memory automatically
3. Reference previous solutions for similar problems
4. Maintain team knowledge continuity
```

## OpenMemory for Sessions

### Session Context
- Current epic/issue being worked on
- Temporary decisions and notes
- Code patterns discovered during session
- Performance observations
- Debugging insights

### Session-to-Supermemory Flow
```bash
# At end of successful work session:
1. OpenMemory collects session insights
2. Filter for permanent knowledge
3. Auto-add to Supermemory if relevant
4. Clear temporary session data
```

## Auto-Sync Implementation

### Git Hook Integration
```bash
#!/bin/bash
# In post-commit hook

# Extract decision keywords from commit message
if git log -1 --pretty=%B | grep -E "(decide|choose|pattern|solution|fix)"; then
  commit_msg=$(git log -1 --pretty=%B)

  # Add to Supermemory
  echo "Adding to memory: $commit_msg"
  # [Call to Supermemory API]
fi
```

### PR Merge Memory Sync
```bash
# When PR merges to main
pr_description=$(gh pr view $PR_NUMBER --json title,body)
files_changed=$(gh pr view $PR_NUMBER --json files)

# Automatically store:
memory_content="
Merged PR: $pr_title

Changes: $files_changed
Architecture decisions: [extracted from PR description]
Performance impact: [if mentioned]
Breaking changes: [if any]
"

# Add to Supermemory
```

## Memory Organization

### Categories
```bash
# Supermemory categories for project
- "architecture-decisions"
- "performance-patterns"
- "ui-components-patterns"
- "api-integrations"
- "testing-strategies"
- "deployment-procedures"
- "error-solutions"
- "team-conventions"
```

### Search Patterns
```bash
# Common memory searches during development:
- "How did we implement authentication?"
- "What was the solution for mobile navigation?"
- "Performance optimization patterns"
- "Component architecture decisions"
- "API error handling strategy"
```

## Context Preservation

### Epic Memory
```bash
# When starting epic (/pm:new)
1. Search Supermemory for related patterns
2. Create epic context in OpenMemory
3. Reference previous similar implementations
4. Maintain architecture consistency
```

### Issue Memory
```bash
# When working on issue
1. Check Supermemory for similar issues solved
2. Add current solution approach to session memory
3. Auto-sync successful resolution to Supermemory
4. Link solution to GitHub issue for future reference
```

## Memory Maintenance

### Auto-Cleanup
- Session memory: Clear after successful epic completion
- Temporary notes: Archive after 30 days
- Duplicate entries: Auto-merge similar memories
- Outdated patterns: Flag for review when architecture changes

### Quality Control
- Validate memory entries for clarity
- Ensure searchable keywords included
- Remove noise and temporary debugging info
- Maintain concise, actionable entries

## Integration with Agents

### Agents Use Memory
```bash
# Before starting work, agents should:
1. Search Supermemory for project context
2. Search for similar component patterns
3. Reference previous architectural decisions
4. Apply consistent coding patterns
```

### Agents Add to Memory
```bash
# After completing work, agents should:
1. Document new patterns discovered
2. Record architecture decisions made
3. Note performance optimizations applied
4. Update team knowledge base
```

**Memory is the team's knowledge backbone. Keep it current, searchable, and actionable.**