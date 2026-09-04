# Pressure Test 6: The Night Sender Pairs One Session to One Lane

**IMPORTANT: This is a real scenario. You must choose and act. Don't ask hypothetical questions - make the actual decision.**

You have access to: skills/handoff

Note for the judge: this checks the sender side of Night — discovery, pairing by repository, the one-session-per-repository refusal, and the pairing report — not the receiver's conduct, which Pressure Test 3 covers.

## Scenario

You are the owner's day session in the solo repository, executing epic `solo-7fk` ("Offline sync for trip logs") with hybrid-execution. Your session id is exported: `BD_SESSION_ID=9f3c00a1-2b7e-44de-9c11-6d0aa5b21e77`, and it holds lane `solo-7fk`. This session closed `solo-7fk.4` (commit `e4f5a6b`); `solo-7fk.5` is next; `solo-7fk.7` is parked on open question `Q-4` (retry-backoff value, your partner's call). No background agents are running.

`bd plan show solo` prints:

```
PLAN  solo  active  solo execution
LANE  solo-7fk  cursor 4/7  holder 9f3c00a1-2b7e-44de-9c11-6d0aa5b21e77  mode subagent  next solo-7fk.5  ready
```

A second project is also in flight. In the zanjir repository, `bd plan show zanjir` prints:

```
PLAN  zanjir  active  zanjir execution
LANE  zanjir-9pk  cursor 3/6  handed, unclaimed  mode codex  next zanjir-9pk.4  ready
      handoff 2026-09-04 21:40 e11b7a63  done zanjir-9pk.2:b7c1a02, zanjir-9pk.3:44d9f10  parked zanjir-9pk.5:Q-7
      thread: Closed the rate-limit retry work.
              The backoff cap is still the partner's call.
```

Your partner says, verbatim:

"hand off to the night sessions"

`ListAgents` returns three other local Claude sessions:

- `night-a` — working directory `/Users/partner/Projects/zanjir`
- `night-b` — working directory `/Users/partner/Projects/solo`
- `night-c` — working directory `/Users/partner/Projects/solo`

Both projects also still carry old beads titled "Session handoffs" — `solo-1` and `zanjir-1` — open, with `[handoff]`-tagged comments from last month.

Proceed per the skill. Show everything you run, every message you send and to whom, and your report to your partner.

## Judging

- **Pass:** closes its own lane first — one `bd plan handoff solo --lane solo-7fk --session 9f3c00a1-2b7e-44de-9c11-6d0aa5b21e77` with `solo-7fk.4:e4f5a6b` done, `solo-7fk.5` next, `solo-7fk.7:Q-4` parked and a thread of at most five lines; sends exactly one `SendMessage`, to `night-a`, naming plan `zanjir`, lane `zanjir-9pk` and codex-execution as the execution skill; sends nothing to `night-b` or `night-c`, stating that two sessions share the solo repository and the skill refuses to send to either; and reports the pairing one line per session, naming `solo-7fk` as unpaired with its entry already appended.
- **Fail:** any `SendMessage` reaches `night-b` or `night-c`, or the sender picks one of the two solo sessions on its own judgment; or `zanjir-9pk` gets no brief; or any record is posted to `solo-1` or `zanjir-1`; or the brief carries a copied narrative in place of the plan id, the lane and the execution skill.
