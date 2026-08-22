---
name: writing-plans
description: Use when you have a spec or requirements for a multi-step task, before touching code
---

# Writing Plans — budget 4000 words

## Overview

Write comprehensive implementation plans assuming the engineer has zero context for our codebase and questionable taste. Document everything they need to know: which files to touch for each task, code, testing, docs they might need to check, how to test it. Give them the whole plan as bite-sized tasks. DRY. YAGNI. TDD. Frequent commits.

Assume they are a skilled developer, but know almost nothing about our toolset or problem domain. Assume they don't know good test design very well.

**Announce at start:** "I'm using the writing-plans skill to create the implementation plan."

**Context:** This should be run in a dedicated worktree (created by brainstorming skill).

**Input:** Receives a root bead ID from the brainstorming skill. All tasks are created as beads under this root.

**Storage:** Task beads are created via `bd create --parent <root-id> --json`, which gives them hierarchical IDs (e.g., `bd-a3f8.1`). Sequential task ordering uses `bd dep add` (default `blocks` type).

**bd conventions:** Read `skills/shared/bd-defaults.md` before using any bd commands.

**Mandatory step:** writing-plans is the mandatory step between an epic bead and ANY execution skill (hybrid-execution, subagent-driven-development, codex-execution). Executing an undecomposed epic — one with no child tasks — is a bypass, not a shortcut.

## Checklist

You MUST create a task for each of these items and complete them in order. The last item is the step most often skipped — keep it on the list until it is genuinely done:

1. **Scope check** — confirm the spec is a single coherent project (decompose if not) with no unresolved design fork (decision bead if it has one — see Decision Beads)
2. **Map file structure** — which files are created/modified and what each is responsible for
3. **Decompose into task beads** — bite-sized tasks, each with its directive sections
4. **Self-review audit** — re-confirm every cited path/symbol and spec-coverage across all tasks
5. **Present execution choice** — offer Subagent-Driven vs Hybrid vs Codex and get the user's pick
6. **Invoke the chosen execution skill** — `Skill(superpowers-beads:subagent-driven-development)`, `Skill(superpowers-beads:hybrid-execution)`, or `Skill(superpowers-beads:codex-execution)`, passing the root bead ID, as your next action

**Terminal step:** Item 6 is complete only when the execution skill has actually been invoked — not when you have "started executing" by running git/bd/worktree commands or dispatching implementers from memory. The only skills you invoke after writing-plans are subagent-driven-development, hybrid-execution, or codex-execution.

## Scope Check

If the spec covers multiple independent subsystems, it should have been broken into sub-project specs during brainstorming. If it wasn't, suggest breaking this into separate plans — one per subsystem. Each plan should produce working, testable software on its own.

## File Structure

Before defining tasks, map out which files will be created or modified and what each one is responsible for. This is where decomposition decisions get locked in.

- Design units with clear boundaries and well-defined interfaces. Each file should have one clear responsibility.
- You reason best about code you can hold in context at once, and your edits are more reliable when files are focused. Prefer smaller, focused files over large ones that do too much.
- Files that change together should live together. Split by responsibility, not by technical layer.
- In existing codebases, follow established patterns. If the codebase uses large files, don't unilaterally restructure - but if a file you're modifying has grown unwieldy, including a split in the plan is reasonable.

This structure informs the task decomposition. Each task should produce self-contained changes that make sense independently.

## Vertical Slices

Default task shape: a **tracer bullet** — a narrow but complete path through every layer the feature touches (schema → logic → surface → tests), demoable or verifiable on its own. Prefer this over horizontal layer-slices ("Task 1: types, Task 2: middleware, Task 3: wiring"): horizontal tasks are the ones that entangle — they need Consumes-From edges and Drift Detectors to referee every seam, and nothing is verifiable until the last slice lands. A vertical slice carries its own proof. Any prefactoring ("make the change easy, then make the easy change") is its own task, first.

**The named exception — wide refactors — sequence as expand–contract.** A wide refactor is one mechanical change (rename a column, retype a shared symbol) whose blast radius fans across the codebase, so no vertical slice can land green. Expand: add the new form beside the old. Migrate: move call sites in batches sized by blast radius (per package, per directory), each batch a task blocked by the expand, CI green throughout because the old form survives. Contract: delete the old form in a final task blocked by every batch.

(Vertical-slice and expand–contract rules adapted from mattpocock/skills `to-tickets`, MIT.)

## Bite-Sized Task Granularity

**Each step is one action (2-5 minutes):**
- "Write the failing test" - step
- "Run it to make sure it fails" - step
- "Implement the minimal code to make the test pass" - step
- "Run the tests and make sure they pass" - step
- "Commit" - step

**Task Size:** one coherent concern, bounded above twice — by the Context Ceiling, and by the **reviewable-diff bound**: the expected diff must be verifiable as one piece by one reviewer. Tripwires: more than ~5 non-test files in Files, or an expected change beyond ~500 LOC — at either, the task is presumed a phase and splits along its file map; keeping it whole requires stating why at plan time, visibly. Within the bounds: a task bundling two concerns splits; a task split only to stay under some minutes-count merges — the unit is the largest single concern the bounds admit.

**The Context Ceiling:** estimate what the executor must hold — every file in Files, everything under Before-you-start, test output across its run. If that plausibly exceeds ~150K tokens, it is two tasks, split at the same seams as any other split. **Why:** an executor re-pays its whole accumulated context on every turn, so cost grows with the square of task length — and an executor near its ceiling degrades exactly when the work gets hard. The fattest tenth of dispatched executors dominates fleet spend.

**Single Responsibility:** Task titles must not contain "and." A task like "Update types and implement middleware" has two concerns — the executor will lose focus on one. Split it into "Task 1: Update types" and "Task 2: Implement middleware."

## Decision Beads

A plan is never written over an unresolved design fork. If the spec — or your file-structure mapping — surfaces a genuine open decision (two viable architectures, an unvalidated external dependency, a data shape only research or a prototype can settle), STOP decomposing that region. Create a **decision bead**: a child task whose deliverable is the ruling, not code — `bd create "Decide: <fork>" --parent <root-id>` — blocking every task bead that depends on the outcome (`bd dep add <task> <decision>`). Resolve it (research, prototype, or a question to your human partner), record the ruling with `bd comment add`, close it, then write the tasks it was blocking. Task beads written over an open fork encode a guess as a contract — the executor will build the guess.

Park a fork ONLY as a decision bead with dep-links — an agenda line has no owner and never gates dispatch (deps and labels do). Triage first, under precedence: a line colliding with a ruling, the code, or the spec it derives from is a plan defect — rewrite the text, don't escalate; so are repo-answered questions, one-safe-answer defaults, self-contradictions, sequencing and Files errors. Unverified factual claims: research or prototype, not a question. Re-reading an inherited fork list re-runs this triage; escalate each survivor once.

For efforts where the forks outnumber the tasks — fog too thick to plan through — route to superpowers-beads:wayfinder instead of forcing a plan.

## Plan Structure in Beads

The root epic bead (created by brainstorming) already contains the spec. Plan tasks are created as child beads:

For each task, write the body to a scratch file, then create the bead:
```bash
# Write task body to scratch file (Edit tool shows diff for user review)
# → .bd/.scratch/task-N.md
# Create bead from file — the exec: label mirrors the body's **Execution:** line
# so the router reads labels, never bodies:
bd create "Task N: <name>" -p 1 --parent <root-bead-id> --body-file .bd/.scratch/task-N.md -l "exec:<mode>" --json
# Clean up:
rm .bd/.scratch/task-N.md
```

This produces hierarchical IDs (e.g., `superpowers-a3f8.1`, `.2`, `.3`).

For sequential dependencies between tasks:
```bash
bd dep add <task-2-id> <task-1-id>
```

Parse JSON output from `bd create --json` to extract the new bead ID.

**Important:** Use `--parent` to create the parent-child relationship. Do NOT use `bd dep add --type related` — that creates a dependency link but not a parent-child relationship, which breaks `bd children`, `bd epic status`, and the epics view in beads-ui.

## Multi-Phase Epics

Some epics can't be fully decomposed up front — later phases depend on what earlier phases actually land, so their tasks don't exist yet. When an epic is executed in phases like this, the **last task of phase N is "Plan phase N+1"**, with acceptance gate "phase N+1 task beads exist and are dep-linked." Write this task at the END of phase N, once you know what phase N actually landed — not as a placeholder guessed at plan time. The planning session executing that task starts by reading `bd comment list <id> --tag next-phase` across the epic and phase-N beads — the durable half of the phase-gate session handoff (phase close = session close).

**Why:** `bd close` auto-closes a parent when its last open child closes; the "Plan phase N+1" task keeps a bead open until the next phase's beads exist, so the epic can't close under an unfinished plan.

Single-phase, fully-decomposed plans — where all the work is known now — don't need this; only add it when a later phase is genuinely not decomposable yet.

## Attention Map

After creating all task beads, add an Attention Map to the root epic body. This is a topological narrative that tells each executor their primary concern and what is NOT their concern.

Update the epic bead:
```bash
# Read current epic body, append Attention Map, write to scratch file
# → .bd/.scratch/<root-id>-body.md
bd update <root-id> --body-file .bd/.scratch/<root-id>-body.md
rm .bd/.scratch/<root-id>-body.md
```

Format:

```markdown
## Attention Map

| Task | Primary Concern | Consumes From | NOT Your Concern |
|------|----------------|---------------|------------------|
| 1: Create-item slice | Create path end-to-end (schema, API, form, tests) | — | Do NOT touch edit/delete flows |
| 2: Edit slice | Edit path end-to-end | Task 1 schema | Do NOT restructure the create form |
| 3: Delete slice | Delete path + list empty state | Task 1 schema | Do NOT add bulk operations |
```

Each row must have a specific "NOT Your Concern" — not generic advice, but the specific sibling task that handles what would be tempting to touch. This prevents cross-task scope creep.

## Task Structure

The task content below is what gets written to `.bd/.scratch/task-N.md` and created via `bd create --body-file`. The markdown formatting is preserved in the bead body for readability in beads-ui.

**Markdown conventions for beads-ui:**
- Reference other issues with `#issue-id` (e.g., `#yuklar-985`) — auto-linked in the UI
- Deep link to sections using markdown links: `[label](/detail/issue-id#fragment)` where fragment is one of: `description`, `acceptance-criteria`, `notes`, `design`, or any content heading slug
- Example: `[see route visualization](/detail/yuklar-985#misjudgments)`
- If the spec bead contains image references (mockups, screenshots), carry relevant references into task beads so the executing agent can view them without navigating back to the spec

````markdown
### Task N: [Component Name]

**Context Anchor:**
Parent: [epic title] — [one-line purpose of the whole feature]
This task: [what this task does and WHY it matters to the plan]
Depends on: [what prior tasks produced that this one consumes, or "—" if first task]

**Execution:** [inline | subagent/cheap | subagent/standard | subagent/capable] — [one-line reason]

**Acceptance Gate — this task is DONE when ALL pass:**
- [ ] [observable signal: file exists, export present, test passes]
- [ ] [observable signal: specific behavior verified]
- [ ] [constraint: only Files modified, plus any test the change broke]

**Drift Detectors:**
- DO NOT [thing another task handles] — that is Task N's job
- DO NOT [tempting adjacent improvement]
- Editing a file not in Files → STOP — unless it is a test this change broke

**Files:**
- Create: `exact/path/to/file.py`
- Modify: `exact/path/to/existing.py:123-145`
- Test: `tests/exact/path/to/test.py`

**Before you start:**
- Read: `exact/path/to/existing.py` — understand current interface, callers, and return types
- Read: `exact/path/to/related_dependency.py` — dependency this task relies on
- Rules: `.claude/rules/relevant.md` — project rules for the area being changed (if they exist)

- [ ] **Step 1: Write the failing test** → gate: [which acceptance gate item this satisfies]

`test_specific_behavior` asserts: [every behavior, named — "returns X for input Y", "raises Z on empty input". Test code inline only when the exact assertion text is the spec.]

- [ ] **Step 2: Run test to verify it fails** → gate: [same item]

Run: `pytest tests/path/test.py::test_name -v`
Expected: FAIL with "function not defined"

- [ ] **Step 3: Implement `function(input)`** → gate: [same item]

[Behavior, precisely: inputs, outputs, edge cases. A code block ONLY where the exact code is the spec — e.g. the regex, the signature a sibling consumes:]

```python
def function(input: list[str]) -> Shape:  # signature consumed by Task 4
```

- [ ] **Step 4: Run test to verify it passes** → gate: [same item]

Run: `pytest tests/path/test.py::test_name -v`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add tests/path/test.py src/path/file.py
git commit -m "feat: add specific feature (<bead-id>)"
```
````

## Writing Directive Tasks

Tasks are prompts, not documentation. When you create a task for a future executor (yourself, a subagent, or a different session), you are performing prompt engineering. Task quality directly determines execution quality. If the project has `docs/CONTEXT.md` (the domain glossary brainstorming maintains), write task bodies in its vocabulary — a glossary term replaces a twenty-word description and keeps naming consistent across tasks.

**Context Anchor:** Explain WHY, not just WHAT. "Implement the middleware" is documentation. "This middleware is the security boundary between public routes and authenticated endpoints — Task 3 wires it in, Task 4 tests it" is a directive. The executor needs to understand the task's role in the plan to make correct judgment calls.

**Acceptance Gate:** Every item must be machine-verifiable. Bad: "works correctly." Good: "test_validate_jwt_expired passes." Bad: "handles errors." Good: "invalid token returns 401 with ErrorResponse body." If you can't write a command that checks it, it's not a gate item.

A gate item must also be falsifiable against *under-doing*, not just not-doing — name what would make a passing result still wrong. "Tests pass" is satisfied by a test that exercises one of nine fields. Write the gate so that under-coverage fails it: "a typo in any mapped field fails a test; every variant has its own assertion." **Why:** a fluent executor will satisfy the literal minimum convincingly — a loose gate certifies slop.

A gate's numbers and factual premises are claims too: derive each from a same-session measurement and check it doesn't contradict evidence already gathered, the spec text it derives from, or a standing ruling.

A gate item names an outcome you observe, never the mechanism that promises it. If you can tick the item without producing and observing the artifact, it is a step, not a gate — "flag X is set", "the handler is wired", "Y is called" belong in steps. A gate written as mechanism-plus-intent ("X is set so Y never happens") certifies the mechanism and takes the intent on faith. And the plan's gates must collectively exercise the regime the artifact exists to survive — the second page, the full buffer, the many-items case — never only the one-of-everything case: an outcome gate run on a fixture too small to violate it passes vacuously. A gate that cannot fail on the small fixture names the fixture that can fail it.

A gate certifies arrival AND non-destruction. At least one item names what the change must leave intact — phrased observably and checked on the same overflow fixture ("pages before the split point render byte-identical", "no page's content height drops below its pre-change value"). A gate that only sets floors invites a mechanism that clears them by degrading everything the gate doesn't mention; the preservation item is what makes the wrong mechanism fail.

**Drift Detectors:** You know all sibling tasks. Use that knowledge. If Task 3 handles integration and Task 4 handles error responses, then Task 2's drift detectors should say "DO NOT wire into server — that is Task 3's job" and "DO NOT define error response format — that is Task 4's job." Generic warnings like "stay focused" are useless.

One exception, yours to grant, never the executor's to take: a test broken solely by an in-contract change is in-contract to update. A test encoding a structural ban — import guards, dependency direction — still stops the turn: a design conflict, not a pin.

**Step-Gate Links:** Each step notes which acceptance gate item it satisfies (via `→ gate: [item]`). This prevents orphan steps that don't contribute to completion, and prevents gate items with no steps that satisfy them.

## Execution Annotation

Every task body carries one `**Execution:**` line — the mode a hybrid executor should use for the task, with a one-line reason. You know every task's file count and spec completeness; decide at plan time so the choice is visible at plan review, not improvised at execution time. Mirror the mode as a bead label at create time (`-l "exec:subagent/standard"`; on a legacy plan, `bd label add <id> "exec:<mode>"`) — the router routes from the ready list plus this label and never opens a body.

- `inline` — 1 file, complete spec, gate verifiable in one command, no judgment (config bump, rename, doc edit)
- `subagent/cheap` — 1–2 files, complete spec, real implementation work
- `subagent/standard` — multi-file integration
- `subagent/capable` — design judgment or broad codebase understanding

Default to `subagent/*`. `inline` is the exception — only when dispatch overhead clearly exceeds the work itself. Tiers are abstract — the executor maps them to its harness's models; never name a concrete model in the annotation.

Down-routing presumes a pinned contract: a task whose steps leave a mechanism or design fork to the executor (the fork test, No Placeholders) is `subagent/capable` regardless of file count. Economize on the contract or on the executor — never both in one task.

Tier measures the judgment a task demands — nothing else. Scheduling never moves it: a task doesn't become `capable` by joining a parallel wave of `capable` siblings; which tasks run concurrently is the dependency graph's property, not the tier's. If the reason you're writing says the work is mechanical, a mirror, or follows an existing template, it is arguing for `standard` at most — fix the tier, not the reason.

Subagent-Driven execution ignores this line harmlessly; hybrid-execution routes on it.

## Verify Before You Cite

Every file path, function, signature, regex, or line range you name in a task body must be opened and confirmed before it lands. Plans that cite symbols without reading them are fabrications.

Before writing a task step like `Modify <file>:<lines>`, `grep for <pattern>`, or `Call <function>(<args>)` (angle brackets are placeholders for whatever you're citing):
- Open the file and confirm the path
- Confirm the signature matches what you're about to cite
- Confirm the regex matches what the codebase actually uses — the canonical name may differ from how callers reference it (local aliases, re-exports, wrapper functions)
- Prefer symbol names over line ranges — line numbers rot on the next refactor

**Why:** every uncited reference is a lie the plan tells a future executor.

A Files list is an absence claim symbol grep cannot verify: it finds callers, never constrainers (a test pinning old behaviour through a public function; a stub matching SQL text). Seal one only after adding, per touched module, its test files (by module path or by running them, never by grep) and any import-ban or dependency-direction config governing them.

## Plan Review Lenses (conditional)

If any task changes schema, persisted data, rollout order, cross-layer contracts, or a public type's shape or representation, read `references/plan-review-lenses.md` and apply its three lenses — Deploy Sequence and Rollout Safety, Cross-Layer Consistency, Semantic Regression Sweep — to those tasks. Plans touching none of those skip this file entirely.

## No Placeholders

Every step must be executable without guessing. These are **plan failures** — never write them:
- "TBD", "TODO", "implement later", "fill in details"
- "Add appropriate error handling" / "add validation" / "handle edge cases"
- "Write tests for the above" (name every behavior each test asserts; test code itself is optional)
- "Similar to Task N" (repeat the spec — the engineer may be reading tasks out of order)
- Steps whose expected behavior isn't stated precisely. A step is behavior + its gate link. **The fork test decides how much detail:** if two competent implementers could both satisfy the gate with observably different behavior, the step is hiding a decision — pin it (code block, exact enumeration, table, or an explicit "either is acceptable") or extract it as a decision bead. Ordinary code whose every observable outcome the gate already pins is the executor's job — no block needed. And any behavior settled in the spec, a ruling, or brainstorming that this task implements must appear in THIS task's body — the executor reads one bead, never the epic; a decision that lives only upstream is unspecified here.
- References to types, functions, or methods not defined in any task
- Tasks that modify existing files without a "Before you start" section

## Self-Review

After all task beads exist, run one audit pass over them yourself (not a subagent dispatch). This is deliberately separate from the rules above: those guide writing each task; this catches what only surfaces once the whole plan is on the page — and it forces you to *re-confirm* claims you made while authoring rather than trust that you did. (Re-confirming, not trusting, is the point: "I already verified that" while authoring is exactly the assertion this pass exists to test.)

Read the beads (`bd show id1 id2 id3 --full`) and re-run each rule section above against every task:
- **No Placeholders**, and **Verify Before You Cite** — re-open and confirm every cited path/symbol; citation drift is fabrication, fix or remove it.
- the **Writing Directive Tasks** bars — Context Anchor explains WHY; every gate item machine-verifiable *and* falsifiable against under-doing; no gate item is tickable without observing the artifact, every gate carries a preservation item, and the plan's gates name the overflow-regime fixture they run on; Drift Detectors name specific sibling tasks; every step has a `→ gate:` link and no gate item is orphaned; no title contains "and"; every task carries an **Execution:** line with a reason whose value matches the rubric.
- **Before you start** present on every task that modifies existing files; rule-governed areas reference the relevant `.claude/rules/` file.

Then two checks only possible now that all tasks exist:
- **Spec coverage:** every requirement in the root spec (`bd show <root-id> --full`) maps to a task bead. Add a bead for any gap.
- **Type consistency:** names, signatures, and shapes used in later tasks match what earlier tasks defined — `clearLayers()` in Task 3 but `clearFullLayers()` in Task 7 is a bug.

Fix inline; no need to re-review.

## Execution Handoff

After all task beads are created and linked, offer execution choice:

**"Plan complete — <N> task beads created under `<root-bead-id>`. Three execution options:**

**1. Subagent-Driven** - I dispatch a fresh subagent per task, review between tasks

**2. Hybrid (recommended when the plan mixes trivial and complex tasks)** - Route each task by its Execution annotation: trivial tasks inline, everything else to a fresh subagent

**3. Codex Execution** - Task beads run via the codex CLI (zero-context executor); this session verifies each landing and runs the terminal whole-diff review

**Which approach?"**

Pass the root bead ID to the chosen execution skill. This completes the final checklist task — and that task is not done until you have actually invoked the execution skill below, not merely "started executing."

**If Subagent-Driven chosen:**
- **REQUIRED SUB-SKILL:** Use superpowers-beads:subagent-driven-development
- Fresh subagent per task + two-stage review

**If Hybrid chosen:**
- **REQUIRED SUB-SKILL:** Use superpowers-beads:hybrid-execution
- Routes each task by its **Execution:** annotation; overrides must be stated

**If Codex Execution chosen:**
- **REQUIRED SUB-SKILL:** Use superpowers-beads:codex-execution
- Sequential codex dispatch per task + per-landing verification + terminal whole-diff review
