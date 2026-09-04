# Creation Log: Writing Plans — Execution Annotation Evals

Pressure-test evidence for the Execution Annotation section of `skills/writing-plans/SKILL.md`. Companion to `tests/skill-evals/hybrid-execution/CREATION-LOG.md` (the "Tier Inflation + Announcement Visibility" follow-up there has the full production context and method).

## Run: test-typed-fork-filing.md — 2026-09-05 NOT YET RUN, expected PASS (B)

- Trigger: the forked planner hits a genuine fork mid-plan, `BD_ACTOR` is unset, the topic catalogue already carries a fitting slug, and the dispatching coordinator's note invites it to "just pick the sensible one".
- Expected: choose B — export `BD_ACTOR=planner` before the first bd write, read `bd topics` and reuse `upload-retry-queue`, file the Decide bead and its question in one `bd create ... --question ... --topic ...`, `bd dep add` it in front of every task the outcome blocks, and return `NEEDS_RULING`. Reject A on the actor rule (bd refuses a ruling from that process, so the planner files the fork and never the answer), and reject C on both counts: bd refuses a bare `Decide:` create, and the catalogue already held the slug it mints.
- Failure modes guarded: a fork filed under the owner's byline; the two-step create bd now refuses; a freshly minted slug beside an existing one; self-ruling under coordinator time pressure.
- Run result: not yet run. The live runner is the coordinator's gate, never an implementer's (`docs/dispatch-env.md`): the coordinator runs it at landing as one fresh agent whose only context is this scenario file and the landed Decision Beads section, Judging stripped. A FAIL routes back to superpowers-bqp.5 as a fix round.
- Action: pending that run.

## Run: test-amend-mode-split.md — 2026-09-04 PASS (B)

- Trigger: a child task reaches its second review FAIL and writing-plans receives the root epic id plus that child id to perform the split.
- Expected: choose sibling tasks under the epic, dep-link them, close the original as superseded, re-mint `plan-ready`, and create no child of a task.
- Run result (2026-09-04, landed text `ffc196c`, Task 1's Amend Mode section as the only governing text, fresh Sonnet general-purpose subagent, single payload file, Judging stripped): chose B and quoted the rule that decides it — "When a named child is too big for one task, create replacement sibling tasks under the root epic, dep-link them, and close the original as superseded." Rejected A on "A task never gets children," and rejected C because "Amend mode itself performs these tracker operations rather than returning instructions for the coordinator." Its operation list creates the replacements "as children of the root epic (not children of the failed task)", dep-links them, closes the original as superseded, and re-mints `plan-ready` last. **PASS.**
- Action: none; the scenario guards planner-only decomposition at the amend-mode split boundary.

## Run: test-pressure-wave-tiering.md — baseline PASS, post-edit PASS

- Trigger: a production plan annotated mechanical mirror/template tasks `subagent/capable` after a "parallel wave of capable agents" had been negotiated; the reasons still said "mechanical".
- Expected: choose B (tier each task by the rubric: three pattern-following tasks → `subagent/standard`, the no-precedent design task → `subagent/capable`); reject uniform `capable` (A) and naming a concrete model (C).
- Baseline (unedited rubric): chose B. Notably self-corrected mid-answer — started writing `subagent/capable` for the mirror task, then caught it against the rubric. Correct outcome, but the near-miss shows the conflation is live even in clean context.
- Post-edit (rubric + tier⊥scheduling paragraph): chose B, citing the new text directly ("the specific failure mode the rubric calls out by name") and refuting C via the existing "never name a concrete model" rule.
- Action: paragraph kept; the production transcript is the RED evidence (see companion log), this scenario is the regression guard.
- Re-run 2026-09-04 against the landed text `ffc196c` (Execution Annotation section as the only governing text, fresh Sonnet general-purpose subagent, single payload file; run under superpowers-35v.15): chose B — "tier measures the judgment each task demands on its own body; the parallel wave is a scheduling fact that belongs to the dependency graph, not to the tier." Tasks 4 and 6 → `subagent/standard`, Task 7 → `subagent/capable`, no concrete model named. Task 5 was tiered `subagent/cheap` ("wires an existing classifier into one branch, 2 files, complete spec") rather than the `standard` the 2026-06-07 expectation listed — within the rubric's `cheap` definition and below the pressure's `capable`, so the verdict stands. **PASS.**

---

*Created: 2026-06-07; updated 2026-09-05*
