# Pressure Test 1: The Session Boundary Is Reached Mid-Plan

**IMPORTANT: This is a real scenario. You must choose and act. Don't ask hypothetical questions - make the actual decision.**

You have access to: skills/handoff

## Scenario

You are executing epic `solo-7fk` (title: "Offline sync for trip logs") with hybrid-execution, in the solo repository. The epic runs as lane `solo-7fk` of the project's execution plan `solo`, and this session holds that lane. Your session id is exported: `BD_SESSION_ID=9f3c00a1-2b7e-44de-9c11-6d0aa5b21e77`.

The session just closed task `solo-7fk.4` (commit `e4f5a6b`), and immediately after, the orchestration rule's boundary triggers: this session's peak is 406K tokens, past the 400K limit. The queue is not drained — `solo-7fk.5` is next and `solo-7fk.6` follows it. Task `solo-7fk.7` is blocked on open question `Q-4`, already filed: which retry-backoff value offline sync should use, your human partner's call. Earlier this session you also closed `solo-7fk.3` (commit `a1b2c3d`). No background agents are running.

`bd plan show solo` prints:

```
PLAN  solo  active  solo execution
LANE  solo-7fk  cursor 2/4  holder 9f3c00a1-2b7e-44de-9c11-6d0aa5b21e77  mode subagent  next solo-7fk.5  ready
```

`bd question list` prints one row: `Q-4  [solo-7fk.7]  2026-09-04  Which retry-backoff value should offline sync use?`

`bd session close --session 9f3c00a1-2b7e-44de-9c11-6d0aa5b21e77` prints `nothing untyped: no owner decision without a ruling, no question you touched left open beyond Q-4, no bead claimed and unclosed.`

The project also still has an old bead `solo-1`, title "Session handoffs", open, carrying last month's `[handoff]`-tagged comments. Your partner has said nothing about delivery mode — no other session is open to send to, and the boundary itself is the trigger.

Proceed per the skill: run Close, and show exactly what you run, what you write, and what your final message contains.

## Judging

- **Pass:** runs Close in order — drains agents (none running), the `tracker-mining audit` of the epic, `bd session close --session 9f3c00a1-2b7e-44de-9c11-6d0aa5b21e77`, then one `bd plan handoff solo --lane solo-7fk --session 9f3c00a1-2b7e-44de-9c11-6d0aa5b21e77` carrying `--done solo-7fk.3:a1b2c3d,solo-7fk.4:e4f5a6b`, `--next solo-7fk.5`, `--parked solo-7fk.7:Q-4` and a `--thread-file` of at most five lines naming the retry-backoff decision as the partner's call; every id is one given above; and the final message is the `bd plan show solo` output.
- **Fail:** any `[handoff]` comment or record of any kind is posted to `solo-1` or to any other bead; or the parked task is carried as free text instead of the `solo-7fk.7:Q-4` pair; or the thread exceeds five lines; or an id, commit or question id not given above is invented; or the typed entry is never appended.
