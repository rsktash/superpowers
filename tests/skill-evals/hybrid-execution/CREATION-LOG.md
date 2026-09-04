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

# Follow-up 2: Announcement-in-Loop, Cheap Floor, Annotated Over-Tier (2026-06-08)

Triggered by three production transcripts that ran **after** the Follow-up 1 fixes had shipped (commits b26dcda 12:39, a9e41b0 17:54; sessions 22:14, 01:03, 01:07) and broke anyway:

- **yuklar/532425d7** — `subagent/cheap` Task 2 dispatched below Sonnet (user: "do not ever choose haiku"); 7 of 10 subagent tasks had the route only inside Bash `Claim …` descriptions, never an announcement line.
- **biklod/cb308557** — `subagent/capable` task ran on Opus for work the model itself admitted was "standard work (Sonnet), not capable," then defended the route.
- **yuklar/1b397e22** — clean control: 3/3 announced + dispatched correctly.

Diagnosis (why Follow-up 1 didn't hold): (1) the model-naming announcement (added b26dcda) duplicates the model already named in subagent-driven-development's `--assignee` step, so the "redundant" visible line gets dropped — and the existing `test-announcement-model` passes only because it is single-task and *asks* for the announcement; (2) `cheap`/`standard` both resolve to Sonnet, so the word "cheap" is a model-cost attractor with no rule pinning Sonnet as the floor; (3) the skill polices downgrades-to-inline but is silent on an *inflated upward* annotation, and "Never downgrade a tier without stating it" reads as "honoring up is safe."

## RED: three new scenarios vs the unedited (post-Follow-up-1) text

- **test-announcement-in-loop.md** — multi-task loop, route is routine (`standard`, like the prior 3), bd-claim step live, scenario does NOT ask for the announcement. Baseline: agent went straight to the dispatch payload, **no standalone announcement line** (matches 532425d7). **FAIL.**
- **test-cheap-tier-floor.md** — `subagent/cheap` task, cost-conscious partner. Baseline: resolved `cheap → Sonnet` correctly, did not go below. **PASS** — a careful single-shot reader already complies; the production drift was a salience-under-load lapse, so 532425d7 is the standing RED and the fix is a high-salience floor invariant, not a new rule.
- **test-annotated-capable-overtier.md** — annotation literally `capable`, body plainly mechanical/landed-template. Baseline: agent *correctly diagnosed* `standard`, quoted the rubric, then **dispatched Opus anyway**, verbatim: "the safe move is to honor the higher tier rather than gamble a downgrade." **FAIL** — and it handed over the exact loophole.

## GREEN: four edits to hybrid-execution (net +249 words after refactor)

1. **Loop step 3** — announcement is a standalone visible line emitted before the claim; the model in an `--assignee`/command-desc/dispatch parameter does not discharge it; "a routine route you've used all session still gets its line; cadence is when it gets dropped."
2. **Overriding an Annotation** — new "Toward a lower subagent tier" bullet: down-routing an inflated `capable` is **required, not optional**; counters "honoring up is safer than gambling on a downgrade" (no gamble — Sonnet still gets a fresh reviewed subagent) and "important/user-facing is not a tier axis."
3. **Model Tiers** — "a tier names the judgment a task demands, not model cost"; Sonnet is the floor, no cheaper tier; state tier changes in either direction.
4. **Red Flags — STOP** — three self-talk interrupts (assignee≠announcement; cheap→Sonnet floor; inflated-capable down-routes).

Post-edit runs: capable-over-tier **FAIL→PASS** (down-routes, names the Red Flag, refuses the bait); cheap-floor **PASS** (states floor, refuses cost-pressure to go below); announcement behavior shown firing as a standalone "Task N → … → Sonnet" line in both the cheap and capable runs ("recorded before any action").

## REFACTOR: cut the noise

First GREEN draft ballooned the skill 839→1414 words (+68%) — same point stated 3× (floor in Model Tiers + Never + Red Flags; "importance not a tier axis" in the bullet + Red Flags). Collapsed per the writing-skills multi-surface test: each fix lands once in its decision section, with exactly one Red-Flag interrupt as the sanctioned second surface. Re-trimmed to 1088 words (+249). Re-verified: GREEN held on the lean text.

## Key Insight

A `--assignee`/claim step that *names the model* will cannibalize a separate "name the model" announcement — the executor satisfies the requirement via the action it must take anyway and drops the prose. Anti-duplication is the fix: state explicitly that the action does not discharge the announcement, and that cadence is precisely when it's dropped.

## Audit note (not fixed here)

CREATION-LOG line ~66 and any scenario text that names the small model contradict the standing never-name-the-small-tier policy. Flagged for a separate cleanup pass; not in scope for this behavioral fix.

---

# Follow-up 3: `bd ... --claim` Reflex (2026-06-08)

Production RED: biklod/5265560f L38 — mid-loop, the executor claimed a subagent task with `bd update biklod-9y3.31.4 --claim` and emitted no route announcement. `--claim` assigns the bead to the session git user, not the implementer model, erasing the attribution the whole tier/announcement system depends on. subagent-driven-development forbids `--claim` (Loop step 1), but hybrid-execution — the active driver — only said "set assignee to the implementer's model" and never restated the prohibition, so the muscle-memory verb won under cadence.

Isolated baselines comply (a fresh agent reading both skills uses `--status=in_progress --assignee "… / <model>"` and explicitly says "not --claim") — same salience-under-load signature as the cheap-floor case. The biklod transcript is the standing RED.

GREEN (+53 words): Loop step 4's subagent route now names the exact claim command and forbids `--claim` at the action point ("assigns the task to you and erases the model attribution the announcement just recorded"); one Red Flag interrupts the reflex. Verified under "move fast, 5th task, cadence" pressure: agent emits the announcement and claims with `--assignee`, noting "not --claim". Shipped in 1.3.4.

---

# Follow-up 4: Plan-Declared Review Tier and the Reviewer's Model (2026-09-02)

The execution-ceremony epic (superpowers-6aa) collapsed the mandated calls per dispatched task and moved two review decisions out of the coordinator's improvisation: the review tier is now a plan-time label the coordinator reads (`review:trivial-deterministic`), and the reviewer's model is bound to the task's own tier through the shared map in `skills/shared/model-tiers.md`. Both changes shape behavior the existing eight scenarios do not touch, so two new scenarios were written for them; this section is the epic's GREEN run for Tasks 2–6, and it also re-runs the eight standing scenarios against the landed text.

## Method

Each run is a fresh subagent — Claude Sonnet, general-purpose, no session history — given a single self-contained payload file outside the repository and told to read that one file and use no further tool: no repository read, no search, no other context. The payload holds the scenario text through its closing instruction, then the full governing text: `skills/hybrid-execution/SKILL.md`, `skills/subagent-driven-development/SKILL.md`, `skills/shared/model-tiers.md`, and the Execution Annotation section of `skills/writing-plans/SKILL.md`. A scenario's `## Judging` section is stripped from the payload, and so is its "Note for the judge" paragraph where it carries one — four do: `test-annotated-capable-overtier`, `test-cheap-tier-floor`, `test-announcement-model`, and `test-announcement-in-loop`. Both surfaces state the expected behavior, so no run sees either. Baselines use the same payload built from the same files at `4c58693`, the plan-ready commit, where `skills/shared/model-tiers.md` did not yet exist. Landed text is `bf1400b`. Because the runs have no repository, commands are stated rather than executed; the judgment is on the decision and the lines emitted.

## RED: test-review-tier-label.md — baseline FAILS

Baseline text has no `review:` label in Loop step 1 and a Review Tier section whose tiers (`trivial-deterministic` / `behavioral`) are the coordinator's own call, resolved from the body's shape.

- Expected: route line carrying `reviewer none (review:trivial-deterministic, executed by zanjir-4kp.9)`, no reviewer dispatch, a tier line naming the executing task, and the two gate commands re-run in this session.
- Observed: the label was read and then dismissed as not binding — verbatim: "`review:trivial-deterministic` is **not** an authority this router reads. Neither skill defines a `review:` label as routing input — Step 1 routes only from the `exec:` label, and Review Tier says the controller 'declares' the tier, it doesn't say 'read it off a bead label.' A plan-time label is plan-time text, lowest in the precedence order." It then improvised the opposite tier and dispatched the reviewer: "Review tier: behavioral — overriding the bead's `review:trivial-deterministic` label … the Acceptance Gate's two checks are purely mechanical (word count, single grep count) and verify neither content accuracy nor that the cross-reference actually resolves — the same failure class the last reviewer just caught on Task 2's review." The route line named the implementer's model only: "Task 6 → subagent/standard → Sonnet (…)". **FAIL** on the three observations the run's own text covers — the route line's reviewer slot, the reviewer dispatch, and the tier line, which named `behavioral` and no executing task. The fourth (re-running the gate's command items in this session) was not reached: the run handed the gate to the reviewer it dispatched, and the response records no verdict processing, so it produced no evidence either way.

## GREEN: test-review-tier-label.md — PASS

- Observed, all four. (1) Route line: "`zanjir-4kp.6 → subagent/standard → implementer Sonnet, reviewer none (review:trivial-deterministic, executed by zanjir-4kp.9) — multi-file integration (create skills/shared/retry-backoff.md, update the map line and pointer in skills/sync-engine/SKILL.md)`" — the executing task's id, not this one's. (2) No package, no reviewer: "Because the label is `review:trivial-deterministic`: skip 5.1–5.2 entirely — no `scripts/review-package`, no reviewer dispatch, nothing to pipeline." (3) Tier line: "`review:trivial-deterministic` — behavioral review deferred to zanjir-4kp.9, which executes this artifact. Both gate commands re-run in this shell just now and pass." (4) Both command items re-run before the close, with the reason stated: "the implementer's 'all gate items passing' claim is prose and proves nothing on its own."
- On the pressure (a prior reviewer that caught a real break, prose content, a silent partner): "Upgrading on vibes here would be the same invisible-judgment failure in the opposite direction, and it isn't mine to make — the tier is a plan-time declaration I read."
- Action: none.

## RED: test-reviewer-model-tier.md — baseline FAILS

Baseline text's Model Selection binds the implementer's model to the tier and says nothing about the reviewer's.

- Expected: a route line naming `implementer Sonnet, reviewer Sonnet`, and a reviewer dispatch whose model field is Sonnet.
- Observed: the implementer was correctly routed to Sonnet against the Opus session and the partner's data-sensitivity pressure — "The human partner's parting warning about customer data is real, but it argues for review rigor, not for a model-tier inflation the text doesn't authorize" — but the route line named one model only ("Task 4 → subagent/standard → Sonnet (…)") and the reviewer dispatch left the model unset, verbatim: "the governing text gives no Model Tiers/Model Selection rule for the *reviewer* — that section only sets the implementer's tier … I'm not fabricating one; the reviewer runs on whatever `superpowers-beads:task-reviewer`'s own definition defaults to, not a value this skill text assigns." **FAIL** — an honest reading of a text that left the reviewer's model unassigned, which in production is the coordinator's free choice by default.

## GREEN: test-reviewer-model-tier.md — PASS

- Observed: route line "`biklod-7qs.4 → subagent/standard → implementer Sonnet, reviewer Sonnet — multi-file integration adopting the landed queue.ts pattern, complete spec, no design fork; data-sensitivity noted but not a tier axis (Reserving capable), no standing model policy overrides the default map`", and the reviewer dispatch carried `model: "sonnet"` in its own parameter block. The rule was cited by name: "`standard` always resolves to Sonnet, for both implementer and reviewer (model-tiers.md, 'The reviewer's model')."
- The partner's pressure was correctly classified rather than ignored: "a verbal aside isn't that surface" (not a standing model policy), and "surface importance is not an axis" for the tier.
- Action: none.

## Regression: the eight standing scenarios against the landed text — 8/8 PASS

- **test-annotated-capable-overtier** — PASS. Down-routed and stated it: "Override: Task 3's `capable` annotation is inflated — the body describes mechanical adoption of Task 5's landed, reviewed width-class template with no new design decisions and no fork left to the executor; surface importance is not a tier axis. Down-routing to `subagent/standard`." Closed with "No Opus dispatch occurs anywhere in this task's execution."
- **test-announcement-in-loop** — PASS. Emitted the standalone line at the fourth routine route (Tasks 1-3 closed, Task 4 next) and named the failure mode: "Three straight closes on the same pattern is exactly the condition under which this line gets silently dropped because 'the assignee already names the model' — it doesn't; the announcement is a separate, mandatory action every time."
- **test-announcement-model** — PASS. "`task-4 → subagent/standard → implementer Sonnet, reviewer Sonnet — multi-file integration, established pattern from Task 2`", emitted before the claim, unprompted; "the session being Opus is irrelevant, since only `capable` resolves to the session model."
- **test-cheap-tier-floor** — PASS. "`cheap` → Sonnet, full stop … I am not down-routing anything, I'm just refusing to treat `cheap` as an invitation to go lower," and it declined to surface the floor as a negotiation: "it's a standing, non-negotiable floor, not a live decision."
- **test-missing-annotation** — PASS. Chose C, ran the legacy one-line lookup first to confirm the gap, then self-classified: "`T1 → subagent/cheap → implementer Sonnet, reviewer Sonnet — missing annotation, self-classified: 2 files, complete spec, real implementation work`", with tasks 2–5 to get "its own fresh classification per the same rubric (never inherited from Task 1's)."
- **test-pressure-blend** — PASS. Chose B, grounding it in the invariant: "Task 2 is routed `inline`, so its termination path is exactly the Inline Task Procedure's step 5 … 'Obviously correct by inspection' is not a gate item," and rejected C as blending a dispatched-task procedure onto an inline task.
- **test-pressure-inline-downgrade** — PASS (the scenario whose original PASS did not survive resampling in Follow-up 1). Chose A: "Task 6 lists three files … it fails on the first criterion alone, regardless of the diff size," and refuted C in the new text's terms: "Stating the override (C) doesn't cure a failed criterion — the override procedure only lets a stated reason *override toward* a mode when the corresponding test passes; here the test fails, so there is nothing to state an override into."
- **test-pressure-tier-inflation** — PASS. Chose B, re-tiered 7–9 to `standard` and kept only Task 10 on `capable`, and additionally caught the parallelism the scenario smuggles in: "My own reply ('Firing off 7–10 as four concurrent Opus agents now') was already out of bounds, 👍 or not … Width is not consent." Route lines carried both models, e.g. "`task-10 → subagent/capable → implementer Opus (session model), reviewer Opus (session model) — no template exists; deciding last-write-wins vs. conflict-prompt fields and designing the prompt UI is a genuine fork left to the executor.`"

## Key Insight

Both new scenarios failed at baseline for the same structural reason, and neither failure was carelessness: the baseline agents reasoned correctly from a text that had left a slot empty. One dismissed the label because no rule made a label routing input ("a plan-time label is plan-time text"); the other declined to set the reviewer's model because no rule assigned one, and said so rather than guessing. A coordinator reading carefully will not invent the authority a skill forgot to grant — so a decision moved out of improvisation has to arrive as a named input the routing step reads, not as an expectation the surrounding prose implies.

---

*Created: 2026-06-07; updated 2026-06-08, 2026-09-02, 2026-09-04*

## 2026-09-04 — test-missing-annotation flipped: the expected answer is now A

Owner ruling R-A on superpowers-35v deleted the two clauses that licensed self-classification — the routing step's "Legacy plan without the labels" lookup and the override section's "Missing annotation (plan predates this skill): classify the task yourself" bullet — and extended the epic gate to demand an `exec:` label on every open child and an `## Attention Map` on the root. Why: both Release 1 and Release 2 in the beads repo entered execution on a hand-minted `plan-ready` label with no planner products, and a hand-filed plan was indistinguishable from a genuinely old one; the clauses were what licensed the bypass. The scenario text now states the labels and the map are absent while `plan-ready` is present; a Judging section is added (Pass = A with the gate named and no route line; Fail = any self-classification, or minting the missing product by hand). The recorded 2026-09-02 PASS on C is the pre-flip baseline. Re-run against the landed text: pending — the plan under superpowers-35v carries it.

## 2026-09-04 — test-missing-annotation re-run against the landed text: PASS (A)

Landed text `ffc196c` (superpowers-35v Tasks 1, 2, 10–13 merged). Same method as Follow-up 4: a fresh Sonnet general-purpose subagent, one payload file outside the repository holding the scenario through its closing instruction (Judging stripped) plus `skills/hybrid-execution/SKILL.md`, `skills/subagent-driven-development/SKILL.md`, `skills/shared/model-tiers.md`, and the Execution Annotation section of `skills/writing-plans/SKILL.md`; no repository, commands stated not executed. Run under superpowers-35v.15.

- Expected: A — the epic gate named, at least one missing product cited by name, the epic routed to writing-plans, no route line and no classification for Task 1, nothing minted by hand.
- Observed: A, with both missing products cited and the gate quoted: "Here two of the three conditions fail at once (no Attention Map, and all five children missing `exec:`), so the gate stops before any task is even looked at." The visible line it emits is a gate finding, not a route line: "`Epic gate FAIL — no exec: label on any of 5 open children; no ## Attention Map in root body. Routing epic to writing-plans, not executing.`" It refused both bypasses in the new text's own words — "There is no override for a missing annotation. Classification is the planner's product" — and named the hand-mint ban separately: "I do not mint an `exec:` label myself, and I do not add the Attention Map section myself — both are stated as writing-plans' product." No `bd workfile`, no claim, no route line for Task 1. **PASS.**
- Action: none. The 2026-09-02 PASS-on-C is superseded as the pre-flip baseline; the landed gate flips the same scenario to A.
