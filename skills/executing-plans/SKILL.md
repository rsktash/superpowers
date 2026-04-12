---
name: executing-plans
description: Use when you have a written implementation plan to execute in a separate session with review checkpoints
---

# Executing Plans

## Overview

Load task beads from beads, review critically, execute all tasks, report when complete.

**Announce at start:** "I'm using the executing-plans skill to implement this plan."

**bd conventions:** Read `skills/shared/bd-defaults.md` before using any bd commands.

## The Process

### Step 1: Load and Review Tasks

1. Receive the root bead ID from writing-plans
2. Read the spec and list all child beads: `bd show <root-id> --json` (includes children regardless of status)
3. Read each task to understand the full plan: `bd show <task-id> --json`
5. Review critically — identify any questions or concerns about the tasks
6. If concerns: Raise them with your human partner before starting
7. If no concerns: Proceed to execution

### Step 2: Execute Tasks

Loop until `bd ready --parent <root-id> --json` returns an empty array `[]`:

1. `bd ready --parent <root-id> --json` — get next unblocked task (returns `[]` when all tasks are done or blocked)
2. Read task and set assignee (do NOT use --claim):
   ```bash
   bd show <task-id> --json
   bd update <task-id> --status=in_progress --assignee "$(git config user.name) / <model-name>"
   ```
   Example assignee: "Alex / Claude Opus 4.6"
3. If the task body contains image references, resolve them to local files and view them before implementing.
4. For each step in the task body:
   a. If this is the first step: read everything listed in "Before you start" — files, rules, callers. Do not skip this.
   b. Execute the step
   c. Persist progress immediately — do NOT proceed to the next step until this is done:
      - Write the updated description (with `- [ ]` → `- [x]`) to `.beads/.scratch/progress.md`
      - `bd update <task-id> --body-file .beads/.scratch/progress.md`
5. `bd close <task-id> --reason "Done"` — mark complete, unblocks dependents
6. Loop back to step 1

**Why persist after every step?** If the session is interrupted mid-task, checkboxes are the only record of which steps completed. The next session uses them to resume from where you left off. Skipping this creates unrecoverable ambiguity.

**When a step fails:** Do not retry the same edit. Read the error output fully, then use superpowers:systematic-debugging to diagnose before touching the file again. The second edit must fix a diagnosed cause, not adjust the previous guess.

**Note:** Closing the last child task may auto-close the parent epic. This is expected — the epic will still be accessible via `bd show`.

Progress is visible in beads-ui in real time. Step-level progress persisted via comments enables recovery if execution is interrupted.

### Resuming After Interruption

If starting a new session to continue work on an existing feature:

1. Find the root bead ID: glob `docs/beads/*-bd-*.md` — the bead ID is in the filename
2. `bd show <root-id> --json` — list all child beads and their statuses (open, in_progress, closed)
3. Check for in-progress tasks: read their comments via `bd show <task-id> --json` to see which steps completed
4. Resume in-progress tasks from the next uncompleted step, then continue with `bd ready --parent <root-id> --json` for remaining unblocked tasks

### Step 3: Complete Development

After all tasks complete and verified:
- Pass the root bead ID to finishing-a-development-branch so it can close the epic and include the bead ID in commits.
- Announce: "I'm using the finishing-a-development-branch skill to complete this work."
- **REQUIRED SUB-SKILL:** Use superpowers:finishing-a-development-branch
- Follow that skill to verify tests, present options, execute choice

## When to Stop and Ask Your Human Partner

**When you encounter work not described in the current task — stop.** Do not skip it. Do not guess.

This includes:
- A missing dependency, API, or component that must exist for your task to proceed
- A bug or edge case unrelated to the current task
- A test that requires functionality not yet implemented
- An instruction you don't understand
- A verification that fails repeatedly

Present two options:
1. Address it now — expand the current session's scope
2. Create a draft bead and continue — `bd create "<title>" --status=draft --parent <root-id>`

Your human partner decides. You do not.

## When to Revisit Earlier Steps

**Return to Review (Step 1) when:**
- Partner updates the task beads based on your feedback
- Fundamental approach needs rethinking

**Don't force through blockers** - stop and ask.

## Remember
- Read "Before you start" before the first step of every task
- One well-researched edit beats five speculative ones — if you cannot explain why an edit will work, read more first
- When a step fails, diagnose before re-editing — use superpowers:systematic-debugging
- After 2 failed attempts at the same step, stop and ask your human partner
- Never start implementation on main/master branch without explicit user consent

## Integration

**Required workflow skills:**
- **superpowers:using-git-worktrees** - REQUIRED: Set up isolated workspace before starting
- **superpowers:writing-plans** - Creates the task beads this skill executes
- **superpowers:finishing-a-development-branch** - Complete development after all tasks
