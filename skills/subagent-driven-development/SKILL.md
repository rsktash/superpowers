---
name: subagent-driven-development
description: Use when executing implementation plans with independent tasks in the current session
---

# Subagent-Driven Development

Execute a plan by dispatching a fresh subagent per task, reviewing each task's output before moving to the next.

**Why subagents:** You construct exactly the context each task needs — subagents never inherit your session history. This keeps them focused and preserves your own context for coordination.

**bd conventions:** Read `skills/shared/bd-defaults.md` before using any bd commands.

**Set up first:** REQUIRED SUB-SKILL — superpowers-beads:using-git-worktrees (isolated workspace before any task).

**Epic gate:** run `bd children <root-id>` first. An epic-type bead with no children is a spec, not a plan — STOP and route to superpowers-beads:writing-plans; never improvise tasks from the epic body.

## Pre-Flight Plan Review

Pre-flight is **state-triggered, not session-triggered**: its findings come from landed work invalidating the unexecuted remainder and from author fabrications no author re-read can catch. writing-plans' Self-Review does not substitute — that is the author re-reading its own work, and author-blind (a fabricated gate premise survives it); pre-flight is a fresh context, which is what catches fabrications.

**Marker.** A completed pre-flight (findings resolved) is recorded on the root bead: `bd comment add <root-id> "pre-flight: <short-sha> / open: <id> <id> …"` — the commit it certified and the open beads it covered.

**At every execution entry** — fresh session, mid-loop continuation, or same-session handoff from writing-plans alike — resolve the marker before the session's first claim (newest `pre-flight:` comment on the root bead, `bd comment list <root-id> --last 5`):

- **No marker** → run the full review below over the epic spec plus ALL open beads.
- **Marker current** — `git log <sha>..HEAD` is empty AND no open child's `updated_at` (`bd show <id> --json`) is newer than the marker comment → skip: one line citing the marker, then start. A multi-round epic pays nothing at round N+1 when nothing changed between rounds.
- **Marker stale** → run the review scoped to what invalidated it: open beads whose Files lists intersect `git diff --name-only <sha>..HEAD`, plus beads created or rewritten since the marker — never the untouched remainder, never closed tasks.

Either running path ends by writing a fresh marker. **A session's first claim requires a marker verified current or earned this session** — the check is one comment read plus one `git log`, so no entry mode is cheap enough to skip it.

Run the review as a READ-ONLY subagent: the in-scope plan enters that agent's context, never yours. Its prompt: read the epic and the in-scope open children, check the five classes below — against each other AND against the current tree — return findings only, no edits, no bd writes. Check for:

1. **Tasks that contradict each other or the spec** — two tasks disagreeing on an interface, format, or decision, or a task drifting from what the spec says.
2. **Anything a task ASKS FOR that a reviewer would flag as a defect** — the plan mandating a bug (e.g. a task whose steps produce the exact anti-pattern review would catch).
3. **Missing dependency edges the task bodies imply** — a task that reads/consumes something a sibling task produces, with no dep link between them.
4. **Gate items no step satisfies** — an Acceptance Gate checkbox nothing in the task's steps actually produces.
5. **Stale premises** — a task body the current tree already contradicts: a "watch it fail" step that is already green, a cited symbol a landed task changed, a resource two writers now own. Landed work invalidates the unexecuted remainder; this class is why a stale marker re-runs pre-flight.

Batch ALL findings into ONE question to your human partner before the session's first claim — never drip them out mid-run as you happen to notice each one. If the review turns up nothing, say so in one line and start.

A ready bead labeled `needs-plan` is not dispatchable — it is a filed finding, not a planned task; it goes through writing-plans (or a decision bead) before it can be claimed.

**Why:** Catching a plan-level contradiction on Task 6 after Tasks 1-5 already built on the wrong assumption is expensive to unwind; reading the affected remainder once per state change is cheap by comparison, and one batched question costs your human partner one interruption instead of five. (Observed: the session-triggered rule made multi-round epics pay a full open-plan scan every round even with nothing landed in between; the marker keeps the resume-time yield — staleness findings live only where work landed — while making the no-change round free.)

## Session Task List (display mirror)

Before Task 1, replace the session todo list (TaskCreate/TodoWrite) wholesale: one todo per task bead, titled `<bead-id>: <title>`, in plan order. This is your human partner's at-a-glance progress view — without it the todo widget keeps showing the planning-phase checklist through the whole run. It mirrors bead state and nothing else: flip a todo to in_progress when you claim its bead, to completed when you close it. No other todo updates — bd stays the single source of truth; deviations, findings, and added beads live on the beads, not the list.

## The Loop

For each task, in order:

1. Claim it (do NOT use --claim): `bd update <task-id> --status=in_progress --assignee "$(git config user.name) / <implementer-model-name>"` (e.g. "Alex / Claude Sonnet 4.6" — the model of the implementer subagent you dispatch for this task per **Model Selection**, since that subagent does the work). Flip the task's todo to in_progress. Record `BASE=$(git rev-parse HEAD)` — the pre-dispatch commit the review package will diff against. Then dispatch the implementer per `implementer-prompt.md` — the prompt carries the bead id, a one-line mission, orchestrator addenda (task-specific facts only, each citing a same-session tool run), and the **test-scope directive** (targeted tests only, never the full suite — the suite gate runs once, in this session). The implementer fetches its own contract from bd; **never open the task body in this session** — routing, claiming, and closing need no contract, and everything you paste or read here is resident to session end. The one sanctioned read is the **scope glance** at claim time: the task's Files section only (`bd show <task-id> --section files`, ~10 lines) — enough to catch a task whose size or file overlap contradicts the route before an implementer burns a session on it. Steps, gates, and context stay unread here. Static environment boilerplate — repo layout, bd invocation, test commands, worktree rules — lives once in the project's `docs/dispatch-env.md` (create it on the project's first-ever dispatch); the constant behavioral doctrine (discipline, escalation, self-review, report format) ships inside the plugin as the `superpowers-beads:implementer` agent's own system prompt. Prompts restate neither. Gates may run in the foreground; if the implementer backgrounds a command, it must poll it to completion before ending its turn — an agent that stops with a live background child sends no completion notification (silent stall).
2. Answer any questions the implementer asks *before* it proceeds.
3. Generate the review package: `scripts/review-package BASE HEAD` (run from this skill's directory — `skills/subagent-driven-development/`; BASE is the pre-dispatch commit recorded in step 1 — NEVER `HEAD~1`, which silently drops all but the last commit of a multi-commit task) and pass the reviewer the printed file path. Review the result (see **Termination**), fix anything open, then close the task (todo → completed). Once the verdict is processed, delete the review file (`.bd/.scratch` hygiene).

After the last task, run the full test suite once — dispatched to `superpowers-beads:suite-gate` (the gate stays this session's decision: accept only deterministic evidence — commands, exit codes, output tails; warm-environment projects use their peer gate-runner instead). Then dispatch one final review of the whole diff, and finish per using-git-worktrees' Finishing: Merge Back and Clean Up.

## Termination — what counts as "reviewed"

**A review verdict is not evidence.** A subagent that reports "PASS / spec compliant / approved" has produced prose, and prose proves nothing on its own. Close a task only on output the model cannot fabricate:

- the test command actually run, with its output visible
- `git diff --name-only` showing which files changed
- `grep` confirming a symbol exists, or is gone

Run ONE review per task — a single reviewer subagent whose prompt covers spec compliance first (does the code match the task?), then quality (is it well-built?); spec findings outrank quality findings. Every claim in its report **terminates in a deterministic artifact you can see**, never in the reviewer's summary. The strongest such artifact is a falsification experiment run inside the disposable review worktree: break the thing a guard claims to cover, show the guard firing (or not), revert — "the test passes" alone cannot distinguish a working guard from a decorative one. Experiments live and die with the review worktree; the live tree and the reviewed commits are never touched. (Ruled 2026-07-12: the former cadence of two dispatches — a spec reviewer, then a quality reviewer — doubled review cost without a catch-rate gain; the quality half overlaps the end-of-plan whole-diff review.)

A confident verdict from a *parallel* reviewer is the weakest signal here, not the strongest. A capable model's mistakes are fluent and well-formatted, and parallel batches that partially cancel are a known surface for manufactured "success" — so independent re-running matters more, not less.

**Verdicts are binary: PASS or FAIL.** Any spec-compliance finding or failed gate item is FAIL. "PASS with findings", "conditional PASS", "PASS once X is fixed" are FAIL misspelled — the condition is the finding, and the verdict flips only after the fix lands and its check re-runs. Quality-only findings may ride a PASS. (Observed: a 48-hour window in which hard FAILs vanished into conditional-pass phrasings while a privilege escalation rode one into a commit.)

If a check fails, route the fix per **Fix Routing** (below) and re-run the check. Don't move on with anything open.

**Why:** The dangerous failure on current models is not visible drift — it's a thorough, convincing, wrong report. Only deterministic output catches it; another subagent's prose does not.

### Acting on review findings

A reviewer's finding is a claim, not a verdict. Reviewer citations — file:line, symbol names, "this is forbidden" framings — are routinely wrong; verify each one against the actual code before changing anything. No performative agreement ("You're absolutely right!", "Great catch!") and no implementing on reflex — restate the finding, check it against the codebase, then act or push back.

- **Verify before implementing.** Open the cited file:line yourself. A confident, well-written finding is not evidence any more than a confident review verdict is (see above) — check it before touching code.
- **One finding at a time.** Implement it, re-run the relevant check (test, grep, diff), confirm it holds, then move to the next. Don't batch fixes on the strength of the report alone.
- **Push back with technical reasoning when a finding is wrong for THIS codebase.** Wrong platform assumption, missing context, breaks working code, YAGNI on an unused path — say so and why, instead of implementing to avoid friction.
- **Findings that conflict with the plan's recorded decisions escalate to your human partner** — don't silently apply a suggestion that contradicts a decision already made for this plan.
- **A finding deferred as a bead is labeled `needs-plan` at creation** (`-l needs-plan`). It carries a gate but no steps — the label keeps `bd ready` from surfacing it as dispatchable until writing-plans turns it into a task or a decision bead resolves it.
- **Fix Routing — who applies a verified finding.** A finding whose fix is fully specified by the finding itself — dead code, a comment's wording, a test the reviewer already wrote and watched pass — is applied by the controller, inline on the current diff: commit, re-run the one check, done. A round back to the implementer is justified only by the implementer knowing something the controller doesn't — a design call, a non-obvious code path, a fix the finding doesn't fully specify — never by preferring the work happen elsewhere. When a round IS dispatched, it carries ALL outstanding findings for the task; a round per finding is pure ceremony. (Fixes land as commits on top of the reviewed ones either way.) A controller-applied fix carries the implementer's full obligations — including the sibling-site sweep for the defect class; a fix whose sweep spans surfaces the finding didn't enumerate is not "fully specified" — dispatch it.

## Coordination Gate

Reviewing code is anchored by the task's Acceptance Gate. Your *own* coordination actions are not — and that ungated space is where drift happens.

Before any status action — closing, reopening, or deferring a bead, or declaring work "done" — state in one line:

1. the observable condition that justifies it, and
2. that you confirmed the tool actually supports the state you're setting.

**Why:** This rule is minted from a real failure — reopening a closed bead "to keep its knowledge live as a tripwire." Both checks catch it: closing a bead doesn't hide its knowledge (false premise), and bd has no such status (unsupported state). Coordination actions taken on reflex, not evidence, are the controller's version of slop.

## Review Tier — declare it, don't skip it silently

Right-size review per task, but make the decision visible and challengeable:

- `trivial-deterministic` (isolated, complete spec) → one deterministic check, no reviewer dispatch
- `behavioral` (multi-file, judgment, integration) → the one combined spec+quality reviewer

State the tier and a one-line reason up front. **Why:** silently downgrading review reads identically to having reviewed — the problem isn't judging a task trivial, it's making that judgment invisible.

## Reviewer Prompt Bias

**The reviewer decides severity, not you.** If the reviewer prompt you are writing contains "do not flag", "don't treat X as a defect", "at most Minor", or "the plan chose" — stop. Provide context (what the task asked for, what landed); never verdicts. Pre-briefing the desired outcome turns the review into an echo.

## Implementer Status

Implementers report one of four:

- **DONE** → review.
- **DONE_WITH_CONCERNS** → read the concerns first. Correctness/scope → address before review. Observation ("this file is getting large") → note and review.
- **NEEDS_CONTEXT** → provide what's missing, re-dispatch.
- **BLOCKED** → change something before retrying, never re-run the same model unchanged: context problem → add context; needs more reasoning → stronger model; too large → split; plan is wrong → escalate to the human.

## Model Selection

Your human partner's standing model policy (project memory, CLAUDE.md) overrides this rubric — check it before resolving any tier. Absent a policy: least powerful model that fits, to save cost and time:

- 1–2 files, complete spec → cheap/fast model
- multi-file integration → standard model
- design judgment or broad codebase understanding → most capable model

The current Sonnet (Sonnet 5 today) is close to the session/most-capable model, so the third bullet is a **high bar, not a default**: reserve the most-capable model for real design judgment or broad synthesis, and let Sonnet carry multi-file integration. When unsure between `standard` and most-capable, pick `standard` — a fresh reviewed Sonnet subagent makes the down-route low-risk. (Model names are point-in-time; the tiers stay version-agnostic.)

Down-routing presumes a pinned contract: a task whose steps leave a mechanism or design fork to the executor is capable-tier regardless of file count. Economize on the contract or on the executor — never both in one task.

## Invariants

**Never:**
- Start on main/master without explicit user consent.
- Close a task while a check shows failures.
- Dispatch a second reviewer for the same task — spec and quality are sections of the ONE review pass (use `reviewer-prompt.md`).
- Run two implementers in parallel on the same worktree (they conflict).
- Paste task bodies into dispatch prompts, or open them in this session at all — the dispatch names the bead id and the implementer fetches its own contract (`bd get <id> body`); the controller's context is the expensive, long-lived one. The Files-section scope glance at claim is the sole exception. (Reversed 2026-08-15; the old rule "hand them the full task text" measurably doubled body delivery — implementers re-read via bd anyway.)
- Treat an implementer's self-review as the review. Both happen.
- Let an implementer run the full test suite — targeted tests only; the suite gate runs once, via the suite-gate dispatch. An implementer that backgrounds a job must finish it before ending its turn.

## Integration

- **superpowers-beads:using-git-worktrees** — REQUIRED before starting (also owns Finishing: merge back + cleanup).
- **superpowers-beads:writing-plans** — creates the plan this skill executes.
- Implementers follow **superpowers-beads:test-driven-development** per task.
