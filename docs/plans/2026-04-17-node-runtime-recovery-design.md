# Node Runtime Recovery Design

**Goal**

Make `setup-opencode.bat` succeed whether the target Windows machine already has a working `Node.js` and `npm` installation or needs that runtime repaired or installed automatically.

**Chosen Approach**

Use a readiness gate before the OpenCode install step. The script first refreshes likely `nodejs` paths, then runs `node -v` and `npm -v`. If either command fails, the script treats the runtime as not ready and runs `winget install --id OpenJS.NodeJS.LTS --scope user --force` as a repair-or-install step.

**Why This Approach**

This keeps the normal path fast for healthy machines while still recovering from the common failure cases that matter here: missing `Node.js`, missing `npm`, and broken or incomplete PATH setup. It avoids always reinstalling Node.js on every run, but it still makes the installer self-healing when the runtime is unusable.

**Behavior**

- Refresh known `nodejs` directories into the current process PATH and user PATH.
- Verify runtime availability with real commands, not only `where` checks.
- If `node` or `npm` is unusable, run `winget` to repair or install `Node.js LTS`.
- Re-check `node -v` and `npm -v` after repair.
- Continue to `npm install -g opencode-ai` only when both commands succeed.
- Fail with a clear message only if `winget` is unavailable or the runtime is still unusable after repair.

**Files**

- Modify `setup-opencode.bat` to add readiness and repair logic.
- Modify `README.md` to explain that the installer now self-recovers when either `node` or `npm` is missing or broken.
