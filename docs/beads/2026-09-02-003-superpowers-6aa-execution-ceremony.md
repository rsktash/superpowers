# superpowers-6aa — Execution ceremony: collapse mandated calls per task and re-tier per-task review

Fourteen days of solo and zanjir transcripts showed that the cost of the execution skills is not their prose but the calls they mandate: an implementer reads its contract three times over, the claim hook injects rulings the coordinator never reads, the review tier is keyed on file count so templated tasks get a full reviewer, an invariant contradicts the tier skip, the scope glance errors on every bead, most reviewers run experiments on the live tree for lack of a pinned worktree, no rule binds the reviewer's model, and 70% of review catches are a green test that proves nothing. This spec makes fifteen changes across the two execution skills, the two subagent charters, the two dispatch prompts, the review-package script, the writing-plans label rule, the shared conventions, and one hook in the agent-rules repository. Every review the data shows catching defects stays.

## Key design decisions

- Executors fetch the contract with one `bd workfile` call: the header carries the rulings, the file carries the body. The implementer's body write-back is dropped; the reviewer's gate-status line is the per-item record. The reviewer also uses workfile, so its authority anchors can see rulings.
- The implementer runs a falsification experiment for every gate item that claims coverage, at most five, before DONE; the reviewer re-runs those and adds its own only where a claim was left unexercised. Both charters cap image reads at two per dispatch, never the same image twice.
- The reviewer skip for a task whose artifact a later plan task executes reaches the coordinator through a plan-time label, `review:trivial-deterministic`; no label means the combined reviewer runs. The reviewer's model is bound to the task's tier map and printed in the route line.
- The review-package script creates the pinned review worktree unconditionally and prints both paths. The scope glance reads the bold Files label instead of a section that does not exist. The hybrid invariant line matches the tier skip.
- The model-tier doctrine lives once, in `skills/shared/model-tiers.md`; the two execution skills carry only the map and a pointer. The bd conventions file is read once per session.
- The claim hook prints ruling ids and first lines only.
- Every skill change rewrites its section whole (ruling R-13): no residual phrases, no drift from the design, cross-references resolve, budgets hold, the skill is read end to end before DONE.

## Acceptance criteria

- Implementer prompt and hybrid inline procedure name `bd workfile` and no longer mandate `bd rulings`, a body export, or a body write-back; the reviewer prompt carries REVIEW_WORKTREE, the tier-bound model line, and workfile with `--out`.
- Both charters require falsification with the five cap and the two-image cap; the implementer's says "NEEDS_CONTEXT before any edit" and no longer says "ask them now".
- The review-package test passes with two-line output, a worktree at HEAD, and an idempotent re-run; the new glance commands work on a real bead.
- The pinned-contract sentence exists in exactly one file; the hybrid invariant no longer forces the combined review; writing-plans documents the review label; all seven conventions lines say once per session.
- The hook change is committed in agent-rules with the injected context under 1.5 KB.
- Three new skill evals pass, the eight existing hybrid-execution evals pass, every touched skill is within budget, the changelog states the word delta, the version is bumped.
