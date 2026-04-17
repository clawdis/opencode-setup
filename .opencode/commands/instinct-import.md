---
description: Import instincts from file or URL into project/global scope
---

# /instinct-import - Import Instincts

Import instincts from local file paths or HTTP(S) URLs.

## Implementation

```bash
python3 .opencode/skills/continuous-learning-v2/scripts/instinct-cli.py import <file-or-url> [options]
```

## Usage

```
/instinct-import team-instincts.yaml
/instinct-import https://github.com/org/repo/instincts.yaml
/instinct-import team-instincts.yaml --dry-run
/instinct-import team-instincts.yaml --scope global --force
```

## What to Do

1. Fetch the instinct file (local path or URL)
2. Parse and validate the format
3. Check for duplicates with existing instincts
4. Merge or add new instincts
5. Save to inherited instincts directory:
   - Project scope: `.opencode/instincts/inherited/`
   - Global scope: `~/.opencode/homunculus/instincts/inherited/`

## Merge Behavior

When importing an instinct with an existing ID:
- Higher-confidence import becomes an update candidate
- Equal/lower-confidence import is skipped
- User confirms unless `--force` is used

## Flags

- `--dry-run`: Preview without importing
- `--force`: Skip confirmation prompt
- `--min-confidence <n>`: Only import instincts above threshold
- `--scope <project|global>`: Select target scope (default: `project`)
