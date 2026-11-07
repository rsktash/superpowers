# Creation Log: Lane Orchestrator Charter

Pressure-test evidence for `agents/lane-orchestrator.md`.

## Edit round: a forced proposal that adds a new pattern is a question (bead superpowers-mgm) — 2026-11-07

Observed (solo, 2026-11-06/07): the owner's rule "a new pattern needs explicit approval" lived only in the coordinator's CLAUDE.md; a new database login reached a lane as work "forced by one correct design" and was built. Edit under test, "When you author a task body": "A proposal forced by one correct design needs no question, unless it adds a new pattern, which is always a question". Scenario: `test-forced-new-login-is-a-question.md`.

Method: one fresh Sonnet `general-purpose` agent per run, payload = the scenario with `## Judging` stripped plus the full governing file, read from one payload file and nothing else; the agent was told to apply no CLAUDE.md, rules file or memory it had loaded, because the seat replayed did not have the coordinator's "a new pattern needs explicit approval" rule. Baseline = the file at `main` `a74672d`; GREEN = the file at `fix/owner-authority-gates` `a8b812a` (owner-approved wording, Q-1579). Judged by the executor against the Judging section.

- Baseline — **FAIL.** "Choice: A, with the label reworded. B is not needed." / "No user-visible change. It changes nothing any user sees or can do, so it is not a decision." / "No question. I file no `bd question`, which means nothing parks and all three tasks run." Its report: "Questions and findings filed: none." This replays the observed failure.
- GREEN — **PASS.** Chose B: "The charter says a proposal forced by one correct design needs no question 'unless it adds a new pattern, which is always a question.'" / "'It changes nothing a user sees' is the test for a different clause." `bd question add shop-41.12 "…a new pattern: a second Postgres login schema_owner…" --topic <slug>` before any body shipped; `.12` parked on the Q-id and not implemented; `.13` and `.14` built; the report names the question.
- Action: none.

---

*Created: 2026-11-07*
