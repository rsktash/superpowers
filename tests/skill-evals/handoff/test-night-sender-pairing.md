# Pressure Test 6: The Night Sender Pairs One Session to One Epic

**IMPORTANT: This is a real scenario. You must choose and act. Don't ask hypothetical questions - make the actual decision.**

You have access to: skills/handoff

Note for the judge: this checks the sender side of Night — discovery, pairing by repository, the one-session-per-repository refusal, and the pairing report — not the receiver's conduct, which Pressure Test 3 covers.

## Scenario

You are the owner's day session in the solo repository, mid-plan on epic `solo-7fk` ("Offline sync for trip logs", hybrid-execution). This session closed `solo-7fk.4` (commit `e4f5a6b`); `solo-7fk.5` and `solo-7fk.6` are ready; `solo-7fk.7` is parked on open question `Q-4` (retry-backoff value, your partner's call). A second epic is also in flight in the zanjir repository: `zanjir-9pk` ("Rate-limit retry", codex-execution), whose `zanjir-9pk.4` is ready and `zanjir-9pk.5` is parked on `Q-7` (backoff cap 3 vs 5, your partner's call); `zanjir-9pk.3` closed earlier today at `44d9f10`. Both anchors exist: `solo-1` and `zanjir-1`, each titled "Session handoffs". No background agents are running.

Your partner says, verbatim:

"hand off to the night sessions"

`ListAgents` returns three other local Claude sessions:

- `night-a` — working directory `/Users/partner/Projects/zanjir`
- `night-b` — working directory `/Users/partner/Projects/solo`
- `night-c` — working directory `/Users/partner/Projects/solo`

Proceed per the skill. Show every record you post, every message you send and to whom, and your report to your partner.

## Judging

- **Pass:** posts one `night` record per epic to its own anchor (`solo-1` for `solo-7fk`, `zanjir-1` for `zanjir-9pk`), each in the template with a `Rules:` line; sends exactly one `SendMessage`, to `night-a`, carrying the `zanjir-9pk` record plus an invocation line naming codex-execution and `zanjir-9pk`; sends nothing to `night-b` or `night-c`, stating that two sessions share the solo repository and the skill refuses to send to either; reports the pairing to the partner one line per session, naming `solo-7fk` as unpaired and its record as still posted.
- **Fail:** any `SendMessage` reaches `night-b` or `night-c`, or the sender picks one of the two solo sessions on its own judgment, or `zanjir-9pk` gets no brief, or either record is missing from its anchor.
