# Hybrid Parallel — full procedure

Read this ONLY after your human partner has said the literal words "hybrid
parallel" (see SKILL.md for the activation rule). Everything here presumes
that consent exists.

When invoked:

- **Width: 2–3 implementers**, never more, regardless of how wide the ready frontier is.
- **Eligibility — both conditions, checked per pair:** the tasks appear simultaneously in `bd ready --parent <root-id> --json`, AND their scopes are disjoint — no file shared between their Files lists, and no "Consumes From" edge between them per the epic's Attention Map. A single shared file or a single consumes-from edge disqualifies the pair: those tasks run serially, pipelined as usual. Eligibility is computed from the plan's recorded lists, never from a felt sense that "they probably won't collide."
- **Isolation:** each implementer works in its own worktree on its own branch, created per using-git-worktrees conventions (`git worktree add .worktrees/<task-id> -b <task-branch>`). No implementer ever shares a worktree with another implementer — that invariant survives this mode untouched.
- **Merge-back is serial and controller-owned:** the controller merges completed branches back one at a time, in dependency order, re-running the merged task's targeted tests after EACH merge. Two branches that each pass in isolation can still break composed — the post-merge test run is what catches that. Reviews stay per task and pipelined exactly as in The Loop, each packaged from its own branch's BASE..HEAD.

**Shared test environment caveat:** one shared test environment — a single docker-compose stack, one attached device, one seeded database — forces serial test gates no matter how many implementers run: their test runs queue on the shared resource and the wall-clock win evaporates. Pipelined reviews still apply and still pay off (the reviewer reads a frozen package, not the environment), but frontier mode does not help there. Check for this before proposing or accepting hybrid parallel.
