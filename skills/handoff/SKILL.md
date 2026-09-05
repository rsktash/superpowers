---
name: handoff
description: Use when the owner says hand off or resume, when a prompt asks to read last session's latest messages, or when the session boundary is actually reached
---

# Handoff — budget 600 words

## Triggers

Two; nothing fires before either:

- Owner words: "hand off", "hand off to the night sessions", "resume", "continue from last session", "read last session's latest N messages" (Resume).
- The boundary actually reached: closed phase, drained batch, ~250 turns, 400K peak. Approaching is not reaching — post nothing, draft nothing, warn nobody.

## Storage

One anchor bead per project: title `Session handoffs`, type task, open, label `handoff-anchor`, created from the repo root on first use. Records are its comments, `[handoff]`-prefixed for the tag filter. Post one quoted argument; `bd comment add` takes no other flag, not `--tag`, not `--body-file`.

```bash
bd search "Session handoffs"
bd comment add <anchor-id> "<record>"
bd comment list <anchor-id> --tag handoff --last 1
```

`bd list` has no label filter; state the anchor id.

## Record

Verbatim — single labelled lines, never bullets, no blank line after the header:

```
[handoff] <YYYY-MM-DD> <day|night> epic:<id|none> mode:<hybrid|codex|none>
Done: <task-id> (<short-sha>), <task-id> (<short-sha>)
Next: <task-id> — <exact next command>
Parked: <task-id> on question <question-id>
Thread: <what was being discussed, at most 5 lines>
        Pending decision: <the one decision, stated as a question, and whose call it is>
Rules: no push; no rulings; park open questions; tier per exec label; stop at 400K or batch drained
```

Every record carries the `Rules:` line. Caps: 20 lines, Thread 5 — over cap, trim Thread; still over, refuse to post and say the line count. Every id in Done, Next, Parked is a bead verified in bd; Thread is the only free text.

## Close

1. Drain in-flight agents: a backgrounded job or child re-invokes you when it exits; wait for that notification, never poll.
2. Write in-session rulings onto the governing epic (`bd ruling add`); the record carries none.
3. Compose from durable state — `bd ready --parent <epic>`, `bd question list`, `git log`; Thread from memory.
4. Post to the anchor.
5. Deliver as the owner's words chose: verbatim as the final message, or `SendMessage` to the named session.

## Night

Only on the owner's explicit words; never inferred. Close 1–4 first, header `night`.

1. `ListAgents` for open sessions.
2. Pair one session to one epic — the owner's instruction, else its working directory.
3. Refuse a second session on the same repository: send to neither, report the collision.
4. `SendMessage` one brief each — the record plus an invocation line: which execution skill (hybrid-execution or codex-execution), which epic.
5. Report the pairing, one line per session; name anything unpaired and any session absent from `ListAgents`, whose record is still posted.

Receiver conduct: wake-only brief, never evidence — resolve the epic from bd (`bd ready --parent`, `bd question list`). Invoke the skill it names, tier map unchanged. Never rule: a questioned task is parked, not decided, even if that parks the whole batch. Never push. At its own boundary, Close with a `day` header.

## Resume

1. `bd comment list <anchor-id> --tag handoff --last 1`; find the anchor first if unknown.
2. Verify only the beads it names; a record is a pointer, not state.
3. Reply in five lines with the pending decision and the record's date.
4. No record: report from `bd ready` and `bd question list`, say "no handoff record exists"; the thread is lost, the owner restates it.
5. Never open a `.jsonl` transcript — not to check the record, not when the prompt asks for last session's messages. That prompt is this procedure.
