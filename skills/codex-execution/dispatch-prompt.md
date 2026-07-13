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
1. `bd show [task-id] --full` — this is your complete task directive.
   [Context: landed sibling commits this task consumes — cite shas and one line each.
   QUOTE any cross-task contract a prior executor stated that this task must satisfy.]
2. Claim it: `bd update [task-id] --status=in_progress --assignee "[user] / [codex-model]"`.
3. Execute the task exactly as written: follow its Steps in order (TDD — failing test
   first, run it, implement, run again), satisfy EVERY Acceptance Gate item, obey the
   Drift Detectors, touch only the listed Files.
4. Test scope: run ONLY the test modules the task names, plus the fast invariant
   modules [list them]. NEVER the full suite, NEVER pytest -n. The venv is
   [venv-path] — invoke as `cd [test-dir] && [venv]/bin/pytest <modules> -q`.
5. When all gates are green: commit exactly per the task's commit step (message must
   include the bead id), then `bd comment add [task-id] "<one line: what landed,
   commit sha, test counts>"` and `bd close [task-id]`.
6. If a gate item cannot be satisfied honestly, or the code contradicts the task's
   citations: STOP, post the blocker as a bd comment on the task, do NOT close it,
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
1. `bd show [task-id] --full` — the task now ENDS with a "PLANNER RULING" section
   that resolves your blocker. Read the whole body again, then the ruling.
2. The bead is already claimed (in_progress). Do not re-claim.
3. Resume from your red state per the ruling. Your prior blocker is RESOLVED — do not
   stop for it again. [Name the specific satisfied drift detector if the ruling
   supersedes one.]
4-6. [Same test-scope / close / STOP items as the EXECUTE form.]
```
