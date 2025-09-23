# Bug Report: /pm:new Command Failure

**Epic**: fix-pm-new
**Date**: 2025-09-23
**Status**: Confirmed Critical Bug
**Severity**: Critical - Core functionality broken

## Summary

The `/pm:new` command in Claude Code is completely non-functional. Despite being documented in `.claude/commands/new.md`, the command fails to execute any of its intended functionality.

## Expected Behavior

According to documentation in `.claude/commands/new.md`, the `/pm:new` command should:

1. ✅ Create epic directory structure in `.claude/epics/<epic-name>/`
2. ✅ Generate `deliverables.json` with epic configuration
3. ✅ Create GitHub issue with epic description
4. ✅ Link epic to GitHub issue via `github_issue` field
5. ✅ Create feature branch `feature/epic-<name>`
6. ✅ Enable auto-sync functionality

## Actual Behavior

When executing `/pm:new <epic-name>` with various parameters:

```bash
# All of these commands produced NO results:
/pm:new fix-pm-new
/pm:new fix-pm-new "Fix critical bug in /pm:new command"
/pm:new test-epic
```

**Result**: Command appears to execute but produces:
- ❌ No directory creation
- ❌ No GitHub issue creation
- ❌ No git branch creation
- ❌ No deliverables.json file
- ❌ No error messages or feedback

## Impact Assessment

### Critical Impact
- **Epic Creation Broken**: Users cannot create new epics using the documented command
- **GitHub Integration Failure**: Auto-sync system expects GitHub issues but they're never created
- **Workflow Disruption**: Forces manual workarounds for core CCPM functionality
- **Auto-Sync Incompatibility**: Epics without GitHub issues show 0% completion indefinitely

### User Experience Impact
- **Silent Failures**: Command appears to run but does nothing
- **No Error Feedback**: Users unaware the command failed
- **Manual Workarounds Required**: Users must manually create epic structures
- **Documentation Mismatch**: Documented features don't work

## Root Cause Analysis

### Investigation Findings

1. **Command Documentation Exists**: `.claude/commands/new.md` properly documents the command
2. **Implementation Missing**: No actual command handler implementation found
3. **Manual Creation Works**: Epic structures can be created manually with proper GitHub integration
4. **Auto-Sync Expects Issues**: System designed around GitHub issue integration but creation fails

### Technical Analysis

The command documentation indicates sophisticated functionality:
```json
{
  "epic": "<epic-name>",
  "github_issue": null,  // Should be populated automatically
  "repository": "owner/repo-name",
  "auto_sync_enabled": true
}
```

However, no implementation exists to:
- Parse `/pm:new` command input
- Create directory structures
- Call GitHub API for issue creation
- Initialize git branches
- Generate deliverable templates

## Evidence

### Reproduction Steps
1. Authenticate GitHub CLI: `gh auth status` ✅ (confirmed working)
2. Execute command: `/pm:new test-epic-name`
3. Check for results: No directories, branches, or GitHub issues created
4. Verify permissions: GitHub CLI has proper repo access ✅

### System State
- **GitHub CLI**: Authenticated with repo permissions
- **Git Repository**: Valid repo with proper remote configuration
- **CCPM System**: Other components (auto-sync, etc.) functional
- **Command Documentation**: Present and detailed

### Workaround Evidence
Manual epic creation using `manual-epic-creator.sh` successfully:
- ✅ Creates directory structure
- ✅ Creates GitHub issue
- ✅ Links epic to issue
- ✅ Creates git branch
- ✅ Enables auto-sync

## Immediate Workaround

Created `manual-epic-creator.sh` script that provides all expected `/pm:new` functionality:

```bash
# Usage
./.claude/scripts/manual-epic-creator.sh epic-name "Description"

# Features
✅ Complete epic directory structure
✅ GitHub issue creation with proper labels
✅ Auto-sync integration
✅ Git branch creation
✅ Deliverables template
✅ Error handling and validation
```

## Recommended Solution

### Short-term (Immediate)
1. ✅ Use `manual-epic-creator.sh` for epic creation
2. ✅ Document workaround for team members
3. ✅ Update CCPM documentation to reference workaround

### Long-term (Proper Fix)
1. **Implement `/pm:new` command handler** in Claude Code
2. **Integrate with GitHub API** for automatic issue creation
3. **Add proper error handling** and user feedback
4. **Test command functionality** before deployment
5. **Update documentation** to match actual implementation

## Team Impact

### Discovered During
- Creation of `github-integration` epic
- Auto-sync testing revealed missing GitHub issues
- User frustration: "Comoooo???? Que falta esa funcionalidad??????"

### User Feedback
- Expected core functionality to work as documented
- Frustrated by silent command failures
- Required manual intervention for basic epic creation
- Questioned reliability of CCPM system

## Priority Classification

**Priority**: P0 (Critical)
**Urgency**: High
**User Impact**: High

### Justification
- Core CCPM functionality completely broken
- Users cannot create epics using documented commands
- Auto-sync system incompatible without GitHub issues
- Documentation promises features that don't exist

## Next Steps

1. **✅ Immediate Relief**: `manual-epic-creator.sh` provides working solution
2. **🔄 Investigation**: Analyze Claude Code implementation for command handling
3. **🔄 Bug Report**: Submit detailed report to Claude Code team
4. **🔄 Implementation**: Either fix command or update documentation to match reality

---

**Reporter**: Claude Code Assistant
**Epic**: fix-pm-new
**GitHub Issue**: #4 (to be created via workaround)
**Status**: Documented, Workaround Available