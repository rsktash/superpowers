# Implementer Subagent Prompt Template

Use this template when dispatching an implementer subagent. Everything
constant across dispatches (the implementer charter: discipline, escalation,
self-review, report format) is the `superpowers-beads:implementer` agent's own
system prompt — shipped inside the plugin. The dispatch prompt carries ONLY
what is specific to this task.

```
Task tool (subagent_type: superpowers-beads:implementer — lean toolset, smaller prefix; use general-purpose ONLY when the task genuinely needs browser/device/MCP tools):
  description: "Implement <bead-id>: [task name]"
  model: [REQUIRED — resolve per SKILL.md Model Selection; an omitted model silently inherits the session's most expensive one]
  prompt: |
    You are implementing task <bead-id> ("[task name]") — one task of a larger plan.

    ## Get Your Contract (first, before anything else)

    1. Read `docs/dispatch-env.md` at the repo root (repo layout, bd invocation,
       test commands, worktree rules), and `docs/CONTEXT.md` (domain glossary)
       if it exists — bead bodies are written in its vocabulary.
    2. `export BD_ACTOR=executor` (your bd writes are findings and questions;
       rulings are refused to you). Need a bd command this prompt does not
       name? `bd prime` prints the full reference — never discover syntax via
       `--help`, the binary, or the database.
       From the repo root: `bd show <bead-id>` (metadata, deps, section index),
       then `bd get <bead-id> body > .bd/.scratch/progress-<bead-id>.md` and
       **Read that file** — your working copy: flip each `- [ ]` to `- [x]`
       there as you complete it (Edit tool, local only),
       then one `bd update <bead-id> --body-file .bd/.scratch/progress-<bead-id>.md`
       at the end. If the section index lists a `design` section, also read
       `bd show <bead-id> --section design`.
    3. `bd rulings <bead-id>` — REQUIRED, never skipped. The body is NOT the
       whole contract: this returns every ruling binding your task,
       inheritance-resolved — a ruling filed on the parent epic binds you and
       is invisible on your bead alone. A ruling OUTRANKS the body it
       contradicts and is settled: implement it, never re-litigate it, never
       re-open it as a fork, never ask about it again.
       Then `bd comment list <bead-id>` — narrative and evidence: review
       verdicts and BLOCKED reports land here, oldest to newest. Two things
       you must carry out of them:
       - An **open question** on the bead, or an inherited fork marked
         unruled, is NOT yours to close (`bd question answer`/`close` refuse
         your actor; `bd question list` shows what blocks you). If your work
         reaches it, stop and report BLOCKED naming the fork.
       - A **prior review verdict** tells you what is already fixed and what is
         still owed. On a RESUMED task that verdict, not the body, is the true
         state of the work — the body describes the task, not its progress.
    4. The body's directive sections govern you: **Context Anchor** (where this
       task fits), **Acceptance Gate** (the ONLY criteria for "done" — do not add
       your own), **Drift Detectors** (editing files outside the Files list →
       STOP — except a test your in-contract change broke, which is in-contract
       to update; a structural ban still stops the turn).

    ## Your Worktree

    [directory, branch, BASE sha — the only place you may edit]

    ## Orchestrator Addenda

    [ONLY task-specific facts not already in the bead — each citing a same-session
     tool run. Never restate body content: the bead is the single source of truth,
     and every line here is resident in the controller's context for the rest of
     its session. Empty is normal.]

    ## Test Scope

    Run ONLY this task's targeted tests: [exact commands]. Never the full suite —
    the suite gate runs once, in the controller's session.

    Report per your charter (your system prompt). Status is one of:
    DONE | DONE_WITH_CONCERNS | BLOCKED | NEEDS_CONTEXT
```
