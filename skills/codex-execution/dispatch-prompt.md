# Codex dispatch prompt template

Fill the bracketed fields. First dispatch of a task uses the EXECUTE form; after a
planner ruling on a blocker, use the RESUME form.

## EXECUTE form

```
You are executing ONE task of an approved implementation plan in this repository
(branch [branch] — verify with `git branch --show-current` before any edit; never
switch branches, never push, NEVER `git stash`).

Read AGENTS.md first (project rules)[, and <dir>/AGENTS.md for scoped rules when the
task works in a rule-carrying subdirectory]. Tracker reference: `bd prime`.

Protocol:
1. `export BD_ACTOR=executor` (your bd writes are findings, questions, comments and
   status; `bd ruling add` is refused to you).
   `bd show [task-id] --full` — your task directive — then `bd rulings [task-id]`:
   every typed ruling binding this task, inheritance-resolved (a ruling filed on the
   parent epic binds you and is invisible on the task alone). A ruling OUTRANKS the
   body it contradicts.
   [Context: landed sibling commits this task consumes — cite shas and one line each.
   QUOTE any cross-task contract a prior executor stated that this task must satisfy.]

## Exploration Map

[VERBATIM output of `${CLAUDE_PLUGIN_ROOT}/scripts/map-check <epic-id> <task-id>
--repo <repo-root>` run at claim — the task's fresh / STALE / CHECK / GONE / NEW /
seam / unindexed lines, its span list for the executor's discovery batch. The
section is left empty, with one line saying so, when the epic has no map file
(exit 2).]
An `unindexed <id> <n> files (callers and tests by text search; no definition
rows)` header line means the discovery batch for that language is the Files list
read whole plus the task's named text queries — `symbol not found` for a name in
that language is neither a missing symbol nor a stop condition.

2. Issue the discovery batch: every read and index query the task's "Before you
   start" block lists, all in ONE turn (one batch of tool calls), using the
   prompt's Exploration Map block for spans. Think once over the results. Take
   a sequential turn only where a result decides the next read; no survey read
   of the tree.
3. Claim it: `bd update [task-id] --status=in_progress --assignee "[user] / [codex-model]"`.
4. Execute the task exactly as written: follow its Steps in order (TDD — failing test
   first, run it, implement, run again), satisfy EVERY Acceptance Gate item, obey the
   Drift Detectors, touch only the listed Files.
5. Test scope: run ONLY the test modules the task names, plus the fast invariant
   modules [list them]. NEVER the full suite, NEVER pytest -n. The venv is
   [venv-path] — invoke as `cd [test-dir] && [venv]/bin/pytest <modules> -q`.
6. When all gates are green: commit exactly per the task's commit step (message must
   include the bead id), then `bd comment add [task-id] "<one line: what landed,
   commit sha, test counts>"` and `bd close [task-id]`.
7. If a gate item cannot be satisfied honestly, or the code contradicts the task's
   citations: STOP, file the blocker with `bd question add [task-id] "<the blocker>"`
   (the task leaves the ready queue until a ruling answers it), do NOT close it,
   and end with a clear FAILURE report. Never weaken a test or gate to pass.

Your final output: a terse report — what changed (files), gate-by-gate evidence
(test counts/exit codes), commit sha, bead status.
[If a later task consumes a contract this task defines, add: "Also state EXPLICITLY:
<the contract> — Task N consumes it."]
```

## RESUME form (after a planner ruling)

```
You are RESUMING a task you (a previous codex run) blocked on, in this repository
(branch [branch] — verify; never switch branches, never push, NEVER `git stash`).

Read AGENTS.md first. Tracker reference: `bd prime`.

Protocol:
1. `export BD_ACTOR=executor`. `bd show [task-id] --full`, then
   `bd rulings [task-id]` — a ruling now resolves your blocker. Read the whole
   body again, then the ruling.
2. The bead is already claimed (in_progress). Do not re-claim.
3. Resume from your red state per the ruling. Your prior blocker is RESOLVED — do not
   stop for it again. [Name the specific satisfied drift detector if the ruling
   supersedes one.]
5-7. [Same test-scope / close / STOP items as the EXECUTE form.]

## Exploration Map

[Re-filled at resume: VERBATIM output of `${CLAUDE_PLUGIN_ROOT}/scripts/map-check
<epic-id> <task-id> --repo <repo-root>` re-run at this dispatch — one line when
the epic has no map file (exit 2).]
```
