---
name: executing-plans
description: Use when you have a written implementation plan to execute in a separate session with review checkpoints
---

# Executing Plans

## Overview

Load task beads from beads, review critically, execute all tasks, report when complete.

**Announce at start:** "I'm using the executing-plans skill to implement this plan."

<HARD-GATE>
## Step 0: Verify beads (MUST complete before ANY other action)

Check session context for `<beads-status>`. If `BEADS_AVAILABLE=false` → tell your human partner: "Beads (`bd`) is not available. It should have been auto-installed by the session-start hook. Try restarting Claude Code, or run `$CLAUDE_PLUGIN_ROOT/scripts/install-deps.sh` manually." STOP. Do NOT proceed. Do NOT launch parallel work.

If beads is available but no `.beads/` directory exists → ask user: "Run `bd init` to set up beads in this project?" and WAIT.

Only after beads is available AND initialized → proceed.
</HARD-GATE>

## The Process

### Step 1: Load and Review Tasks

1. Receive the root bead ID from writing-plans
2. Read the spec and list all child beads: `bd show <root-id> --json` (includes children regardless of status)
3. Read each task to understand the full plan: `bd show <task-id> --json`
5. Review critically — identify any questions or concerns about the tasks
6. If concerns: Raise them with your human partner before starting
7. If no concerns: Proceed to execution

### Step 2: Execute Tasks

Loop until `bd ready --parent <root-id> --json` returns no tasks:

1. `bd ready --parent <root-id> --json` — get next unblocked task
2. `bd show <task-id> --json` — read task content (steps, code, verification commands)
3. `bd update <task-id> --claim` — mark in_progress (atomic assignment)
4. Execute each step from the task body
5. After each step completes, post progress: `bd comments add <task-id> "Step N complete"`
6. `bd close <task-id> --reason "Done"` — mark complete, unblocks dependents
7. Loop back to step 1

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

## When to Stop and Ask for Help

**STOP executing immediately when:**
- Hit a blocker (missing dependency, test fails, instruction unclear)
- Task bead has critical gaps preventing starting
- You don't understand an instruction
- Verification fails repeatedly

**Ask for clarification rather than guessing.**

## When to Revisit Earlier Steps

**Return to Review (Step 1) when:**
- Partner updates the task beads based on your feedback
- Fundamental approach needs rethinking

**Don't force through blockers** - stop and ask.

## Remember
- Review tasks critically first
- Follow task steps exactly
- Don't skip verifications
- Reference skills when task says to
- Stop when blocked, don't guess
- Never start implementation on main/master branch without explicit user consent

## Integration

**Required workflow skills:**
- **superpowers:using-git-worktrees** - REQUIRED: Set up isolated workspace before starting
- **superpowers:writing-plans** - Creates the task beads this skill executes
- **superpowers:finishing-a-development-branch** - Complete development after all tasks
