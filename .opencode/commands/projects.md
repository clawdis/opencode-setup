---
description: List known projects and their instinct statistics
---

# /projects - List Projects

List project registry entries and per-project instinct/observation counts.

## Implementation

```bash
python3 .opencode/skills/continuous-learning-v2/scripts/instinct-cli.py projects
```

## Usage

```bash
/projects
```

## What to Do

1. Read `~/.opencode/homunculus/projects.json`
2. For each project, display:
   - Project name, id, root, remote
   - Personal and inherited instinct counts
   - Observation event count
   - Last seen timestamp
3. Also display global instinct totals
