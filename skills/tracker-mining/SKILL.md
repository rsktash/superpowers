---
name: tracker-mining
description: Use when a tracker question needs exploring rather than answering — where an epic stands, what is still open or blocked, which topics duplicate, whether ground is settled — so the reads run forked and only a capped brief comes back. Runs in its own forked agent; invoke it directly from the coordinator, never through a wrapper subagent.
context: fork
model: sonnet
disallowed-tools: Edit, Write, NotebookEdit
---

# Tracker Mining — budget 900 words

Mining a live tracker in a coordinator's session cost 321K tokens (2026-09-02). This skill runs those reads forked and returns one **mining brief**, the only thing that crosses back.

**Input:** `$ARGUMENTS` names one job and its scope. Five jobs, no sixth; an unmatched argument is reported unrecognised in the header; no reads run.

## Jobs

**`triage <plan-id>`** — what each lane is on and what blocks it. `bd plan show <plan-id>`, bare `bd question list`, `bd authority <cursor-id> --json` per lane. Brief: a line per lane (name, cursor, holder, next, blocker), then the blocking questions.

**`audit <project|epic-id>`** — four checks, never a listing.

Scope first; neither verb scopes as its name suggests. Project rulings are bare `bd rulings` — never `bd rulings --scope project`, which lists only issue-id-null rulings, none here. Epic rulings are `bd rulings <epic-id>`, inheritance resolved. Questions never inherit: both scopes run bare `bd question list` and select rows by the `[issue-id]` cell each carries — the epic's id plus every `<epic-id>.` child, which `bd question list <epic-id>` misses. Then `bd topics --all` once.

- **Contradicting rulings** — two active rulings on one scope that disagree; bd never refuses the second. Pair by the slug each settled (`bd topics --all`), compare full texts (`bd rulings --json`), since headlines truncate.
- **Stale citations** — an answered question still called open, a superseded ruling still quoted as law. `bd settled "<cited-id>"` finds the statements repeating it; `bd question list --status answered`, then `--status superseded`, gives the truth.
- **Unpromoted candidates** — an owner decision that never became a ruling: findings from `bd authority <scope> --json`, its owner sentence from `bd source <id>`, then the scope's rulings to confirm none carries it.
- **Duplicate and label-shaped topics** — two slugs for one subject (`execution-lane` beside `execution-lanes`), or a slug naming a process step, not a subject in dispute. `bd topics --all` is the whole input.

Brief: a line per hit, grouped by check; a check with no hit says so, so silence never reads as clean.

**`state <epic-id|words>`** — where one thread stands. `bd authority <epic-id>`, or `bd authority "<words>" --concern <name>` — bd refuses a words query without a concern, so ask rather than guess — then `bd settled "<words>"` for truncated statements. Brief: the BRIEF line, the statements, and the lane line if the scope has one.

**`backfill <project>`** — which statements should carry which topic. `bd topics --all` first: that catalogue is the whole vocabulary. Then `bd authority <epic-id> --json` per open epic for statements with no slug. Brief: a line per untopiced statement with the slug proposed and why. Minting is not a proposal this job may make (R-40); a statement no slug fits is reported unfitted. Its proposed actions are `bd topics assign <statement-ids> --topic <slug>`, one line per assignment: that verb does not exist yet — it belongs to beads-537 — so the job never runs it, nor substitutes another.

**`search "<words>" --concern <name>`** — whether this ground is settled. That `bd authority` query, `bd settled "<words>"`, `bd source <id>` on at most three hits. Brief: a line per hit, ruling before question before finding.

## What may be read

The read list, entire: `bd authority` (with `--json` wherever the job parses or filters rather than copies), `bd plan show`, `bd rulings`, `bd question list`, `bd topics --all`, `bd settled`, `bd source`.

Three reads are banned:

- **A `--full` body.** No `bd show --full`, no `bd workfile`, no body read.
- **A comment thread.** No `bd comment list`, at any tag or `--last`.
- **A `.jsonl` transcript.** Never opened, never grepped, not even the path `bd source` prints — that grep line is copied into the brief, never run here.

A question the read list cannot answer is reported unanswered, naming the read that would.

## The brief, and nothing else

```
MINING <job> <scope> <YYYY-MM-DD>
<id>  <date>  <author>  <headline>
...
Proposed actions:
bd <verb> ...
```

Brief lines mirror `bd authority`'s line format — id, date, author, headline — one terminal line each, truncated with `…`. Proposed actions are bd commands, one per line, for the caller — never run here.

**The cap is 40 lines: one header, at most 25 brief lines, at most 12 proposed actions.** Cut at the cap; append one `N more` line naming what was dropped (`12 more findings`). The cap is never widened, not even for a caller wanting everything: they get the capped brief plus the command showing the rest. No prose, no preamble.

## This skill writes nothing

Export `BD_ACTOR=miner` before the first bd command, for the whole run. Then write nothing: no `bd question add`, `bd finding add`, `bd comment add`, `bd ruling add`, `bd update` or `bd topics assign`; no file edit. No "the coordinator asked me to" exception: a caller wanting a write gets it as a proposed action. Why both: Bash cannot be restricted per command, so `disallowed-tools` stops the file tools but not a bd write; the export and this text are the whole defence, neither working alone.
