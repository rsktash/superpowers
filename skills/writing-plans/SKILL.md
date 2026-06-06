---
name: writing-plans
description: Use when you have a spec or requirements for a multi-step task, before touching code
---

# Writing Plans

## Overview

Write comprehensive implementation plans assuming the engineer has zero context for our codebase and questionable taste. Document everything they need to know: which files to touch for each task, code, testing, docs they might need to check, how to test it. Give them the whole plan as bite-sized tasks. DRY. YAGNI. TDD. Frequent commits.

Assume they are a skilled developer, but know almost nothing about our toolset or problem domain. Assume they don't know good test design very well.

**Announce at start:** "I'm using the writing-plans skill to create the implementation plan."

**Context:** This should be run in a dedicated worktree (created by brainstorming skill).

**Input:** Receives a root bead ID from the brainstorming skill. All tasks are created as beads under this root.

**Storage:** Task beads are created via `bd create --parent <root-id> --json`, which gives them hierarchical IDs (e.g., `bd-a3f8.1`). Sequential task ordering uses `bd dep add` (default `blocks` type).

**bd conventions:** Read `skills/shared/bd-defaults.md` before using any bd commands.

## Checklist

You MUST create a task for each of these items and complete them in order. The last item is the step most often skipped — keep it on the list until it is genuinely done:

1. **Scope check** — confirm the spec is a single coherent project (decompose if not)
2. **Map file structure** — which files are created/modified and what each is responsible for
3. **Decompose into task beads** — bite-sized tasks, each with its directive sections
4. **Self-review audit** — re-confirm every cited path/symbol and spec-coverage across all tasks
5. **Present execution choice** — offer Inline vs Subagent-Driven vs Hybrid and get the user's pick
6. **Invoke the chosen execution skill** — `Skill(superpowers-beads:executing-plans)`, `Skill(superpowers-beads:subagent-driven-development)`, or `Skill(superpowers-beads:hybrid-execution)`, passing the root bead ID, as your next action

**Terminal step:** Item 6 is complete only when the execution skill has actually been invoked — not when you have "started executing" by running git/bd/worktree commands or dispatching implementers from memory. The only skills you invoke after writing-plans are executing-plans, subagent-driven-development, or hybrid-execution.

## Scope Check

If the spec covers multiple independent subsystems, it should have been broken into sub-project specs during brainstorming. If it wasn't, suggest breaking this into separate plans — one per subsystem. Each plan should produce working, testable software on its own.

## File Structure

Before defining tasks, map out which files will be created or modified and what each one is responsible for. This is where decomposition decisions get locked in.

- Design units with clear boundaries and well-defined interfaces. Each file should have one clear responsibility.
- You reason best about code you can hold in context at once, and your edits are more reliable when files are focused. Prefer smaller, focused files over large ones that do too much.
- Files that change together should live together. Split by responsibility, not by technical layer.
- In existing codebases, follow established patterns. If the codebase uses large files, don't unilaterally restructure - but if a file you're modifying has grown unwieldy, including a split in the plan is reasonable.

This structure informs the task decomposition. Each task should produce self-contained changes that make sense independently.

## Bite-Sized Task Granularity

**Each step is one action (2-5 minutes):**
- "Write the failing test" - step
- "Run it to make sure it fails" - step
- "Implement the minimal code to make the test pass" - step
- "Run the tests and make sure they pass" - step
- "Commit" - step

**The 10-Minute Rule:** Each task should be completable in 10-15 minutes of execution. This keeps the whole task — its gate, its files, its steps — small enough to hold and verify as one unit. A task that runs much longer usually bundles more than one concern (split it); a much shorter one is dominated by context-switching overhead.

**Single Responsibility:** Task titles must not contain "and." A task like "Update types and implement middleware" has two concerns — the executor will lose focus on one. Split it into "Task 1: Update types" and "Task 2: Implement middleware."

## Plan Structure in Beads

The root epic bead (created by brainstorming) already contains the spec. Plan tasks are created as child beads:

For each task, write the body to a scratch file, then create the bead:
```bash
# Write task body to scratch file (Edit tool shows diff for user review)
# → .bd/.scratch/task-N.md
# Create bead from file:
bd create "Task N: <name>" -p 1 --parent <root-bead-id> --body-file .bd/.scratch/task-N.md --json
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
| 1: Types | Define interfaces | — | Do NOT implement logic |
| 2: Middleware | JWT validation | Task 1 types | Do NOT wire into server |
| 3: Integration | Route wiring | Task 2 middleware | Do NOT refactor middleware |
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
- [ ] [constraint: only files listed in Files were modified]

**Drift Detectors:**
- DO NOT [thing another task handles] — that is Task N's job
- DO NOT [tempting adjacent improvement]
- If you find yourself editing files not listed in Files, STOP and re-read this section

**Files:**
- Create: `exact/path/to/file.py`
- Modify: `exact/path/to/existing.py:123-145`
- Test: `tests/exact/path/to/test.py`

**Before you start:**
- Read: `exact/path/to/existing.py` — understand current interface, callers, and return types
- Read: `exact/path/to/related_dependency.py` — dependency this task relies on
- Rules: `.claude/rules/relevant.md` — project rules for the area being changed (if they exist)

- [ ] **Step 1: Write the failing test** → gate: [which acceptance gate item this satisfies]

```python
def test_specific_behavior():
    result = function(input)
    assert result == expected
```

- [ ] **Step 2: Run test to verify it fails** → gate: [same item]

Run: `pytest tests/path/test.py::test_name -v`
Expected: FAIL with "function not defined"

- [ ] **Step 3: Write minimal implementation** → gate: [same item]

```python
def function(input):
    return expected
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

Tasks are prompts, not documentation. When you create a task for a future executor (yourself, a subagent, or a different session), you are performing prompt engineering. Task quality directly determines execution quality.

**Context Anchor:** Explain WHY, not just WHAT. "Implement the middleware" is documentation. "This middleware is the security boundary between public routes and authenticated endpoints — Task 3 wires it in, Task 4 tests it" is a directive. The executor needs to understand the task's role in the plan to make correct judgment calls.

**Acceptance Gate:** Every item must be machine-verifiable. Bad: "works correctly." Good: "test_validate_jwt_expired passes." Bad: "handles errors." Good: "invalid token returns 401 with ErrorResponse body." If you can't write a command that checks it, it's not a gate item.

A gate item must also be falsifiable against *under-doing*, not just not-doing — name what would make a passing result still wrong. "Tests pass" is satisfied by a test that exercises one of nine fields. Write the gate so that under-coverage fails it: "a typo in any mapped field fails a test; every variant has its own assertion." **Why:** a fluent executor will satisfy the literal minimum convincingly — a loose gate certifies slop. (Observed: a task whose gate said "3 passing tests" got 3 tests covering 3 of 9 fields, and passed.)

**Drift Detectors:** You know all sibling tasks. Use that knowledge. If Task 3 handles integration and Task 4 handles error responses, then Task 2's drift detectors should say "DO NOT wire into server — that is Task 3's job" and "DO NOT define error response format — that is Task 4's job." Generic warnings like "stay focused" are useless.

**Step-Gate Links:** Each step notes which acceptance gate item it satisfies (via `→ gate: [item]`). This prevents orphan steps that don't contribute to completion, and prevents gate items with no steps that satisfy them.

## Execution Annotation

Every task body carries one `**Execution:**` line — the mode a hybrid executor should use for the task, with a one-line reason. You know every task's file count and spec completeness; decide at plan time so the choice is visible at plan review, not improvised at execution time.

- `inline` — 1 file, complete spec, gate verifiable in one command, no judgment (config bump, rename, doc edit)
- `subagent/cheap` — 1–2 files, complete spec, real implementation work
- `subagent/standard` — multi-file integration
- `subagent/capable` — design judgment or broad codebase understanding

Default to `subagent/*`. `inline` is the exception — only when dispatch overhead clearly exceeds the work itself. Tiers are abstract — the executor maps them to its harness's models; never name a concrete model in the annotation.

Inline Execution and Subagent-Driven execution ignore this line harmlessly; superpowers-beads:hybrid-execution routes on it.

## Verify Before You Cite

Every file path, function, signature, regex, or line range you name in a task body must be opened and confirmed before it lands. Plans that cite symbols without reading them are fabrications.

Before writing a task step like `Modify <file>:<lines>`, `grep for <pattern>`, or `Call <function>(<args>)` (angle brackets are placeholders for whatever you're citing):
- Open the file and confirm the path
- Confirm the signature matches what you're about to cite
- Confirm the regex matches what the codebase actually uses — the canonical name may differ from how callers reference it (local aliases, re-exports, wrapper functions)
- Prefer symbol names over line ranges — line numbers rot on the next refactor

**Why:** Reviewers repeatedly catch plans that reference non-existent files, wrong helper signatures, or regexes that miss real call sites. Every uncited reference is a lie the plan tells a future executor.

## Deploy Sequence and Rollout Safety

Tasks that change schema, persisted data, feature activation, or route behavior must state their rollout constraints. Code that lands independently of its preconditions causes production outages — tests pass; the deploy fails.

For each task that introduces such changes, require:
- **Precondition** — what must already be live before this task's code runs (completed migration, finished backfill, dependency deployed, parent flag enabled)
- **Activation gate** — what triggers the new behavior (flag flip, route cutover, schema switch) and whether the old path is removed in the same task or left for a follow-up
- **Intermediate-state safety** — what protects users and data while rollout is partial; if both old and new paths must coexist, state the invariant that keeps them consistent
- **Rollback condition** — what signal triggers a revert and what reverting costs (data loss, re-run needed, none)

**Why:** Reviewers repeatedly catch activation gates that land before their preconditions finish, producing zero-result queries or hard errors on real traffic.

## Cross-Layer Consistency

When two or more architectural layers must agree on a computed value, token set, or contract, define one source of truth that every layer consumes. If an unavoidable duplication exists, state how drift will be detected.

For each concept that spans layers, the plan must:
- Identify every layer that derives or consumes the concept
- Point to the single shared definition, or to the shared helper every layer calls
- If duplication is unavoidable, specify the drift-detection signal — round-trip test, shared type, runtime assertion

**Why:** Independently implemented "same logic" in separate layers drifts on the next edit and produces silent consistency bugs that unit tests miss, because each layer's tests pass in isolation.

## Semantic Regression Sweep for Representation Changes

When a task changes a public type, representation, or shape (primitive to wrapper, optional to required, scalar to collection, nullable to non-null, etc.), list the operations whose semantics change with the new shape and verify each:

- **Truthiness** — what counts as "empty" under the new shape?
- **Equality** — reference vs. structural comparison; hash/set membership
- **Serialization** — JSON, URL, log output, `toString`
- **Defaulting** — placeholder rendering (`|| fallback`, `?? default`), conditional branches keyed on the old shape
- **Formatting** — length-based truncation, locale-aware rendering, rounding

Enumerate the call sites the sweep must visit. Code that compiles after the type change is not evidence the behavior survived.

**Why:** Representation changes routinely break truthiness-based placeholder rendering and equality-based dedup logic. Compilation passes; users see broken output.

## No Placeholders

Every step must contain the actual content an engineer needs. These are **plan failures** — never write them:
- "TBD", "TODO", "implement later", "fill in details"
- "Add appropriate error handling" / "add validation" / "handle edge cases"
- "Write tests for the above" (without actual test code)
- "Similar to Task N" (repeat the code — the engineer may be reading tasks out of order)
- Steps that describe what to do without showing how (code blocks required for code steps)
- References to types, functions, or methods not defined in any task
- Tasks that modify existing files without a "Before you start" section

## Self-Review

After all task beads exist, run one audit pass over them yourself (not a subagent dispatch). This is deliberately separate from the rules above: those guide writing each task; this catches what only surfaces once the whole plan is on the page — and it forces you to *re-confirm* claims you made while authoring rather than trust that you did. (Re-confirming, not trusting, is the point: "I already verified that" while authoring is exactly the assertion this pass exists to test.)

Read the beads (`bd show id1 id2 id3 --full`) and re-run each rule section above against every task:
- **No Placeholders**, and **Verify Before You Cite** — re-open and confirm every cited path/symbol; citation drift is fabrication, fix or remove it.
- the **Writing Directive Tasks** bars — Context Anchor explains WHY; every gate item machine-verifiable *and* falsifiable against under-doing; Drift Detectors name specific sibling tasks; every step has a `→ gate:` link and no gate item is orphaned; no title contains "and"; every task carries an **Execution:** line with a reason whose value matches the rubric.
- **Before you start** present on every task that modifies existing files; rule-governed areas reference the relevant `.claude/rules/` file.

Then two checks only possible now that all tasks exist:
- **Spec coverage:** every requirement in the root spec (`bd show <root-id> --full`) maps to a task bead. Add a bead for any gap.
- **Type consistency:** names, signatures, and shapes used in later tasks match what earlier tasks defined — `clearLayers()` in Task 3 but `clearFullLayers()` in Task 7 is a bug.

Fix inline; no need to re-review.

## Execution Handoff

After all task beads are created and linked, offer execution choice:

**"Plan complete — <N> task beads created under `<root-bead-id>`. Three execution options:**

**1. Inline Execution** - Execute tasks in this session using executing-plans, driven by `bd ready`

**2. Subagent-Driven** - I dispatch a fresh subagent per task, review between tasks

**3. Hybrid (recommended when the plan mixes trivial and complex tasks)** - Route each task by its Execution annotation: trivial tasks inline, everything else to a fresh subagent

**Which approach?"**

Pass the root bead ID to the chosen execution skill. This completes the final checklist task — and that task is not done until you have actually invoked the execution skill below, not merely "started executing."

**If Inline Execution chosen:**
- **REQUIRED SUB-SKILL:** Use superpowers-beads:executing-plans
- Execution driven by `bd ready --parent <root-id> --json`

**If Subagent-Driven chosen:**
- **REQUIRED SUB-SKILL:** Use superpowers-beads:subagent-driven-development
- Fresh subagent per task + two-stage review

**If Hybrid chosen:**
- **REQUIRED SUB-SKILL:** Use superpowers-beads:hybrid-execution
- Routes each task by its **Execution:** annotation; overrides must be stated
