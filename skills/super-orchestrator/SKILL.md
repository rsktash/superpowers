---
name: super-orchestrator
description: Use when this session is the super orchestrator under an owner feedback-loop mode — relaying owner reports to a persistent lane-orchestrator subagent, transcribing owner words into rulings, closing questions, scheduling a heartbeat, or reporting a round to the owner.
---

# Super Orchestrator — budget 700 words

The coordinator is a relay and a clerk: dispatch, relay, transcription, tracker writes, one-fact checks; everything else runs forked. Boundary and resume: `superpowers-beads:handoff`.

## Your own calls

A one-fact check returns one value: a version, a status, one field. A design section, a rulings filter, a `git log`, a screenshot is mining: fork `superpowers-beads:miner` or `superpowers-beads:tracker-mining` with a line cap, end the turn, answer from the brief. Residency is the test, not size.

## Owner words

A statement that names an answer becomes a ruling BEFORE the relay; the relay names the R-id.

```bash
bd ruling add <epic> "<text>" --topic <slug> --verbatim "<owner sentence>"   # --answers Q-n inherits the topic; --supersedes R-n
bd rulings <epic> --json | jq '.[-1]'                # the exit code proves nothing
bd question close Q-n --reason moot --note "<why>"   # superseded needs --of
```

**Re-derive before relaying.** A ruling that replaces a control or a model retires the premise of every earlier ruling that assumed it: supersede what no longer holds, question what the words left open, relay the new set.

**A feedback item is a class across every surface.** A screenshot's origin narrows nothing; exclusions carry reasons, same round.

## Design gaps

A screen behaviour nobody ruled is a design gap: a forked design pass — a proposal grounded in the design system's established patterns — that the owner approves. Words name the outcome, not the control: when an established pattern does the outcome better, the pass proposes it. The dispatch carries the gap, the screenshot and the rulings; the pass chooses the answer. Your own questions carry only decisions that are the owner's by nature: vendor, cost, business rule, priority. Options with one recommended, a fix named in a relay, a proposal dictated to the pass: all you designing.

## The orchestrator

- Its charter ("When you author a task body") makes gap-fills proposals. Before reporting a round, fork a read of each authored child's design section; a server fact turned into a user limit is a decision to surface.
- Schedule the 59-minute no-op heartbeat and end the turn; it wakes you, messages nobody, and reschedules itself when nothing is new.
- Near ~250K tokens, replace it: the successor starts from the tracker, never a transcript; its prompt names mode, branch, stack and evidence surfaces.
- "Left as is" on a defect the owner would meet goes back as a bead.

## Reporting

Owner-visible evidence (a window, a running stack, a relaunched app), with where to look and how to sign in. The final message is all the owner reads: localhost and device currency first, changes per surface in complete sentences, gates with the tip hash, named exclusions, at most one decision.

## Corpus fixes

A repeating workflow defect: forked `superpowers-beads:diagnosing-workflow-defects`, licensing text blamed with dates, fix promoted into the charter or a skill (`superpowers-beads:writing-skills`), licensing memory deleted, owner's explicit go first. A plugin change releases the same turn: `scripts/bump-version.sh`, FORK-CHANGELOG, merge, push, `claude plugin marketplace update`, `claude plugin update`, owner `/reload-plugins`. A running orchestrator's prompt is frozen: message it the clause.

## Quick reference

| Event | Move |
|---|---|
| Owner names an answer | Ruling `--verbatim`, verify `--json`, relay the R-id |
| Owner replaces a control | Re-derive the topic, supersede, relay |
| Screen behaviour unruled | Forked design pass, owner approves |

## Rationalizations

| Excuse | Reality |
|---|---|
| "Two small reads add nothing" | Residency, not size. Fork. |
| "Not designing, only transcribing constraints" | Naming the fix is the design. |
| "Telling the pass the pattern is faster" | A dictated proposal is your design. |
| "R-n excludes it; no decision exists" | The complaint targets what R-n fixed. Re-derive. |
| "A comment instead of closing Q-n" | Nothing binding in a comment. Close moot. |

## Red flags

- `bd get … design`, a rulings text filter, `git log`, `grep` in your own turn
- Options for a screen behaviour; the answer inside a design-pass prompt
- A relay reaffirming a ruling whose premise the owner replaced; "only web" from a screenshot's origin
- A headless emulator; a turn held for a child; a heartbeat that sends
