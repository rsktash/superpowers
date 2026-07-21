# Fork Changelog

Release history of the superpowers-beads fork. Upstream's own history stays in
`CHANGELOG.md` / `RELEASE-NOTES.md` (vendored, never edited here — their top
version marks the fork's upstream sync point).

## [1.4.0] - 2026-07-22

Usage-analysis-driven overhaul of the skill roster (epic `superpowers-yz0`),
based on a three-project transcript analysis (206 sessions): every serious
friction event was a missed or bypassed trigger, never skill overhead.

### Removed (breaking)

- **Four skills retired**: `dispatching-parallel-agents` (0 invocations in 206
  sessions), `receiving-code-review` (0), `finishing-a-development-branch`
  (superseded), `executing-plans` (displaced by hybrid/codex execution).
  Surviving content folded: the inline per-task procedure now lives in
  hybrid-execution's own **Inline Task Procedure** section; branch finishing
  lives in using-git-worktrees' **Finishing: Merge Back and Clean Up**;
  review-reception discipline lives in subagent-driven-development's
  **Acting on review findings**.
- **writing-plans execution handoff is now 3 options** (Subagent-Driven,
  Hybrid, Codex) — the Inline option retired with executing-plans; all-inline
  plans are served by Hybrid routing.

### Added

- **Pipelined reviews by default in hybrid-execution**: task N's reviewer runs
  in the background against a frozen review package while N+1 implements;
  opt-in **Hybrid Parallel** mode (literal "hybrid parallel" from the user)
  for 2–3 disjoint-scope implementers in separate worktrees.
- **review-package script** (ported from upstream v6, adapted to
  `.bd/.scratch/`): reviewers read a frozen commit-list + stat + U15 diff
  file — never a pasted diff, never the moving working tree.
- **Two advisory plugin hooks** (never blocking): `fail-streak-guard`
  (PostToolUse — 2+ consecutive failures of one command class → reminder to
  load systematic-debugging and offer outsource-review) and `completion-gate`
  (PreToolUse on `bd close`/`git commit` — warns when code changed since the
  last passing verification run). Mechanical ignition for the two skills the
  analysis showed never self-invoke mid-firefight.
- **Pre-Flight Plan Review** (upstream v6 port, bd-adapted): whole-plan
  contradiction scan before Task 1, findings batched into one question.
- **Epic gate** at all three execution entry points: an epic bead with no
  children routes to writing-plans — undecomposed epics never execute.
- **Multi-Phase Epics rule** in writing-plans: the last task of phase N is
  "Plan phase N+1", so bd auto-close can't silently swallow a continuation.
- **Required `model:` field** in implementer/reviewer dispatch templates
  (upstream v6 port) — an omitted model silently inherits the session's most
  expensive one.
- **Reviewer Prompt Bias guardrail** (upstream v6 port): "do not flag" /
  "at most Minor" in a reviewer prompt is a stop signal — the reviewer
  decides severity, not the controller.
- **Evidence-first guard** in brainstorming: suspected-problem brainstorms
  require a shown problem (repro/error) before design.

### Fixed

- Version manifests re-synced via `bump-version.sh` (1.3.11 release had
  hand-bumped only 2 of 5 files, leaving cursor/gemini manifests at 1.3.10).
- Live skill tests run on stock macOS (GNU `timeout` absent) and the sdd
  test's task-loading assertion matches this fork's bd-based flow.
