---
name: writing-plans
description: Use when you have a spec or requirements for a multi-step task, before touching code. Runs in its own forked agent; invoke it directly from the coordinator, never through a wrapper subagent.
context: fork
model: opus
---

# Writing Plans — budget 2776 words

## Overview

Write implementation plans assuming a skilled engineer with zero context for our codebase: which files each task touches, what each change is for, how to verify it. Bite-sized tasks. DRY. YAGNI. TDD. Frequent commits.

A plan is a contract of intent, not a transcript of the code to come. The planner owns the decomposition, the file map, the gates, and the scope fences. The executor stands in the live tree and owns the specifics — names, signatures, wiring, which tests break — and logs deviations on the bead. A plan that dictates specifics it never verified is worse than one that stays abstract: the executor is bound to obey it, and it lies.

**Announce at start:** "I'm using the writing-plans skill to create the implementation plan."

**Input:** `$ARGUMENTS` has two shapes. A root epic bead id alone selects full mode for the spec held by that epic. A root epic id followed by one or more child ids selects amend mode for those named children. Both modes run forked (see Venue) with no conversation history, so read the epic, the named children when present, and the repo rather than a caller's context. Full mode creates tasks as child beads: `bd create "Task N: <name>" -p 1 --parent <root-id> --body-file .bd/.scratch/task-N.md -l "exec:<mode>" -l "review:trivial-deterministic" --json` — hierarchical IDs, sequential deps via `bd dep add <task-2> <task-1>`; `-l` is repeatable, and the second label is added only when the task earns it (Execution Annotation). Use `--parent`, never `--type related` (that breaks `bd children` and epic views). Read `skills/shared/bd-defaults.md` once per session, skip if already read — a forked skill has a fresh context, so this one always reads it.

**Mandatory step:** writing-plans is the step between an epic and ANY execution skill. Executing an undecomposed epic is a bypass, not a shortcut.

**Venue: you are the forked planning agent (`context: fork`).** This skill runs in an isolated subagent, so invoking it never loads this procedure into the coordinator's session, and you do not dispatch a further planner — you ARE it. Verify citations freely: opening every cited file here costs the coordinator nothing, because none of that reading lands in its session. Return a **receipt** and nothing else: bead ids, per-task Files lists, `exec:` labels, `plan-ready` marker.

**`NEEDS_RULING` is a successful, partial return:** task beads for the unforked region, decision beads over the rest. Never resolve an owner-level fork to avoid returning empty. Persist the draft to the beads and `.bd/.scratch` before returning, so any resumer starts from the draft, never zero.

## Checklist

Complete in order:

1. **Scope check** — one coherent project, no unresolved design fork
2. **Map file structure** — what is created/modified, each file's responsibility
3. **Decompose into task beads** — thin directive bodies per Task Structure
4. **Lint every body** — `node <skill-dir>/scripts/lint-citations.mjs <body-file> --repo <root>` must exit 0 before its `bd create`. A body that fails the lint is not created; fix or delete the claim.
5. **Write the exploration map** — symbol and seam rows per **Exploration Map**, into `docs/beads/<epic-id>.map.md` in the target repo
6. **Attention Map** onto the root epic body
7. **Write the `plan-ready` marker and STOP** — `bd label rm <root-id> plan-ready:<prior-sha>` if re-planning, then `bd label add <root-id> plan-ready:<short-sha>` (`bd children` is the task record). Return the receipt.

Full mode runs steps 1–7. Amend mode runs steps 3–7 for the named children only, applying the Amend Mode rules during decomposition.

**Terminal step:** planning ends at the marker. Do NOT invoke an execution skill — the execution mode is the owner's decision, taken at the coordinator's pickup against the receipt. The execution skills' epic gate checks this marker.

## Scope Check

If the spec covers multiple independent subsystems, it should have been split during brainstorming. If it wasn't, suggest separate plans — each producing working, testable software on its own.

## File Structure

Before defining tasks, map which files are created or modified and what each is responsible for — this locks in the decomposition. Clear boundaries, one responsibility per file; prefer focused files you can hold in context; files that change together live together; follow the codebase's existing patterns.

## Vertical Slices

Default task shape: a **tracer bullet** — a narrow, complete path through every layer the feature touches (schema → logic → surface → tests), verifiable on its own. Horizontal layer-slices entangle: every seam needs refereeing and nothing is verifiable until the last slice lands. Prefactoring is its own task, first.

The exception — wide mechanical refactors — sequence as **expand–contract**: add the new form beside the old; migrate call sites in batches sized by blast radius, each batch a task, CI green throughout; delete the old form last. (Both rules adapted from mattpocock/skills `to-tickets`, MIT.)

## Task Granularity

**The TDD skeleton is mandatory and never collapses:** write the failing test → run it and observe RED → implement → run GREEN → commit. Fold "watch it fail" into implement and the executor never observes RED — which is how a test that asserts nothing passes.

**Size:** one coherent concern. Tripwires — more than ~5 non-test files, or an expected diff beyond ~500 LOC, or an executor context estimate past ~150K tokens (executors re-pay accumulated context every turn; cost grows with the square of task length) — presume a split along the file map. Titles must not contain "and": two concerns, two tasks.

## Decision Beads

A plan is never written over an unresolved design fork. Triage before parking: a line colliding with a ruling, code, or spec is a defect to rewrite; repo-answered questions and one-safe-answer defaults pruned; unverified claims researched, not asked. Export `BD_ACTOR=planner` before your first bd write, all run: bd bylines your questions and findings planner, refusing your rulings. Reuse a slug `bd topics` prints; mint if none fits. One command per survivor: `bd create "Decide: <fork>" -p 1 --parent <root> --question "<fork>" --topic <slug>`, held out of `bd ready` by its question; `bd dep add <task> <decide-id>` for every task it blocks — still created, bodies naming the decision as an input, never picking sides. On an already-created task: `bd question add <task-id> "<fork>" --topic <slug>`. Coordinator or owner rules each separately: `bd ruling add <decide-id> "<text>" --answers <Q-id> --close`. Forks outnumbering tasks → superpowers-beads:wayfinder.

## What a Task Body May Claim

The section the linter enforces. A body carries intent, Files, the gate, and scope fences — and as few verbatim facts as those need.

**Every verbatim fact is machine-verified or absent.** A cited path, symbol, quoted string, locale key, or commit claim goes into the body's fenced ```citations block (`file:`, `symbol: <name> @ <path>`, `string: "<text>" @ <path>`, `key: <dot.path> @ <file.json>`, `commit-contains: <sha> <text>`, `new: <path>` for files this task creates), and the lint proves each against the tree before `bd create`. A fact you cannot write as a passing citation line does not go in the body — name the file and the intent, and let the executor resolve the specifics. Prefer symbols over line numbers; line pins rot.

**Reuse is cited, never re-implemented.** A symbol the task reuses gets a `symbol:` citation, and while confirming it, confirm its visibility: a private symbol means the export is prefactoring — its own task, first — or a BLOCKED report, never a second copy. An executor facing a private symbol with no export step will retype it, and the copy passes every gate while it drifts.

**Rendered truth is not plannable.** For visual work the planner writes what to verify in a real browser — never what the page will look like, which DOM will exist, or how CSS will resolve. A planner that has not rendered the page describes a DOM it never saw, and its own two tests can assert opposite facts about it.

**No placeholders.** "TBD", "add appropriate error handling", "write tests for the above", "similar to Task N" are plan failures. Every step is executable without guessing. **The fork test decides how much detail:** if two competent implementers could satisfy the gate with observably different behavior, the step hides a decision — pin it with a verified citation, state "either is acceptable", or extract a decision bead. Behavior the gate already pins fully is the executor's job — no block needed. A decision settled upstream (spec, ruling) that this task implements appears in this body — cited by bead and section, not reproduced.

**Each behavior is stated once** — as the pin, the gate item, or the step — and referenced elsewhere, never restated.

## Task Structure

Write each body to `.bd/.scratch/task-N.md`, lint it, create the bead, delete the scratch file. Carry image references from the spec into task beads that need them.

````markdown
### Task N: [Name]

**Context Anchor:**
Parent: [epic title] — [one-line purpose of the feature]
This task: [what it does and WHY it matters to the plan]
Depends on: [what prior tasks produced that this consumes, or "—"]

**Execution:** [inline | subagent/cheap | subagent/standard | subagent/capable] — [one-line reason; if `review:trivial-deterministic` applies, name the executing task]

**Acceptance Gate — ONE turn, DONE when ALL pass:**
All gate commands run together and report together in this turn — the verification batch.
- [ ] [observable outcome]
- [ ] [the same outcome on the regime that can fail it]
- [ ] [what the change must leave intact]
- [ ] Only Files modified, plus any test this change broke

**Drift Detectors:**
- DO NOT [specific thing a named sibling task handles]
- Editing a file not in Files → STOP — unless it is a test this change broke

**Files:**
- Create: `exact/path`
- Modify: `exact/path` — [the intent of the change]
- Test: `exact/path`

**Before you start — ONE turn (discovery batch):**
- Read: the span of every fresh map entry; every STALE map entry in full at its current span
- Run: [the index queries this task names — `structural-index symbol|callers|tests <name>`, each with its expected count]
- A file this task creates or restructures is read whole and stated in the report
- All issued in a single turn; no other file is opened before the first edit
- Rules: [the `.claude/rules/` file governing this area, if one exists]

**Steps:** the TDD skeleton, one action each, naming every behavior each test asserts.

```citations
file: exact/path/that/must/exist.ts
symbol: reusedThing @ its/home.ts
```
````

## Writing the Gate

Every gate item is an outcome you observe, machine-verifiable — "test_validate_jwt_expired passes", never "works correctly" — and falsifiable against under-doing: write it so under-coverage fails ("every variant has its own assertion"), because a fluent executor will satisfy the literal minimum convincingly. Gates collectively exercise the regime the artifact exists to survive — the second page, the full buffer — never only the one-of-everything case; and at least one item names what must stay intact, checked on that same regime. Mechanisms ("flag X is set", "Y is called") belong in steps, not gates. Visual work's gate names what the owner verifies against pixels. The planner names the index queries and expected counts the task's discovery batch runs.

## Exploration Map

Run `scripts/structural-index languages --repo <root>` first; its roster is the map file's header line. Write the map to `docs/beads/<epic-id>.map.md` in the target repo, rows `| Task | Symbol | File | Hash | Note | Source |`, Task holding the task number. Every symbol a task cites in a `symbol:` citation, creates, or restructures gets a row. A seam between tasks earns its row — `N→M | seam: <what> | — | — | <one sentence> | planner` — naming the interface the consumer reads from the tree. Callers and tests rows are never stored — the index answers them at dispatch. The Hash cell is either the 12-hex hash `scripts/structural-index symbol` prints at the planning commit (Source `index`), or the literal token `new` — a symbol no definition resolves, one this plan creates (Source `planner`). A `none` backend resolves nothing: symbols in unindexed languages get body citations only and no map row; their `callers` queries in the discovery batch carry the note "text answer". No whole-file or line-range hash exists either: a file whose symbols the index cannot resolve earns none — Files list and citations are its only record (R-B: symbol-keyed). Nobody edits hashes, no bead maintains the map, and freshness is `scripts/map-check`'s dispatch output (R-B, R-C). Append one pointer line to the epic body — `Exploration map: docs/beads/<epic-id>.map.md`. Commit the map with the plan.

## Attention Map

After creating all task beads, append to the root epic body a table telling each executor its concern and its non-concern — the record hybrid-parallel reads for wave eligibility:

```markdown
| Task | Primary Concern | Consumes From | NOT Your Concern |
|------|-----------------|---------------|------------------|
| 1: Create slice | Create path end-to-end | — | Do NOT touch edit/delete flows |
| 2: Edit slice | Edit path end-to-end | Task 1 schema | Do NOT restructure the create form |
```

Each "NOT Your Concern" names the specific sibling that owns it — never generic advice.

## Execution Annotation

Every body carries one `**Execution:**` line, mirrored as the create-time `exec:<mode>` label — the router routes from labels and never opens a body.

- `inline` — 1 file, complete spec, gate verifiable in one command, no judgment
- `subagent/cheap` — 1–2 files, complete spec, real implementation work
- `subagent/standard` — multi-file integration
- `subagent/capable` — design judgment or broad codebase understanding

Default to `subagent/*`; `inline` only when dispatch overhead clearly exceeds the work. Tiers are abstract — never name a concrete model. A task whose steps leave a genuine fork to the executor is `subagent/capable` regardless of file count — economize on the contract or on the executor, never both. Tier measures the judgment the task demands, nothing else: scheduling never moves it — a task doesn't become `capable` by joining a wave of `capable` siblings; concurrency belongs to the dependency graph. A reason that says "mechanical" or "follows a template" argues for `standard` at most — fix the tier, not the reason.

A second, independent label is emitted alongside it at create time: `review:trivial-deterministic`, when every gate item is a command, or when a later plan task executes the artifact — and in that second case the Execution line's one-line reason names the executing task. No second label means the combined reviewer runs; subagent-driven-development's Review Tier resolves the label at routing, this section only states when to emit it.

## Multi-Phase Epics

When later phases depend on what earlier phases actually land, the last task of phase N is "Plan phase N+1" — written at the END of phase N, gated on "phase N+1 task beads exist and are dep-linked". It keeps a bead open so `bd close` can't auto-close the epic under an unfinished plan. That planning session starts from `bd children <epic-id>` plus the epic body. Fully-decomposed single-phase plans skip this.

## Amend Mode

Amend mode's input is the root epic id plus one or more child ids: an unlabeled child, a `needs-plan` bead, or a task a second review FAIL must split.
Amend mode runs forked exactly like full mode.
Rewrite each named child's body to the Task Structure template.
Lint each named child's rewritten body with the citation lint before updating the child.
Label each named child `exec:<mode>` and also `review:trivial-deterministic` when it earns that label.
Add each named child to the epic body's `## Attention Map` table as its own row.
Append the named child's rows to the epic's map file.
Re-mint `plan-ready` on the root epic after all named children are planned.
When a named child is too big for one task, create replacement sibling tasks under the root epic, dep-link them, and close the original as superseded.
A task never gets children.
Amend mode returns a receipt only: bead ids, per-task Files lists, `exec:` labels, and the `plan-ready` marker.

## Plan Review Lenses (conditional)

If any task changes schema, persisted data, rollout order, cross-layer contracts, or a public type's shape, read `references/plan-review-lenses.md` and apply its three lenses to those tasks. Otherwise skip the file.

## Handoff

Write the marker on the root bead and stop:

```bash
bd label add <root-id> plan-ready:$(git rev-parse --short HEAD)
```

Return the receipt, the exploration map path `docs/beads/<epic-id>.map.md` among its items, plus any open decision beads and `NEEDS_RULING` if so. A receipt carrying prose reintroduces the residency the venue split removed. The marker's consumer is the execution skills' epic gate — a run finding none routes back to planning.
