---
name: subagent-driven-development
description: Use when executing implementation plans with independent tasks in the current session
---

# Subagent-Driven Development — budget 3556 words

Execute a plan by dispatching a fresh subagent per task, reviewing each task's output before moving to the next.

**Why subagents:** You construct exactly the context each task needs — subagents never inherit your session history. This keeps them focused and preserves your own context for coordination.

**bd conventions:** Read `skills/shared/bd-defaults.md` once per session, skip if already read.

**Set up first:** REQUIRED SUB-SKILL — superpowers-beads:using-git-worktrees (isolated workspace before any task).

**Epic gate:** run `bd children <root-id>` first. An epic-type bead with no children — or with no `plan-ready:` label on the root (`bd label list <root-id>`) — is a spec or a half-written plan, not a plan: STOP and route to superpowers-beads:writing-plans; never improvise tasks from the epic body.

## Pre-Flight Plan Review

**Pre-flight runs ONCE per plan and never again.** Its one pass spends a reader on the semantic residue no script and no downstream gate can reach. Mechanical citation truth is not its job: writing-plans' citation lint already proved every cited path, symbol, string, and commit claim at `bd create` time.

**Why:** a second pass over landed work returns what the workflow already catches downstream — executors read `bd workfile <id>`'s header (rulings print before the body file is Read) and re-read every cited file under "Before you start", and Drift Detectors stop a task whose premises moved — so it re-reads the whole remaining plan to buy nothing.

**Marker.** A completed pre-flight (findings resolved) is recorded on the root bead: `bd comment add <root-id> "[pre-flight] <short-sha> / open: <id> <id> …"` — the commit it certified and the open beads it covered. The sha is a record of WHEN the review happened, never a freshness key: there is no stale state and no scoped re-run.

**At execution entry**, resolve the root's newest marker — `bd comment list <root-id> --tag pre-flight --last 1` (tag filtering is applied before `--last`, so the marker cannot scroll out of view):

- **No marker** → run the full review below over the epic spec plus ALL open beads, then write the marker.
- **Marker present** → skip: one line citing it, then start. Whatever has landed since does not matter.

A body rewritten after the marker is the rewriter's job — writing-plans' citation lint runs at write time — never a trigger for a second pre-flight.

Run the review as ONE READ-ONLY subagent per epic: the in-scope plan enters that agent's context, never yours. Its prompt: read the epic and the in-scope open children, check the five classes below — against each other AND against the current tree — return findings only, no edits, no bd writes. These are the semantic residue a script cannot reach:

1. **Tasks that contradict each other or the spec** — two tasks disagreeing on an interface, format, or decision, or a task drifting from what the spec says.
2. **Anything a task ASKS FOR that a reviewer would flag as a defect** — the plan mandating a bug (e.g. a pinned target type over a documented source with no adapter named between them).
3. **Missing dependency edges the task bodies imply** — a task that reads/consumes something a sibling task produces, with no dep link between them.
4. **Stale premises** — a task body the current tree already contradicts: a "watch it fail" step that is already green, a cited symbol a landed task changed, a resource two writers now own. This is the one pass where the plan is read against the tree it will actually run on.
5. **Unreturned forks** — a pin whose cited authority exists but does not say that, or a fork the planner resolved by analogy instead of returning. The citation lint proves existence; only a reader can check that the authority actually rules what the pin claims.

A finding may not itself rest on a prediction of rendered behavior: its reading-checkable part — a real contradiction with the spec or design record — returns under the classes above; what only a browser can settle returns as a proposed browser-gate item, never as a NEEDS FIX with a prescribed repair.

Batch ALL findings into ONE question to your human partner before the session's first claim — never drip them out mid-run as you happen to notice each one: one batched question costs one interruption instead of five. If the review turns up nothing, say so in one line and start.

A ready bead labeled `needs-plan` is not dispatchable — it is a filed finding, not a planned task; it goes through writing-plans (or a decision bead) before it can be claimed.

## The Loop

For each task, in order:

1. Claim it (do NOT use --claim): `bd update <task-id> --status=in_progress --assignee "$(git config user.name) / <implementer-model-name>"` (e.g. "Alex / Claude Sonnet 4.6" — the model of the implementer subagent you dispatch for this task per **Model Selection**, since that subagent does the work). Record `BASE=$(git rev-parse HEAD)` — the pre-dispatch commit the review package will diff against. Then dispatch the implementer per `implementer-prompt.md` — the prompt carries the bead id, a one-line mission, orchestrator addenda (task-specific facts only, each citing a same-session tool run), and the **test-scope directive** (targeted tests only, never the full suite — the suite gate runs once, in this session). The implementer fetches its own contract from bd; **never open the task body in this session** — routing, claiming, and closing need no contract, and everything you paste or read here is resident to session end. The one read sanctioned at claim time is the **scope glance**: the task's Files block only (`bd get <task-id> body | sed -n '/^\*\*Files:\*\*/,/^$/p'`, ~10 lines) — enough to catch a task whose size or file overlap contradicts the route before an implementer burns a session on it. Steps, gates, and context stay unread here. Static environment boilerplate — repo layout, bd invocation, test commands, worktree rules — lives once in the project's `docs/dispatch-env.md` (create it on the project's first-ever dispatch); the constant behavioral doctrine (discipline, escalation, self-review, report format) ships inside the plugin as the `superpowers-beads:implementer` agent's own system prompt. Prompts restate neither. Gates may run in the foreground; if the implementer backgrounds a command, it must poll it to completion before ending its turn — an agent that stops with a live background child sends no completion notification (silent stall).
2. Answer any questions the implementer asks *before* it proceeds.
3. Generate the review package: `scripts/review-package BASE HEAD` (run from this skill's directory — `skills/subagent-driven-development/`; BASE is the pre-dispatch commit recorded in step 1 — NEVER `HEAD~1`, which silently drops all but the last commit of a multi-commit task). The script prints two lines — the package file path, then the pinned review worktree path at HEAD, creating or reusing it — and both are recorded. Pass the reviewer the package file path and name the worktree as the ONLY directory it may run commands in. Review the result (see **Termination**), fix anything open, then close the task. Once the verdict is processed, remove the review worktree and delete the package file in one chained call: `git worktree remove <worktree-path> && rm -f <package-path>`.

After the last task, run the full test suite once — in this session's own shell, commands copied from the project's runbook, never composed from memory (accept only deterministic evidence — commands, exit codes, output tails; warm-environment projects use their peer gate-runner instead). Then dispatch one final review of the whole diff, and finish per using-git-worktrees' Finishing: Merge Back and Clean Up.

## Termination — what counts as "reviewed"

**A review verdict is not evidence.** A subagent that reports "PASS / spec compliant / approved" has produced prose, and prose proves nothing on its own. Close a task only on output the model cannot fabricate:

- the test command actually run, with its output visible
- `git diff --name-only` showing which files changed
- `grep` confirming a symbol exists, or is gone

Run ONE review per task — a single reviewer subagent whose prompt covers spec compliance first (does the code match the task?), then quality (is it well-built?); spec findings outrank quality findings. Every claim in its report **terminates in a deterministic artifact you can see**, never in the reviewer's summary. The strongest such artifact is a falsification experiment run inside the disposable review worktree: break the thing a guard claims to cover, show the guard firing (or not), revert — "the test passes" alone cannot distinguish a working guard from a decorative one. Experiments live and die with the review worktree; the live tree and the reviewed commits are never touched. (Ruled 2026-07-12: the former cadence of two dispatches — a spec reviewer, then a quality reviewer — doubled review cost without a catch-rate gain; the quality half overlaps the end-of-plan whole-diff review.)

A confident verdict from a *parallel* reviewer is the weakest signal here, not the strongest. A capable model's mistakes are fluent and well-formatted, and parallel batches that partially cancel are a known surface for manufactured "success" — so independent re-running matters more, not less.

**Verdicts are binary: PASS or FAIL.** A verdict carrying any unresolved spec or gate finding is FAIL, however phrased; it flips only after the fix lands and its check re-runs. Quality-only findings may ride a PASS.

If a check fails, route the fix per **Fix Routing** (below) and re-run the check. Don't move on with anything open.

**Why:** the dangerous failure is a thorough, convincing, wrong report; only deterministic output catches it.

### Acting on review findings

A reviewer's finding is a claim, not a verdict. Reviewer citations — file:line, symbol names, "this is forbidden" framings — are routinely wrong; verify each one against the actual code before changing anything. No performative agreement ("You're absolutely right!", "Great catch!") and no implementing on reflex — restate the finding, check it against the codebase, then act or push back.

- **Verify before implementing.** Open the cited file:line yourself.
- **One finding at a time.** Implement it, re-run the relevant check (test, grep, diff), confirm it holds, then move to the next. Don't batch fixes on the strength of the report alone.
- **Push back with technical reasoning when a finding is wrong for THIS codebase.** Wrong platform assumption, missing context, breaks working code, YAGNI on an unused path — say so and why, instead of implementing to avoid friction.
- **Authority triage — after verification, before disposition.** A verified finding is a **defect** only if it cites the authority it violates: a gate item, a normative task-body clause (descriptive prose is not authority), an explicit convention (file:line — one code exemplar is not a convention), or a recorded owner ruling — an actual owner message, never a label an agent minted. A reproducible, externally observable failure introduced by `BASE..HEAD` — including a regression in pre-existing behavior the diff changed — anchors to the task's stated purpose by definition; an input the gate never enumerated is a missing test, not a missing anchor. A pre-existing failure the diff merely encounters stays a proposal absent independent authority. The label the reviewer chose is itself a claim: re-derive the anchor in both directions before disposing. A true finding with no such citation is a **proposal**: it cannot flip a verdict, board a fix round, or amend the task; it takes the filing threshold's backlog line, a severity-bar bead, or — when it is a genuine fork — one owner question. The test is actor-agnostic: the controller's own observations take it too. In an unattended run a fork parks its task on the bead and the queue continues on disjoint tasks — never self-ruled. **Why:** the measured failure mode (2026-08-22..24, solo) was an authority-conversion loop — reviewer fact → controller "ruling" → bead comment read as spec → binary re-review enforcing it; one bead burned nine rounds against a requirement no owner wrote.
- **Findings that conflict with the plan's recorded decisions escalate to your human partner** — don't silently apply a suggestion that contradicts a decision already made for this plan.
- **Filing threshold — a defect (per Authority triage) is fixed in the round (Fix Routing) or triaged by severity, never filed by default.** Propose a standalone bead only for: wrong behavior a user can hit, security, data loss, or something that blocks current work. Everything else is one comment line on the project's backlog bead (`bd comment add <backlog-id> "<one line>"`).
- **Where a filing lands:** under the executing epic ONLY if it blocks that epic's own acceptance — a defect in what the epic built, or a gap that makes its gates unmeetable — dep-linked as a blocker. Everything else goes to the backlog line or, past the severity bar, a standalone bead outside the epic. The epic's close-set is its plan batch plus its own blockers, nothing else — that is what lets a five-task epic close at five.
- **A finding deferred as a bead is labeled `needs-plan` at creation** (`-l needs-plan`). It carries a gate but no steps — the label keeps `bd ready` from surfacing it as dispatchable until writing-plans turns it into a task or a decision bead resolves it.
- **The session's completion report lists every bead it created**, each with its one-line severity justification — filing visibility without mid-run stops.
- **Fix Routing — who applies a defect.** A defect whose fix is fully specified by the finding itself — dead code, a comment's wording, a test the reviewer already wrote and watched pass — is applied by the controller, inline on the current diff: commit, re-run the one check, done. A round back to the implementer is justified only by the implementer knowing something the controller doesn't — a design call, a non-obvious code path, a fix the finding doesn't fully specify — never by preferring the work happen elsewhere. When a round IS dispatched, it carries ALL outstanding defects for the task — and no proposals; a round per finding is pure ceremony. (Fixes land as commits on top of the reviewed ones either way.) A controller-applied fix carries the implementer's full obligations — including the sibling-site sweep for the defect class; a fix whose sweep spans surfaces the finding didn't enumerate is not "fully specified" — dispatch it.
- **A second FAIL splits the task — after an authority audit.** Before splitting or dispatching anything further, re-walk every open finding's authority chain end to end: a finding whose asserted authority exists solely in an agent-authored comment — not independently traceable to a gate item, normative clause, convention, or verbatim owner message — is struck, not fixed, and the round count usually collapses with it. What survives splits along the task's file map (per writing-plans' Task Size) into child beads — no third same-shape round; the redo unit must shrink before any further round.

## Coordination Gate

Reviewing code is anchored by the task's Acceptance Gate. Your *own* coordination actions are not — and that ungated space is where drift happens.

Before any status action — closing, reopening, or deferring a bead, or declaring work "done" — state in one line:

1. the observable condition that justifies it, and
2. that you confirmed the tool actually supports the state you're setting.

**Why:** coordination actions taken on reflex, not evidence, are the controller's version of slop.

## Review Tier — declare it, don't skip it silently

Review is right-sized per task, and the size is a plan-time declaration you read, not a judgment you improvise at routing:

- `review:trivial-deterministic` (the label writing-plans puts on the task) → no reviewer dispatch. A task earns the label when every gate item is a command, or when a later plan task executes its artifact; the body's Execution line names that executing task.
- `behavioral` (no label) → the one combined spec+quality reviewer, as for any task whose gates need judgment to read.

Resolve the tier from the label alone (`bd label list <task-id>`), never by opening the body to infer it.

For a labeled task your own check stands in for the reviewer: read the Acceptance Gate block and nothing else — `bd get <task-id> body | sed -n '/^\*\*Acceptance Gate/,/^$/p'`, the second sanctioned glance, after the scope glance at claim — re-run every command item in this session's own shell, state the tier line naming the executing task's id, and close on that output. The executing task's GREEN run is the behavioral review the reviewer would have been: it exercises what landed here, later and for real. A failure in that run routes back to the artifact's task as a fix round — it is never a defect of the task that ran it.

State the tier and a one-line reason up front. **Why:** silently downgrading review reads identically to having reviewed — the problem isn't judging a task trivial, it's making that judgment invisible.

**A FAIL's re-review is tiered by the fix, not by the fact of the FAIL.** A fix is **controller-clearable** only when ALL hold: every open finding is fully specified by the finding itself (Fix Routing's test); each names the deterministic check that flips it; and `git diff --name-only <reviewed-tip>..<fix-tip>` stays inside the files those findings cite. Then the controller re-runs each named check on the fix tip and flips the verdict, declaring the tier in one line — the reviewer authored the checks, so running them executes the verdict condition rather than replacing the reviewer. Any fix wider than the citations, any finding without a named check, or a **second FAIL on the same task** → dispatched re-review, package spanning the task's original BASE to the fix tip. A controller never clears a fix it had to design — Fix Routing's boundary and this one are the same line.

## Reviewer Prompt Bias

**The reviewer decides severity, not you.** If the reviewer prompt you are writing contains "do not flag", "don't treat X as a defect", "at most Minor", or "the plan chose" — stop. Provide context (what the task asked for, what landed); never verdicts. Pre-briefing the desired outcome turns the review into an echo.

This rule governs the dispatch prompt only. Post-verdict, disposition follows Authority triage: severity ranks defects, it does not convert a proposal into round content — a reviewer's "fix this in the same round" is a request, not a verdict.

## Implementer Status

Implementers report one of four:

- **DONE** → review.
- **DONE_WITH_CONCERNS** → read the concerns first. Correctness/scope → address before review. Observation ("this file is getting large") → note and review.
- **NEEDS_CONTEXT** → provide what's missing, re-dispatch.
- **BLOCKED** → change something before retrying, never re-run the same model unchanged: context problem → add context; needs more reasoning → stronger model; too large → split; plan is wrong → escalate to the human.

## Model Selection

Each task's tier is declared by the plan (superpowers-beads:writing-plans, Execution Annotation); this section only resolves it to a model. Your human partner's standing model policy (project memory, CLAUDE.md) overrides the map — check it before resolving any tier. Absent a policy, on Claude harnesses: `cheap` → Sonnet, `standard` → Sonnet, `capable` → the session's model.

The doctrine behind the map — what a tier measures, when `capable` is earned, the pinned contract down-routing presumes, and the model the task's reviewer runs on — lives in `skills/shared/model-tiers.md`. Read it before resolving a contested tier.

## Invariants

**Never:**
- Start on main/master without explicit user consent.
- Close a task while a check shows failures.
- Dispatch a second reviewer for the same task — spec and quality are sections of the ONE review pass (use `reviewer-prompt.md`).
- Run two implementers in parallel on the same worktree (they conflict).
- Paste task bodies into dispatch prompts, or open them in this session at all — the dispatch names the bead id and the implementer fetches its own contract with `bd workfile <id>` (the header's rulings block surfaces parent rulings its own bead read cannot); the controller's context is the expensive, long-lived one. Three exceptions only, each a single block of the body: the scope glance at claim, the Acceptance Gate glance on a `review:trivial-deterministic` task (**Review Tier**), and Authority triage's clause check — post-review, reading only the cited clause and its minimal enclosing section. (Reversed 2026-08-15; the old rule "hand them the full task text" measurably doubled body delivery — implementers re-read via bd anyway.)
- Treat an implementer's self-review as the review. Both happen.
- Amend a task's body or Acceptance Gate from a review finding, or write `[owner ruling]` above anything but a verbatim owner message. A gate proven wrong against the approved design is corrected by re-deriving from the design source, cited line by line, logged as a deviation — or parked for the owner when the design does not answer. Review output is evidence, never product authority.
- Let an implementer run the full test suite — targeted tests only; the suite gate runs once, in this session. An implementer that backgrounds a job must finish it before ending its turn.

## Integration

- **superpowers-beads:using-git-worktrees** — REQUIRED before starting (also owns Finishing: merge back + cleanup).
- **superpowers-beads:writing-plans** — creates the plan this skill executes.
- Implementers follow **superpowers-beads:test-driven-development** per task.
