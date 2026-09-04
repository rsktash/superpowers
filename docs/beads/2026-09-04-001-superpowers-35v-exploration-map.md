# superpowers-35v — Exploration map, turn batching, planner-only decomposition

Two evidence sets — the Release 2 run in the beads repo and a codex mining of 64 zanjir sessions and 545 subagents — showed that agents re-run the same exploration and checks, and that the dominant cost is turns × context (98 % of input was a cache re-read of an unchanged prefix; implementer median 77 tool calls; 682M of 2.09B implementer + reviewer tokens spent before the first edit). This spec makes three approved changes: the execution skills' epic gate demands planner products and the legacy-plan fallbacks are deleted, with writing-plans gaining an amend mode so that only the planner decomposes, and only flat; a symbol-keyed exploration map, fed by a deterministic structural index, is written once at plan time as a file that lives with the code, with freshness computed at dispatch and no bead writes to maintain it; and the implementer, reviewer and pre-flight prompts batch discovery and verification into one turn each.

## Key design decisions

- Gate: `plan-ready` label AND Attention Map on the root AND `exec:` label on every open child; nothing hand-minted. The "legacy plan" sentence and the "missing annotation" bullet in hybrid-execution are deleted.
- writing-plans amend mode: epic id + child ids; plans children in place; a split files siblings under the epic and closes the original; a task never gets children. sdd's second-FAIL split and `needs-plan` routing go through it.
- Structural index: `symbol`, `callers`, `tests` for TypeScript and Go; generator is an open decision (ctags / tree-sitter / LSP) settled by a measured trial.
- Map: `docs/beads/<epic-id>.map.md`, rows `Task | Symbol | File | Hash | Note | Source`, symbol-keyed, callers never stored; `map-check` prints fresh / STALE / CHECK lists from plan-time hashes into the dispatch header. Nobody edits hashes; findings are never used for map changes (owner ruling).
- Batching: "Before you start — ONE turn" and "Acceptance Gate — ONE turn" in the task template and charters; the reviewer's seam check becomes one `callers` query.
- Measurement is the method, not a recommendation: the archived mining scripts re-run over the first epic under the new skills, against the recorded baseline medians.

## Acceptance criteria

- A hand-filed plan with a hand-minted `plan-ready` label cannot be executed; neither legacy clause exists in the plugin.
- Amend mode plans a named child in place and never nests; the coordinator never creates task beads.
- The index answers the three queries with recorded correctness; writing-plans writes the map file; map-check reports freshness with no bead write.
- Task template, both charters, both prompts and the pre-flight prompt carry the one-turn instructions.
- One epic under the new skills is measured with the archived scripts and compared to the baseline on this epic.
