# Skill Roster Overhaul — usage-driven removals, mechanical triggers, upstream v6 ports

**Bead:** `superpowers-yz0` (epic, p1) — source of truth; this file is an immutable snapshot.

A three-project transcript analysis (biklod/zanjir/mt-mpp, 206 sessions) showed the pipeline trio works and all serious friction comes from missed or bypassed triggers, never skill overhead. This epic acts on that evidence in one release: delete four dead/displaced skills (`dispatching-parallel-agents`, `receiving-code-review`, `finishing-a-development-branch`, `executing-plans`) with their surviving content folded into hybrid-execution, the worktree skills, and the reviewer prompt; add two advisory plugin hooks (fail-streak-guard → systematic-debugging, completion-gate → verification evidence) as mechanical ignition for the two skills that never self-invoke; port four upstream v6 items adapted to bd (file-based review handoff via review-package, required `model:` dispatch field, anti-bias reviewer rule, pre-flight plan review); make hybrid-execution pipeline reviews by default with opt-in "hybrid parallel" frontier execution; and land targeted content edits (writing-plans epic gate + phase-N+1 rule, brainstorming evidence-first guard, outsource-review alias/no-substitution fixes, biklod verify-suite fold).

## Key design decisions

1. Everything as one epic, three surfaces (fork repo, user-level outsource-review, biklod verify-suite) — external-surface tasks tracked here, committed in their own homes.
2. Removal mode: delete + fold (not delist, not shared/ demotion).
3. Trigger home: plugin hooks in `hooks/` + `hooks.json`, advisory injection only, never blocking.
4. All four upstream v6 ports join, adapted to bd (skip `task-brief`; bd is the task-text mechanism).
5. Parallelism: pipelined reviews default; frontier parallelism only on explicit "hybrid parallel" with disjoint Attention-Map scopes.

## Acceptance criteria (abridged)

Four skill dirs gone with cross-refs fixed; hybrid-execution documents both parallelism modes; reviewer dispatches pass diff file paths with required `model:` field; both hooks ship with passing shell tests; writing-plans carries epic gate + phase-N+1; outsource-review resolves gpt-5.6-sol without substitution; version bumped in lockstep with CHANGELOG/RELEASE-NOTES.
