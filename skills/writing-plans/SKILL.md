---
name: writing-plans
description: Use when you have a spec or requirements for a multi-step task, before touching code
---

# Writing Plans — budget 2000 words

## Overview

Write implementation plans assuming a skilled engineer with zero context for our codebase: which files each task touches, what each change is for, how to verify it. Bite-sized tasks. DRY. YAGNI. TDD. Frequent commits.

A plan is a contract of intent, not a transcript of the code to come. The planner owns the decomposition, the file map, the gates, and the scope fences. The executor stands in the live tree and owns the specifics — names, signatures, wiring, which tests break — and logs deviations on the bead. A plan that dictates specifics it never verified is worse than one that stays abstract: the executor is bound to obey it, and it lies.

**Announce at start:** "I'm using the writing-plans skill to create the implementation plan."

**Input:** a root epic bead (from brainstorming) holding the spec. Tasks are created as child beads: `bd create "Task N: <name>" -p 1 --parent <root-id> --body-file .bd/.scratch/task-N.md -l "exec:<mode>" --json` — hierarchical IDs, sequential deps via `bd dep add <task-2> <task-1>`. Use `--parent`, never `--type related` (that breaks `bd children` and epic views). Read `skills/shared/bd-defaults.md` before any bd command.

**Mandatory step:** writing-plans is the step between an epic and ANY execution skill. Executing an undecomposed epic is a bypass, not a shortcut.

**Venue: a dispatched planning agent, never the coordinator's session** — verifying citations opens every cited file, and in the coordinator that reading is resident to session end. Return a **receipt**: bead ids, per-task Files lists, `exec:` labels, `plan-ready` marker. Nothing else.

**`NEEDS_RULING` is a successful, partial return:** task beads for the unforked region, decision beads over the rest. Never resolve an owner-level fork to avoid returning empty. Persist the draft to the beads and `.bd/.scratch` before returning, so any resumer starts from the draft, never zero.

## Checklist

Complete in order:

1. **Scope check** — one coherent project, no unresolved design fork
2. **Map file structure** — what is created/modified, each file's responsibility
3. **Decompose into task beads** — thin directive bodies per Task Structure
4. **Lint every body** — `node <skill-dir>/scripts/lint-citations.mjs <body-file> --repo <root>` must exit 0 before its `bd create`. A body that fails the lint is not created; fix or delete the claim.
5. **Attention Map** onto the root epic body
6. **Write the `plan-ready` marker and STOP** — `bd comment add <root-id> "plan-ready: <short-sha> / tasks: <id> <id> …"`, return the receipt.

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

A plan is never written over an unresolved design fork. A genuine open decision (two viable architectures, an unvalidated dependency, a shape only a prototype can settle) stops decomposition of that region: `bd create "Decide: <fork>" --parent <root-id>`, dep-linked to block every task that depends on the outcome. Triage before parking: a line colliding with a ruling, the code, or the spec is a plan defect — rewrite it; repo-answered questions and one-safe-answer defaults are pruned; unverified factual claims are researched, not asked. Only survivors return, each ruled separately. Forks outnumbering tasks → route to superpowers-beads:wayfinder.

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

**Execution:** [inline | subagent/cheap | subagent/standard | subagent/capable] — [one-line reason]

**Acceptance Gate — DONE when ALL pass:**
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

**Before you start:**
- Read: [the files whose current behavior this task changes or consumes]
- Rules: [the `.claude/rules/` file governing this area, if one exists]

**Steps:** the TDD skeleton, one action each, naming every behavior each test asserts.

```citations
file: exact/path/that/must/exist.ts
symbol: reusedThing @ its/home.ts
```
````

## Writing the Gate

Every gate item is an outcome you observe, machine-verifiable — "test_validate_jwt_expired passes", never "works correctly" — and falsifiable against under-doing: write it so under-coverage fails ("every variant has its own assertion"), because a fluent executor will satisfy the literal minimum convincingly. Gates collectively exercise the regime the artifact exists to survive — the second page, the full buffer — never only the one-of-everything case; and at least one item names what must stay intact, checked on that same regime. Mechanisms ("flag X is set", "Y is called") belong in steps, not gates. Visual work's gate names what the owner verifies against pixels.

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

Every body carries one `**Execution:**` line, mirrored as the create-time label — the router routes from labels and never opens a body.

- `inline` — 1 file, complete spec, gate verifiable in one command, no judgment
- `subagent/cheap` — 1–2 files, complete spec, real implementation work
- `subagent/standard` — multi-file integration
- `subagent/capable` — design judgment or broad codebase understanding

Default to `subagent/*`; `inline` only when dispatch overhead clearly exceeds the work. Tiers are abstract — never name a concrete model. A task whose steps leave a genuine fork to the executor is `subagent/capable` regardless of file count — economize on the contract or on the executor, never both. Tier measures the judgment the task demands, nothing else: scheduling never moves it — a task doesn't become `capable` by joining a wave of `capable` siblings; concurrency belongs to the dependency graph. A reason that says "mechanical" or "follows a template" argues for `standard` at most — fix the tier, not the reason.

## Multi-Phase Epics

When later phases depend on what earlier phases actually land, the last task of phase N is "Plan phase N+1" — written at the END of phase N, gated on "phase N+1 task beads exist and are dep-linked". It keeps a bead open so `bd close` can't auto-close the epic under an unfinished plan. That planning session starts from `bd comment list <id> --tag next-phase` across the epic and phase-N beads. Fully-decomposed single-phase plans skip this.

## Plan Review Lenses (conditional)

If any task changes schema, persisted data, rollout order, cross-layer contracts, or a public type's shape, read `references/plan-review-lenses.md` and apply its three lenses to those tasks. Otherwise skip the file.

## Handoff

Write the marker on the root bead and stop:

```bash
bd comment add <root-id> "plan-ready: $(git rev-parse --short HEAD) / tasks: <id> <id> ..."
```

Return the receipt, plus any open decision beads and `NEEDS_RULING` if so. A receipt carrying prose reintroduces the residency the venue split removed. The marker's consumer is the execution skills' epic gate — a run finding none routes back to planning.
