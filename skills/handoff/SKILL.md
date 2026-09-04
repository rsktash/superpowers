---
name: handoff
description: Use when the owner says hand off or resume, when a prompt asks for last session's messages, or when the session boundary is actually reached
---

# Handoff — budget 600 words

## Triggers

Two; nothing fires before either:

- Owner words: "hand off", "hand off to the night sessions", "resume", "continue from last session", "read last session's latest N messages" (Resume).
- The boundary actually reached: closed phase, drained batch, ~250 turns, 400K peak. Approaching is not reaching — post nothing, draft nothing, warn nobody.

## State

A handoff is a typed row on a lane, never prose. The coordinator created and claimed that lane (`skills/shared/plan-lane.md`); this skill only reads and writes it.

```bash
bd plan handoff <prefix> --lane <lane> --session "$BD_SESSION_ID" \
  --done <id>:<sha>,<id>:<sha> --next <id> --parked <id>:<question-id>,<id>:<question-id> --thread-file <path>
```

It appends the entry and releases the lane. Every id is verified in bd. `--done` and `--parked` take comma-separated pairs, never a repeated flag. A parked item needs a question id — file it first: free text like "owner must rule" has no field to live in. Omit `--next` when the queue is finished. The thread holds five lines at most, the only free text left.

`$BD_SESSION_ID` comes from the SessionStart hook; empty is a broken hook to report, never a value to invent.

The anchor bead is retired: the first Close under this skill closes it with one final comment naming the plan id; nothing posts to it after.

## Close

1. Drain in-flight agents: poll every backgrounded job to completion.
2. `tracker-mining audit <epic-id>` for untyped decisions and stale citations.
3. `bd session close --session "$BD_SESSION_ID"` lists, writing nothing. Transcribe each owner decision as a ruling on the governing epic, `bd question add` every pending decision on the bead it concerns, and resolve every `pending-` topic slug once bd carries that state.
4. Holding a lane: run the command above — done and next from `bd plan show <prefix>`, `bd ready` and `git log`; thread from memory. Holding none: post nothing at all.
5. Deliver: holding a lane, the final message is the `bd plan show <prefix>` output. Holding none, it says no entry was appended because this session holds no lane, the thread is lost by design, and the next session starts from `bd ready`, `bd question list` and `bd plan show <prefix>`. For a session the owner named, send the plan id, lane and execution skill there.

## Resume

1. `bd plan show <prefix>` and `bd question list`. Nothing else: no `.jsonl` transcript, not for a prompt asking for last session's messages, no anchor bead.
2. Claim the lane the owner named, else the one reading `handed, unclaimed`, by the lane step's claim.
3. Verify only the ids it names.
4. More than one lane, or a blocked next id: `tracker-mining triage <prefix>` first.
5. Reply in five lines: lane, next id, parked ids with questions, the entry's date.

## Night

Only on the owner's explicit words; never inferred. Close 1–4 first.

1. `ListAgents` for open sessions.
2. Pair one session to one lane — the owner's instruction, else its working directory.
3. Refuse a second session on one repository: send to neither, report the collision.
4. `SendMessage` one brief each: plan id, lane, execution skill.
5. Report the pairing, one line per session; name anything unpaired.

Receiver conduct: the brief is wake-only, never evidence — resolve the lane from `bd plan show`. Never rule: a questioned task is parked, not decided. Never push. At its own boundary it runs Close, its thread opening with the `day` header.
