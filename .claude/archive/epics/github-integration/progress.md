# GitHub Integration Epic - Progress Tracking

**Epic**: github-integration
**Started**: 2025-09-23
**Status**: In Progress
**Completion**: 0%

## 🎯 **Objective**

Implement simple, user-driven GitHub Issues polling integration to detect external issues/PRs from stakeholders without webhook complexity.

## 📋 **Deliverables Status**

### Core Implementation
- [ ] `.claude/scripts/github-sync.sh` - Core polling script
- [ ] `.claude/scripts/inbox-manager.sh` - Inbox management
- [ ] `.claude/inbox/` directory structure
- [ ] `.claude/commands/sync.md` - /pm:sync documentation
- [ ] `.claude/commands/inbox.md` - /pm:inbox documentation

### Quality Assurance
- [ ] `.claude/scripts/ci/test-github-sync.sh` - Test coverage
- [ ] Integration with existing /pm:status command
- [ ] Rate limiting and error handling

### Documentation
- [ ] `.claude/epics/github-integration/decisions.md` - Architecture decisions

## 🏗️ **Implementation Approach**

Based on ZEN consensus analysis:
- **Simple polling** using GitHub REST API with `since` parameter
- **ETag caching** for API efficiency
- **User-driven workflow** - no automatic actions
- **External detection** via `author_association` field
- **Inbox pattern** for user review and adoption

## 🔧 **Technical Specs**

- API: `GET /repos/{owner}/{repo}/issues?since=ISO8601&state=all`
- Auth: Reuse existing GitHub token from CCPM config
- State: Minimal - just `last_sync` timestamp + ETag per repo
- Detection: External if `author_association NOT IN [OWNER, MEMBER, COLLABORATOR]`

## 📊 **Success Criteria**

1. ✅ User can run `/pm:sync` to check for external issues
2. ✅ External issues appear in `/pm:inbox` for review
3. ✅ User can adopt external issues into current epic
4. ✅ No webhooks, no real-time automation, no infrastructure
5. ✅ Respects GitHub API rate limits with ETag efficiency

## 🎛️ **Commands Added**

- `/pm:sync` - Poll GitHub for external issues/PRs
- `/pm:inbox` - Review pending external issues
- `/pm:adopt <issue-number>` - Adopt external issue
- `/pm:ignore <issue-number>` - Mark external issue as ignored

**Next Steps**: Setup feature branch and begin core implementation.