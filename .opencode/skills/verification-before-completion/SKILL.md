---
name: verification-before-completion
version: 1.1.0
description: Use when about to claim work is complete, fixed, or passing, before committing or creating PRs - requires running verification commands and confirming output before making any success claims; evidence before assertions always
integrated_instincts:
  - javluv-build-verification (95% confidence)
  - javluv-project-status-update (90% confidence)
---
**Announce at start:** "I'm using the Verification Before Completion skill to implement this plan."
# Verification Before Completion

## Overview

Claiming work is complete without verification is dishonesty, not efficiency.

**Core principle:** Evidence before claims, always.

**Violating the letter of this rule is violating the spirit of this rule.**



## The Iron Law

```
NO COMPLETION CLAIMS WITHOUT FRESH VERIFICATION EVIDENCE
```

If you haven't run the verification command in this message, you cannot claim it passes.

## The Gate Function

```
BEFORE claiming any status or expressing satisfaction:

1. IDENTIFY: What command proves this claim?
2. RUN: Execute the FULL command (fresh, complete)
3. READ: Full output, check exit code, count failures
4. VERIFY: Does output confirm the claim?
   - If NO: State actual status with evidence
   - If YES: State claim WITH evidence
5. ONLY THEN: Make the claim

Skip any step = lying, not verifying
```

## Common Failures

| Claim | Requires | Not Sufficient |
|-------|----------|----------------|
| Tests pass | Test command output: 0 failures | Previous run, "should pass" |
| Linter clean | Linter output: 0 errors | Partial check, extrapolation |
| Build succeeds | Build command: exit 0 | Linter passing, logs look good |
| Bug fixed | Test original symptom: passes | Code changed, assumed fixed |
| Regression test works | Red-green cycle verified | Test passes once |
| Agent completed | VCS diff shows changes | Agent reports "success" |
| Requirements met | Line-by-line checklist | Tests passing |

## Red Flags - STOP

- Using "should", "probably", "seems to"
- Expressing satisfaction before verification ("Great!", "Perfect!", "Done!", etc.)
- About to commit/push/PR without verification
- Trusting agent success reports
- Relying on partial verification
- Thinking "just this once"
- Tired and wanting work over
- **ANY wording implying success without having run verification**

## Rationalization Prevention

| Excuse | Reality |
|--------|---------|
| "Should work now" | RUN the verification |
| "I'm confident" | Confidence ≠ evidence |
| "Just this once" | No exceptions |
| "Linter passed" | Linter ≠ compiler |
| "Agent said success" | Verify independently |
| "I'm tired" | Exhaustion ≠ excuse |
| "Partial check is enough" | Partial proves nothing |
| "Different words so rule doesn't apply" | Spirit over letter |

## Key Patterns

**Tests:**
```
✅ [Run test command] [See: 34/34 pass] "All tests pass"
❌ "Should pass now" / "Looks correct"
```

**Regression tests (TDD Red-Green):**
```
✅ Write → Run (pass) → Revert fix → Run (MUST FAIL) → Restore → Run (pass)
❌ "I've written a regression test" (without red-green verification)
```

**Build:**
```
✅ [Run build] [See: exit 0] "Build passes"
❌ "Linter passed" (linter doesn't check compilation)
```

**Requirements:**
```
✅ Re-read plan → Create checklist → Verify each → Report gaps or completion
❌ "Tests pass, phase complete"
```

**Agent delegation:**
```
✅ Agent reports success → Check VCS diff → Verify changes → Report actual state
❌ Trust agent report
```

## Why This Matters

From 24 failure memories:
- your human partner said "I don't believe you" - trust broken
- Undefined functions shipped - would crash
- Missing requirements shipped - incomplete features
- Time wasted on false completion → redirect → rework
- Violates: "Honesty is a core value. If you lie, you'll be replaced."

## When To Apply

**ALWAYS before:**
- ANY variation of success/completion claims
- ANY expression of satisfaction
- ANY positive statement about work state
- Committing, PR creation, task completion
- Moving to next task
- Delegating to agents

**Rule applies to:**
- Exact phrases
- Paraphrases and synonyms
- Implications of success
- ANY communication suggesting completion/correctness

## The Bottom Line

**No shortcuts for verification.**

Run the command. Read the output. THEN claim the result.

This is non-negotiable.

---

## 🧠 JavLuv-Specific Instincts

The following instincts are auto-triggered when completing work in JavLuv:

### 🔨 Build Verification (95% confidence)

**Trigger:** When claiming implementation is complete

**Action:** ALWAYS run `Build_release.bat` before stating work is complete. If build fails, fix errors immediately.

```powershell
# Full build verification
.\Build_release.bat

# For scraper-only changes
.\Build_StandaloneScraper_Release.bat
```

**Evidence:** Build verification required in user rules. All releases verified through build scripts.

**Checklist:**
- [ ] Build output shows "Build succeeded"
- [ ] No compilation errors
- [ ] No warnings treated as errors

---

### 📋 Project Status Update (90% confidence)

**Trigger:** When completing any significant task in JavLuv

**Action:** After completing any milestone, feature, fix, or significant task, update `PROJECT_STATUS.md`:

1. Mark Active Milestones as completed (`[x]`)
2. Add new row to History Log with date, activity, and status
3. Add new items to Backlog if identified

**Example History Log Entry:**
```markdown
| 2026-01-29 | Implemented feature X | ✅ Completed |
```

**Evidence:** 95% of releases include PROJECT_STATUS.md updates. Central source of truth for all agents.

---

## 🏁 JavLuv Completion Gate

Before claiming ANY task is complete in JavLuv:

```
✅ REQUIRED STEPS:
1. Run Build_release.bat → Verify "Build succeeded"
2. Test functionality (StandaloneScraper for scrapers)
3. Update PROJECT_STATUS.md
4. THEN claim completion

❌ NEVER:
- Claim "done" before build verification
- Skip PROJECT_STATUS.md update
- Assume changes work without testing
```
