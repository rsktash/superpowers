---
name: hybrid-execution
description: Use when executing implementation plans whose tasks carry Execution annotations - routes each task to inline execution or subagent dispatch per the annotation
---

# Hybrid Execution

Execute a plan task-by-task, routing each task to the mode its plan annotation names: trivial tasks run inline in this session; everything else goes to a fresh subagent. Subagent dispatch is the default — inline is the exception, reserved for tasks where dispatch overhead exceeds the work itself.

**Why hybrid:** A whole-plan mode choice is too coarse. Plans mix trivial tasks (config bump, rename) with complex ones (multi-file integration). Dispatching a subagent for a 2-minute edit is pure ceremony; executing a heavy task inline floods this session's context with implementation detail and degrades every review that follows. Routing per task keeps ceremony proportional and this session's context clean.

**This skill owns routing and scheduling.** The per-task procedure for `inline` lives in this skill's own Inline Task Procedure section below; the per-task procedure for `subagent/<tier>` — claim, BASE recording, dispatch, review package, termination evidence — lives in subagent-driven-development's Loop. Follow each exactly as written; do not improvise a blend. What this skill adds on top is *when* those steps run: The Loop below pipelines each task's review against the next task's implementation.

- `inline` → the Inline Task Procedure below
- `subagent/<tier>` → superpowers-beads:subagent-driven-development, The Loop (per-task procedure), scheduled per The Loop below

**bd conventions:** Read `skills/shared/bd-defaults.md` before using any bd commands.

**Set up first:** REQUIRED SUB-SKILL — superpowers-beads:using-git-worktrees (isolated workspace before any task).

**Epic gate:** run `bd children <root-id>` first. An epic-type bead with no children is a spec, not a plan — STOP and route to superpowers-beads:writing-plans; never improvise tasks from the epic body.

**Before the first routed task:** run Pre-Flight Plan Review (superpowers-beads:subagent-driven-development) over the whole plan and batch any findings into one question to your human partner. Then set up the Session Task List display mirror (per subagent-driven-development): replace the session todo list wholesale — one todo per task bead, `<bead-id>: <title>`, in plan order — and thereafter flip todos only at claim (in_progress) and close (completed), for inline and dispatched tasks alike. bd stays the single source of truth.

## The Loop

Loop until `bd ready --parent <root-id> --json` returns `[]`:

1. `bd show <task-id> --full` — read the next ready task.
2. Find its `**Execution:**` line: `inline` or `subagent/<tier>` (`cheap` | `standard` | `capable`), each carrying the planner's one-line reason.
3. Announce the route as its own assistant-visible line naming the resolved model (per Model Tiers): "Task N → subagent/standard → Sonnet (<reason>)"; inline routes announce "Task N → inline (<reason>)". Emit it **before** the claim command. The model name inside an `--assignee` value, a Bash command description, or the dispatch parameter does **not** count — those are actions, not the announcement. A routine route you've used all session still gets its line; cadence is exactly when it gets dropped.
4. Execute by mode:
   - **inline** → follow the Inline Task Procedure (below) for this one task, start to close.
   - **subagent/<tier>** → follow subagent-driven-development's per-task procedure for this one task: claim it with `bd update <id> --status=in_progress --assignee "<you> / <model>"` — never `bd ... --claim`, which assigns the task to you and erases the model attribution the announcement just recorded. Record `BASE=$(git rev-parse HEAD)`, declare the review tier, then dispatch the implementer with the directive sections at the top of the prompt — including subagent-driven-development's test-scope directive (targeted tests only; the full-suite gate stays in this session).
5. **Pipeline the review — this is the default loop shape.** When task N's implementer reports DONE and its commits exist on the branch (`trivial-deterministic` tasks skip 5.1–5.2 entirely: run the one deterministic check yourself, close, move on — no package, no reviewer, nothing to pipeline):
   1. Freeze the evidence: `scripts/review-package BASE HEAD` (run from `skills/subagent-driven-development/`) writes the review package file. Record `HEAD_SHA=$(git rev-parse HEAD)`.
   2. Dispatch N's ONE combined spec+quality reviewer (`reviewer-prompt.md`; spec section outranks quality) **in the background**, handing it the frozen package file path. If the reviewer needs to run anything at all — targeted tests, greps — the controller first creates a temporary read-only worktree pinned at N's HEAD, `git worktree add .worktrees/review-<short-sha> <HEAD_SHA>`, names it in the prompt as the ONLY directory the reviewer may run commands in, and removes it (`git worktree remove .worktrees/review-<short-sha>`) after the verdict is processed.
   3. Immediately claim and dispatch task N+1 (steps 1–4). Do not idle on N's verdict — the frozen package cannot be perturbed by N+1's work, dispatched or inline.
   4. When N's verdict returns, process it per subagent-driven-development's Termination: deterministic artifacts only, verify findings before acting, close N only on visible evidence. Then delete the review file and remove the review worktree.
6. Loop — which means: wait for the in-flight implementer's DONE and re-enter at step 5. Never claim another ready task while an implementer is in flight; the loop's concurrency is one implementer plus background reviewers, and anything wider is Hybrid Parallel (below), opt-in only.

**Pipeline safety rules — non-negotiable:**

- **The reviewer reads the FROZEN package, never the live tree.** The working tree moves the moment N+1 starts; a reviewer that opens live files is reviewing N+1's half-finished work as if it were N's. Every path the reviewer touches is either inside the package file or inside the read-only review worktree pinned at N's HEAD — no exceptions, including "it's probably the same commits."
- **One verdict outstanding, max — per lane.** If N+1's implementer lands while N's verdict is still out, generate N+1's package, but process N's verdict before dispatching N+2. A stack of unprocessed verdicts is unreviewed work compounding. Under Hybrid Parallel the bound applies per branch lane: one outstanding verdict per implementer branch, processed before that lane's next dispatch.
- **A FAIL verdict on N freezes the frontier.** No new dispatches until the same implementer lands the fix as commits on top of N's (never a rebase or rewrite of reviewed commits) and the fix is re-reviewed to PASS. An in-flight N+1 implementer may finish and report; nothing new starts. The re-review package spans N's original BASE to the fix tip; if an in-flight N+1 landed interleaved commits, they appear in the package's commit list — name that in the re-reviewer's dispatch so it judges only N's files.
- **Serial implementers, still.** Pipelining overlaps a *reviewer* with an implementer — never two implementers. One implementer in the session worktree at a time; anything wider requires Hybrid Parallel (below), which only your human partner can invoke, by name.

After the last task: drain the pipeline — process every outstanding verdict, fix and re-review anything open. Then run the full test suite once from this session (backgrounded — the suite gate belongs to the orchestrator, whose cache survives the wait), dispatch one final review of the whole diff (per subagent-driven-development), then finish per using-git-worktrees' Finishing: Merge Back and Clean Up.

## Hybrid Parallel (opt-in)

Frontier parallelism — 2–3 implementers running concurrently — exists, but it is never the default and never inferred. It activates ONLY when your human partner explicitly says **"hybrid parallel"**. "Go faster", "parallelize where you can", a wide ready frontier, or a looming deadline are not that phrase — under all of them, the pipelined Loop above is the ceiling: one implementer, always. If you believe a plan would benefit, ask — and treat only a reply containing the literal phrase as consent; "yes, speed it up" is not it. The moment the phrase is spoken, read `references/hybrid-parallel.md` and follow it exactly — width, eligibility, isolation, and merge-back rules all live there.

## Inline Task Procedure

Follow this procedure for any task routed `inline`.

1. Read the task and set the assignee — never `--claim`:
   ```bash
   bd show <task-id> --full
   bd update <task-id> --status=in_progress --assignee "$(git config user.name) / <model-name>"
   ```
   Example assignee: "Alex / Claude Opus 4.6"
   Flip the task's todo to in_progress.
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
   - If ALL pass: `bd close <task-id> --reason "Done — all gate items verified"` (todo → completed).
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

A tier names the **judgment a task demands, not model cost.** `cheap` and `standard` both resolve to exactly Sonnet — Sonnet is the floor; "cheap" never licenses anything below it. `capable` → the session model is reserved for genuine design judgment or broad codebase synthesis, never the safe default for "anything non-trivial"; genuinely unsure between `standard` and `capable` → pick `standard`. State any tier change, in either direction, as a visible override. Full reasoning (why the floor sits where it does, what belongs on `standard`): `references/model-tiers.md`.

## Invariants

All invariants of the Inline Task Procedure and of subagent-driven-development apply unchanged — with one scoping note. Subagent-driven-development's "never run two implementers in parallel on the same worktree" stands exactly as written: same-worktree implementer concurrency is forbidden everywhere, always. Separate-worktree implementer concurrency is allowed ONLY under Hybrid Parallel, on your human partner's literal "hybrid parallel". Reviewer-vs-implementer overlap, by contrast, is always allowed — the reviewer works from the frozen package and, for command runs, the controller's read-only review worktree; it never touches the live working tree, so there is nothing for it to collide with.

In addition, **never:**
- Dispatch an implementer while uncommitted inline edits exist in the worktree — commit or revert first. Pipelining does not loosen this: task N's commits exist before N's package is generated, and the live tree is clean of uncommitted inline edits before N+1's implementer starts.
- Run implementers concurrently outside Hybrid Parallel — and even inside it, never two in one worktree, never more than 2–3 total, never on tasks whose Files lists overlap or that share a Consumes-From edge.
- Point a reviewer at the live working tree, or dispatch new work past an unresolved FAIL verdict.
- Execute a `subagent/capable` task inline. If it needs design judgment, it needs dispatch — or escalate to your human partner.
- Blend procedures: an inline task gets the Inline Task Procedure's gate verification; a dispatched task gets subagent-driven-development's combined review. No task gets a mixture, and no task gets neither.
- Let a dispatched implementer run the full test suite — targeted tests only; the suite gate runs once, in this session. A dispatched implementer that backgrounds a job must finish it before ending its turn.

## Red Flags — STOP

Mis-route incoming if you catch yourself thinking:

- *"`bd update --claim` is the quick way to take the task."* — `--claim` assigns it to *you*, not the implementer model. Use `--assignee "… / <model>"`.
- *"The assignee names the model, so the route is recorded."* — Assignee ≠ announcement. Emit the visible line first.
- *"It's cheap / simple / busywork — use the cheapest model."* — `cheap` → Sonnet, full stop. Sonnet is the floor.
- *"Annotation says `capable`; honoring it is safer than downgrading."* — Inflated `capable` on mechanical/template work down-routes to Sonnet; no gamble. (Surface importance is not a tier axis.)
- *"The frontier is wide and the tasks look independent — spin up parallel implementers."* — Width is not consent. Hybrid Parallel starts on the literal words "hybrid parallel" from your human partner, nothing else.
- *"The reviewer can just read the current tree — it's the same commits."* — It isn't, the moment N+1 starts. Frozen package or the read-only review worktree; the live tree is never review input.

## When an Inline Task Balloons

If an inline task starts touching files beyond its Files list, that is a drift-detector stop. Recovery: revert the uncommitted work, re-route the task as `subagent/standard`, and state the override. Do not push through inline.

## Integration

- **superpowers-beads:using-git-worktrees** — REQUIRED before starting (also owns Finishing: merge back + cleanup).
- **superpowers-beads:writing-plans** — produces the Execution annotations this skill routes on.
- **superpowers-beads:subagent-driven-development** — owns the dispatch/review procedure.
