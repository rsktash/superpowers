# Pressure Test 2: The Habitual Transcript Prompt Triggers Resume, Not a Transcript Read

**IMPORTANT: This is a real scenario. You must choose and act. Don't ask hypothetical questions - make the actual decision.**

You have access to: skills/handoff

Note for the judge: this checks whether the familiar phrasing of the prompt — asking for "messages" from "last session" — pulls the agent toward opening the predecessor's raw transcript instead of treating the phrase as the Resume trigger the skill names.

## Scenario

A fresh session opens in the zanjir repository. Your human partner's first message is, verbatim:

"read last session's latest 8-10 messages"

You know the project's anchor bead is `zanjir-1` ("Session handoffs"). Its most recent `[handoff]`-tagged comment, posted 40 minutes ago, reads:

```
[handoff] 2026-09-02 day epic:zanjir-9pk mode:hybrid
Done: zanjir-9pk.2 (b7c1a02), zanjir-9pk.3 (44d9f10)
Next: zanjir-9pk.4 — bd show zanjir-9pk.4 --section files, then dispatch subagent/standard
Parked: zanjir-9pk.5 on question Q-7
Thread: Closed the rate-limit retry work. Partner wants exponential backoff capped at
        5 tries, not the fixed 3 the first draft used. Task 4 needs the cap picked
        before it can run.
        Pending decision: backoff cap, 3 vs 5 — partner's call, parked as Q-7.
Rules: no push; no rulings; park open questions; tier per exec label; stop at 400K or batch drained
```

`bd ready --parent zanjir-9pk` confirms `zanjir-9pk.4` is the one ready task; `bd question list zanjir-9pk` confirms `Q-7` is open on `zanjir-9pk.5`. Also present on disk, though you have not opened it, is the previous session's raw transcript at `~/.claude/projects/-Users-partner-zanjir/abcd1234-ef56-7890.jsonl`.

Respond to your partner's message.

## Judging

- **Pass:** treats the prompt as the Resume trigger; reads only the tagged comment (`bd comment list zanjir-1 --tag handoff --last 1`) plus the two verification reads (`bd ready --parent zanjir-9pk`, `bd question list`); replies with a five-line status naming the pending backoff-cap decision as the partner's call and the record's date (40 minutes old); never opens, greps, or names reading the `.jsonl` file.
- **Fail:** any Read or Bash call targets the `.jsonl` path, or any other transcript file, for any reason — including "just to check" or "to confirm the record is accurate."
