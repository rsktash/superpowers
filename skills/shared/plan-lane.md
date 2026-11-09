# The Lane Step — the plan, the epic's lane, the claim

Lane creation is the coordinator's job, at execution start.

Run the three steps in order, after the epic gate passes and before the run's
first claim.

## 1. Ensure the project's plan

A project has **one** execution plan, active for the life of the project, and
its id is the tracker prefix — `proj` for beads numbered `proj-x1.2`. Every epic of that project runs as a lane inside it, so
the first coordinator that needs a plan creates it and every coordinator after
that reuses it. Read before you write:

```bash
bd plan show <tracker-prefix>
```

A plan prints → that is the project's plan; go to step 2. `error: plan
<tracker-prefix> not found` → you are the first, so create it:

```bash
bd plan create "<project> execution" --id <tracker-prefix>
```

Never create a second plan: `bd ready` and `bd authority` refuse while two are active. A project whose active plan carries an older id keeps reusing it.

## 2. Add the epic's lane

```bash
bd plan lane add <plan-id> <epic-id> --queue <ids> --mode <mode> --rulings <ids>
```

prints `lane <epic-id> added to <plan-id> with <n> queued`. The four values:

- **the lane name is the epic id**.
- `--queue` — the epic's open children in `bd children <epic-id>` order,
  comma-separated, minus every child whose title starts with `Decide:`.
- `--mode` — the skill you are running: `opencode` for opencode-execution, `subagent` for the other two.
- The owner's serial-or-parallel choice is not a `--mode` value: it lives on
  the epic as the label `exec-mode:serial` or `exec-mode:hybrid-parallel`, and
  a resumed lane reads it again.
- `--rulings` — every id `bd rulings <epic-id>` prints, comma-separated.

A lane step 1's `bd plan show` already lists is not added again.

Tasks that arrive after the lane is drawn — writing-plans amend mode adding
siblings under an epic already in flight — go into their own lane named
`<epic-id>-<n>`, `<epic-id>-2` for the first such batch. The lane that is
already draining keeps its queue and its cursor untouched.

## 3. Claim the lane

```bash
bd plan claim <plan-id> --lane <epic-id> --session "$BD_SESSION_ID"
```

prints `session <session-id> holds lane <epic-id> of <plan-id>`.
`$BD_SESSION_ID` is this session's own id, exported by the SessionStart hook;
an empty variable is a broken
hook to report, never a value to invent. A lane the plan does not carry fails
the claim with `error: not found`.

**A held lane stops the run.** The refusal names the holder:

```
error: lane <epic-id> is held by session <holder-id> since <timestamp>
```

Another session is executing this epic right now. Report the holder id and the
timestamp in one line and STOP — never a second lane for the same epic, never
the epic without a lane.

Until bd carries `bd plan close`, a second `bd plan create` in a project is a defect; once it does, close a finished plan before creating the next.

## Epic gate

**Epic gate:** run `bd children <root-id>` first, then `bd label list <root-id>` and `bd label list <task-id>` for every open child. An epic-type bead with no children, no `plan-ready:` label on the root, no `## Attention Map` section in the root body (`bd show <root-id>` outline), or an open child without an `exec:` label is not a plan: STOP and dispatch `superpowers-beads:planner`. Exempt from the `exec:` check: an open child titled `Decide:` that an open task depends on (`bd get <id> rdeps` non-empty; none → orphan fork, the gate stops on it), and an open child carrying an open owner question (`bd question list`). Never improvise tasks from the epic body; never mint the missing label or section by hand. A ready bead labeled `needs-plan` is not dispatchable: dispatch `superpowers-beads:planner` with the root epic and bead ids, amend mode.
