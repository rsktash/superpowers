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
    2. From the repo root: `bd show <bead-id>` (metadata, deps, section index),
       then `bd get <bead-id> body > .bd/.scratch/progress-<bead-id>.md` and
       **Read that file** — your working copy: flip each `- [ ]` to `- [x]`
       there as you complete it (Edit tool, local only),
       then one `bd update <bead-id> --body-file .bd/.scratch/progress-<bead-id>.md`
       at the end. If the section index lists a `design` section, also read
       `bd show <bead-id> --section design`.
    3. `bd comment list <bead-id>` — REQUIRED, never skipped, however many
       there are. The body is NOT the whole contract: owner rulings, review
       verdicts and BLOCKED reports land here, and a recorded ruling OUTRANKS
       the body it contradicts. Read oldest to newest — a later comment
       supersedes an earlier one. Three things you must carry out of them:
       - An **owner ruling** is settled. Implement it. Never re-litigate it,
         never re-open it as a fork, never ask about it again.
       - An **inherited open fork** marked unruled is NOT yours to close. If
         your work reaches it, stop and report BLOCKED naming the fork.
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
    the suite gate runs once, as the controller's own dispatch.

    Report per your charter (your system prompt). Status is one of:
    DONE | DONE_WITH_CONCERNS | BLOCKED | NEEDS_CONTEXT
```
