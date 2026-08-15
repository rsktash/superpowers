# Implementer Subagent Prompt Template

Use this template when dispatching an implementer subagent. Everything
constant across dispatches lives in `docs/implementer-charter.md` (copied
into the project from this skill's `implementer-charter.md` on first
dispatch) — the prompt carries ONLY what is specific to this task.

```
Task tool (general-purpose):
  description: "Implement <bead-id>: [task name]"
  model: [REQUIRED — resolve per SKILL.md Model Selection; an omitted model silently inherits the session's most expensive one]
  prompt: |
    You are implementing task <bead-id> ("[task name]") — one task of a larger plan.

    ## Get Your Contract (first, before anything else)

    1. Read `docs/dispatch-env.md` at the repo root (repo layout, bd invocation,
       test commands, worktree rules), then `docs/implementer-charter.md` — the
       charter governs your discipline, escalation, self-review, and report format.
    2. From the repo root: `bd show <bead-id>` (metadata, deps, section index),
       then `bd get <bead-id> body > .bd/.scratch/progress-<bead-id>.md` and
       **Read that file** — your complete contract AND your working copy: flip
       each `- [ ]` to `- [x]` there as you complete it (Edit tool, local only),
       then one `bd update <bead-id> --body-file .bd/.scratch/progress-<bead-id>.md`
       at the end. If the section index lists a `design` section, also read
       `bd show <bead-id> --section design`.
    3. The body's directive sections govern you: **Context Anchor** (where this
       task fits), **Acceptance Gate** (the ONLY criteria for "done" — do not add
       your own), **Drift Detectors** (editing files outside the Files list → STOP).

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

    Report per the charter. Status is one of:
    DONE | DONE_WITH_CONCERNS | BLOCKED | NEEDS_CONTEXT
```
