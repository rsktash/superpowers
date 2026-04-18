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
3. Extract the **Acceptance Gate** from the task body. These are the machine-verifiable completion criteria (lines starting with `- [ ]` under the "Acceptance Gate" heading). Keep these visible — you will re-read them between steps and verify them before closing.
4. If the task body contains image references, resolve them to local files and view them before implementing.
5. Copy the task body into `.beads/.scratch/progress.md` once, at the start of the task. This is your working copy — you will check boxes here as steps complete, and sync to bd at the end.
6. For each step in the task body:
   a. If this is the first step: read everything listed in "Before you start" — files, rules, callers. Do not skip this.
   b. **Attention refresh:** Before executing, re-read the Acceptance Gate items. This counters attention drift — after 3-4 tool calls, the LLM's focus on initial goals decays. Re-injecting the gate keeps generative attention on the actual completion criteria.
   c. Execute the step
   d. In `.beads/.scratch/progress.md`, flip the step's `- [ ]` to `- [x]`. Local edit only — do not `bd update` per step.
7. After all steps complete, sync the final checkbox state to bd once: `bd update <task-id> --body-file .beads/.scratch/progress.md`
8. **Verify Acceptance Gate** before closing:
   - Re-read the Acceptance Gate items from the task body
   - For each item, run the verification command (test, file check, grep for export)
   - If ALL items pass: `bd close <task-id> --reason "Done — all gate items verified"`
   - If ANY item fails: Do NOT close. Instead:
     a. Identify which gate items failed and why
     b. Fix the failing items (this may mean re-executing steps or writing new code)
     c. Re-verify ALL gate items (not just the ones that failed — fixes can cause regressions)
     d. Only close after all items pass
   - If gate verification fails twice, stop and ask your human partner
9. Loop back to step 1

**Why batch the checkbox sync?** Earlier versions required a `bd update` after every step for interruption recovery. In practice LLMs skipped it — the per-step bd roundtrip was expensive enough that it got dropped. Batching (one `bd update` per task) keeps the bookkeeping cheap enough to actually happen. Tradeoff: if a session dies mid-task, the next session re-runs the task rather than resuming mid-step. This is acceptable because task steps are expected to be idempotent and tasks are scoped small.

**When a finding changes the plan:** If execution surfaces something that alters the plan — scope shift, different approach than the spec, new dependency discovered, acceptance criteria adjustment, assumption that turned out wrong — record it via `bd comments add <task-id> "<what changed and why>"` before continuing. Do NOT log routine observations or every finding — only deviations that change what the plan says. **Why:** The task body shows the *current* plan; comments show *how we got here*. Without this, reviewers and future sessions cannot distinguish intentional deviations from drift.

**When a step fails:** Do not retry the same edit. Read the error output fully, then use superpowers-beads:systematic-debugging to diagnose before touching the file again. The second edit must fix a diagnosed cause, not adjust the previous guess.

**Note:** Closing the last child task may auto-close the parent epic. This is expected — the epic will still be accessible via `bd show`.

Task-level progress is visible in beads-ui once the task completes and syncs. Plan-altering findings (logged as comments, see below) appear in real time.

### Resuming After Interruption

If starting a new session to continue work on an existing feature:

1. Find the root bead ID: glob `docs/beads/*-bd-*.md` — the bead ID is in the filename
2. `bd show <root-id> --json` — list all child beads and their statuses (open, in_progress, closed)
3. For any in-progress task, re-run it from the first unchecked step in the task body. Because checkbox sync happens at task end, an interrupted task's body still shows all boxes unchecked — treat the task as not-yet-started and re-execute. Task steps are expected to be idempotent.
4. Continue with `bd ready --parent <root-id> --json` for remaining unblocked tasks

### Step 3: Complete Development

After all tasks complete and verified:
- Pass the root bead ID to finishing-a-development-branch so it can close the epic and include the bead ID in commits.
- Announce: "I'm using the finishing-a-development-branch skill to complete this work."
- **REQUIRED SUB-SKILL:** Use superpowers-beads:finishing-a-development-branch
- Follow that skill to verify tests, present options, execute choice

## When to Stop and Ask Your Human Partner

**When you encounter work not described in the current task — stop.** Do not skip it. Do not guess.

This includes:
- A missing dependency, API, or component that must exist for your task to proceed
- A bug or edge case unrelated to the current task
- A test that requires functionality not yet implemented
- An instruction you don't understand
- A verification that fails repeatedly
- A drift detector violation — you're editing files not listed in the task's Files section, or doing work that another task's drift detectors say is their responsibility

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
- When a step fails, diagnose before re-editing — use superpowers-beads:systematic-debugging
- After 2 failed attempts at the same step, stop and ask your human partner
- Never start implementation on main/master branch without explicit user consent
- Verify the Acceptance Gate before closing ANY task — never close based on "it looks done"
- Re-read the Acceptance Gate between steps — attention drifts after 3-4 tool calls
- If a gate item fails, fix and re-verify ALL items, not just the failed one

## Integration

**Required workflow skills:**
- **superpowers-beads:using-git-worktrees** - REQUIRED: Set up isolated workspace before starting
- **superpowers-beads:writing-plans** - Creates the task beads this skill executes
- **superpowers-beads:finishing-a-development-branch** - Complete development after all tasks
