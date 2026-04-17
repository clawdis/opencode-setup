# Node Runtime Recovery Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make the Windows OpenCode installer recover automatically when `Node.js` or `npm` is missing, broken, or not yet available in PATH.

**Architecture:** Keep the batch installer single-file and add a small runtime readiness gate before the OpenCode install step. Reuse one path refresh routine and one runtime check routine so the script can verify, repair with `winget`, and verify again before continuing.

**Tech Stack:** Windows batch, PowerShell, `winget`, `npm`

---

### Task 1: Add Node.js readiness and repair flow

**Files:**
- Modify: `setup-opencode.bat`

- [ ] **Step 1: Add a runtime readiness check**

Check `node -v` and `npm -v` after refreshing likely `nodejs` paths.

- [ ] **Step 2: Add the repair branch**

If either command fails, run:

```bat
winget install --id OpenJS.NodeJS.LTS -e --accept-package-agreements --accept-source-agreements --scope user --force
```

- [ ] **Step 3: Re-run readiness verification**

Run `node -v` and `npm -v` again and fail clearly only if they still do not work.

### Task 2: Update installer documentation

**Files:**
- Modify: `README.md`

- [ ] **Step 1: Update feature summary**

Document that the script can repair a broken or incomplete `Node.js`/`npm` setup, not only install from scratch.

- [ ] **Step 2: Update notes**

Clarify that `winget` is required only when the runtime is not ready and the script needs to repair or install it.

### Task 3: Verify both main runtime paths

**Files:**
- Verify: `setup-opencode.bat`

- [ ] **Step 1: Verify healthy-runtime path**

Run the installer in a sandbox with fake working `node`, `npm`, and `opencode` commands and confirm it skips repair and completes.

- [ ] **Step 2: Verify repair path**

Run the installer in a sandbox with no initial `node` or `npm`, a fake `winget`, and confirm the script repairs the runtime and completes.
