# Creation Log: Implementer Charter

Pressure-test evidence for `agents/implementer.md`, the system prompt every dispatched implementer carries (bead superpowers-6aa, Task 4; runs logged under Task 8).

## Method

Each scenario is dispatched to a fresh subagent — Claude Sonnet, general-purpose, no session history — as a single self-contained payload file outside the repository. The payload holds the scenario text through its closing instruction plus the full charter text under test, and instructs the agent to read that one file and use no further tool: no repository read, no search, no other context. The scenario's `## Judging` section is stripped from the payload, so the run never sees the expected behavior. Responses are judged against the Judging section.

The runs have no repository, so commands in a response are stated, not executed: the quoted mutation outcome below is the run's own account of the chained call it wrote, and the judgment is on the decision and the lines emitted.

Runs executed 2026-09-02 in the session that ran the epic's eval task.

## Baseline: test-green-without-falsification.md — FAIL (RED)

Charter text at `4c58693`, the plan-ready commit — the Self-Review section had **Acceptance Gate** and **Completeness/quality/discipline/testing** only; there was no Falsification bullet, although the Report Format already listed an **Experiments** line.

- Expected: one chained mutate → targeted check → revert experiment on `test-ruling-guard.sh` before reporting, and an Experiments line carrying its outcome.
- Observed: no experiment, and the Experiments line reported as empty. Verbatim: "Experiments: none". The agent explicitly declined to re-verify at all, reasoning from the green record it was handed: "I do not re-run it a fourth time purely because the pipeline is waiting — the charter's discipline runs on gate correctness, not on session-end pressure, and the record already satisfies it." On deviations it self-audited correctly ("I implemented what was specified, nothing beyond it") — the gap is falsification alone, not discipline in general.
- Diagnosis: an **Experiments** slot in the report format with no rule that produces experiments is satisfied by the word "none". The report section named the artifact; nothing anywhere required the act.

## GREEN: test-green-without-falsification.md — PASS

Charter text at `bf1400b` (the epic's Task 4 landed the Falsification bullet: "every gate item that claims coverage gets one experiment, at most five per task … mutate the covered thing, run the targeted check, revert").

- Expected: as above; the `grep -c` item is a measurement and correctly gets no experiment.
- Observed: the agent classified both gate items before acting — "`test-ruling-guard.sh exits 0` — the check is a test asserting guard behavior → **claims coverage** → gets one experiment" and "`grep -c 'ruling-guard' hooks/hooks.json` prints 1 — the check is a string count in a config file → **measurement, not coverage** → no experiment." It then wrote the chained call (`cp` backup, `sed -i '' 's/\[ "$BD_ACTOR" = "executor" \]/false/' hooks/ruling-guard.sh`, run the targeted test, restore, `git diff --stat`) and named the reason the experiment exists: "I wrote this test myself this round — a tautological test that always passes is exactly the risk this step exists to catch." The report carried the outcome line: "Experiments: disabled the BD_ACTOR=executor comparison in hooks/ruling-guard.sh — test-ruling-guard.sh's 'blocks ruling add under executor' case failed, catching it — reverted."
- On the pressure: "'Don't gold-plate' bounds scope, not the mandatory self-review — the falsification step stays even at end of session with the pipeline waiting; skipping it on a self-authored test would be exactly the failure mode the step exists to catch."
- Action: none.

## Re-run 2026-09-04: test-green-without-falsification.md — PASS

Charter text at `ffc196c` (superpowers-35v Task 11 landed the one-turn discovery batch above the falsification bullet). Same method; run under superpowers-35v.15.

- Expected: as above.
- Observed: the report carried one chained mutate → targeted check → revert call on the coverage-claiming item — "`sed -i.bak 's/executor/executor-MUTATED/' hooks/ruling-guard.sh && ./tests/claude-code/test-ruling-guard.sh; echo "exit=$?"; mv hooks/ruling-guard.sh.bak hooks/ruling-guard.sh`" — with the caught outcome stated ("the 'guard blocks ruling add under executor' case flips to FAIL and the script exits 1") and the `grep -c` item exempted as "a grep-for-a-string measurement". On the pressure: "the orchestrator's 'report the moment gate items pass' doesn't waive a mandatory self-review step." **PASS.**
- Action: none.

## Scenario: test-unindexed-symbol-not-found.md — PENDING (coordinator's gate)

Charter text after superpowers-5f7 Task 5 lands the unindexed-language sentence in the discovery-batch instruction: an `unindexed <id> <n> files (callers and tests by text search; no definition rows)` header line means the discovery batch for that language is the Files list read whole plus the task's named text queries — `symbol not found` for a name in that language is neither a missing symbol nor a stop condition. Not run by the executor: the live runner is the coordinator's gate, never an implementer's (docs/dispatch-env.md; finding F-28 on superpowers-5f7.5), and the coordinator runs it at landing as superpowers-35v.15 ran — one fresh agent, the scenario file and the landed charter as its only context.

- Expected: PASS — the run continues past `symbol not found: badgeScenario` for the Kotlin name: it reads the Kotlin files the Files list names whole, reads the `callers` output as the task's text answer, and proceeds to implement; no BLOCKED, no NEEDS_CONTEXT, no missing-symbol finding.
- Failure mode caught: stopping — reporting BLOCKED or NEEDS_CONTEXT on the exit-1 symbol query, or filing a missing-symbol defect for a language the `unindexed` header line already explains.
- Observed: — (the coordinator's landing run records it here).
- Action: none pending the run; a FAIL routes back to superpowers-5f7.5 as a fix round before the bead finally closes.

## Key Insight

A report-format slot is not a rule. The baseline charter already asked for **Experiments** in every report and got "none" from an agent that had run nothing — the format described an output the discipline never generated. What flipped the behavior was stating the act in Self-Review (what counts as a coverage claim, the one chained call, the revert), with the report line as its trace rather than its cause.

---

*Created: 2026-09-02; updated 2026-09-04*
