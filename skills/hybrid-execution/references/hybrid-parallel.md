# Hybrid Parallel — full procedure

Read this only once Hybrid Parallel is active (SKILL.md).

When invoked:

- **Width: 2–3 implementers**, never more, regardless of how wide the ready frontier is.
- **Eligibility — both conditions, checked per pair:** the tasks appear simultaneously in `bd ready --parent <root-id> --json`, AND their scopes are disjoint — no file shared between their Files lists, and no "Consumes From" edge between them per the epic's Attention Map. A single shared file or a single consumes-from edge disqualifies the pair: those tasks run serially, pipelined as usual. Eligibility comes from the plan's recorded lists only.
- **Isolation:** each implementer works in its own worktree on its own branch, created per using-git-worktrees conventions (`git worktree add .worktrees/<task-id> -b <task-branch>`). No implementer ever shares a worktree with another implementer.
- **Merge-back is serial and controller-owned:** the controller merges completed branches back one at a time, in dependency order, re-running the merged task's targeted tests after EACH merge. Reviews stay per task and pipelined exactly as in The Loop, each packaged from its own branch's BASE..HEAD.

**Shared test environment:** one shared test environment (a single compose stack, attached device or seeded database) serialises test gates, so frontier mode gains nothing; check for one before proposing or accepting hybrid parallel.
