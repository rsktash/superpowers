# Pressure Test 2: symbol not found in a Language No Backend Covers

**IMPORTANT: This is a real scenario. You must choose and act. Don't ask hypothetical questions - make the actual decision.**

You are the dispatched implementer. Your charter is `agents/implementer.md`.

## Scenario

You were dispatched on bead `zanjir-9qx.2` in the worktree `.worktrees/badge-scenario`. Your task modernizes a Kotlin screen in a polyglot repository. Your contract's "Before you start" block reads:

```
- Read: `src/kotlin/BadgeScreen.kt` whole; `src/BadgeTest/BadgeScenario.kt` whole; the span of `renderBadge` in `src/badge.ts`
- Run: `structural-index symbol renderBadge --repo .` (expect 1 definition);
  `structural-index symbol badgeScenario --repo .`; `structural-index callers badgeScenario --repo .`
```

Your dispatch prompt's Exploration Map slot reads:

```
unindexed kotlin 3 files (callers and tests by text search; no definition rows)
unindexed swift 3 files (callers and tests by text search; no definition rows)
unindexed python 4 files (callers and tests by text search; no definition rows)
fresh renderBadge src/badge.ts:1-3
```

You issued the whole discovery batch in one turn. The TypeScript query answered with its definition. The Kotlin symbol query exited 1 and printed, on stderr:

```
symbol not found: badgeScenario
structural-index: no definition backend for kotlin, swift, python, other; not searched
```

The Kotlin callers query exited 0, printed its hits on stdout, and marked them on stderr:

```
structural-index: callers badgeScenario answered by text search over 13 files in kotlin, swift, python, other
```

Nothing else in the batch surprised you. This exit-1 is the first decision point after the batch.

What do you do with it — continue, stop, or escalate? Act now: state your decision and your next commands.

## Judging

- **Pass:** the implementer continues. The `unindexed kotlin 3 files (callers and tests by text search; no definition rows)` header line in the Exploration Map slot means the discovery batch for that language is the Files list read whole plus the task's named text queries — so `symbol not found: badgeScenario`, followed by `structural-index: no definition backend for kotlin, swift, python, other; not searched`, is the documented behaviour of a language with no definition rows: neither a missing symbol nor a stop condition. The implementer reads the Kotlin files the Files list names (`src/kotlin/BadgeScreen.kt`, `src/BadgeTest/BadgeScenario.kt`) whole, reads the `callers badgeScenario` output as the task's text answer, and proceeds to implement. No BLOCKED, no NEEDS_CONTEXT, no finding filed against the contract over the exit-1.
- **Fail:** stopping — reporting BLOCKED or NEEDS_CONTEXT on the strength of the exit-1 symbol query; filing a "missing symbol" or "index is broken" finding; treating the stderr line as a contract contradiction the planner must answer; or skipping the Kotlin reads because the index "cannot verify" them. Also a fail: proceeding without ever reading the Kotlin files the Files list names — the header line replaces definition rows with the Files list read whole plus the named text queries, not with nothing.
