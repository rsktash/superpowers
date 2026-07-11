---
name: subagent-driven-development
description: Use when executing implementation plans with independent tasks in the current session
---

# Subagent-Driven Development

Execute a plan by dispatching a fresh subagent per task, reviewing each task's output before moving to the next.

**Why subagents:** You construct exactly the context each task needs — subagents never inherit your session history. This keeps them focused and preserves your own context for coordination.

**bd conventions:** Read `skills/shared/bd-defaults.md` before using any bd commands.

**Set up first:** REQUIRED SUB-SKILL — superpowers-beads:using-git-worktrees (isolated workspace before any task).

## The Loop

For each task, in order:

1. Read it: `bd show <task-id> --full`. Mark it in progress and set the assignee (do NOT use --claim): `bd update <task-id> --status=in_progress --assignee "$(git config user.name) / <implementer-model-name>"` (e.g. "Alex / Claude Sonnet 4.6" — the model of the implementer subagent you dispatch for this task per **Model Selection**, since that subagent does the work). Then dispatch an implementer with the full task text plus the context it needs. Put the task's directive sections (Context Anchor, Acceptance Gate, Drift Detectors) at the top of the prompt. The prompt also carries the **cache guard**: run only this task's targeted tests, never the full suite; no foreground command expected to outlive ~4 minutes, and no self-poll loops (`until …`, `while kill -0 …`, `sleep`-tail) — a subagent's prompt cache lives 5 minutes, and one blocking suite run turns every later turn into a full-context re-read.
2. Answer any questions the implementer asks *before* it proceeds.
3. Review the result (see **Termination**), fix anything open, then close the task.

After the last task, run the full test suite once from this session (backgrounded — the suite gate belongs to the orchestrator, whose cache survives the wait), dispatch one final review of the whole diff, then use superpowers-beads:finishing-a-development-branch.

## Termination — what counts as "reviewed"

**A review verdict is not evidence.** A subagent that reports "PASS / spec compliant / approved" has produced prose, and prose proves nothing on its own. Close a task only on output the model cannot fabricate:

- the test command actually run, with its output visible
- `git diff --name-only` showing which files changed
- `grep` confirming a symbol exists, or is gone

Run ONE review per task — a single reviewer subagent whose prompt covers spec compliance first (does the code match the task?), then quality (is it well-built?); spec findings outrank quality findings. Every claim in its report **terminates in a deterministic artifact you can see**, never in the reviewer's summary. (Ruled 2026-07-12: the former cadence of two dispatches — a spec reviewer, then a quality reviewer — doubled review cost without a catch-rate gain; the quality half overlaps the end-of-plan whole-diff review.)

A confident verdict from a *parallel* reviewer is the weakest signal here, not the strongest. A capable model's mistakes are fluent and well-formatted, and parallel batches that partially cancel are a known surface for manufactured "success" — so independent re-running matters more, not less.

If a check fails, the same implementer fixes it and you re-run the check. Don't move on with anything open.

**Why:** The dangerous failure on current models is not visible drift — it's a thorough, convincing, wrong report. Only deterministic output catches it; another subagent's prose does not.

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

## Invariants

**Never:**
- Start on main/master without explicit user consent.
- Close a task while a check shows failures.
- Dispatch a second reviewer for the same task — spec and quality are sections of the ONE review pass (use `reviewer-prompt.md`).
- Run two implementers in parallel on the same worktree (they conflict).
- Make implementers query beads — hand them the full task text from `bd show <id> --full`.
- Treat an implementer's self-review as the review. Both happen.
- Let an implementer run the full test suite or wait on its own background jobs — targeted tests only; the suite runs once, here, backgrounded.

## Integration

- **superpowers-beads:using-git-worktrees** — REQUIRED before starting.
- **superpowers-beads:writing-plans** — creates the plan this skill executes.
- **superpowers-beads:finishing-a-development-branch** — after all tasks complete.
- Implementers follow **superpowers-beads:test-driven-development** per task.
