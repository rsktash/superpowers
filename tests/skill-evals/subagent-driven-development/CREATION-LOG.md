# Creation Log: Subagent-Driven Development — Fix Routing

Pressure-test evidence for the **Fix Routing** bullet of
`skills/subagent-driven-development/SKILL.md` (bead superpowers-bqp, Task 7).

## Method

Each scenario is dispatched to a fresh subagent — Claude Sonnet,
general-purpose, no session history — as a single self-contained payload: the
scenario text through its closing instruction, with the `## Judging` section
stripped, plus the full landed text of
`skills/subagent-driven-development/SKILL.md`. The agent reads that payload and
nothing else: no repository, no search, no other context. Responses are judged
against the scenario's Judging section.

The runs have no repository, so commands in a response are stated, not executed;
the judgment is on the routing decision and the lines emitted.

**Not run by the executor.** The live runner is the coordinator's gate, never an
implementer's (`docs/dispatch-env.md`), and the coordinator runs each scenario
at landing as one fresh agent with the scenario file and the landed skill text
as its only context — the way `superpowers-5f7.5` recorded it and the way
`tests/skill-evals/implementer/test-no-fitting-topic-slug.md` was run. A FAIL of
that run routes back to superpowers-bqp.7 as a fix round before the bead closes.

## What changed, and why these two scenarios

The old Fix Routing bullet made "fully specified by the finding itself" the test
of who applies a fix: a defect the finding pinned down went to the controller,
and a round back to the implementer needed a justification beyond preference.
That collided with the delegation directive (orchestration rule: findings return
to the implementer's live session, which holds context a fresh fixer lacks) and
with R-41 on superpowers-bqp, which rules that every behavioural defect goes to
that session and the controller keeps only mechanical edits with no design
content.

The rewrite therefore has exactly two ways to fail, and one scenario guards each
side of the new line:

- Over-applying: the controller keeps a fix because the finding specified it
  fully — the *old* test, surviving in habit.
- Over-dispatching: the controller sends a comment's wording back to an
  implementer because "every defect goes to the implementer" swallowed the
  rule's own exception.

## Scenario: test-fully-specified-still-dispatched.md — expected PASS

A FAIL verdict with two anchored defects and one proposal. Finding 1 is a
two-character `-ge` → `-gt` edit the reviewer wrote, tested, and watched pass
inside the review worktree; the implementer's session is still live; the
controller is at 320K context with four tasks left. Every pressure the old test
answered with "the controller applies it" is present at once.

- Expected: PASS — findings 1 and 2 go back to the implementer's live session as
  **one** round (not a fresh implementer, not one round per finding); finding 3
  stays out of the round as a proposal and takes the backlog line or a
  severity-bar bead; the fix is expected as commits on top of the reviewed ones.
- Failure mode caught: applying a fully specified defect inline because the
  finding pinned it down, the diff is two characters, the reviewer already
  tested it, or the controller's context is nearly spent — plus the two
  adjacent slips the same bullet governs, a fresh implementer while the task's
  own session is live, and a round per finding.

## Scenario: test-comment-wording-inline.md — expected PASS

A FAIL verdict whose single finding is a stale comment's wording, with the
replacement text given, the one check named, and the sibling-site sweep already
run in the controller's shell returning exactly the cited line. The implementer's
session is live and the controller has just re-read the rule that sends defects
there.

- Expected: PASS — the controller applies the rewording inline as a mechanical
  edit with no design content, commits on top of the reviewed commit, re-runs
  the named check, and clears the verdict on that output, with the single-hit
  sweep as what licenses the inline edit.
- Failure mode caught: dispatching a round (or a fresh implementer) for a
  comment's wording, reading the delegation rule as absolute and losing its
  stated exception; and the three ways an inline fix can be done badly — no
  check re-run, no sweep for the defect class, or an amended reviewed commit.

## Why the sweep is clean in the second scenario

The rewritten bullet keeps the implementer's full obligations on a
controller-applied fix, including the sibling-site sweep, and rules that a sweep
spanning surfaces the finding did not enumerate is design content — dispatch it.
So a second scenario site would have flipped the expected verdict to *dispatch*
and stopped testing the inline exception at all. The sweep output is therefore
given in the scenario as a single hit, and the Judging section checks that the
agent uses it rather than skipping it.

## Coordinator runs — 2026-09-05, skill text at `10395c8`

Each run: one fresh Sonnet general-purpose agent, payload = the scenario file with `## Judging` stripped plus the full landed `skills/subagent-driven-development/SKILL.md`, no repository and no other tool.

- `test-fully-specified-still-dispatched.md` — **PASS**: both defects went to the implementer's live session as one round, the response stating that Fix Routing bars the inline edit because "'small,' 'obvious,' and 'the reviewer already wrote the test' are not the test"; finding 3 was disposed as a proposal on the backlog line, and the fix was asked for as commits on top of the existing two.
- `test-comment-wording-inline.md` — **PASS**: the controller applied the rewording inline as a mechanical edit with no design content, committed on top of the reviewed commit without amending, re-ran the named `grep` check to clear the verdict, and named the single-hit sibling sweep as what discharged the obligation that licenses the inline edit.
- Action: none. No fix round.

---

*Created: 2026-09-05*
