---
name: codex-execution
description: Use when executing an implementation plan's task beads via the codex CLI instead of Claude subagents — session-budget execution, "run this plan with codex", or the Codex Execution mode chosen at the writing-plans handoff
---

# Codex Execution — budget 1100 words

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

- **Epic gate:** run `bd children <root-id>` first. An epic-type bead with no children — or with no `plan-ready:` label on the root (`bd label list <root-id>`) — is a spec or a half-written plan, not a plan: STOP and route to superpowers-beads:writing-plans; never improvise tasks from the epic body.
- **Pre-Flight Plan Review:** resolve the root's marker per Pre-Flight Plan Review (superpowers-beads:subagent-driven-development) before the first dispatch — marker present → skip, no marker → run the review once and write it. It runs once per plan, never again. A ready bead labeled `needs-plan` is not dispatchable.
- **Codex-fatal lint, each task body before its dispatch:** sandbox-impossible commands, gate commands that cannot run as written, unresolved placeholders — any hit labels the bead `needs-plan` instead of dispatching. Codex halts on these mid-run at a full round-trip each; the lint pays once, up front.
- **AGENTS.md parity:** codex reads `AGENTS.md`, never `CLAUDE.md`. EVERY directory
  with a `CLAUDE.md` must carry a sibling `AGENTS.md` symlink (`ln -s CLAUDE.md AGENTS.md`).
  Verify: `find . -name CLAUDE.md -not -path "*/node_modules/*"` — each hit has a
  symlink sibling. A stale AGENTS.md COPY is worse than none (codex obeys dead rules).
- Model comes from `~/.codex/config.toml` — do NOT pass `--model` unless the user ruled one.
- Tracker access: the sandbox blocks network by default; bd needs it (see flags below).

**Session task list (display mirror):** before the first dispatch, replace the session
todo list wholesale — one todo per task bead, `<bead-id>: <title>`, in plan order.
Flip to in_progress at dispatch; to completed only after per-landing verification
confirms the bead closed (codex closing it is a claim, not the flip trigger). bd stays
the single source of truth — no other todo updates.

## The Loop (SEQUENTIAL — one working tree; parallel codex runs collide)

Loop until `bd ready --parent <root-id> --json` returns `[]`:

1. Pick the next ready task; announce "Task N → codex" as its own line. Flip its todo to in_progress.
2. Launch in background (`run_in_background:true`) — completion re-invokes the session; no fallback heartbeat:

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
   Fill slots carry facts, not judgment: the bead's own content, landed shas, quoted
   contracts, the task's named test modules. Any constraint you ADD beyond the bead
   (an environment fact, a "do not run X") must cite a tool run from THIS session —
   and environment/toolchain facts expire when any task changes the toolchain;
   re-verify or omit. The executor treats every slot line as ground truth.
3. Verify the landing (below); todo → completed. Only then dispatch the next task.

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
2. RESOLVE from existing cited authority only — the spec, a convention (file:line), or
   a recorded ruling (`bd rulings <task-id>`); file the resolution as a finding, then close the question with it:
   `bd finding add <task-id> "<resolution + citation>" -j` (capture the id), then
   `bd question answer <question-id> --finding <finding-id>` (coordinator actor —
   never from an executor shell). A spec-derived resolution is a verified fact, not
   an owner decision: `bd ruling add` stays reserved for transcribing the owner. When no existing authority
   determines the answer, the open question already parks the task — ask the owner;
   never amend the body from the blocker.
3. Re-dispatch as a RESUME: bead stays claimed; prompt says "your blocker is resolved
   by the cited authority — do not stop for it again; any OTHER blocker still stops."
Never let codex resolve its own blocker (scope authority), never re-dispatch with a
silently "corrected" prompt (the resolution must live on the bead, not in the prompt).

## Plan end

Full static gates (suite once, typecheck, build) + a FRESH-context whole-diff review
over the entire plan range against the spec, every task's gates/detectors, and the
architecture boundaries — findings fixed inline by the orchestrator, own commits,
each only past subagent-driven-development's Authority triage: a finding that cites
no violated gate, spec line, convention, or verbatim owner ruling is a proposal —
one backlog line, never an inline fix.
**REQUIRED SUB-SKILL:** superpowers-beads:requesting-code-review for the reviewer dispatch shape.

## Common mistakes

| Mistake | Reality |
|---|---|
| Parallel codex dispatches | One worktree — they race the index. Sequential, always. |
| Omitting `network_access=true` | bd claim/close dies inside the sandbox; task work lands untracked. |
| Trusting codex's test counts | Re-run yourself; every count you report must be your own run. |
| Full suite per task | Plan-level gate runs it once; per-task runs violate the ruling. |
| Prompt-only blocker fixes | Ruling goes on the BEAD (audit trail + survives re-dispatch). |
| Unverified constraint in a fill slot | Executor obeys it as ground truth; a stale pre-toolchain-bump "fact" becomes a binding false order. Verify same-session or omit. |
| Skipping AGENTS.md parity check | Codex executes with stale or missing rules in nested dirs. |
| Passing `--model` by guess | The configured default is the ruling; a guessed model id silently downgrades. |
