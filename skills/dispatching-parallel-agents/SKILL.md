---
name: dispatching-parallel-agents
description: Use when facing 2+ independent tasks that can be worked on without shared state or sequential dependencies
---

# Dispatching Parallel Agents

Run one agent per independent problem domain, concurrently. You construct exactly the context each needs — they don't inherit your session history.

**Core principle:** Parallelize independent work — then verify every result against deterministic evidence, because a parallel agent's report is the least trustworthy signal you have.

## Trust the returned summary the least

This is the load-bearing rule, so it comes first.

A returning agent's summary — "fixed it / tests pass / 0 blockers" — is prose, and prose is fabricable. On current models this is a known, measured failure surface: when a parallel batch partially cancels or its results interleave, the model can manufacture a confident success narrative with invented specifics (counts, paths, "verified"), occasionally citing things that don't exist.

So when agents return, do **not** integrate on their word:

1. Read each summary as a *claim*, not a result.
2. Re-run the deterministic check yourself, once, over the combined result — full test suite, `git diff --name-only`, `grep`.
3. Check the diffs don't conflict or overlap.
4. Spot-check: agents make systematic errors, and parallel agents make them independently.

Integrate only when the suite is green and the diffs are clean. Not before.

**Why:** A parallel agent's verdict is the weakest evidence in the room, not the strongest — fluent, well-formatted, and produced under the exact conditions that trigger fabrication. The deterministic artifact is the only thing that actually closes the loop.

## When to Use

**Use when** the problems are genuinely independent — different test files, different subsystems, no shared state, each understandable without the others.

**Don't use when:**
- failures may be related (fixing one might fix the others) — investigate together first
- you don't yet know what's broken — that's exploration, not parallel work
- agents would touch the same files or resources — they'll conflict

## Build Focused Tasks

Each agent gets:

- **Scope** — one file or subsystem, named explicitly. "Fix all the tests" makes the agent lose the thread.
- **Context** — the actual error messages, test names, and paths. Not "fix the race condition."
- **Constraints** — what NOT to touch ("tests only", "do not change production code").
- **Output** — what to return: root cause plus what changed, so you can verify it.

## Don't over-spawn

One agent per *distinct* domain, no more. Excess parallel agents cost tokens and widen the fabrication surface above without adding coverage. If two "domains" share state, they are one task — not two.
