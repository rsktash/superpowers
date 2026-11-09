---
name: opencode-execution
description: Use when executing an implementation plan's task beads via the OpenCode CLI instead of Claude subagents — session-budget execution, "run this plan with opencode", or the OpenCode Execution mode chosen at the writing-plans handoff
---

# OpenCode Execution — budget 1401 words

Execution mode: opencode (`opencode run`, non-interactive) implements each task bead; this
session orchestrates, verifies every landing, and runs the terminal whole-diff review.
No per-task code review: falsifiable task gates, per-landing verification and the end review carry it.

**Entry contract:** receive the root bead ID from
the planner (or locate it via `docs/beads/*.md` when resuming); drive the loop with
`bd ready --parent <root-id> --json` until it returns `[]`.

**REQUIRED BACKGROUND:** beads come from superpowers-beads:planner — self-contained
directives (Acceptance Gates falsifiable against under-doing, Drift Detectors, allowed
Files, TDD steps).

**bd conventions:** Read `skills/shared/bd-defaults.md` once per session, skip if already read.

## Preconditions (check BEFORE the first dispatch)

- **Epic gate:** per `skills/shared/plan-lane.md`, Epic gate.
- **Lane step:** with the gate passed, take this epic's lane per `skills/shared/plan-lane.md`, mode `opencode`, before the first dispatch.
- **Pre-Flight Plan Review:** resolve the root's marker per Pre-Flight Plan Review (superpowers-beads:subagent-driven-development) before the first dispatch — marker present → skip, no marker → run the review once and write it.
- **Executor-fatal lint, each task body before its dispatch:** sandbox-impossible commands, gate commands that cannot run as written, unresolved placeholders — any hit labels the bead `needs-plan` and routes it to amend mode per `skills/shared/plan-lane.md`, Epic gate, instead of dispatching.
- **Rules:** OpenCode loads the root `AGENTS.md` and every ancestor folder's `AGENTS.md` when it
  reads a file, so the prompt never pastes rules. Legacy rulings reach the executor through
  `bd rulings` in the prompt and bind only where no AGENTS.md covers the code.
- **Model, passed on every run:** `-m openai/gpt-6.1-sol` for non-UI tasks; `-m opencode-go/deepseek-v4.1-flash`
  for a task you judge small (state why on the dispatch line). UI tasks never come to this skill.
- Tracker access: bd needs network and must run without a permission prompt; read
  `~/.config/opencode/opencode.json` once before the first dispatch.

**Session task list (display mirror):** before the first dispatch, replace the session
todo list wholesale — one todo per task bead, `<bead-id>: <title>`, in plan order.
Flip to in_progress at dispatch; to completed only after per-landing verification
confirms the bead closed. bd stays
the single source of truth — no other todo updates.

## The Loop (sequential)

Loop until `bd ready --parent <root-id> --json` returns `[]`:

1. Pick the next ready task; announce "Task N → opencode <model>" as its own line. Flip its todo to in_progress.
2. Launch in background (`run_in_background:true`) — completion re-invokes the session; no fallback heartbeat:

```bash
env -u OPENCODE_SESSION_ID opencode run -m <model> --dir <repo-root> "$(cat <<'PROMPT'
[fill from dispatch-prompt.md in this skill's directory]
PROMPT
)" < /dev/null
```

   The template encodes the ownership rule: **the executor claims, commits (bead id in
   message), comments evidence, and closes the bead itself** — the orchestrator never
   commits on its behalf. Fill the context line with the landed sibling commits the
   task consumes, and QUOTE any cross-task contract a prior executor stated into the consumer task's prompt. Fill the template's Exploration Map block with the
   verbatim output of `${CLAUDE_PLUGIN_ROOT}/scripts/map-check <epic-id> <task-id> --repo <repo-root>`
   run at claim — one line when the epic has no map file (exit 2).
   Fill slots carry facts, not judgment: the bead's own content, landed shas, quoted
   contracts, the task's named test modules. Any constraint you ADD beyond the bead
   (an environment fact, a "do not run X") must cite a tool run from THIS session —
   and environment/toolchain facts expire when any task changes the toolchain;
   re-verify or omit.
3. Verify the landing (below); todo → completed. Only then dispatch the next task.

## Per-landing verification

1. Re-run the task's gate test modules + fast invariants YOURSELF; compare counts.
2. `git show --stat <sha>` — files ⊆ the task's allowed Files; tree clean after.
3. Spot-read the law-bearing hunks (the lines the task exists for).
4. Bead closed with an evidence comment.

Full suite: ONCE at plan end, never per task.

## Blocker loop

The executor must stop when a gate can't be satisfied honestly. When it does:
1. VERIFY the blocker yourself against code/live data.
2. RESOLVE from existing cited authority only — the spec, a convention (file:line), an
   AGENTS.md rule, or a legacy ruling where it binds (`bd rulings <task-id>`); file the resolution as a finding, then close the question with it:
   `bd finding add <task-id> "<resolution + citation>" --topic <slug> -j` (slug picked from the printed catalogue; capture the id), then
   `bd question answer <question-id> --finding <finding-id>` (coordinator actor —
   never from an executor shell). A spec-derived resolution is a verified fact, not
   an owner decision: Only the owner approves an AGENTS.md edit. When no existing authority
   determines the answer, the open question already parks the task — ask the owner;
   never amend the body from the blocker.
3. Re-dispatch as a RESUME: bead stays claimed; prompt says "your blocker is resolved
   by the cited authority — do not stop for it again; any OTHER blocker still stops."
Never let the executor resolve its own blocker, never re-dispatch with a
silently "corrected" prompt.

## Plan end

Full static gates (suite once, typecheck, build) + a FRESH-context whole-diff review
over the entire plan range against the spec, every task's gates/detectors, and the
architecture boundaries — findings fixed inline by the orchestrator, own commits,
each only past subagent-driven-development's Authority triage: a finding that cites
no violated gate, spec line, convention, AGENTS.md rule, or verbatim owner ruling is a proposal —
one backlog line, never an inline fix.
**REQUIRED SUB-SKILL:** superpowers-beads:requesting-code-review for the reviewer dispatch shape.

