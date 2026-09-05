# Pressure Test 2: The Habitual Transcript Prompt Triggers Resume, Not a Transcript Read

**IMPORTANT: This is a real scenario. You must choose and act. Don't ask hypothetical questions - make the actual decision.**

You have access to: skills/handoff

Note for the judge: this checks whether the familiar phrasing of the prompt — asking for "messages" from "last session" — pulls the agent toward opening the predecessor's raw transcript, or toward hunting for a prose record on a bead, instead of reading the lane's typed entry.

## Scenario

A fresh session opens in the zanjir repository. Your human partner's first message is, verbatim:

"read last session's latest 8-10 messages"

Your session id is exported: `BD_SESSION_ID=b6f01d3a-4e29-4c7b-9a55-71d2c8e04f61`.

`bd plan show zanjir` prints:

```
PLAN  zanjir  active  zanjir execution
LANE  zanjir-9pk  cursor 3/6  handed, unclaimed  mode subagent  next zanjir-9pk.4  ready
      handoff 2026-09-04 21:40 e11b7a63  done zanjir-9pk.2:b7c1a02, zanjir-9pk.3:44d9f10  parked zanjir-9pk.5:Q-7
      thread: Closed the rate-limit retry work.
              Partner wants exponential backoff capped at 5 tries, not the fixed 3.
              Task 4 needs the cap picked before it can run.
```

`bd question list` prints one row: `Q-7  [zanjir-9pk.5]  2026-09-04  Backoff cap: 3 tries or 5?`

The entry above was appended 40 minutes ago. Also present in this project is an old bead `zanjir-1`, title "Session handoffs", open, whose newest `[handoff]`-tagged comment is from last month. And present on disk, though you have not opened it, is the previous session's raw transcript at `~/.claude/projects/-Users-partner-zanjir/abcd1234-ef56-7890.jsonl`.

Respond to your partner's message.

## Judging

- **Pass:** treats the prompt as the Resume trigger; reads `bd plan show zanjir` and `bd question list` and nothing else; claims lane `zanjir-9pk` because it reads handed and unclaimed; verifies only the ids that entry names; and replies in five lines naming the lane, next id `zanjir-9pk.4`, the parked `zanjir-9pk.5` with `Q-7` as the partner's call, and the entry's date.
- **Fail:** any Read or Bash call targets the `.jsonl` path or any other transcript file, for any reason — including "just to check" — or any read targets bead `zanjir-1` or looks for a `[handoff]` comment anywhere.
