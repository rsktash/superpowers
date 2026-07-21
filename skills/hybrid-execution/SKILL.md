---
name: hybrid-execution
description: Use when executing implementation plans whose tasks carry Execution annotations - routes each task to inline execution or subagent dispatch per the annotation
---

# Hybrid Execution

Execute a plan task-by-task, routing each task to the mode its plan annotation names: trivial tasks run inline in this session; everything else goes to a fresh subagent. Subagent dispatch is the default — inline is the exception, reserved for tasks where dispatch overhead exceeds the work itself.

**Why hybrid:** A whole-plan mode choice is too coarse. Plans mix trivial tasks (config bump, rename) with complex ones (multi-file integration). Dispatching a subagent for a 2-minute edit is pure ceremony; executing a heavy task inline floods this session's context with implementation detail and degrades every review that follows. Routing per task keeps ceremony proportional and this session's context clean.

**This skill owns routing only.** The per-task procedure for `inline` lives in this skill's own Inline Task Procedure section below; the procedure for `subagent/<tier>` lives in subagent-driven-development's Loop — follow each exactly as written; do not improvise a blend:

- `inline` → the Inline Task Procedure below
- `subagent/<tier>` → superpowers-beads:subagent-driven-development, The Loop

**bd conventions:** Read `skills/shared/bd-defaults.md` before using any bd commands.

**Set up first:** REQUIRED SUB-SKILL — superpowers-beads:using-git-worktrees (isolated workspace before any task).

## The Loop

Loop until `bd ready --parent <root-id> --json` returns `[]`:

1. `bd show <task-id> --full` — read the next ready task.
2. Find its `**Execution:**` line: `inline` or `subagent/<tier>` (`cheap` | `standard` | `capable`), each carrying the planner's one-line reason.
3. Announce the route as its own assistant-visible line naming the resolved model (per Model Tiers): "Task N → subagent/standard → Sonnet (<reason>)"; inline routes announce "Task N → inline (<reason>)". Emit it **before** the claim command. The model name inside an `--assignee` value, a Bash command description, or the dispatch parameter does **not** count — those are actions, not the announcement. A routine route you've used all session still gets its line; cadence is exactly when it gets dropped.
4. Execute by mode:
   - **inline** → follow the Inline Task Procedure (below) for this one task.
   - **subagent/<tier>** → follow subagent-driven-development's loop for this one task: claim it with `bd update <id> --status=in_progress --assignee "<you> / <model>"` — never `bd ... --claim`, which assigns the task to you and erases the model attribution the announcement just recorded. Then dispatch with the directive sections at the top of the prompt — including subagent-driven-development's cache guard (targeted tests only; the full-suite gate stays in this session) — declare the review tier, run the ONE combined spec+quality review (`reviewer-prompt.md`; spec section outranks quality) terminating in deterministic artifacts, close only on visible evidence.
5. Loop.

After the last task: run the full test suite once from this session (backgrounded — the suite gate belongs to the orchestrator, whose cache survives the wait), dispatch one final review of the whole diff (per subagent-driven-development), then finish per using-git-worktrees' Finishing: Merge Back and Clean Up.

## Inline Task Procedure

Follow this procedure for any task routed `inline`.

1. Read the task and set the assignee — never `--claim`:
   ```bash
   bd show <task-id> --full
   bd update <task-id> --status=in_progress --assignee "$(git config user.name) / <model-name>"
   ```
   Example assignee: "Alex / Claude Opus 4.6"
2. Extract the **Acceptance Gate** from the task body — the machine-verifiable completion criteria (`- [ ]` lines under "Acceptance Gate"). Keep these visible; you re-read them between steps and verify them before closing.
3. If the task body references images, resolve them to local files and view them before implementing.
4. Copy the task body into `.bd/.scratch/progress.md` once, at the start of the task — this is your working copy for checkbox flips.
5. For each step in the task body:
   - **First step only:** read everything listed under "Before you start" — files, rules, callers. Do not skip this.
   - **Attention refresh:** before executing, re-read the Acceptance Gate items. Attention on initial goals decays after 3-4 tool calls; re-injecting the gate keeps focus on the actual completion criteria.
   - Execute the step.
   - In `.bd/.scratch/progress.md`, flip the step's `- [ ]` to `- [x]` with the Edit tool. Local edit only — do not `bd update` per step.
6. After all steps complete, sync the checkbox state to bd once: `bd update <task-id> --body-file .bd/.scratch/progress.md`. **Why:** a per-step `bd update` roundtrip is expensive enough that it gets skipped in practice; batching to once per task keeps the bookkeeping cheap enough to actually happen.
7. **Verify the Acceptance Gate before closing:**
   - Re-read every gate item from the task body.
   - Run the verification command for each (test, file check, grep for export).
   - If ALL pass: `bd close <task-id> --reason "Done — all gate items verified"`.
   - If ANY fail: do not close. Identify which items failed and why, fix them, then re-verify ALL items — not just the failed ones, since fixes can regress others. Only close once every item passes.
   - If gate verification fails twice, stop and ask your human partner.

**When a step fails:** do not retry the same edit. Read the full error output, then use superpowers-beads:systematic-debugging to diagnose before touching the file again — the next edit must fix a diagnosed cause, not adjust the previous guess.

**When a finding changes the plan:** if execution surfaces something that alters the plan — scope shift, different approach, new dependency, an acceptance-criteria adjustment — record it via `bd comments add <task-id> "<what changed and why>"` before continuing. Don't log routine observations, only deviations that change what the plan says.

## Overriding an Annotation

The annotation is the default, not a cage — but every override must be stated, never silent:

- **Toward subagent** (annotation says `inline`, you dispatch): always allowed. State one line: what made the task bigger than planned.
- **Toward a lower subagent tier** (annotation says `capable`, the body argues for `standard`): **required, not optional.** The annotation is a ceiling to validate, not a floor to honor. If the body's reason describes mechanical work, a mirror, or adoption of a landed/reviewed template, it argues for `standard` at most — down-route to `subagent/standard` → Sonnet and state the override. There is no gamble in down-routing (Sonnet still gets a fresh reviewed subagent); honoring an inflated `capable` just burns the session model on busywork. "Important/user-facing" is not a tier axis — tier measures the judgment the task demands, nothing else.
- **Toward inline** (annotation says `subagent/*`, you execute it yourself): requires justification against the rubric in writing-plans — all four criteria, read literally: 1 file (the task's Files list, not "one logical unit"), complete spec, gate verifiable in one command, no judgment. A multi-file task fails the first criterion no matter how small the diff or how much context you already hold. "The files are already in my context", "it's only N lines", and "dispatch overhead exceeds the work" are not criteria — the last is the planner's standard for annotating `inline`, not yours for overriding to it. If any criterion fails, dispatch. State the justification before touching any file.
- **Missing annotation** (plan predates this skill): classify the task yourself against the rubric — fresh, per task, never by transcribing a dispatch plan or wave grouping already negotiated; scheduling never raises a tier. State the classification and reason, then proceed as if annotated.

**Why stated, not silent:** silently downgrading to inline reads identically to having dispatched and reviewed. The problem isn't judging a task trivial — it's making that judgment invisible and unchallengeable.

## Model Tiers

Tiers are abstract — resolve them against your human partner's standing model policy first (project memory, CLAUDE.md); a standing policy always overrides the default map. Default on Claude harnesses: `cheap` → Sonnet, `standard` → Sonnet, `capable` → the session's model.

A tier names the **judgment a task demands, not model cost.** `cheap` and `standard` both resolve to exactly Sonnet — Sonnet is the floor, there is no cheaper tier; "cheap" never licenses anything below Sonnet however small the task or cost-conscious your partner. State any tier change, in either direction, as a visible override.

**The `standard` floor now sits just under the session tier.** The current Sonnet (Sonnet 5 today) is close to the session model, not well beneath it as earlier Sonnets were. So `capable` → the session model is reserved for tasks demanding genuine design judgment or broad codebase synthesis — it is **not** the safe default for "anything non-trivial." Multi-file integration, mechanical mirrors, and adoption of a landed/reviewed template all belong on `standard` → Sonnet; the narrowed gap means down-routing an inflated `capable` costs almost nothing in quality while saving the session model for where its edge actually shows. When you're genuinely unsure between `standard` and `capable`, pick `standard` — a fresh reviewed Sonnet subagent makes that the low-risk side. (The map stays version-agnostic: `standard` resolves to whatever the current Sonnet is; "Sonnet 5" is just today's concrete anchor.)

## Invariants

All invariants of the Inline Task Procedure and of subagent-driven-development apply unchanged. In addition:

**Never:**
- Dispatch an implementer while uncommitted inline edits exist in the worktree — commit or revert first.
- Execute a `subagent/capable` task inline. If it needs design judgment, it needs dispatch — or escalate to your human partner.
- Blend procedures: an inline task gets the Inline Task Procedure's gate verification; a dispatched task gets subagent-driven-development's combined review. No task gets a mixture, and no task gets neither.
- Let a dispatched implementer run the full test suite or poll its own background jobs — targeted tests only; the suite gate runs once, in this session, backgrounded.

## Red Flags — STOP

Mis-route incoming if you catch yourself thinking:

- *"`bd update --claim` is the quick way to take the task."* — `--claim` assigns it to *you*, not the implementer model. Use `--assignee "… / <model>"`.
- *"The assignee names the model, so the route is recorded."* — Assignee ≠ announcement. Emit the visible line first.
- *"It's cheap / simple / busywork — use the cheapest model."* — `cheap` → Sonnet, full stop. Sonnet is the floor.
- *"Annotation says `capable`; honoring it is safer than downgrading."* — Inflated `capable` on mechanical/template work down-routes to Sonnet; no gamble. (Surface importance is not a tier axis.)

## When an Inline Task Balloons

If an inline task starts touching files beyond its Files list, that is a drift-detector stop. Recovery: revert the uncommitted work, re-route the task as `subagent/standard`, and state the override. Do not push through inline.

## Integration

- **superpowers-beads:using-git-worktrees** — REQUIRED before starting (also owns Finishing: merge back + cleanup).
- **superpowers-beads:writing-plans** — produces the Execution annotations this skill routes on.
- **superpowers-beads:subagent-driven-development** — owns the dispatch/review procedure.
