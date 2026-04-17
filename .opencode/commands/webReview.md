---
description: Submit implementation plan to Plannotator web review for interactive annotation and approval. This is the ONLY authorized way to call submit_plan.
---

# /webReview

## What This Command Does

Opens the current implementation plan in Plannotator's interactive web UI where you can:
- **Annotate** specific sections with feedback
- **Delete** sections you don't want
- **Replace** sections with your own text
- **Approve** the plan to save it as an approved `.md` file
- **Request Changes** to send feedback back to the agent

## When to Use

- After the agent has drafted an implementation plan and you want to **review it visually**
- When you want to **edit or annotate** a plan before it becomes the source of truth
- Before routing to TaskManager for subtask decomposition

## How It Works

1. You invoke `/webReview` (with optional plan text or context)
2. The agent calls `submit_plan` with the current plan content
3. Plannotator opens the plan in your browser for interactive review
4. You annotate, edit, approve, or request changes
5. **If approved**: Plan is saved to `C:\Users\TechnoStar\.plannotator\plans\` as `*-approved.md`
6. **If changes requested**: Feedback is returned to the agent for revision

## CRITICAL RULE

> **`submit_plan` MUST ONLY be called when the user explicitly invokes `/webReview`.**
> The agent must NEVER call `submit_plan` autonomously or as part of other workflows.
> If the agent needs to present a plan without web review, use normal markdown output instead.

## Example Usage

```
/webReview
```
Agent submits the current plan draft to Plannotator for web review.

```
/webReview Here is my plan for the new feature...
```
Agent formats the provided text as a plan and submits it to Plannotator.

## Integration with TaskManager

After a plan is approved via `/webReview`:
1. The approved plan is saved at `C:\Users\TechnoStar\.plannotator\plans\{date}-{title}-approved.md`
2. **The agent MUST capture this path** from Plannotator's approval response
3. When delegating to TaskManager, **always pass `source_plan_path: {captured-path}`** — do NOT rely solely on auto-detect
4. TaskManager enters **Plan Extraction Mode** and creates subtasks referencing the original plan sections

**CRITICAL**: The agent must remember the approved plan path for the rest of the session.
If TaskManager is invoked later in the same session, the path MUST be passed explicitly.
This eliminates the need for the user to re-specify the plan path after approval.

This creates a clean pipeline:
```
/webReview → Approve → Agent captures path → /plan or TaskManager(source_plan_path) → Subtask decomposition (no re-planning)
```
