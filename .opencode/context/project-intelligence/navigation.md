<!-- Context: project-intelligence/nav | Priority: high | Version: 1.1 | Updated: 2026-02-10 -->

# Project Intelligence

> Start here for quick project understanding. These files bridge business and technical domains.

## Structure

```
.opencode/context/project-intelligence/
├── navigation.md              # This file - quick overview
├── business-domain.md         # Business context and problem statement
├── technical-domain.md        # Stack, architecture, technical decisions
├── business-tech-bridge.md    # How business needs map to solutions
├── decisions-log.md           # Major decisions with rationale
└── living-notes.md            # Active issues, debt, open questions
```

## Quick Routes

| What You Need | File | Section |
|---------------|------|---------|
| **Scraper Patterns** | `technical-domain.md` | [Scraper Template](#scraper-template-srcwebscraper) |
| **UI/MVVM Logic** | `technical-domain.md` | [MVVM ViewModel Template](#mvvm-viewmodel-template-srcjavluv) |
| **Auth & Cookies** | `technical-domain.md` | [Security & Persistence](#security--persistence) |
| **The "Why"** | `business-domain.md` | Problem, users, value proposition |
| **The "How"** | `technical-domain.md` | Stack, architecture, integrations |

## Usage

**New Team Member / Agent**:
1. Start with `navigation.md` (this file)
2. Read `technical-domain.md` for coding patterns
3. Read `business-domain.md` for context

## Integration

This folder is referenced from:
- `.opencode/context/core/standards/project-intelligence.md` (standards and patterns)
- `.opencode/context/core/system/context-guide.md` (context loading)

See `.opencode/context/core/context-system.md` for the broader context architecture.
