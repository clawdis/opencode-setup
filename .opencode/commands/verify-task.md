---
description: Enforce definition of done with build and status reporting
---

# Verify Task Command

## Skill:
- javluv-patterns
- javluv-patterns-generated
- javluv-build-verification
- javluv-status-tracking
- javluv-project-status-update

## Trigger
Run this command when you believe a task is complete.

## Workflow

### 1. Build Verification
```powershell
.\Build_release.bat
```
- If this fails: **STOP**. Fix errors immediately.

### 2. Status Update
- Edit `PROJECT_STATUS.md`
- Mark active milestones as `[x]`
- Add entry to **History Log**
- Add any new **Backlog** items

### 3. Changelog (If applicable)
- If user-facing change, update `Changelog.md`

### 4. Final Report
- Summarize changes to User
- Confirm build success
- Confirm status update