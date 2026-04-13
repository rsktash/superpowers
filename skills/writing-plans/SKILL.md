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

## Task Structure

The task content below is what gets written to `.beads/.scratch/task-N.md` and created via `bd create --body-file`. The markdown formatting is preserved in the bead body for readability in beads-ui.

**Markdown conventions for beads-ui:**
- Reference other issues with `#issue-id` (e.g., `#yuklar-985`) — auto-linked in the UI
- Deep link to sections using markdown links: `[label](/detail/issue-id#fragment)` where fragment is one of: `description`, `acceptance-criteria`, `notes`, `design`, or any content heading slug
- Example: `[see route visualization](/detail/yuklar-985#misjudgments)`
- If the spec bead contains image references (mockups, screenshots), carry relevant references into task beads so the executing agent can view them without navigating back to the spec

````markdown
### Task N: [Component Name]

**Files:**
- Create: `exact/path/to/file.py`
- Modify: `exact/path/to/existing.py:123-145`
- Test: `tests/exact/path/to/test.py`

**Before you start:**
- Read: `exact/path/to/existing.py` — understand current interface, callers, and return types
- Read: `exact/path/to/related_dependency.py` — dependency this task relies on
- Rules: `.claude/rules/relevant.md` — project rules for the area being changed (if they exist)

- [ ] **Step 1: Write the failing test**

```python
def test_specific_behavior():
    result = function(input)
    assert result == expected
```

- [ ] **Step 2: Run test to verify it fails**

Run: `pytest tests/path/test.py::test_name -v`
Expected: FAIL with "function not defined"

- [ ] **Step 3: Write minimal implementation**

```python
def function(input):
    return expected
```

- [ ] **Step 4: Run test to verify it passes**

Run: `pytest tests/path/test.py::test_name -v`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add tests/path/test.py src/path/file.py
git commit -m "feat: add specific feature (<bead-id>)"
```
````

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
