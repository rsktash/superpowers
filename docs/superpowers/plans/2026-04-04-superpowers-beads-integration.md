# Superpowers-Beads Integration Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans (recommended) or superpowers:subagent-driven-development to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Modify 6 skills and 3 supporting files in this repo so that all spec/plan CRUD operations use beads (`bd` CLI) instead of markdown files.

**Architecture:** Each skill is a markdown instruction document that shapes agent behavior. The changes replace file-write instructions with `bd` CLI commands, file-read instructions with `bd show --json`, and checkpoint-style tracking with `bd ready --parent` / `bd update --claim` / `bd close --reason`. No code is compiled — these are behavioral instructions.

**Tech Stack:** Markdown (skill files), beads CLI (`bd`), Dolt (beads backend)

**Spec:** `docs/superpowers/specs/2026-04-04-superpowers-beads-integration-design.md`

---

### Task 1: Modify brainstorming/SKILL.md

**Files:**
- Modify: `skills/brainstorming/SKILL.md`

- [ ] **Step 1: Read the current skill file**

Read `skills/brainstorming/SKILL.md` and identify all sections that reference markdown file output. Key sections to change:
- Checklist item 6: "Write design doc — save to `docs/superpowers/specs/YYYY-MM-DD-<topic>-design.md`"
- "After the Design" → "Documentation" section
- "Spec Self-Review" section
- "User Review Gate" section

- [ ] **Step 2: Add bd detection gate at the top**

After the `<HARD-GATE>` block, add a new section:

```markdown
## Beads Requirement

Before starting, verify beads is available:

\`\`\`bash
which bd && bd --version
\`\`\`

**If `bd` is not found:** Stop. Tell your human partner: "This plugin requires beads (`bd`) to be installed. See https://github.com/gastownhall/beads for installation instructions."

**If no beads database is detected** (no `.beads/` directory and no `BEADS_DIR` environment variable): Ask your human partner: "Beads is installed but not initialized in this project. Run `bd init` to set up?" Wait for confirmation before running `bd init`.
```

- [ ] **Step 3: Update the Checklist**

Replace checklist item 6:

Old:
```
6. **Write design doc** — save to `docs/superpowers/specs/YYYY-MM-DD-<topic>-design.md` and commit
```

New:
```
6. **Create spec bead** — store spec in beads via `bd create` and write summary file to `docs/beads/`
```

- [ ] **Step 4: Replace the "After the Design" → "Documentation" section**

Old content references writing to `docs/superpowers/specs/YYYY-MM-DD-<topic>-design.md` and committing.

Replace with:

```markdown
**Storage:**

- Create a root epic bead with the validated design:
  ```bash
  echo '<spec markdown>' | bd create "Feature: <title>" -t epic -p 1 --stdin --json
  ```
- Parse the JSON output to extract the bead ID (e.g., `bd-a3f8`). This ID anchors the entire feature lifecycle.
- Write a summary file for git searchability:
  - Glob `docs/beads/YYYY-MM-DD-*.md` (today's date) to find the next daily increment
  - Write to `docs/beads/{date}-{incr}-{bd-id}-{short-title}.md`
    - `{date}`: today in `YYYY-MM-DD` format
    - `{incr}`: three-digit zero-padded counter (`001`, `002`, `003`)
    - `{bd-id}`: the root bead ID
    - `{short-title}`: slugified feature name
  - Contents: one-paragraph summary, key design decisions, acceptance criteria
  - This file is an **immutable snapshot** — written once, never updated. The bead is the source of truth.
- Commit the summary file to git
```

- [ ] **Step 5: Update "Spec Self-Review" section**

Replace file-reading instructions. Change:
- "After writing the spec document, look at it with fresh eyes" → "After creating the spec bead, look at it with fresh eyes"
- Add: read the spec back via `bd show <bead-id> --json` for the review instead of reading a file

- [ ] **Step 6: Update "User Review Gate" section**

Replace the existing gate message:

Old:
```
> "Spec written and committed to `<path>`. Please review it and let me know if you want to make any changes before we start writing out the implementation plan."
```

New:
```
> "Spec stored in beads as `<bead-id>` and summary committed to `<summary-file-path>`. Run `bd show <bead-id>` to review the full spec. Let me know if you want to make any changes before we start writing the implementation plan."
```

- [ ] **Step 7: Update "Implementation" section**

Add that the bead ID (not a file path) is passed to writing-plans:

```markdown
- Invoke the writing-plans skill to create a detailed implementation plan
- Pass the root bead ID to writing-plans (not a file path)
- Do NOT invoke any other skill. writing-plans is the next step.
```

- [ ] **Step 8: Verify the edit**

Read back `skills/brainstorming/SKILL.md` and verify:
- No references to `docs/superpowers/specs/` remain
- `bd create` command uses `--json` flag
- `-t epic` is included in the create command
- Summary file naming convention matches spec: `{date}-{incr}-{bd-id}-{short-title}.md`
- Bead ID is passed to writing-plans

- [ ] **Step 9: Commit**

```bash
git add skills/brainstorming/SKILL.md
git commit -m "feat: brainstorming skill stores specs in beads instead of markdown files"
```

---

### Task 2: Modify brainstorming/spec-document-reviewer-prompt.md

**Files:**
- Modify: `skills/brainstorming/spec-document-reviewer-prompt.md`

- [ ] **Step 1: Update the reviewer prompt to use bead ID instead of file path**

Change the dispatch instructions:

Old:
```
**Dispatch after:** Spec document is written to docs/superpowers/specs/
```

New:
```
**Dispatch after:** Spec bead is created via `bd create`
```

And in the prompt template, change:

Old:
```
    **Spec to review:** [SPEC_FILE_PATH]
```

New:
```
    **Spec to review:** Read the spec content via `bd show [BEAD_ID] --json`
```

- [ ] **Step 2: Verify and commit**

Read back the file. Verify no references to `docs/superpowers/specs/` remain.

```bash
git add skills/brainstorming/spec-document-reviewer-prompt.md
git commit -m "feat: spec reviewer reads from beads instead of markdown file"
```

---

### Task 3: Modify writing-plans/SKILL.md

**Files:**
- Modify: `skills/writing-plans/SKILL.md`

- [ ] **Step 1: Read the current skill file and identify changes**

Key sections to change:
- "Save plans to" line at the top
- Plan Document Header (references plan file)
- Task Structure (may reference plan file)
- Self-Review section
- Execution Handoff section

- [ ] **Step 2: Replace the "Save plans to" instruction**

Old:
```
**Save plans to:** `docs/superpowers/plans/YYYY-MM-DD-<feature-name>.md`
- (User preferences for plan location override this default)
```

New:
```
**Input:** Receives a root bead ID from the brainstorming skill. All tasks are created as beads under this root.

**Storage:** Task beads are created via `bd create --json` and linked to the root via `bd dep add --type relates_to`. Sequential task ordering uses `bd dep add` (default `blocks` type).
```

- [ ] **Step 3: Update the Plan Document Header**

The plan "document" no longer exists as a file. Replace the header template with instructions for how to structure task beads:

Old header references a markdown file with Goal/Architecture/Tech Stack.

New:
```markdown
## Plan Structure in Beads

The root epic bead (created by brainstorming) already contains the spec. Plan tasks are created as child beads:

For each task, create a bead and link it:
\`\`\`bash
echo '<task markdown>' | bd create "Task N: <name>" -p 1 --stdin --json
bd dep add <new-task-id> <root-bead-id> --type relates_to
\`\`\`

For sequential dependencies between tasks:
\`\`\`bash
bd dep add <task-2-id> <task-1-id>
\`\`\`

Parse JSON output from `bd create --json` to extract the new bead ID.

Note: The exact mechanism for hierarchical IDs (`bd-a3f8.1`) vs flat IDs needs to be determined via `bd create --help`. The dependency graph works regardless of ID scheme.
```

- [ ] **Step 4: Update the Task Structure section**

The task structure (files list, steps with checkboxes, code blocks, verification commands) stays the same — this is the content that goes into the bead body. Add a note:

```markdown
The task content below is what gets piped into `bd create --stdin`. The markdown formatting is preserved in the bead body for readability in beads-ui.
```

- [ ] **Step 5: Update the Self-Review section**

Change file-reading to bead-reading:

Old references: "Search your plan for red flags"
New: "Read each task bead via `bd show <task-id> --json` and check for red flags"

Old references: spec coverage by skimming sections
New: "Read the root spec bead via `bd show <root-id> --json` and verify each requirement has a corresponding task bead"

- [ ] **Step 6: Update the Execution Handoff section**

Replace the current handoff (which recommends subagent-driven as default):

```markdown
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
```

- [ ] **Step 7: Verify the edit**

Read back `skills/writing-plans/SKILL.md` and verify:
- No references to `docs/superpowers/plans/` remain
- `bd create` uses `--json` and `--stdin` flags
- `bd dep add` uses `--type relates_to` for root linkage
- Sequential deps use default `blocks` type
- Executing-plans is recommended as default, not subagent-driven
- Root bead ID is passed to execution skill

- [ ] **Step 8: Commit**

```bash
git add skills/writing-plans/SKILL.md
git commit -m "feat: writing-plans skill creates task beads instead of markdown plan file"
```

---

### Task 4: Modify writing-plans/plan-document-reviewer-prompt.md

**Files:**
- Modify: `skills/writing-plans/plan-document-reviewer-prompt.md`

- [ ] **Step 1: Update reviewer prompt to use bead IDs**

Change dispatch instructions:

Old:
```
**Dispatch after:** The complete plan is written.
```

New:
```
**Dispatch after:** All task beads are created and linked under the root epic.
```

In the prompt template, change:

Old:
```
    **Plan to review:** [PLAN_FILE_PATH]
    **Spec for reference:** [SPEC_FILE_PATH]
```

New:
```
    **Plan to review:** List task beads via `bd ready --parent [ROOT_BEAD_ID] --json` and read each via `bd show <id> --json`
    **Spec for reference:** Read spec via `bd show [ROOT_BEAD_ID] --json`
```

- [ ] **Step 2: Verify and commit**

Read back the file. Verify no file path references remain.

```bash
git add skills/writing-plans/plan-document-reviewer-prompt.md
git commit -m "feat: plan reviewer reads from beads instead of markdown file"
```

---

### Task 5: Modify executing-plans/SKILL.md

**Files:**
- Modify: `skills/executing-plans/SKILL.md`

- [ ] **Step 1: Read the current skill file and identify changes**

Key sections to change:
- Step 1: Load and Review Plan (reads plan file)
- Step 2: Execute Tasks (follows checkboxes)
- Step 3: Complete Development (calls finishing-a-development-branch)

- [ ] **Step 2: Add bd detection gate**

Add the same beads requirement section as brainstorming (from Task 1, Step 2). Place it after the overview.

- [ ] **Step 3: Rewrite Step 1: Load and Review Plan**

Old: "Read plan file" → "Review critically" → "Create TodoWrite"

New:
```markdown
### Step 1: Load and Review Tasks

1. Receive the root bead ID from writing-plans
2. Read the spec: `bd show <root-id> --json`
3. List all task beads: `bd ready --parent <root-id> --json`
4. Read each task to understand the full plan: `bd show <task-id> --json`
5. Review critically — identify any questions or concerns
6. If concerns: Raise them with your human partner before starting
7. If no concerns: Proceed to execution
```

- [ ] **Step 4: Rewrite Step 2: Execute Tasks**

Old: "Mark as in_progress in TodoWrite" → "Follow each step" → "Mark as completed"

New:
```markdown
### Step 2: Execute Tasks

Loop until `bd ready --parent <root-id> --json` returns no tasks:

1. `bd ready --parent <root-id> --json` — get next unblocked task
2. `bd show <task-id> --json` — read task content (steps, code, verification commands)
3. `bd update <task-id> --claim` — mark in_progress (atomic assignment)
4. Execute each step from the task body
5. After each step completes, post progress: `bd comments add <task-id> "Step N complete"`
6. `bd close <task-id> --reason "Done"` — mark complete, unblocks dependents
7. Loop back to step 1

Progress is visible in beads-ui in real time. Step-level progress persisted via comments enables recovery if execution is interrupted.
```

- [ ] **Step 5: Add Interruption Recovery section**

Add after Step 2:

```markdown
### Resuming After Interruption

If starting a new session to continue work on an existing feature:

1. Find the root bead ID: glob `docs/beads/*-bd-*.md` — the bead ID is in the filename
2. `bd ready --parent <root-id> --json` — see what tasks remain
3. Check for in-progress tasks: if a task shows `in_progress`, read its comments to see which steps completed
4. Resume from the next uncompleted step
```

- [ ] **Step 6: Update Step 3 and references**

Keep "Complete Development" pointing to finishing-a-development-branch. Add:
- Pass the root bead ID to finishing-a-development-branch so it can close the epic and include the bead ID in commits.

- [ ] **Step 7: Remove TodoWrite references**

Search for any remaining references to TodoWrite or plan files. Remove them.

- [ ] **Step 8: Update Integration section**

Update the "Required workflow skills" section to reflect beads-native flow. Remove reference to writing-plans creating "the plan this skill executes" and replace with "writing-plans creates the task beads this skill executes."

- [ ] **Step 9: Verify the edit**

Read back `skills/executing-plans/SKILL.md` and verify:
- No references to plan files or TodoWrite remain
- All `bd` commands use `--json` where output is parsed
- `bd ready` uses `--parent <root-id>`
- `bd update --claim` (not `bd claim`)
- `bd close --reason` (not bare positional arg)
- `bd comments add` for step progress
- Interruption recovery section exists

- [ ] **Step 10: Commit**

```bash
git add skills/executing-plans/SKILL.md
git commit -m "feat: executing-plans skill uses beads for task tracking and execution"
```

---

### Task 6: Modify subagent-driven-development/SKILL.md and code-quality-reviewer-prompt.md

**Files:**
- Modify: `skills/subagent-driven-development/SKILL.md`
- Modify: `skills/subagent-driven-development/code-quality-reviewer-prompt.md`

- [ ] **Step 1: Read SKILL.md and identify plan-file references**

Key sections:
- "Read plan, extract all tasks with full text" at the top of the process
- Per-task loop: references reading from plan file
- Example Workflow section
- TodoWrite references

- [ ] **Step 2: Update the process start**

Old: "Read plan file once" → "Extract all tasks with full text"

New:
```markdown
[Receive root bead ID from writing-plans]
[Read spec: bd show <root-id> --json]
[List tasks: bd ready --parent <root-id> --json]
[Read each task fully: bd show <task-id> --json for each]
[Create TodoWrite with all tasks for session tracking]
```

Note: TodoWrite is still used here for in-session tracking by the controller. Beads tracks the persistent state; TodoWrite tracks the controller's session progress.

- [ ] **Step 3: Update the per-task dispatch**

Change "Get Task N text and context (already extracted)" to "Read task from beads: `bd show <task-id> --json`"

After completion, change "Mark task complete in TodoWrite" to:
```markdown
[bd close <task-id> --reason "Done — spec and quality review passed"]
[bd comments add <task-id> "Spec review: PASS"]
[bd comments add <task-id> "Code quality review: PASS"]
[Mark task complete in TodoWrite]
```

- [ ] **Step 4: Update the Example Workflow**

Replace file-reading references with beads commands. Change:
```
[Read plan file once: docs/superpowers/plans/feature-plan.md]
```
To:
```
[Read spec: bd show <root-id> --json]
[List tasks: bd ready --parent <root-id> --json]
```

- [ ] **Step 5: Update Red Flags section**

Change: "Make subagent read plan file (provide full text instead)" stays the same in spirit — subagents still receive full text, they never query beads directly.

- [ ] **Step 6: Update code-quality-reviewer-prompt.md**

Change:
```
  PLAN_OR_REQUIREMENTS: Task N from [plan-file]
```
To:
```
  PLAN_OR_REQUIREMENTS: Task N content from bd show <task-bead-id> --json
```

- [ ] **Step 7: Verify both files**

Read back both files. Verify:
- No references to plan markdown files remain
- `bd ready` uses `--parent <root-id>`
- `bd close --reason` used (not bare `bd close`)
- `bd comments add` for review status
- Subagents still receive full text (never query beads directly)

- [ ] **Step 8: Commit**

```bash
git add skills/subagent-driven-development/SKILL.md skills/subagent-driven-development/code-quality-reviewer-prompt.md
git commit -m "feat: subagent-driven-development uses beads for task tracking"
```

---

### Task 7: Modify finishing-a-development-branch/SKILL.md

**Files:**
- Modify: `skills/finishing-a-development-branch/SKILL.md`

- [ ] **Step 1: Add bead ID enforcement to commit messages**

Add a new section after "Step 1: Verify Tests":

```markdown
### Step 1.5: Identify Root Bead

If a root bead ID was passed from the execution skill, use it. Otherwise, find it:

```bash
ls docs/beads/*-bd-*.md
```

Extract the bead ID from the filename (e.g., `2026-04-04-001-bd-a3f8-widget-caching-layer.md` → `bd-a3f8`).

**All commit messages must include the bead ID:** `feat: <feature name> (<bead-id>)`
```

- [ ] **Step 2: Add root epic closure to Options 1 and 2**

In Option 1 (Merge Locally), after the merge and test verification, add:
```bash
# Close the root epic bead
bd close <root-bead-id> --reason "All tasks complete, merged to <base-branch>"
```

In Option 2 (Push and Create PR), after PR creation, add:
```bash
# Close the root epic bead
bd close <root-bead-id> --reason "All tasks complete, PR created"
```

- [ ] **Step 3: Update PR body to include bead ID**

In Option 2, update the `gh pr create` template to include the bead ID:

```bash
gh pr create --title "<title> (<bead-id>)" --body "$(cat <<'EOF'
## Summary
<2-3 bullets of what changed>

**Beads:** `<bead-id>` — run `bd show <bead-id>` for full spec

## Test Plan
- [ ] <verification steps>
EOF
)"
```

- [ ] **Step 4: Verify the edit**

Read back the file. Verify:
- Bead ID discovery step exists
- `bd close --reason` called in Options 1 and 2
- PR template includes bead ID
- Commit message format includes bead ID

- [ ] **Step 5: Commit**

```bash
git add skills/finishing-a-development-branch/SKILL.md
git commit -m "feat: finishing-a-development-branch closes root epic and enforces bead ID in commits"
```

---

### Task 8: Modify using-superpowers/SKILL.md

**Files:**
- Modify: `skills/using-superpowers/SKILL.md`

- [ ] **Step 1: Add beads context to the bootstrap**

This is a minimal change. Add a note in the skill so agents understand the storage model. After the "Skill Priority" section, add:

```markdown
## Spec/Plan Storage

This fork uses beads (`bd` CLI) as the single source of truth for specs, plans, and task progress. The brainstorming, writing-plans, executing-plans, and subagent-driven-development skills all use `bd` commands instead of writing markdown files. Run `bd ready` to see what work is available.
```

- [ ] **Step 2: Verify and commit**

Read back the file. Verify the addition is minimal and doesn't conflict with existing content.

```bash
git add skills/using-superpowers/SKILL.md
git commit -m "feat: using-superpowers bootstrap mentions beads storage model"
```

---

### Task 9: Create docs/beads/ directory

**Files:**
- Create: `docs/beads/.gitkeep`

- [ ] **Step 1: Create the directory**

```bash
mkdir -p docs/beads
touch docs/beads/.gitkeep
```

- [ ] **Step 2: Commit**

```bash
git add docs/beads/.gitkeep
git commit -m "feat: add docs/beads/ directory for summary files"
```
