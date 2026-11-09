# Implementer Subagent Prompt Template

Use this template when dispatching an implementer subagent. Everything
constant across dispatches (the implementer charter: discipline, escalation,
self-review, report format) is the `superpowers-beads:implementer` agent's own
system prompt — shipped inside the plugin. The dispatch prompt carries ONLY
what is specific to this task.

```
Task tool (subagent_type: superpowers-beads:implementer; use general-purpose ONLY when the task genuinely needs browser/device/MCP tools):
  description: "Implement <bead-id>: [task name]"
  model: [REQUIRED — resolve per SKILL.md Model Selection]
  prompt: |
    You are implementing task <bead-id> ("[task name]") — one task of a larger plan.

    ## Get Your Contract (first, before anything else)

    1. Read `docs/dispatch-env.md` at the repo root (repo layout, bd invocation,
       test commands, worktree rules), and `docs/CONTEXT.md` (domain glossary)
       if it exists — bead bodies are written in its vocabulary.
    2. `export BD_ACTOR=executor`. File a finding or question without `--topic` first so bd prints the catalogue; pick an existing slug, never mint one. None fits → `--topic pending-<task id lowercased, each run of characters outside [a-z0-9] → one hyphen, cut to 48 chars>`; the coordinator resolves it at Close. Need a bd
       command this prompt does not name? `bd prime` prints the full
       reference — never discover syntax via `--help`, the binary, or the
       database.
       From the repo root: `bd workfile <bead-id>` — one call whose header
       prints metadata, deps, the **LEGACY RULINGS** block, findings, the
       section index, and notes, and whose body writes to
       `.bd/.scratch/<bead-id>.md`. **Read that file once** — it is your
       complete contract AND your local working copy. Every tool result you
       pull in is re-read on every later turn: read ranges, never whole
       files or full logs.
       Your rules are the AGENTS.md files of the folders you touch — the
       root one and each folder's own, loaded as you read files there. The
       header's LEGACY RULINGS block is REQUIRED reading, never skipped: it
       binds only where no AGENTS.md covers the code you touch, and there it
       is inheritance-resolved. A rule OUTRANKS the body it
       contradicts and is settled:
       implement it; never re-open it.
       If the section index lists a `design` section, also read
       `bd show <bead-id> --section design`.
       Then `bd comment list <bead-id>` — narrative and evidence: review
       verdicts and BLOCKED reports land here, oldest to newest. Two things
       you must carry out of them:
       - An **open question** on the bead, or an inherited fork marked
         unruled, is NOT yours to close. If your work
         reaches it, stop and report BLOCKED naming the fork.
       - A **prior review verdict** tells you what is already fixed and what is
         still owed. On a RESUMED task that verdict, not the body, is the true
         state of the work.
    3. The body's directive sections govern you: **Context Anchor** (where this
       task fits), **Acceptance Gate** (the ONLY criteria for "done" — do not add
       your own), **Drift Detectors** (editing files outside the Files list →
       STOP — except a test your in-contract change broke, which is in-contract
       to update; a structural ban still stops the turn).

    ## Your Worktree

    [absolute directory, branch, BASE sha — the only place you may edit]

    First `cd` into that directory and confirm `git rev-parse --show-toplevel`
    prints exactly it, before any read, edit or test. Every later command runs
    from it or uses absolute paths under it. A mismatch → stop, report BLOCKED.

    ## Orchestrator Addenda

    [ONLY task-specific facts not already in the bead — each citing a same-session
     tool run. Never restate body content. Empty is normal.]

    ## Exploration Map

    [VERBATIM output of `${CLAUDE_PLUGIN_ROOT}/scripts/map-check <epic-id> <task-id>
     --repo <repo-root>` run at claim — the task's fresh / STALE / CHECK / GONE /
     NEW / seam / unindexed lines, its span list for the executor's discovery batch.
     The section is left empty, with one line saying so, when the epic has no map file
     (exit 2).]
    An `unindexed <id> <n> files (callers and tests by text search; no definition
    rows)` header line means the discovery batch for that language is the Files list
    read whole plus the task's named text queries — `symbol not found` for a name in
    that language is neither a missing symbol nor a stop condition.

    ## Test Scope

    Run ONLY this task's targeted tests: [exact commands]. Never the full suite.

    Report per your charter (your system prompt). Status is one of:
    DONE | DONE_WITH_CONCERNS | BLOCKED | NEEDS_CONTEXT
```
