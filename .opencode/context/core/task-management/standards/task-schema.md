# Standard: Task JSON Schema

**Purpose**: JSON schema reference for task management files

**Last Updated**: 2026-02-20

---

## Core Concepts

Task management uses two JSON file types:
- `task.json` - Feature-level metadata and tracking
- `subtask_NN.json` - Individual atomic tasks with dependencies

Location: `.tmp/tasks/{feature-slug}/` (at project root)

---

## task.json Schema

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | string | Yes | kebab-case identifier |
| `name` | string | Yes | Human-readable name (max 100) |
| `status` | enum | Yes | active / completed / blocked / archived |
| `source_plan` | string | No | Path to the Plannotator approved plan used as source of truth. `null` if TaskManager created its own plan. When present, `reference_files` should include this path. |
| `objective` | string | Yes | One-line objective (max 200) |
| `context_files` | array | No | **Standards paths only** — coding conventions, patterns, security rules to follow |
| `reference_files` | array | No | **Source material only** — project files to look at (existing code, config, schemas) |
| `exit_criteria` | array | No | Completion conditions |
| `subtask_count` | int | No | Total subtasks |
| `completed_count` | int | No | Done subtasks |
| `created_at` | datetime | Yes | ISO 8601 |
| `completed_at` | datetime | No | ISO 8601 |

---

## subtask_NN.json Schema

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | string | Yes | {feature}-{seq} |
| `seq` | string | Yes | 2-digit (01, 02) |
| `title` | string | Yes | Task title (max 100) |
| `plan_section` | string | No | Exact heading from Plannotator source plan this subtask maps to (e.g., `## Task 3: Create Orchestrator`). When present, agents MUST read this section from `source_plan` for full implementation detail. `null` if no source plan. |
| `status` | enum | Yes | pending / in_progress / completed / blocked |
| `depends_on` | array | No | Sequence numbers of dependencies |
| `parallel` | bool | No | True if can run alongside others |
| `context_files` | array | No | **Standards paths only** — conventions and patterns to follow |
| `reference_files` | array | No | **Source material only** — existing files to reference |
| `suggested_agent` | string | No | Recommended agent for this task (e.g., OpenFrontendSpecialist) |
| `acceptance_criteria` | array | No | Binary pass/fail conditions |
| `deliverables` | array | No | Files to create/modify |
| `agent_id` | string | No | Set when in_progress |
| `started_at` | datetime | No | ISO 8601 |
| `completed_at` | datetime | No | ISO 8601 |
| `completion_summary` | string | No | What was done (max 200) |

---

## Status Transitions

```
pending → in_progress   (by working agent, when deps satisfied)
in_progress → completed (by TaskManager, after verification)
* → blocked             (by either, when issue found)
blocked → pending       (when unblocked)
```

---

## Parallel Flag

- `parallel: true` = Isolated task, can run alongside others
- `parallel: false` = May affect shared state, run sequentially

Use `task-cli.ts parallel` to find all parallelizable tasks ready to run.

---

## context_files vs reference_files — The Rule

These two fields serve fundamentally different purposes. **Never mix them.**

| Field | Answers | Contains | Agent behavior |
|-------|---------|----------|----------------|
| `context_files` | "What rules do I follow?" | Standards, conventions, patterns from `.opencode/context/` | Load and apply as coding guidelines |
| `reference_files` | "What existing code do I look at?" | Project source files, configs, schemas | Read to understand existing patterns |

**Wrong** ❌ — mixing standards and source files:
```json
"context_files": [
  ".opencode/context/core/standards/code-quality.md",
  "package.json",
  "src/existing-auth.ts"
]
```

**Right** ✅ — clean separation:
```json
"context_files": [
  ".opencode/context/core/standards/code-quality.md",
  ".opencode/context/core/standards/security-patterns.md"
],
"reference_files": [
  "package.json",
  "src/existing-auth.ts"
]
```

---

## Example

**Without Plannotator** (plan_section is null):
```json
{
  "id": "auth-system-02",
  "seq": "02",
  "title": "Create JWT service",
  "plan_section": null,
  "status": "pending",
  "depends_on": ["01"],
  "parallel": false,
  "context_files": [
    ".opencode/context/core/standards/code-quality.md",
    ".opencode/context/core/standards/security-patterns.md"
  ],
  "reference_files": [
    "src/auth/token-utils.ts"
  ],
  "acceptance_criteria": ["JWT tokens signed with RS256", "Tests pass"],
  "deliverables": ["src/auth/jwt.service.ts"]
}
```

**With Plannotator** (plan_section references source plan):
```json
{
  "id": "enhanced-scraping-03",
  "seq": "03",
  "title": "Create ActressScrapeOrchestrator",
  "plan_section": "## Task 3: Create ActressScrapeOrchestrator",
  "status": "pending",
  "depends_on": ["01", "02"],
  "parallel": false,
  "context_files": [
    ".opencode/context/core/standards/code-quality.md"
  ],
  "reference_files": [
    "src/WebScraper/Scraper.cs"
  ],
  "acceptance_criteria": ["Orchestrator registered in Scraper.cs", "Build passes"],
  "deliverables": ["src/WebScraper/ActressScrapeOrchestrator.cs"]
}
```
When `plan_section` is not null, agent reads the section from `source_plan` for full implementation detail (code snippets, file paths, design decisions).

---

## Plannotator Integration

When TaskManager extracts tasks from a Plannotator-approved plan:

- `task.json` has `source_plan` pointing to the approved `.md` file
- Each `subtask_NN.json` has `plan_section` pointing to the relevant heading in that plan
- Working agents receiving subtasks with `plan_section` MUST:
  1. Read `source_plan` path from the parent `task.json`
  2. Navigate to the `plan_section` heading in that file
  3. Use the full detail under that heading as implementation guidance
  4. The plan section is the **authoritative source** for WHAT to implement and WHY
  5. The subtask JSON provides the HOW (dependencies, order, acceptance criteria)

**Example:**
```json
// task.json
{ "source_plan": "C:\\Users\\TechnoStar\\.plannotator\\plans\\2026-02-20-slug-approved.md" }

// subtask_01.json  
{ "plan_section": "## Task 1: Add Settings Property" }
```

The agent reads `## Task 1: Add Settings Property` from the source plan to get full code snippets, file paths, and detailed instructions.

---

## Related

- `../guides/splitting-tasks.md` - How to decompose features
- `../guides/managing-tasks.md` - Lifecycle workflow
- `../lookup/task-commands.md` - CLI reference
