---
name: hybrid-execution
description: Use when executing implementation plans whose tasks carry Execution annotations - routes each task to inline execution or subagent dispatch per the annotation
---

# Hybrid Execution

Execute a plan task-by-task, routing each task to the mode its plan annotation names: trivial tasks run inline in this session; everything else goes to a fresh subagent. Subagent dispatch is the default — inline is the exception, reserved for tasks where dispatch overhead exceeds the work itself.

**Why hybrid:** A whole-plan mode choice is too coarse. Plans mix trivial tasks (config bump, rename) with complex ones (multi-file integration). Dispatching a subagent for a 2-minute edit is pure ceremony; executing a heavy task inline floods this session's context with implementation detail and degrades every review that follows. Routing per task keeps ceremony proportional and this session's context clean.

**This skill owns routing only.** The per-task procedures live in the two skills it routes to — follow them exactly as written; do not improvise a blend:

- `inline` → superpowers-beads:executing-plans, Step 2 (Execute Tasks) procedure
- `subagent/<tier>` → superpowers-beads:subagent-driven-development, The Loop

**bd conventions:** Read `skills/shared/bd-defaults.md` before using any bd commands.

**Set up first:** REQUIRED SUB-SKILL — superpowers-beads:using-git-worktrees (isolated workspace before any task).

## The Loop

Loop until `bd ready --parent <root-id> --json` returns `[]`:

1. `bd show <task-id> --full` — read the next ready task.
2. Find its `**Execution:**` line: `inline` or `subagent/<tier>` (`cheap` | `standard` | `capable`), each carrying the planner's one-line reason.
3. Announce the route in one line, naming the model the tier resolves to (per Model Tiers): "Task N → subagent/standard → Sonnet (<planner's reason, or your override reason>)". Inline routes announce "Task N → inline (<reason>)". The announcement is not optional and the model is not implied — an unnamed model is unauditable from the transcript.
4. Execute by mode:
   - **inline** → follow executing-plans Step 2 for this one task: set assignee, copy the body to `.bd/.scratch/progress.md`, attention-refresh the Acceptance Gate between steps, verify every gate item before closing.
   - **subagent/<tier>** → follow subagent-driven-development's loop for this one task: set assignee to the implementer's model, dispatch with the directive sections at the top of the prompt, declare the review tier, run spec then quality checks terminating in deterministic artifacts, close only on visible evidence.
5. Loop.

After the last task: dispatch one final review of the whole diff (per subagent-driven-development), then use superpowers-beads:finishing-a-development-branch.

## Overriding an Annotation

The annotation is the default, not a cage — but every override must be stated, never silent:

- **Toward subagent** (annotation says `inline`, you dispatch): always allowed. State one line: what made the task bigger than planned.
- **Toward inline** (annotation says `subagent/*`, you execute it yourself): requires justification against the rubric in writing-plans — all four criteria, read literally: 1 file (the task's Files list, not "one logical unit"), complete spec, gate verifiable in one command, no judgment. A multi-file task fails the first criterion no matter how small the diff or how much context you already hold. "The files are already in my context", "it's only N lines", and "dispatch overhead exceeds the work" are not criteria — the last is the planner's standard for annotating `inline`, not yours for overriding to it. If any criterion fails, dispatch. State the justification before touching any file.
- **Missing annotation** (plan predates this skill): classify the task yourself against the rubric — fresh, per task, never by transcribing a dispatch plan or wave grouping already negotiated; scheduling never raises a tier. State the classification and reason, then proceed as if annotated.

**Why stated, not silent:** silently downgrading to inline reads identically to having dispatched and reviewed. The problem isn't judging a task trivial — it's making that judgment invisible and unchallengeable.

## Model Tiers

Tiers are abstract — map them to whatever harness you run on; for example, on Claude harnesses: `cheap` → Haiku, `standard` → Sonnet, `capable` → the session's model. Never downgrade a tier without stating it as an override.

## Invariants

All invariants of both routed skills apply unchanged. In addition:

**Never:**
- Dispatch an implementer while uncommitted inline edits exist in the worktree — commit or revert first.
- Execute a `subagent/capable` task inline. If it needs design judgment, it needs dispatch — or escalate to your human partner.
- Blend procedures: an inline task gets executing-plans' gate verification; a dispatched task gets subagent-driven-development's two checks. No task gets a mixture, and no task gets neither.

## When an Inline Task Balloons

If an inline task starts touching files beyond its Files list, that is a drift-detector stop (per executing-plans). Recovery: revert the uncommitted work, re-route the task as `subagent/standard`, and state the override. Do not push through inline.

## Integration

- **superpowers-beads:using-git-worktrees** — REQUIRED before starting.
- **superpowers-beads:writing-plans** — produces the Execution annotations this skill routes on.
- **superpowers-beads:executing-plans** — owns the inline per-task procedure.
- **superpowers-beads:subagent-driven-development** — owns the dispatch/review procedure.
- **superpowers-beads:finishing-a-development-branch** — after all tasks complete.
