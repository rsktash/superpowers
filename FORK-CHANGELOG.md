# Fork Changelog

Release history of the superpowers-beads fork. Upstream's own history stays in
`CHANGELOG.md` / `RELEASE-NOTES.md` (vendored, never edited here — their top
version marks the fork's upstream sync point).

## [1.4.6] - 2026-08-15

Workflow redesign: the orchestrator never touches a task body. Measured
(solo project): bodies were delivered up to 4x per task — orchestrator
`--full` read, pasted into the dispatch prompt, executor `--full` read,
executor Write of the progress copy — two of those resident in the
long-lived orchestrator (~4K/task, ~800K per 200-task project).

### Changed (breaking doctrine reversal)

- **subagent-driven-development**: implementer-prompt.md no longer pastes
  Context Anchor / Gate / Drift / full task text — the prompt names the bead
  id and the implementer fetches its own contract (`bd show` +
  `bd get <id> body > .bd/.scratch/progress.md` + Read). The "hand them the
  full task text" invariant is REVERSED: never paste bodies, never open them
  in the controller session. Pre-Flight Plan Review now runs as a READ-ONLY
  subagent (the whole plan enters its context, not the controller's).
- **hybrid-execution**: the Loop routes from `bd ready --json` + the `exec:`
  label — the controller never opens a body (legacy fallback: grep the one
  `**Execution:**` line). Inline Task Procedure delivers the contract via
  the progress-copy redirect — body in context once, as the working file.
- **writing-plans**: the Execution annotation is mirrored as a bead label at
  create time (`-l "exec:<mode>"`) so routing needs no body read.

Companion (pending): `bd workfile` command + labels in `ready --json` in the
beads repo — until then the get-redirect pattern and `bd label list` serve.

## [1.4.5] - 2026-08-15

Compression sweep (progressive disclosure): rarely-needed sections move to
`references/` files read on demand; every rule kept verbatim, nothing dropped.
Loads shrink ~1.2K tokens per skill invocation.

### Changed

- **hybrid-execution** (20.3K -> 18.0K chars): Hybrid Parallel procedure ->
  `references/hybrid-parallel.md` (activation rule stays in SKILL.md); Model
  Tiers reasoning -> `references/model-tiers.md` (map + floor rule stay).
- **writing-plans** (22.6K -> 20.1K chars): the three conditional review
  lenses (Deploy Sequence, Cross-Layer Consistency, Semantic Regression
  Sweep) -> `references/plan-review-lenses.md`, applied only when a task
  touches schema/rollout/contracts/type shapes.

## [1.4.4] - 2026-08-15

Two residency reducers from the 2026-08-15 token audit of the solo project
(18 orchestrator + 248 executor transcripts): dispatch-prompt boilerplate and
oversized tasks were the two schema-level contributors to fleet spend.

### Changed

- **subagent-driven-development**: static environment boilerplate moves to the
  project's `docs/dispatch-env.md`, referenced by path from dispatch prompts
  instead of inlined. (Measured: the same ~250-token block inlined in 248
  dispatch prompts, each resident in the orchestrator to session end.)
- **writing-plans**: new Context Ceiling rule under Bite-Sized Task
  Granularity — a task whose executor would plausibly accumulate >~150K tokens
  of context is two tasks. (Measured: the top decile of executors reached
  200–418K resident and dominated fleet spend.)

## [1.4.1] - 2026-07-26

Two guardrails against unverified orchestrator assertions reaching executors,
from the 2026-07-26 volunteered-rigor incident analysis (Opus 5 sessions
`40391637` / `25d32456`): every fabrication that reached an executor entered
through orchestrator-added content — dispatch-prompt fill slots and gate
premises — never through an audited bead body.

### Changed

- **codex-execution**: dispatch-prompt fill slots carry facts, not judgment —
  any constraint the orchestrator adds beyond the bead must cite a
  same-session tool run, and environment/toolchain facts expire when a task
  changes the toolchain. New Common-mistakes row. (Observed: a stale
  pre-toolchain-bump "allTests executes none" order; codex correctly refused,
  costing a full round trip.)
- **writing-plans**: acceptance-gate numbers and factual premises are claims —
  derive each from a same-session measurement and check it against evidence
  already gathered. (Observed: a ">= 3 distinct offsets" gate that
  mis-encoded two DST transitions, plus a zone the same session had already
  measured as a one-off.)

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
