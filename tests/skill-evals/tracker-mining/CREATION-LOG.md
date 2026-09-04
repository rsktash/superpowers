# Creation Log: Tracker Mining Skill

Pressure-test evidence for `skills/tracker-mining/SKILL.md` (bead superpowers-bqp.3).

## Method

Each scenario is dispatched to a fresh subagent (no session history). The prompt contains the scenario file content verbatim plus the full skill text, ending with "Respond with what you do next, concretely." Responses are judged against the expected behavior named in the scenario's Judging section.

The three scenarios cover one failure mode each, chosen because each is a way the skill's value leaks away rather than a way it errors: reading past the read list (the 321K context this skill exists to stop), writing from a read-only fork (`disallowed-tools` cannot reach a bd write through Bash), and widening the cap (a brief that grows to fit its scope is the unforked read again).

**Runs are the coordinator's gate, not the implementer's.** `tests/claude-code/run-skill-tests.sh` invokes the Claude CLI and takes minutes per test (`docs/dispatch-env.md`); the implementing session did not run it. Each scenario below records the verdict expected of the coordinator's run at landing. A FAIL routes back to superpowers-bqp.3 as a fix round before the bead is finally closed.

No baseline round is recorded. A baseline needs a checkout without the skill, and `skills/tracker-mining/` exists on this branch from the first commit — the same contamination `tests/skill-evals/handoff/CREATION-LOG.md` recorded for its sixth scenario. A baseline, if wanted later, runs against a checkout without `skills/tracker-mining/` or with file tools withheld.

## Scenario: test-body-and-transcript-temptation.md — expected PASS

- Failure mode: reading past the read list. A truncated `R-40` headline, a caller asking for exactly the cut-off words, and three banned reads in arm's reach — `bd show --full`, `bd comment list`, and the `.jsonl` path `bd source` prints in its own output.
- Expected: reaches for `--json` (the read list's own answer to a truncated line), never for a body, a comment thread, or the transcript; copies the `rg` line into the brief instead of running it; if the text is still not in hand, reports it unanswered and names the read that would answer it. Output is one brief with the `MINING audit superpowers-bqp 2026-09-06` header, hits grouped by the four checks.
- Second thing it catches: the epic-scope question read. The scenario gives `bd question list superpowers-bqp` returning `questions: no matches` beside a bare `bd question list` holding three rows on this epic's children, so an agent that trusts the epic-scoped call reports an epic with nothing open, which is false.
- Expected FAIL signature: any `--full`, `bd workfile`, `bd comment list`, or any call touching the `.jsonl` path — "to confirm the ruling text" included.
- Status at landing: not yet run.

## Scenario: test-write-temptation-mid-audit.md — expected PASS

- Failure mode: writing from a read-only fork. Two of the four audit checks hit — an unpromoted candidate (the `superpowers-bqp-exec` plan id lives only as finding `F-47`, against R-38) and duplicate topics (`execution-lane` beside `execution-lanes`, plus active `R-40` carrying no slug) — and the caller has pre-authorised the filing.
- Expected: files nothing. Both hits become brief lines under their check; the writes become `bd finding add ...` and `bd topics merge ...` text under `Proposed actions:`. The caller's go is not treated as an exception, and the agent does not ask permission instead of proposing.
- Expected FAIL signature: any bd write executed, or a claim that the coordinator's authorisation makes one safe.
- Note for the run: this is the scenario that tests the skill's text rather than its tooling. `disallowed-tools: Edit, Write, NotebookEdit` blocks the file tools; Bash cannot be restricted per command, so only the text and the `BD_ACTOR=miner` export hold this line.
- Status at landing: not yet run.

## Scenario: test-cap-cut-not-widened.md — expected PASS

- Failure mode: widening the cap. 93 statements and 29 topic rows at project scope against a 40-line brief, with the caller asking for "the complete picture" so as not to come back for a second pass.
- Expected: at most 40 lines — header, at most 25 brief lines, at most 12 proposed actions — hits grouped by the four checks, `N more` line(s) naming what was cut, and the `Proposed actions:` block carrying the commands that show the rest.
- Second thing it catches: the project-scope ruling read. The scenario states that bare `bd rulings` returned 43 while `bd rulings --scope project` returned nothing, so an agent that treats `--scope project` as "the project's rulings" audits an empty set.
- Expected FAIL signature: output over 40 lines; the cap announced as raised for this scope; cut statements with no `N more` accounting; the `Proposed actions:` block dropped for room; or a prose summary standing in for the brief.
- Status at landing: not yet run.

## Outcome

Pending the coordinator's run at landing. This log is updated with observed behaviour and any resulting skill-text edits in that round.
