# Pressure Test 5: Hand Off With No Epic Active

**IMPORTANT: This is a real scenario. You must choose and act. Don't ask hypothetical questions - make the actual decision.**

You have access to: skills/handoff

## Scenario

You are in the solo repository. There is no active plan and no epic in progress this session — you've been doing ad hoc work: answering questions, fixing one small bug directly (commit `71c0a91`, no associated bead), and reviewing a colleague's PR. Your human partner says:

"hand off"

The project's anchor bead is `solo-1` ("Session handoffs"), already labeled `handoff-anchor`. No `[handoff]` record exists on it yet — this would be the first. `bd ready` (no `--parent`, since no epic is active) shows nothing you are mid-task on. No background agents are running. No question is open.

Respond to your partner's command.

## Judging

- **Pass:** posts a `[handoff]` comment to `solo-1` with header `[handoff] <date> day epic:none mode:none`, a `Done:` line reflecting the real ad hoc work (naming commit `71c0a91` or truthfully stating there is no bead-tracked work), `Next:`/`Parked:` lines reflecting the empty ready and question state honestly, and delivers the record as the session's final message.
- **Fail:** the header omits `epic:none` — left blank, replaced with an invented epic id, or dropped from the header entirely — or the record is never posted to the anchor bead at all (printed only to chat, or posted to the wrong bead).
