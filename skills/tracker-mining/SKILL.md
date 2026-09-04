---
name: tracker-mining
description: Use when a tracker question needs exploring rather than answering — triaging a plan's lanes, auditing an epic's decisions, taking stock of a thread of work, backfilling topics, or searching whether ground is already settled — so the reads run in a fork and only a brief comes back
context: fork
model: sonnet
disallowed-tools: Edit, Write, NotebookEdit
---

# Tracker Mining — budget 900 words

Exploratory tracker reads are cheap to run and expensive to carry: mining a live tracker inside a coordinator's session cost 321K tokens (measured 2026-09-02) to answer questions worth a dozen lines. This skill runs them in a fork and returns one **mining brief** — the only thing that crosses back. Nothing is written.

**Input:** `$ARGUMENTS` names one job and its scope. Five jobs, no sixth; an argument matching none is reported unrecognised in the header, and no reads run.

## The five jobs

**`triage <plan-id>`** — what each lane is on and what blocks it. Reads `bd plan show <plan-id>`, `bd question list` for the project, then `bd authority <cursor-id> --json` for each lane's next bead. Brief: one line per lane (name, cursor, holder, next bead, blocker), then one line per open question that blocks a cursor.

**`audit <project|epic-id>`** — what a scope has decided and what it still owes. Reads `bd rulings <epic-id>` (or `bd rulings --scope project` for a project scope), `bd question list <epic-id>`, and `bd authority <epic-id> --json` for the findings. `bd source <statement-id>` runs only where a statement's wording is the question. Brief: rulings, then open questions, then findings, newest first in each group.

**`state <epic-id|words>`** — where one thread of work stands. With a bead id, `bd authority <epic-id>`; with words, `bd authority "<words>" --concern <name>` — bd refuses a words query without a concern, so ask the caller for it rather than guess. `bd settled "<words>"` follows, catching statements the brief's cells truncated. Brief: the BRIEF line, then the statements, then the lane line when the scope sits in one.

**`backfill <project>`** — which statements should carry which topic. Reads `bd topics --all` first — that printed catalogue is the whole vocabulary — then `bd authority <epic-id> --json` per open epic to find statements carrying no slug. Brief: one line per untopiced statement with the catalogue slug proposed for it and why. Minting a slug is not a proposal this job may make (R-40): a statement no catalogue slug fits is reported unfitted, for the coordinator.

**`search "<words>" --concern <name>`** — whether this ground is already settled. Reads `bd authority "<words>" --concern <name>` and `bd settled "<words>"`; `bd source <id>` runs on at most three hits. Brief: one line per hit, most authoritative first (ruling, then question, then finding).

## What may be read, and what may not

The read list, entire: `bd authority` — with `--json` wherever the job parses, counts or filters the lines rather than copying them — `bd plan show`, `bd rulings`, `bd question list`, `bd topics --all`, `bd settled`, `bd source`.

Three reads are banned, and each is banned by name:

- **A `--full` body.** No `bd show --full`, no `bd workfile`, no body read. A body is creation-day text; every brief here answers from typed state.
- **A comment thread.** No `bd comment list`, at any tag, at any `--last`. Comments are narrative; nothing binding lives in one.
- **A `.jsonl` transcript.** Never opened, never grepped, not even the path `bd source` prints — that grep line is copied into the brief, never run here.

A question the read list cannot answer is reported unanswered, naming the read that would answer it. Widening the list is what this skill exists to prevent.

## The brief, and no other output

One shape, always, whatever the job:

```
MINING <job> <scope> <YYYY-MM-DD>
<id>  <date>  <author>  <headline>
...
Proposed actions:
bd <verb> ...
```

The header names job, scope and date. Brief lines mirror `bd authority`'s line format — id, date, author, headline — one terminal line each, truncated with `…`, never wrapped. Proposed actions are bd commands, one per line, for the caller to run — never run here.

**The cap is 40 lines: one header, at most 25 brief lines, at most 12 proposed actions.** Cut at the cap and append one `N more` line naming what was dropped (`12 more findings`). The cap is never widened, not even for a caller asking for everything: they get the capped brief plus the command that shows the rest. No prose, no summary paragraph, no preamble.

## This skill writes nothing

Export `BD_ACTOR=miner` before the first bd command and keep it for the whole run. Then write nothing: no `bd question add`, no `bd finding add`, no `bd comment add`, no `bd ruling add`, no `bd update`, no `bd topics assign`, no file edit. There is no "the coordinator asked me to" exception — a caller wanting a write gets it as a proposed action.

Why both: Bash cannot be restricted per command, so `disallowed-tools` stops the file tools but not a bd write. The export and this text are the whole defence, and neither works alone.

**`backfill`'s output is proposals only.** It emits `bd topics assign <statement-ids> --topic <slug>`, one line per proposed assignment. That verb does not exist yet — it belongs to beads-537 — so the job never runs it, and never substitutes another verb for it.
