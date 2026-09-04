# The Lane Step — the plan, the epic's lane, the claim

The one home for lane creation. hybrid-execution, codex-execution and
subagent-driven-development each cite this file once, immediately after their
epic gate; every rule below is stated once, here, for the three alike. Lane
creation is the coordinator's job and it happens at execution start: the
planner never writes plan state, and the handoff skill only reads and writes a
lane this step already created.

Run the three steps in order, after the epic gate passes and before the run's
first claim.

## 1. Ensure the project's plan

A project has **one** execution plan, active for the life of the project, and
its id is the tracker prefix — `superpowers` for beads numbered
`superpowers-bqp.2`. Every epic of that project runs as a lane inside it, so
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

`bd plan create` is open to every actor and refuses nothing at creation time;
a second plan costs the whole project one command later, at `bd ready`:

```
error: bd ready: plans <a> and <b> are both active; end one with bd plan handoff/close before ordering
```

`bd authority` stops on the same collision. So a project whose active plan
carries an older id keeps that id and reuses it — the prefix rule fixes what a
new plan is named, never what an existing one is renamed to.

## 2. Add the epic's lane

```bash
bd plan lane add <plan-id> <epic-id> --queue <ids> --mode <mode> --rulings <ids>
```

prints `lane <epic-id> added to <plan-id> with <n> queued`. The four values:

- **the lane name is the epic id** — one lane per epic, so the name is never
  chosen.
- `--queue` — the epic's open children in `bd children <epic-id>` order,
  comma-separated, minus every child whose title starts with `Decide:`: a
  decision bead is the owner's to rule, never a queue entry to execute.
- `--mode` — the skill you are running: hybrid-execution passes `subagent`,
  codex-execution passes `codex`, subagent-driven-development passes
  `subagent`. bd's third value, `inline`, is passed by no execution skill.
- `--rulings` — every id `bd rulings <epic-id>` prints, comma-separated. That
  list is inheritance-resolved, so the rulings the epic's parents carry are
  already in it.

A lane the plan already lists is not added a second time — `bd plan lane add`
refuses the duplicate with `error: UNIQUE constraint failed:
plan_lane.plan_id, plan_lane.lane`, and step 1's `bd plan show` already named
every lane that exists.

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
this step defines no fallback of its own, so an empty variable is a broken
hook to report, never a value to invent. A lane the plan does not carry fails
the claim with `error: not found`.

**A held lane stops the run.** The refusal names the holder:

```
error: lane <epic-id> is held by session <holder-id> since <timestamp>
```

Another session is executing this epic right now. Report the holder id and the
timestamp in one line and STOP — never a second lane for the same epic, never
the epic without a lane. Two sessions on one epic is exactly the collision the
lane exists to prevent.

## Once a plan-close verb exists

`bd plan` carries claim, create, handoff, join, lane and show — there is no
close verb yet, which is why step 1's one-plan rule has no exit and `bd ready`'s
refusal names a verb bd does not yet carry. When `bd plan close` ships, a
finished plan is closed before the next is created, and that close is the one
thing that makes a second `bd plan create` in a project safe; until it ships,
a second create is a defect.
