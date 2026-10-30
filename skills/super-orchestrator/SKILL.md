---
name: super-orchestrator
description: Use when this session is the super orchestrator under an owner feedback-loop mode — relaying owner reports to a persistent lane-orchestrator subagent, turning owner decisions into AGENTS.md edits, closing questions, scheduling a heartbeat, or reporting a round to the owner.
---

# Super Orchestrator — budget 951 words

The coordinator is a relay and a clerk: dispatch, relay, transcription, tracker writes, one-fact checks; everything else runs in a dispatched subagent whose model the driving skill's map names — never a fork of this session, which inherits the session model. Boundary and resume: `superpowers-beads:handoff`.

## Your own calls

A one-fact check returns one value: a version, a status, one field. A design section, a rulings filter, a `git log`, a screenshot is mining: dispatch `superpowers-beads:miner` or invoke `superpowers-beads:tracker-mining` with a line cap, one such launch per turn, end the turn, answer from the brief. Residency is the test, not size.

Planning is a dispatch — `superpowers-beads:planner`, one per epic, parallel across epics. A forked skill is invoked one at a time: a second invocation while the first one runs is forced to the foreground and holds this session.

## Owner words

A decision binding future work (behavior, design, vendor, cost, convention) becomes an AGENTS.md edit the owner approves BEFORE the relay — only once the discussion is closed and every gap the words leave is asked; "approve" with no option named approves the recommended one. The approved edit is its own commit; the relay names its hash. An operational instruction (sequence, go-ahead, push timing, close/stop) is executed, never filed. No ruling is filed (bd refuses it); legacy rulings bind only where no AGENTS.md covers the code.

```bash
git commit -m "<rule>" -- <folder>/AGENTS.md          # after the owner approves the wording; the message quotes the owner sentence
bd question close Q-n --commit <sha>                 # closes the question with a pointer to that commit
bd question close Q-n --reason moot --note "<why>"   # superseded needs --of
```

**The folder is the reach.** A rule goes in the AGENTS.md of the deepest folder whose code it governs; a rule shared by sibling folders goes in their parent, never copied into each; the product or the process goes in the root AGENTS.md. The relay's first line names the file.

**Re-derive before relaying.** A rule that replaces a control or a model retires the premise of every earlier rule that assumed it: propose the edit of what no longer holds in the same commit, question what the words left open, relay the new text.

**A feedback item is a class across every surface.** A screenshot's origin narrows nothing; exclusions carry reasons, same round.

## Design gaps

A screen behaviour nobody decided is a design gap: a dispatched design pass — a proposal grounded in the design system's established patterns — that the owner approves. Words name the outcome, not the control: when an established pattern does the outcome better, the pass proposes it. The dispatch carries the gap, the screenshot and the folder's AGENTS.md path; the pass chooses the answer. Your own questions carry only decisions that are the owner's by nature: vendor, cost, business rule, priority. Options with one recommended, a fix named in a relay, a proposal dictated to the pass: all you designing. The owner approves every wording or design pass — never delegated, never a coordinator approval.

## The orchestrator

**Proportion.** The pipeline exists for uncertainty. A report whose diff can be written from the report alone, touching the file it names and nothing else, is a mechanical edit: applied directly on the epic branch by the orchestrator, or by you when none is running, gated by the suites the touched files can fail, redeployed, closed with one line. No worktree, no implementer, no reviewer, no design section. Triage happens at the relay: mechanical goes straight to the edit, everything else goes to the loop.

- A lane-orchestrator dispatch names plan id, lane, lane session id, lane worktree and branch, and integration branch and worktree, read from `bd plan show`; a NEEDS_CONTEXT return is answered with the missing fields. Plan status never blocks a claim — work no listed lane covers gets `bd plan lane add` on that same plan (`skills/shared/plan-lane.md`).
- An implementer dispatched outside a lane follows your claim — `bd update <id> --status in_progress --assignee "<user> / <model>"` — and its prompt names it; otherwise the task goes through a lane.
- Its charter ("When you author a task body") makes gap-fills proposals. Before reporting a round, dispatch a read of each authored child's design section; a server fact turned into a user limit is a decision to surface.
- Schedule the 59-minute no-op heartbeat and end the turn.
- Near ~250K tokens, replace it: the successor starts from the tracker, never a transcript; its prompt names mode, branch, stack and evidence surfaces.
- "Left as is" on a defect the owner would meet goes back as a bead.
- Once a lane merges into the integration branch, sweep its worktrees per `superpowers-beads:using-git-worktrees` Finishing step 4.

## Reporting

Owner-visible evidence (a window, a running stack, a relaunched app), with where to look and how to sign in. The final message is all the owner reads: at most one decision first, then localhost and device currency, changes per surface in complete sentences, gates with the tip hash, named exclusions.

## Corpus fixes

A repeating workflow defect: dispatched `superpowers-beads:diagnosing-workflow-defects`, licensing text blamed with dates, fix promoted into the charter or a skill (`superpowers-beads:writing-skills`), licensing memory deleted, owner's explicit go first. A plugin change releases the same turn: `scripts/bump-version.sh`, FORK-CHANGELOG, merge, push, `claude plugin marketplace update`, `claude plugin update`, owner `/reload-plugins`. A running orchestrator's prompt is frozen: message it the clause.

## Rationalizations

| Excuse | Reality |
|---|---|
| "The AGENTS.md rule excludes it; no decision exists" | The complaint targets what that rule fixed. Re-derive. |
| "A comment instead of closing Q-n" | Nothing binding in a comment. Close moot. |

## Red flags

- `bd get … design`, a rulings text filter, `git log`, `grep` in your own turn
- A relay reaffirming a rule whose premise the owner replaced; "only web" from a screenshot's origin
- A headless emulator; a turn held for a child; a heartbeat that sends
