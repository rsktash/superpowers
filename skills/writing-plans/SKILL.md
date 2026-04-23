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

**The 10-Minute Rule:** Each task should be completable in 10-15 minutes of execution. This is long enough to accomplish meaningful work but short enough to stay within the LLM's effective attention span. If a task takes longer, the executor's attention drifts and quality degrades. If a task is shorter, the overhead of context switching dominates.

**Single Responsibility:** Task titles must not contain "and." A task like "Update types and implement middleware" has two concerns — the executor will lose focus on one. Split it into "Task 1: Update types" and "Task 2: Implement middleware."

## Plan Structure in Beads

The root epic bead (created by brainstorming) already contains the spec. Plan tasks are created as child beads:

For each task, write the body to a scratch file, then create the bead:
```bash
# Write task body to scratch file (Edit tool shows diff for user review)
# → .beads/.scratch/task-N.md
# Create bead from file:
bd create "Task N: <name>" -p 1 --parent <root-bead-id> --body-file .beads/.scratch/task-N.md --json
# Clean up:
rm .beads/.scratch/task-N.md
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
# → .beads/.scratch/<root-id>-body.md
bd update <root-id> --body-file .beads/.scratch/<root-id>-body.md
rm .beads/.scratch/<root-id>-body.md
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

The task content below is what gets written to `.beads/.scratch/task-N.md` and created via `bd create --body-file`. The markdown formatting is preserved in the bead body for readability in beads-ui.

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

**Drift Detectors:** You know all sibling tasks. Use that knowledge. If Task 3 handles integration and Task 4 handles error responses, then Task 2's drift detectors should say "DO NOT wire into server — that is Task 3's job" and "DO NOT define error response format — that is Task 4's job." Generic warnings like "stay focused" are useless.

**Step-Gate Links:** Each step notes which acceptance gate item it satisfies (via `→ gate: [item]`). This prevents orphan steps that don't contribute to completion, and prevents gate items with no steps that satisfy them.

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

## Remember
- Exact file paths always
- Complete code in every step — if a step changes code, show the code
- Exact commands with expected output
- DRY, YAGNI, TDD, frequent commits

## Self-Review

After creating all task beads, review the plan against the spec. This is a checklist you run yourself — not a subagent dispatch.

**1. Spec coverage:** Read the root spec bead via `bd show <root-id> --json` and verify each requirement has a corresponding task bead. List any gaps.

**2. Placeholder scan:** Read each task bead via `bd show <task-id> --json` and check for red flags — any of the patterns from the "No Placeholders" section above. Fix them by updating the bead.

**2b. Attention anchors:** Does every task that modifies existing files have a "Before you start" section listing what to read? Does every task touching a rule-governed area reference the relevant `.claude/rules/` file? If not, add them.

**2c. Attention quality:** For each task bead, verify:
- Context Anchor explains WHY this task matters to the plan, not just WHAT it does
- All Acceptance Gate items are machine-verifiable (can be checked with a command, not a judgment call)
- Drift Detectors reference specific sibling tasks by name ("that is Task 3's job"), not generic warnings
- Every step has a `→ gate:` link to an acceptance gate item
- No acceptance gate item is orphaned (every item has at least one step that satisfies it)
- Task title does not contain "and" (split into two tasks if it does)

**2d. Citation reality check:** For every file path, function name, signature, or regex cited in any task body, confirm by opening the file that the path exists and the symbol matches what was cited. Citation drift is a fabrication — fix the task body or remove the reference.

**3. Type consistency:** Do the types, method signatures, and property names you used in later tasks match what you defined in earlier tasks? A function called `clearLayers()` in Task 3 but `clearFullLayers()` in Task 7 is a bug.

If you find issues, fix them inline. No need to re-review — just fix and move on. If you find a spec requirement with no task, add the task bead.

## Execution Handoff

After all task beads are created and linked, offer execution choice:

**"Plan complete — <N> task beads created under `<root-bead-id>`. Two execution options:**

**1. Inline Execution (recommended)** - Execute tasks in this session using executing-plans, driven by `bd ready`

**2. Subagent-Driven** - I dispatch a fresh subagent per task, review between tasks

**Which approach?"**

Pass the root bead ID to the chosen execution skill.

**If Inline Execution chosen:**
- **REQUIRED SUB-SKILL:** Use superpowers-beads:executing-plans
- Execution driven by `bd ready --parent <root-id> --json`

**If Subagent-Driven chosen:**
- **REQUIRED SUB-SKILL:** Use superpowers-beads:subagent-driven-development
- Fresh subagent per task + two-stage review
