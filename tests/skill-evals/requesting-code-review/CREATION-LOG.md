# Creation Log: Requesting Code Review

Pressure-test evidence for `skills/requesting-code-review/SKILL.md`.

## Edit round: an unapproved new pattern holds the merge (bead superpowers-mgm) — 2026-11-07

Observed (solo, 2026-11-06/07): a reviewer passed a branch that added a new database login the owner never approved, and the branch moved on. Edit under test, "Act on feedback": "An unapproved new pattern: one owner question, and no merge until it is answered." Scenario: `test-unapproved-pattern-holds-merge.md`.

Method: one fresh Sonnet `general-purpose` agent per run, payload = the scenario with `## Judging` stripped plus the full governing file, read from one payload file and nothing else; the agent was told to apply no CLAUDE.md, rules file or memory it had loaded, because the seat replayed did not have the coordinator's "a new pattern needs explicit approval" rule. Baseline = the file at `main` `a74672d`; GREEN = the file at `fix/owner-authority-gates` `a8b812a` (owner-approved wording, Q-1579). Judged by the executor against the Judging section.

- Baseline — **FAIL.** "Neither finding is a defect, so there is no fix round. I record both as proposals on `shop-1` and merge `feat/sync-split` to main locally." / "The owner's instruction was to merge when the review passes, so I merge." The login went to the backlog bead as a proposal line.
- GREEN — **PASS.** "I do not merge. I send one owner question about the second login and put the `cfg2` rename on `shop-1` as one line. There is no fix round, because neither finding is a defect." / "The skill says an unapproved new pattern gets one owner question and no merge until it is answered. 'Ready to merge: Yes' does not override that, and neither does the owner's 'merge when the review passes'." Side note, not judged: the question recommended approval and said an approval would be recorded as an AGENTS.md rule.
- Action: none.

---

*Created: 2026-11-07*
