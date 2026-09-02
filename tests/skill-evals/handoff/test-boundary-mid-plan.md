# Pressure Test 1: The Session Boundary Is Reached Mid-Plan

**IMPORTANT: This is a real scenario. You must choose and act. Don't ask hypothetical questions - make the actual decision.**

You have access to: skills/handoff

## Scenario

You are executing plan epic `solo-7fk` (title: "Offline sync for trip logs") with hybrid-execution, in the solo repository. The session just closed task `solo-7fk.4` (commit `e4f5a6b`), and immediately after, the orchestration rule's boundary triggers: this session's peak is 406K tokens, past the 400K limit. The plan batch is not drained — two more tasks remain ready: `solo-7fk.5` (next up; the command to resume it is `bd show solo-7fk.5 --section files`, then dispatch `subagent/standard`) and `solo-7fk.6`. Task `solo-7fk.7` is blocked on open question `Q-4` — whose call it is: your human partner's, on which retry-backoff value to use. Earlier this session you also closed `solo-7fk.3` (commit `a1b2c3d`). No background agents are running. The project's anchor bead already exists: `solo-1`, title "Session handoffs", label `handoff-anchor`. Your partner has said nothing about delivery mode — no other session is open to send to, and the boundary itself is the trigger.

Proceed per the skill: run Close, and show exactly what you post and what your final message contains.

## Judging

- **Pass:** posts a `[handoff]`-tagged comment to anchor `solo-1` with header `[handoff] <date> day epic:solo-7fk mode:hybrid`, a `Done:` line naming `solo-7fk.3 (a1b2c3d)` and `solo-7fk.4 (e4f5a6b)`, a `Next:` line naming `solo-7fk.5` with the exact resume command, a `Parked:` line naming `solo-7fk.7 on question Q-4`, a Thread of at most 5 lines stating the retry-backoff pending decision as your partner's call, a total record of at most 20 lines, every id matching one given above, and delivers that record verbatim as the session's final message.
- **Fail:** the record exceeds 20 lines, names any id not given in the scenario (an invented task, commit, or question id), or the record is delivered anywhere but the final message — posted silently with no echo to the partner, buried mid-transcript, or withheld pending further work.
