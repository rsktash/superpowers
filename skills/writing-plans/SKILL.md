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

<HARD-GATE>
## Step 0: Verify beads (MUST complete before ANY other action)

Check session context for `<beads-status>`. If `BEADS_AVAILABLE=false` → tell your human partner: "Beads (`bd`) is not available. It should have been auto-installed by the session-start hook. Try restarting Claude Code, or run `$CLAUDE_PLUGIN_ROOT/scripts/install-deps.sh` manually." STOP. Do NOT proceed. Do NOT launch parallel work.

If beads is available but no `.beads/` directory exists → ask user: "Run `bd init` to set up beads in this project?" and WAIT.

Only after beads is available AND initialized → proceed.
</HARD-GATE>

**Input:** Receives a root bead ID from the brainstorming skill. All tasks are created as beads under this root.

**Storage:** Task beads are created via `bd create --parent <root-id> --json`, which gives them hierarchical IDs (e.g., `bd-a3f8.1`). Sequential task ordering uses `bd dep add` (default `blocks` type).

## bd Default Behaviors

- **Create child beads sequentially, not in parallel.** `--parent` assigns sequential IDs (`.1`, `.2`, `.3`). Parallel creates cause ID conflicts and failures.
- **`bd list`** shows **open issues only** by default. Use `--all` to include closed.
- **`bd show <id> --json`** works on any bead regardless of status. This is the reliable way to inspect any bead.
- **`bd close`** on the last open child may **auto-close the parent epic**. This is expected behavior.
- **`bd update` body from stdin:** use `bd update <id> --stdin`, NOT `--body --stdin`. The `--body` flag does not exist — it gets parsed as an argument and silently corrupts the description.
- **`bd create` body from file:** use `bd create --body-file <path>` or `--stdin`. Write to `.beads/.scratch/` first so the Edit tool shows diffs for user review.

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

The task content below is what gets piped into `bd create --stdin`. The markdown formatting is preserved in the bead body for readability in beads-ui.

**Markdown conventions for beads-ui:**
- Reference other issues with `#issue-id` (e.g., `#yuklar-985`) — auto-linked in the UI
- Deep link to a section: `#yuklar-985#audit-mockup` (heading text is slugified)
- Use `attach://path` for file attachments — resolved via `FILE_ATTACHMENT_BASE_URL`

````markdown
### Task N: [Component Name]

**Files:**
- Create: `exact/path/to/file.py`
- Modify: `exact/path/to/existing.py:123-145`
- Test: `tests/exact/path/to/test.py`

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

## Remember
- Exact file paths always
- Complete code in every step — if a step changes code, show the code
- Exact commands with expected output
- DRY, YAGNI, TDD, frequent commits

## Self-Review

After creating all task beads, review the plan against the spec. This is a checklist you run yourself — not a subagent dispatch.

**1. Spec coverage:** Read the root spec bead via `bd show <root-id> --json` and verify each requirement has a corresponding task bead. List any gaps.

**2. Placeholder scan:** Read each task bead via `bd show <task-id> --json` and check for red flags — any of the patterns from the "No Placeholders" section above. Fix them by updating the bead.

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
- **REQUIRED SUB-SKILL:** Use superpowers:executing-plans
- Execution driven by `bd ready --parent <root-id> --json`

**If Subagent-Driven chosen:**
- **REQUIRED SUB-SKILL:** Use superpowers:subagent-driven-development
- Fresh subagent per task + two-stage review
