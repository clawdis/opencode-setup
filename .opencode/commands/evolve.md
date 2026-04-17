---
description: Analyze instincts and suggest or generate evolved structures (skills/commands/agents)
---

# /evolve - Evolve Instincts

Analyzes instincts and clusters related ones into higher-level structures.

## Implementation

Run the instinct CLI:

```bash
python3 .opencode/skills/continuous-learning-v2/scripts/instinct-cli.py evolve [--generate]
```

## Usage

```
/evolve                    # Analyze all instincts and suggest evolutions
/evolve --generate         # Also generate files under evolved/{skills,commands,agents}
```

## Evolution Rules

### → Command (User-Invoked)
When instincts describe actions a user would explicitly request:
- Multiple instincts about "when user asks to..."
- Instincts with triggers like "when creating a new X"
- Instincts that follow a repeatable sequence

### → Skill (Auto-Triggered)
When instincts describe behaviors that should happen automatically:
- Pattern-matching triggers
- Error handling responses
- Code style enforcement

### → Agent (Needs Depth/Isolation)
When instincts describe complex, multi-step processes:
- Debugging workflows
- Refactoring sequences
- Research tasks

## What to Do

1. Detect current project context
2. Read project instincts from `.opencode/instincts/` + global from `~/.opencode/homunculus/instincts/`
3. Group instincts by trigger/domain patterns
4. Identify:
   - Skill candidates (trigger clusters with 2+ instincts)
   - Command candidates (high-confidence workflow instincts)
   - Agent candidates (larger, high-confidence clusters)
5. Show promotion candidates (project -> global) when applicable
6. If `--generate` is passed, write files to evolved/ directories
