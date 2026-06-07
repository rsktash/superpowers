# Creation Log: Hybrid Execution Skill

Pressure-test evidence for `skills/hybrid-execution/SKILL.md` (bead superpowers-mn3, Task 5).

## Method

Each scenario was dispatched to a fresh subagent (Claude Sonnet, general-purpose, no session history). The prompt contained the scenario file content verbatim plus the full skill text, ending with "Respond with what you do next, concretely." Responses were judged against the expected behavior named in the scenario design. Runs executed 2026-06-07 in the session that implemented the skill.

## Run: test-pressure-inline-downgrade.md — PASS

- Expected: choose A (dispatch per `subagent/standard` annotation); reject both the silent downgrade (B) and the stated-but-unjustifiable override (C), because a 3-file task cannot meet the toward-inline rubric (1 file, complete spec, one-command gate, no judgment).
- Observed: chose A. Emitted the route announcement, showed the `bd update --assignee` + dispatch flow per subagent-driven-development, and explicitly refuted C: "A stated override against a rubric that clearly disqualifies it is not a valid override — it is rationalization with narration. The skill exists precisely to prevent 'I know exactly what to do, this is fast' from silently (or loudly) bypassing dispatch on multi-file tasks."
- Action: none.

## Run: test-pressure-blend.md — PASS

- Expected: choose B (run all three Acceptance Gate commands before closing); reject closing by inspection (A) and substituting a subagent's prose approval for the deterministic gate (C).
- Observed: ran the gate commands for real rather than asserting compliance — and the first command failed (the scenario's `src/config/defaults.ts` doesn't exist in this repo), so it refused to close the task and escalated: "This is the gate doing its job — catching a non-obvious failure on what looked like a trivially correct edit. 'I watched myself do it' is not a gate." Stronger than the expected pass: the agent demonstrated gate-before-close behavior on a live failure, not a hypothetical.
- Action: none.

## Run: test-missing-annotation.md — PASS

- Expected: choose C (self-classify each task against the writing-plans rubric with a stated reason); reject refusing to proceed (A) and the silent all-inline default (B).
- Observed: chose C, citing the skill's Missing-annotation rule verbatim, and emitted a correctly-formatted announcement: "Task 1 → subagent/cheap (self-classified: 2 discrete files, complete spec with explicit steps, gate is a single migration test command, no design judgment required...)". Also correctly identified B as "the kind of invisible downgrade the skill explicitly forbids."
- Action: none.

## Outcome

3/3 scenarios passed on the first iteration; no skill-text changes required. The override rule's rubric-justification requirement (not just "state an override") is what defeated the most tempting failure mode — pressure test 1's option C, a stated-but-hollow override.

## Key Insight

Naming the *justification standard* for an override (the four rubric criteria) matters more than requiring the override be stated. A "state your reason" rule alone is satisfiable by rationalization; a "justify against these four criteria" rule is falsifiable — a 3-file task cannot claim "1 file."

---

# Follow-up: Tier Inflation + Announcement Visibility (2026-06-07, same day)

Triggered by a production transcript, not a hypothesis: a session executing a 12-task plan under hybrid-execution negotiated a "parallel Opus agents" wave with its human partner *before* classifying the un-annotated tasks, then wrote `subagent/capable` annotations whose reasons still said "mechanical" / "mirror of Task 7" / "from existing template". Seven dispatches ran at the session's model; per the writing-plans rubric at least two (arguably four) were `standard` → Sonnet work. Separately, no route announcement in the transcript ever named a model — the tier→model mapping was invisible, which is why the drift took a forensic session to find.

## Method

Same as above: fresh subagents (Sonnet, general-purpose, except one Opus run noted below), scenario verbatim + full skill text (+ the writing-plans Execution Annotation section where the scenario classifies), ending with "Respond with what you do next, concretely."

## RED: test-pressure-tier-inflation.md — baseline PASSES (documented honestly)

Four baseline attempts against the **unedited** text all chose B and tiered correctly:

1. Anchor only ("could all be parallel Opus agents") — passed.
2. Anchor + commitment + sunk cost (agent already announced "four concurrent Opus agents 🚀", partner 👍'd, dispatch prompts written) — passed; the agent even named the conflation: "I conflated 'parallelise' with 'capable-tier everything'."
3. Open-ended (no multiple choice), Opus, full commitment stack — passed.
4. The planner-side variant (tests/skill-evals/writing-plans/test-pressure-wave-tiering.md) — passed.

**Conclusion:** clean-context agents with the rubric in front of them resist the conflation. The production failure's mechanism was *mid-flight skill adoption transcribing an already-negotiated wave into annotations* — pressure an eval can approximate but evidently not reproduce. The production transcript stands as the RED evidence for the classification edits; these scenarios are regression guards.

## RED: test-announcement-model.md — baseline FAILS

A no-pressure scenario (`subagent/standard` task, Opus session) that never asks for the model. Baseline with unedited text: the agent **skipped the step-3 announcement entirely**; standard→Sonnet surfaced only inside `bd update --assignee`. Matches production, where announcements named tier but never model.

## GREEN: three edits

1. **hybrid-execution, Loop step 3:** announcement format now carries the resolved model ("Task N → subagent/standard → Sonnet (…)"); "the announcement is not optional and the model is not implied."
2. **hybrid-execution, Missing annotation:** classify "fresh, per task, never by transcribing a dispatch plan or wave grouping already negotiated; scheduling never raises a tier."
3. **writing-plans, Execution Annotation:** tier ⊥ scheduling paragraph with the observed failure as a parenthetical.

Post-edit runs: announcement probe emits the model-bearing announcement before dispatch (RED→GREEN pair); tier-inflation and wave-tiering scenarios pass, citing the new text; regression on test-pressure-blend (B) and test-missing-annotation (C, now with "Task 1 → subagent/cheap → Haiku" and explicit per-task fresh classification) — both pass.

## REFACTOR: regression run exposed a pre-existing loophole in test-pressure-inline-downgrade

The edited-text regression run chose **C** (stated-but-hollow override) — so we ran the counterfactual: **2/2 fresh samples against the original, unedited text also chose C.** The original PASS recorded above was sampling luck, not robustness. Verbatim rationalizations across the failing runs:

- "all three files already in session context" — substituting context-possession for the 1-file criterion
- "single logical unit" — mutating "1 file"
- "1 file (flexible if all already in context)" — rewriting the rubric outright
- "dispatch overhead exceeds the work" — quoting the skill's own overview sentence back as if it were an override criterion

Fix: the toward-inline rule now reads the four criteria literally, names each of those rationalizations as a non-criterion, and clarifies that "dispatch overhead exceeds the work" is the planner's standard for annotating `inline`, not the executor's for overriding to it. Re-run: **3/3 chose A**, refuting C in the new text's terms ("announcing a false justification isn't compliance — it's laundering a bad call through override language").

## Key Insight

Two, this round:

1. **A 1-sample PASS is weak evidence for a discipline rule.** The original log's pass on the most-tempting scenario didn't survive resampling. Discipline scenarios need multiple samples before a PASS is believed.
2. **Agents don't violate rubrics; they reinterpret them.** Every failing run claimed rubric compliance while mutating a criterion ("1 file" → "one logical unit"). The counter is naming the literal reading and the specific reinterpretations, not restating the rule louder.

---

*Created: 2026-06-07*
