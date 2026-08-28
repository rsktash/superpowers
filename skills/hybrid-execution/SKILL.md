---
name: hybrid-execution
description: Use when executing implementation plans whose tasks carry Execution annotations - routes each task to inline execution or subagent dispatch per the annotation
---

# Hybrid Execution — budget 2900 words

Execute a plan task-by-task, routing each task to the mode its plan annotation names: trivial tasks run inline in this session; everything else goes to a fresh subagent. Dispatch is the default — inline is reserved for tasks where dispatch overhead exceeds the work itself.

**Why hybrid:** per-task routing keeps ceremony proportional and this session's context clean.

**This skill owns routing and scheduling.** The per-task procedure for `inline` lives in this skill's own Inline Task Procedure section below; the per-task procedure for `subagent/<tier>` — claim, BASE recording, dispatch, review package, termination evidence — lives in subagent-driven-development's Loop. Follow each exactly as written. What this skill adds on top is *when* those steps run: The Loop below pipelines each task's review against the next task's implementation.

- `inline` → the Inline Task Procedure below
- `subagent/<tier>` → superpowers-beads:subagent-driven-development, The Loop (per-task procedure), scheduled per The Loop below

**bd conventions:** Read `skills/shared/bd-defaults.md` before using any bd commands.

**Set up first:** REQUIRED SUB-SKILL — superpowers-beads:using-git-worktrees (isolated workspace before any task).

**Epic gate:** run `bd children <root-id>` first. An epic-type bead with no children — or with no `plan-ready:` comment on the root (`bd comment list <root-id> --last 5`) — is a spec or a half-written plan, not a plan: STOP and route to superpowers-beads:writing-plans; never improvise tasks from the epic body.

## The Loop

Loop until `bd ready --parent <root-id> --json` returns `[]`:

**Step 0 — pre-flight gate:** resolve the pre-flight marker per Pre-Flight Plan Review (superpowers-beads:subagent-driven-development) before this session's first claim, every entry mode alike.

1. Route the next ready task from `bd ready --parent <root-id> --json` — id and title from the list, mode from its `exec:` label (`bd label list <task-id>`): `inline` or `subagent/<tier>` (`cheap` | `standard` | `capable`). Legacy plan without the label: `bd get <task-id> body | grep -m1 '^\*\*Execution'` — the one line, never the body. A ready bead labeled `needs-plan` is not dispatchable — route it to writing-plans.
2. **Never open a task body in this session.** Routing, claiming, and closing need no contract — the executor (subagent, or you under the Inline Task Procedure) reads its own. Everything read here is resident to session end. The one sanctioned read is the **scope glance** at claim time: the task's Files section only (`bd show <task-id> --section files`, ~10 lines) — enough to catch a task whose size or file overlap contradicts the route. Steps, gates, and context stay unread here.

   **Source reads the same way: never upfront, only on a cited failure.** No survey of a task's files before dispatch — that is the planner's read. On a concrete FAIL or BLOCKED, open the cited hunk and the minimal contract or ruling clause: Termination requires verifying a finding against code and authority before it becomes an obligation, and delegating THAT makes the reviewer the product authority. Thin, not blind.
3. Announce the route as its own assistant-visible line naming the resolved model (per Model Tiers) — "Task N → subagent/standard → Sonnet (<reason>)", inline routes "Task N → inline (<reason>)" — emitted **before** the claim command. Assignee values, Bash command descriptions, and dispatch parameters are actions, not the announcement. Every route gets its line, however routine.
4. Execute by mode:
   - **inline** → follow the Inline Task Procedure (below) for this one task, start to close.
   - **subagent/<tier>** → follow subagent-driven-development's per-task procedure for this one task: claim it with `bd update <id> --status=in_progress --assignee "<you> / <model>"` — never `bd ... --claim`, which assigns the task to you and erases the model attribution the announcement just recorded. Record `BASE=$(git rev-parse HEAD)`, declare the review tier, then dispatch the implementer per subagent-driven-development's `implementer-prompt.md` — by bead id, the implementer fetches its own contract — including the test-scope directive (targeted tests only; the full-suite gate stays in this session).
5. **Pipeline the review — this is the default loop shape.** When task N's implementer reports DONE and its commits exist on the branch (`trivial-deterministic` tasks skip 5.1–5.2 entirely: run the one deterministic check yourself, close, move on — no package, no reviewer, nothing to pipeline):
   1. Freeze the evidence: `scripts/review-package BASE HEAD` (run from `skills/subagent-driven-development/`) writes the review package file. Record `HEAD_SHA=$(git rev-parse HEAD)`.
   2. Dispatch N's ONE combined spec+quality reviewer (`reviewer-prompt.md`; spec section outranks quality) **in the background**, handing it the frozen package file path. If the reviewer needs to run anything at all — targeted tests, greps — the controller first creates a temporary read-only worktree pinned at N's HEAD, `git worktree add .worktrees/review-<short-sha> <HEAD_SHA>`, names it in the prompt as the ONLY directory the reviewer may run commands in, and removes it (`git worktree remove .worktrees/review-<short-sha>`) after the verdict is processed.
   3. Immediately claim and dispatch task N+1 (steps 1–4). Do not idle on N's verdict — the frozen package cannot be perturbed by N+1's work, dispatched or inline.
   4. When N's verdict returns, process it per subagent-driven-development's Termination: deterministic artifacts only, verify findings before acting, close N only on visible evidence. Then delete the review file and remove the review worktree.
6. Loop — which means: wait for the in-flight implementer's DONE and re-enter at step 5. Never claim another ready task while an implementer is in flight; the loop's concurrency is one implementer plus background reviewers, and anything wider is Hybrid Parallel (below), opt-in only.

**Pipeline safety rules — non-negotiable:**

- **The reviewer reads the FROZEN package, never the live tree.** The tree moves the moment N+1 starts; a reviewer opening live files is reviewing N+1's half-finished work as if it were N's. Every path the reviewer touches is inside the package file or the read-only review worktree pinned at N's HEAD.
- **One verdict outstanding, max — per lane.** If N+1's implementer lands while N's verdict is still out, generate N+1's package, but process N's verdict before dispatching N+2. A stack of unprocessed verdicts is unreviewed work compounding. Under Hybrid Parallel the bound applies per branch lane: one outstanding verdict per implementer branch, processed before that lane's next dispatch.
- **A FAIL verdict on N freezes the frontier.** No new dispatches until the fix lands as commits on top of N's (never a rebase or rewrite of reviewed commits) — by the same implementer, or by the controller when subagent-driven-development's Fix Routing applies — and the fix clears re-review per subagent-driven-development's Review Tier — a controller-clearable fix flips on the reviewer's own named checks re-run at the fix tip; anything wider is a dispatched re-review whose package spans N's original BASE to the fix tip. An in-flight N+1 implementer may finish and report; nothing new starts. The re-review package spans N's original BASE to the fix tip; if an in-flight N+1 landed interleaved commits, they appear in the package's commit list — name that in the re-reviewer's dispatch so it judges only N's files.
- **Serial implementers, still.** Pipelining overlaps a *reviewer* with an implementer — never two implementers. One implementer in the session worktree at a time; anything wider requires Hybrid Parallel (below), which only your human partner can invoke, by name.

After the last task: drain the pipeline — process every outstanding verdict, fix and re-review anything open. Then close out per subagent-driven-development: suite gate, final whole-diff review, and using-git-worktrees' Finishing: Merge Back and Clean Up.

**Skip the final whole-diff review when the run closed exactly one task** — it spans the same BASE..HEAD the per-task reviewer already read. The suite gate still runs. From two tasks on it earns its place on cross-task seams.

## Hybrid Parallel (opt-in)

Frontier parallelism — 2–3 implementers running concurrently — activates ONLY when your human partner says the literal phrase **"hybrid parallel"**. "Go faster", "parallelize where you can", a wide frontier, or a deadline are not that phrase — under all of them the pipelined Loop is the ceiling: one implementer, always. If you believe a plan would benefit, ask; only a reply containing the literal phrase is consent. On the phrase, read `references/hybrid-parallel.md` and follow it exactly — width, eligibility, isolation, and merge-back live there.

## Inline Task Procedure

Follow this procedure for any task routed `inline`.

1. Get the contract and claim — never `--claim`:
   ```bash
   bd show <task-id>
   bd rulings <task-id>
   bd get <task-id> body > .bd/.scratch/progress.md
   bd update <task-id> --status=in_progress --assignee "$(git config user.name) / <model-name>"
   ```
   The rulings output is part of the contract: it is inheritance-resolved, so
   a ruling filed on the parent epic binds this task and no read of the task
   alone surfaces it. A ruling outranks the body it contradicts.
   Read `.bd/.scratch/progress.md` — it is your complete contract AND your working copy; the body enters context once, as the file you'll work in. If `bd show`'s section index lists `design`, also read `bd show <task-id> --section design`. Example assignee: "Alex / Claude Opus 4.6".
2. Extract the **Acceptance Gate** from the working copy — the machine-verifiable completion criteria (`- [ ]` lines under "Acceptance Gate"). Keep these visible; you re-read them between steps and verify them before closing.
3. If the task body references images, resolve them to local files and view them before implementing.
4. Checkbox flips happen in `.bd/.scratch/progress.md` — it already exists from step 1; never re-print the body to get a working copy.
5. For each step in the task body:
   - **First step only:** read everything listed under "Before you start" — files, rules, callers. Do not skip this.
   - **Attention refresh:** re-read the Acceptance Gate items before executing — attention on initial goals decays after 3–4 tool calls.
   - Execute the step.
   - In `.bd/.scratch/progress.md`, flip the step's `- [ ]` to `- [x]` with the Edit tool. Local edit only — do not `bd update` per step.
6. After all steps complete, sync the checkbox state to bd once: `bd update <task-id> --body-file .bd/.scratch/progress.md`. **Why:** per-step `bd update` roundtrips get skipped in practice; batching keeps the bookkeeping cheap enough to happen.
7. **Verify the Acceptance Gate before closing:**
   - Re-read every gate item from the task body.
   - Run the verification command for each (test, file check, grep for export).
   - If ALL pass: `bd close <task-id> --reason "Done — all gate items verified"`.
   - If ANY fail: do not close. Identify which items failed and why, fix them, then re-verify ALL items — not just the failed ones, since fixes can regress others. Only close once every item passes.
   - If gate verification fails twice, stop and ask your human partner.

**When a step fails:** do not retry the same edit. Read the full error output, then use superpowers-beads:systematic-debugging to diagnose before touching the file again — the next edit must fix a diagnosed cause, not adjust the previous guess.

**When a finding changes the plan:** if execution surfaces something that alters the plan — scope shift, different approach, new dependency, an acceptance-criteria adjustment — record it via `bd finding add <task-id> "<what changed and why>" --evidence "<file:line or command>"` before continuing. Don't log routine observations, only deviations that change what the plan says. A genuine design fork the plan left open is not yours to resolve inline: file `bd question add <task-id> "<the fork>"` and stop — the task leaves `bd ready` until a ruling answers it.

## Overriding an Annotation

The annotation is the default, not a cage — but every override must be stated, never silent:

- **Toward subagent** (annotation says `inline`, you dispatch): always allowed. State one line: what made the task bigger than planned.
- **Toward a lower subagent tier** (annotation says `capable`, the body argues for `standard`): **required, not optional** — provided the contract pins the mechanism; a task leaving a design fork to the executor stays `capable` however mechanical the reason reads. The annotation is a ceiling to validate, not a floor to honor. A reason describing mechanical work, a mirror, or a landed/reviewed template argues for `standard` at most — down-route to Sonnet and state the override. Down-routing has no gamble (Sonnet still gets a fresh reviewed subagent); honoring an inflated `capable` burns the session model on busywork. Tier measures the judgment the task demands — surface importance is not an axis.
- **Toward inline** (annotation says `subagent/*`, you execute it yourself): requires all four writing-plans criteria, read literally: 1 file (the task's Files list, not "one logical unit"), complete spec, gate verifiable in one command, no judgment. A multi-file task fails the first criterion however small the diff. "The files are already in my context", "it's only N lines", and "dispatch overhead exceeds the work" are not criteria — the last is the planner's standard for annotating `inline`, not yours for overriding to it. Any criterion fails → dispatch. State the justification before touching any file.
- **Missing annotation** (plan predates this skill): classify the task yourself against the rubric — fresh, per task, never by transcribing a dispatch plan or wave grouping already negotiated; scheduling never raises a tier. State the classification and reason, then proceed as if annotated.

**Why stated, not silent:** a silent downgrade is invisible and unchallengeable.

## Model Tiers

Tiers are abstract — resolve them against your human partner's standing model policy first (project memory, CLAUDE.md); a standing policy always overrides the default map. Default on Claude harnesses: `cheap` → Sonnet, `standard` → Sonnet, `capable` → the session's model.

A tier names the **judgment a task demands, not model cost.** `cheap` and `standard` both resolve to exactly Sonnet — the floor; "cheap" never licenses anything below it. `capable` → the session model is reserved for genuine design judgment or broad codebase synthesis, never the safe default for "anything non-trivial"; unsure between `standard` and `capable` → `standard`. State any tier change, in either direction, as a visible override. Down-routing presumes a pinned contract: a task whose steps leave a mechanism or design fork to the executor is `capable` regardless of file count — economize on the contract or on the executor, never both in one task. Full reasoning: `references/model-tiers.md`.

## Invariants

All invariants of the Inline Task Procedure and of subagent-driven-development apply unchanged — with one scoping note. Same-worktree implementer concurrency is forbidden everywhere, always; separate-worktree implementer concurrency is allowed ONLY under Hybrid Parallel, on your human partner's literal "hybrid parallel". Reviewer-vs-implementer overlap is always allowed (frozen package + read-only review worktree, per Pipeline safety rules).

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

An inline task touching files beyond its Files list is a drift-detector stop: revert the uncommitted work, re-route as `subagent/standard`, state the override. A test the change itself broke is in-contract to update and is not ballooning; a structural ban is.

## Integration

- **superpowers-beads:using-git-worktrees** — REQUIRED before starting (also owns Finishing: merge back + cleanup).
- **superpowers-beads:writing-plans** — produces the Execution annotations this skill routes on.
- **superpowers-beads:subagent-driven-development** — owns the dispatch/review procedure.
