# superpowers-5f7 — structural index coverage for languages without a compiler backend

Spec bead: `superpowers-5f7` (epic). Brainstormed 2026-09-04; the bead is the source of truth, this file is an immutable snapshot.

## Summary

The structural index (`scripts/structural-index`) covers TypeScript and Go only, and nothing tells a planner, implementer, or reviewer which languages it covers: an uncovered language answers "symbol not found" exactly like a misspelled name, `map-check` has no line shape for it, and the reviewer's per-symbol seam check fails on every symbol. The owner's bead-tracked repositories are mostly Kotlin Multiplatform, often mixed with TypeScript and Swift, plus one Python repository. This feature adds two tiers inside the existing CLI: tier 1 publishes a per-repository language roster, answers `callers` and `tests` for uncovered languages by word-boundary text search with an explicit stderr grade, and gives every model-facing surface (map-check header, planner, implementer, reviewer, dispatch prompt, runbook, glossary) one sentence of coverage; tier 2 adds a definition backend per ruled language behind the interface TypeScript and Go already use.

## Key decisions (owner rulings on the bead)

- R-27: tier 2 languages are Kotlin, Swift, Python; nothing else.
- R-28: the generator per language is chosen by a measured trial per language on the owner's own repositories (yuklar, biklod), then ruled on a decision bead per language, as R-23 was for TypeScript and Go.
- R-29: one epic, one plan — no phase split; backend tasks are written now against the fixed backend interface and gated on their decision bead.
- Inherited: R-23 compiler APIs, R-B symbol-keyed map (a text search never claims a definition), R-26 toolchain resolution (in-repo first, then `STRUCTURAL_INDEX_<LANGUAGE>_TOOLCHAIN`, else exit 2 naming the variable), CLAUDE.md zero-dependency rule (nothing vendored).

## Acceptance criteria

1. `structural-index languages` prints the roster for zanjir, beads, yuklar, and the plugin repository, identically from cache.
2. On yuklar, `callers <kotlin name>` returns text hits with the text-answer stderr line; `callers <typescript name>` returns compiler hits only.
3. `map-check` exits 0 on a Kotlin-only repository and prints the `unindexed` header line; on zanjir its output is byte-identical to today's.
4. Every edited skill file holds its word budget; the line-shape list is identical across the four consumers.
5. Three trial beads carry the scored table; three decision beads are ruled; each ruled backend's test passes with its variable set and prints `[SKIP]` without it.
6. Deterministic suite green with `STRUCTURAL_INDEX_TYPESCRIPT_PACKAGE` exported; `docs/dispatch-env.md` lists every toolchain variable.
