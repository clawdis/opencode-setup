# OpenCode Windows Setup

This repository is a portable Windows setup for OpenCode.

It is meant for users who want to:
- install Node.js if it is missing
- install OpenCode with `npm`
- copy the prepared global config into `%USERPROFILE%\.config\opencode`
- copy the prepared global `.opencode` assets into the same config directory

## What gets installed

- `Node.js LTS` via `winget` when `node` is not available
- `opencode-ai` via `npm install -g opencode-ai`

## What gets copied

The setup script copies these files into the official global OpenCode config directory:

- `%USERPROFILE%\.config\opencode\opencode.json`
- `%USERPROFILE%\.config\opencode\opencode.jsonc`
- the contents of `.opencode\` into `%USERPROFILE%\.config\opencode\`

OpenCode loads and merges both `opencode.json` and `opencode.jsonc`, so both files are kept.

## How to use

1. Download this repository as a ZIP or clone it.
2. Extract it anywhere on the target Windows machine.
3. Double-click `setup-opencode.bat`.
4. Wait for the script to finish.

## After setup

Run:

```bat
opencode
```

Then inside OpenCode:

1. Run `/connect` to add your provider or OpenCode account.
2. Run `/init` inside a project if you want OpenCode to initialize project instructions.

## Notes

- Official docs recommend WSL for the best Windows experience, but this setup targets native Windows.
- The script expects `winget` to be available if Node.js must be installed automatically.
- The script keeps the console open at the end so users can read any errors.
