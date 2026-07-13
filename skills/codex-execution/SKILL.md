---
name: codex-execution
description: Use when executing an implementation plan's task beads via the codex CLI instead of Claude subagents — session-budget execution, "run this plan with codex", or the Codex Execution mode chosen at the writing-plans handoff
---

# Codex Execution

Execution mode: codex (`codex exec`, non-interactive) implements each task bead; this
session orchestrates, verifies every landing, and runs the terminal whole-diff review.
Per-task code review is absent BY DESIGN — its job moves into falsifiable task gates
(written at plan time), per-landing verification, and the end review.
Proven: biklod shape-law plan 2026-07-13 — 10 tasks, 2 honest STOPs, 0 gate-weakenings.

**Entry contract (same as the other execution modes):** receive the root bead ID from
writing-plans (or locate it via `docs/beads/*.md` when resuming); drive the loop with
`bd ready --parent <root-id> --json` until it returns `[]`.

**REQUIRED BACKGROUND:** beads come from superpowers-beads:writing-plans — self-contained
directives (Acceptance Gates falsifiable against under-doing, Drift Detectors, allowed
Files, TDD steps). Codex cannot compensate for a vague bead.

**bd conventions:** Read `skills/shared/bd-defaults.md` before using any bd commands.

## Preconditions (check BEFORE the first dispatch)

- **AGENTS.md parity:** codex reads `AGENTS.md`, never `CLAUDE.md`. EVERY directory
  with a `CLAUDE.md` must carry a sibling `AGENTS.md` symlink (`ln -s CLAUDE.md AGENTS.md`).
  Verify: `find . -name CLAUDE.md -not -path "*/node_modules/*"` — each hit has a
  symlink sibling. A stale AGENTS.md COPY is worse than none (codex obeys dead rules).
- Model comes from `~/.codex/config.toml` — do NOT pass `--model` unless the user ruled one.
- Tracker access: the sandbox blocks network by default; bd needs it (see flags below).

## The Loop (SEQUENTIAL — one working tree; parallel codex runs collide)

Loop until `bd ready --parent <root-id> --json` returns `[]`:

1. Pick the next ready task; announce "Task N → codex" as its own line.
2. Launch in background (`run_in_background:true`), arm ONE fallback heartbeat, kill it
   the instant the run completes:

```bash
codex exec -s workspace-write -c sandbox_workspace_write.network_access=true \
  --cd <repo-root> - <<'PROMPT'
[fill from dispatch-prompt.md in this skill's directory]
PROMPT
```

   The template encodes the ownership ruling: **codex claims, commits (bead id in
   message), comments evidence, and closes the bead itself** — the orchestrator never
   commits on codex's behalf. Fill the context line with the landed sibling commits the
   task consumes, and QUOTE any cross-task contract a prior executor stated (e.g. a
   batch-naming contract) into the consumer task's prompt — contracts travel in
   prompts, not in your memory.
3. Verify the landing (below). Only then dispatch the next task.

## Per-landing verification (NON-OPTIONAL; codex claims are leads, not citations)

1. Re-run the task's gate test modules + fast invariants YOURSELF; compare counts.
2. `git show --stat <sha>` — files ⊆ the task's allowed Files; tree clean after.
3. Spot-read the law-bearing hunks (the lines the task exists for).
4. Bead closed with an evidence comment.

Full suite: ONCE at plan end, never per task (plan-level gate; per-task full runs burn
wall-clock and violate the process ruling this skill inherits).

## Blocker loop (a codex STOP is a plan-defect signal, not a failure)

Codex must stop when a gate can't be satisfied honestly. When it does:
1. VERIFY the blocker yourself against code/live data — codex may be wrong.
2. RULE the resolution as planner; append a `**PLANNER RULING**` section to the task
   body (`bd update <id> --body-file`), and comment the ruling trail on the bead.
3. Re-dispatch as a RESUME: bead stays claimed; prompt says "your blocker is resolved
   by the ruling — do not stop for it again; any OTHER blocker still stops."
Never let codex resolve its own blocker (scope authority), never re-dispatch with a
silently "corrected" prompt (the ruling must live on the bead, not in the prompt).

## Plan end

Full static gates (suite once, typecheck, build) + a FRESH-context whole-diff review
over the entire plan range against the spec, every task's gates/detectors, and the
architecture boundaries — findings fixed inline by the orchestrator, own commits.
**REQUIRED SUB-SKILL:** superpowers-beads:requesting-code-review for the reviewer dispatch shape.

## Common mistakes

| Mistake | Reality |
|---|---|
| Parallel codex dispatches | One worktree — they race the index. Sequential, always. |
| Omitting `network_access=true` | bd claim/close dies inside the sandbox; task work lands untracked. |
| Trusting codex's test counts | Re-run yourself; every count you report must be your own run. |
| Full suite per task | Plan-level gate runs it once; per-task runs violate the ruling. |
| Prompt-only blocker fixes | Ruling goes on the BEAD (audit trail + survives re-dispatch). |
| Skipping AGENTS.md parity check | Codex executes with stale or missing rules in nested dirs. |
| Passing `--model` by guess | The configured default is the ruling; a guessed model id silently downgrades. |
