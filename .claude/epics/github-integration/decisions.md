# GitHub Integration Epic - Architecture Decisions

**Epic**: github-integration
**Date**: 2025-09-23
**Status**: Complete

## Decision Context

The CCPM system needed a way to detect external GitHub issues and PRs created by stakeholders (20% use case) without adding complexity to the primarily user-driven workflow (80% use case).

### Original Problem
- Issue #2 from bikefort project was created externally but not tracked by CCPM
- Epics worked directly on main branch without GitHub issue integration
- No mechanism to adopt existing external GitHub issues into epic workflow
- Missing cross-repository collaboration capabilities

## Key Decisions Made

### 1. Polling Over Webhooks ✅

**Decision**: Use simple GitHub REST API polling instead of webhooks

**Rationale**:
- **Simplicity**: No webhook infrastructure required
- **Private repos**: Works with private repositories without external endpoints
- **User control**: Manual trigger via `/pm:sync` gives users control
- **No surprises**: Avoids unexpected automated actions
- **80/20 rule**: External detection is occasional (20%), not real-time requirement

**Alternatives Rejected**:
- **Webhooks**: Too complex for occasional use, requires public endpoints
- **GitHub Apps**: Overkill for simple polling needs
- **Real-time sync**: Not needed for external stakeholder workflow

### 2. External Detection Strategy ✅

**Decision**: Use GitHub `author_association` field for external detection

**Implementation**:
```bash
# External (detected)
"NONE"|"FIRST_TIME_CONTRIBUTOR"|"CONTRIBUTOR"

# Internal (ignored)
"OWNER"|"MEMBER"|"COLLABORATOR"
```

**Rationale**:
- **Accurate**: GitHub provides reliable association data
- **Simple**: Single field check, no complex heuristics
- **Maintainable**: GitHub manages the association logic

### 3. User-Driven Workflow ✅

**Decision**: No automatic actions, all decisions require explicit user action

**Implementation**:
```bash
/pm:sync          # Detect external issues
/pm:inbox         # Review detected issues
/pm:inbox adopt   # Manual adoption decision
/pm:inbox ignore  # Manual ignore decision
```

**Rationale**:
- **User control**: Maintains 80% user-driven principle
- **No surprises**: System never creates epics or issues automatically
- **Review process**: User evaluates relevance before adoption
- **Manual integration**: Adoption triggers manual epic creation

### 4. Inbox Pattern ✅

**Decision**: Use inbox metaphor for external issue management

**Implementation**:
- **Detection**: External issues stored in `.claude/inbox/external-issues.jsonl`
- **Review**: `/pm:inbox` command for issue review
- **Status flow**: `pending` → `adopted` or `ignored`
- **Adoption**: Manual integration into CCPM workflow

**Rationale**:
- **Familiar pattern**: Email inbox metaphor is intuitive
- **Clear workflow**: Detection → Review → Decision → Integration
- **Status tracking**: Simple state management
- **Non-intrusive**: Doesn't interfere with main CCPM workflow

### 5. API Efficiency Design ✅

**Decision**: Implement ETag caching and incremental polling

**Implementation**:
```bash
# Incremental polling
GET /repos/{owner}/{repo}/issues?since=ISO8601&state=all

# ETag support (structure ready)
If-None-Match: "etag-value"
HTTP 304 Not Modified
```

**Rationale**:
- **Rate limiting**: Respects GitHub API limits
- **Efficiency**: Only fetches changes since last sync
- **Scalability**: Works for repositories with many issues
- **Good citizen**: Reduces unnecessary API calls

### 6. Simple Command Structure ✅

**Decision**: Reuse existing CCPM command pattern with new functionality

**Commands Added**:
- `/pm:sync` - Trigger external issue detection (reuses existing sync command pattern)
- `/pm:inbox` - Manage external issues (new command)

**Rationale**:
- **Consistency**: Follows existing CCPM command patterns
- **Discoverability**: Commands follow expected naming
- **Integration**: Works with existing command infrastructure

## Technical Architecture

### Data Flow
```
GitHub API → github-sync.sh → external-issues.jsonl → inbox-manager.sh → User Decision
                                                                            ↓
                                                                    Manual Epic Creation
```

### File Structure
```
.claude/
├── scripts/
│   ├── github-sync.sh          # Core polling script
│   ├── inbox-manager.sh        # Issue management
│   └── ci/test-github-sync.sh  # Test suite
├── inbox/
│   ├── external-issues.jsonl  # Issues database
│   └── sync-state.json        # Sync state per repo
└── commands/
    └── inbox.md               # Command documentation
```

### Integration Points
- **GitHub API**: REST API with personal access tokens
- **CCPM System**: New commands integrate with existing infrastructure
- **Git Repository**: Auto-detects repository from git remote
- **User Workflow**: Manual adoption triggers standard epic creation

## Consensus Process

### ZEN Consensus Rounds
1. **Round 1**: Issue adoption functionality exploration
2. **Round 2**: GitHub Issues as central hub (corrected by user)
3. **Round 3**: Simple polling without webhooks (final decision)

### User Feedback Integration
- **"No webhooks"**: User explicitly rejected webhook complexity
- **"Private repos"**: System designed for private repository workflow
- **"80/20 rule"**: External detection as occasional use case
- **"Simple system"**: Avoided over-engineering

### Key User Corrections
- Focus on private repositories, not public open-source workflow
- Question webhook necessity for occasional external detection
- Emphasize user-driven workflow over automation
- Keep system simple and maintainable

## Success Metrics

### Functional Requirements ✅
1. ✅ User can run `/pm:sync` to check for external issues
2. ✅ External issues appear in `/pm:inbox` for review
3. ✅ User can adopt external issues into current epic
4. ✅ No webhooks, no real-time automation, no infrastructure
5. ✅ Respects GitHub API rate limits with ETag efficiency

### Quality Requirements ✅
- **Test Coverage**: Comprehensive test suite with 9 test cases
- **Documentation**: Complete command documentation and workflow guides
- **Error Handling**: Graceful failure modes and user feedback
- **Maintainability**: Simple bash scripts, clear separation of concerns

### User Experience ✅
- **Intuitive Commands**: Follows CCPM patterns
- **Clear Workflow**: Detection → Review → Decision → Integration
- **No Surprises**: All actions require explicit user consent
- **Helpful Output**: Colored CLI output with clear status messages

## Future Considerations

### Potential Enhancements (Not Planned)
- **ETag Implementation**: Currently structured but not fully implemented
- **Multi-Repository**: Currently single repository, could expand
- **Issue Templates**: Could add template matching for auto-categorization
- **Notification**: Could add optional notification integration

### Maintenance Notes
- **GitHub API**: Monitor rate limits and API changes
- **Token Management**: Users responsible for token configuration
- **Repository Changes**: Auto-detects from git remote, works across repos
- **State Management**: Simple JSON files, easy to inspect and debug

## Lessons Learned

### Design Principles Applied
1. **Simplicity over complexity**: Polling beats webhooks for this use case
2. **User control**: No surprises, explicit decisions required
3. **80/20 optimization**: Design for primary use case, accommodate edge case
4. **Good citizenship**: Respect API limits and external systems

### User Feedback Importance
- Initial webhook-focused design was corrected by user input
- Private repository focus changed the architectural approach
- User's "80/20 rule" shaped the interaction design
- Simplicity emphasis prevented over-engineering

### Technical Decisions
- **Bash scripts**: Simple, maintainable, no additional dependencies
- **JSON storage**: Human-readable, easy to debug and inspect
- **Command pattern**: Consistent with existing CCPM infrastructure
- **Test coverage**: Comprehensive testing for reliability

**Epic successfully delivers simple, user-driven external issue detection without compromising CCPM's core workflow simplicity.**