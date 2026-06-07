# Creation Log: Writing Plans — Execution Annotation Evals

Pressure-test evidence for the Execution Annotation section of `skills/writing-plans/SKILL.md`. Companion to `tests/skill-evals/hybrid-execution/CREATION-LOG.md` (the "Tier Inflation + Announcement Visibility" follow-up there has the full production context and method).

## Run: test-pressure-wave-tiering.md — baseline PASS, post-edit PASS

- Trigger: a production plan annotated mechanical mirror/template tasks `subagent/capable` after a "parallel wave of capable agents" had been negotiated; the reasons still said "mechanical".
- Expected: choose B (tier each task by the rubric: three pattern-following tasks → `subagent/standard`, the no-precedent design task → `subagent/capable`); reject uniform `capable` (A) and naming a concrete model (C).
- Baseline (unedited rubric): chose B. Notably self-corrected mid-answer — started writing `subagent/capable` for the mirror task, then caught it against the rubric. Correct outcome, but the near-miss shows the conflation is live even in clean context.
- Post-edit (rubric + tier⊥scheduling paragraph): chose B, citing the new text directly ("the specific failure mode the rubric calls out by name") and refuting C via the existing "never name a concrete model" rule.
- Action: paragraph kept; the production transcript is the RED evidence (see companion log), this scenario is the regression guard.

---

*Created: 2026-06-07*
