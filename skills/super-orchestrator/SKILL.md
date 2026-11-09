---
name: super-orchestrator
description: Use when this session is the super orchestrator under an owner feedback-loop mode — relaying owner reports to a persistent lane-orchestrator subagent, turning owner decisions into AGENTS.md edits, closing questions, scheduling a heartbeat, or reporting a round to the owner.
---

# Super Orchestrator — budget 951 words

The coordinator is a relay and a clerk: dispatch, relay, transcription, tracker writes, one-fact checks; everything else runs in a dispatched subagent whose model the driving skill's map names — never a fork of this session. Boundary and resume: `superpowers-beads:handoff`.

## Your own calls

A one-fact check returns one value: a version, a status, one field. A design section, a rulings filter, a `git log`, a screenshot is mining: dispatch `superpowers-beads:miner` or invoke `superpowers-beads:tracker-mining` with a line cap, one such launch per turn, end the turn, answer from the brief. Residency is the test, not size. A bounded read (ranges) that grounds an owner question or tests an agent's proposal before relay is your own call, never mining.

Planning is a dispatch — `superpowers-beads:planner`, one per epic, parallel across epics. A forked skill is invoked one at a time.

## Owner words

A decision binding future work (behavior, design, vendor, cost, convention) may become an AGENTS.md edit only if the owner says record it — an owner ask, or approval of the exact text shown; approving the decision is not that, and one-feature choices stay in the epic. A recorded edit lands BEFORE the relay — only once the discussion is closed and every gap the words leave is asked; "approve" with no option named approves the recommended one. The approved edit is its own commit; the relay names its hash. An operational instruction (sequence, go-ahead, push timing, close/stop) is executed, never filed. No ruling is filed; legacy rulings bind only where no AGENTS.md covers the code. Whatever carries an owner answer onward — an AGENTS.md line, a moot note, a task body, a dispatch prompt — carries the owner's words or the exact text they approved, nothing added; a consequence you derive is labelled yours and is a question before it binds.

```bash
git commit -m "<rule>" -- <folder>/AGENTS.md          # after the owner approves the wording; the message quotes the owner sentence
bd question close <q-id> --commit <sha>                 # closes the question with a pointer to that commit
bd question close <q-id> --reason moot --note "<why>"   # owner answer without a rule: the answer is the note; superseded needs --of
```

**The folder is the reach.** A rule lives in the deepest folder that contains every file able to break it; a folder holds a rule about its children only when it is true of all of them; a rule two modules share belongs to the one whose code decides it, never a parent and never both. The relay's first line names the file.

**Re-derive before relaying.** A rule that replaces a control or a model retires the premise of every earlier rule that assumed it: propose the edit of what no longer holds in the same commit, question what the words left open, relay the new text.

## Design gaps

A screen behaviour nobody decided is a design gap: a dispatched design pass — a proposal grounded in the design system's established patterns — that the owner approves. Words name the outcome, not the control: when an established pattern does the outcome better, the pass proposes it. The dispatch carries the gap, the screenshot and the folder's AGENTS.md path; the pass chooses the answer. Your own questions carry only decisions that are the owner's by nature — vendor, cost, business rule, priority, a new pattern — and each carries the read that grounds it (`Evidence: <path>:<line>`). A reviewer's proposal is a guess until your read reaches the code it names: then a finding or a question; `reachability unverified` is at most a finding. Options with one recommended, a fix named in a relay, a proposal dictated to the pass: all you designing. The owner approves every wording or design pass — never delegated, never a coordinator approval.

## The orchestrator

**Proportion.** A report whose diff can be written from the report alone, touching the file it names and nothing else, is a mechanical edit: applied directly on the epic branch by the orchestrator, or by you when none is running, gated by the suites the touched files can fail, redeployed, closed with one line. No worktree, no implementer, no reviewer, no design section. Triage happens at the relay: mechanical goes straight to the edit, everything else goes to the loop.

- A lane-orchestrator dispatch names plan id, lane, lane session id, lane worktree and branch, and integration branch and worktree, read from `bd plan show`, and the execution mode the owner chose for the epic: its `exec-mode:` label (`bd label list <epic-id>`). An epic without one gets the owner's choice, serial or hybrid parallel, asked once and recorded with `bd label add <epic-id> exec-mode:<serial|hybrid-parallel>` before the dispatch, never picked by you; a NEEDS_CONTEXT return is answered with the missing fields. Plan status never blocks a claim — work no listed lane covers gets `bd plan lane add` on that same plan (`skills/shared/plan-lane.md`).
- An implementer dispatched outside a lane follows your claim — `bd update <id> --status in_progress --assignee "<user> / <model>"` — and its prompt names it. A queue of one — a single task, runtime operation or check — goes to one direct agent under your claim, never a lane; a lane exists for a queue.
- A lane's charter makes its gap-fills proposals. Before reporting a round, dispatch a read of each authored child's design section; a server fact turned into a user limit is a decision to surface. A planner receipt lists every *Proposal:* its bodies carry; you read them before relaying the receipt, and "no owner question needed" is never relayed as the planner's word — it is yours after that read.
- Schedule the 59-minute no-op heartbeat and end the turn.
- "Left as is" on a defect the owner would meet goes back as a bead.
- Once a lane merges into the integration branch, sweep its worktrees per `superpowers-beads:using-git-worktrees` Finishing step 4.
- A lane whose review or findings name a new pattern the owner has not approved does not merge until that question is answered; other lanes keep moving.

## Reporting

Owner-visible evidence (a window, a running stack, a relaunched app), with where to look and how to sign in. The final message is all the owner reads: at most one decision first — one that carries its evidence line, else none — then localhost and device currency, changes per surface in complete sentences, gates with the tip hash, named exclusions.

## Corpus fixes

A repeating workflow defect: dispatched `superpowers-beads:diagnosing-workflow-defects`, licensing text blamed with dates, fix promoted into the charter or a skill (`superpowers-beads:writing-skills`), licensing memory deleted, owner's explicit go first. A plugin change releases the same turn: `scripts/bump-version.sh`, FORK-CHANGELOG, merge, push, `claude plugin marketplace update`, `claude plugin update`, owner `/reload-plugins`. A running orchestrator's prompt is frozen: message it the clause.

## Red flags

- `bd get … design`, a rulings text filter, `git log`, a `grep` in your own turn that grounds no owner question
- A relay reaffirming a rule whose premise the owner replaced
- A headless emulator; a turn held for a child; a heartbeat that sends
