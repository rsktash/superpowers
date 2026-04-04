# Superpowers-Beads: Beads-Native Spec/Plan Lifecycle

Replace superpowers' markdown-based spec/plan storage with beads as the single source of truth. Modify skills in this forked repo to read and write via `bd` CLI.

## Motivation

Superpowers stores specs and plans as markdown files in `docs/superpowers/specs/` and `docs/superpowers/plans/`. This works but creates split-brain tracking — status lives in checkbox syntax inside files, progress isn't queryable, and there's no dependency graph between tasks. Agents parse markdown to figure out what to do next.

Beads (`bd`) is a distributed graph issue tracker purpose-built for AI agents. It provides structured CRUD, hierarchical task decomposition, dependency-aware scheduling (`bd ready`), and atomic task claiming. It uses Dolt (version-controlled SQL) as its backend.

By making beads the single source of truth for specs, plans, and task execution, agents get structured workflows instead of text parsing, and users get real-time visibility via beads-ui.

## Scope

**6 skills modified** (in place, in this repo):
1. `skills/using-superpowers/SKILL.md` — bootstrap references updated
2. `skills/brainstorming/SKILL.md` — spec storage via `bd create`
3. `skills/writing-plans/SKILL.md` — plan task creation via `bd create` + `bd dep add`; execution handoff recommends `executing-plans` as default (not subagent-driven-development)
4. `skills/executing-plans/SKILL.md` — execution loop via `bd ready --parent` / `bd update --claim` / `bd close --reason`
5. `skills/subagent-driven-development/SKILL.md` — same dispatch model, beads for tracking (available but not the default recommendation)
6. `skills/finishing-a-development-branch/SKILL.md` — enforce bead ID in commit messages, close root epic after merge

**8 skills unchanged** (no spec/plan storage, no modifications needed):
- dispatching-parallel-agents, receiving-code-review, requesting-code-review, systematic-debugging, test-driven-development, using-git-worktrees, verification-before-completion, writing-skills

## Design Decisions

### Beads is the single source of truth

No markdown files for specs or plans. Spec content lives in the top-level bead body. Plan task content lives in child bead bodies. Progress is tracked via bead status (`open` → `in_progress` → `closed`). The agent queries beads, not the filesystem, for what to do next.

Summary markdown files committed to git are **immutable snapshots** — written once at spec creation, never updated. They exist solely for `git log` searchability. If the spec evolves in beads, the summary file is not updated. The bead is authoritative; the summary is a historical breadcrumb.

### One bead tree per feature

A feature maps to a single bead hierarchy. The root bead is created with `-t epic` to mark it as a grouping container, not an executable task.

Task beads are linked to the root via `related` (not `blocks`), which groups them under the epic without creating a completion dependency that would prevent `bd ready` from surfacing them. Sequential ordering between tasks uses `blocks` dependencies.

```
bd-a3f8                           # Root epic: the spec/feature
  type: epic
  body: full spec markdown
  status: open → closed (when all tasks done and branch merged)

bd-a3f8.1                         # Child: plan task 1
  body: task markdown (file list, steps with checkboxes, code, verification)
  rel: related bd-a3f8
  dep: none (first task — immediately ready)

bd-a3f8.2                         # Child: plan task 2
  body: task markdown
  rel: related bd-a3f8
  dep: blocked_by bd-a3f8.1

bd-a3f8.3                         # Child: plan task 3
  body: task markdown
  rel: related bd-a3f8
  dep: blocked_by bd-a3f8.2
```

Steps within tasks remain as structured markdown in the task body (checkboxes, code blocks, verification commands). They are not decomposed into sub-beads. Rationale: steps are 2-5 minute actions — individual bead tracking adds overhead without value. The meaningful unit of progress is "task done."

### Root bead lifecycle

The root bead tracks the feature's overall status:

- **Created** by brainstorming skill → status `open`
- **Stays `open`** through planning and execution (it is a grouping epic, not a task to claim)
- **Closed** by finishing-a-development-branch skill after all task beads are closed and the branch is merged/PR'd → `bd close <root-id> --reason "All tasks complete, merged"`
- If the feature is abandoned, the user closes it manually: `bd close <root-id> --reason "Abandoned"`

No skill ever claims (`--claim`) the root bead. Only task beads are claimed and executed.

### Summary markdown files for git searchability

Bead content lives in Dolt, not git. To preserve `git log` searchability, a lightweight summary file is committed to git when a spec is created:

**Location:** `docs/beads/{date}-{incr}-{bd-id}-{short-title}.md`

**Naming convention:**
- `{date}`: `YYYY-MM-DD` format
- `{incr}`: three-digit zero-padded daily counter (`001`, `002`, `003`)
- `{bd-id}`: the root bead ID (e.g., `bd-a3f8`)
- `{short-title}`: slugified feature name

**Example:** `docs/beads/2026-04-04-001-bd-a3f8-widget-caching-layer.md`

**Contents:** A one-paragraph summary, key design decisions, and acceptance criteria — enough to understand the "why" from git history without needing to query beads.

**Immutability:** Written once at spec creation, never updated. The bead is the source of truth; the file is a historical breadcrumb for git search.

The daily counter is determined by globbing `docs/beads/{today's date}-*.md` and incrementing from the highest found.

Additionally, all code commit messages include the bead ID: `feat: implement cache invalidation (bd-a3f8.2)`. This is enforced by the modified `finishing-a-development-branch` skill.

## Skill Behavior Changes

### brainstorming/SKILL.md

Same conversational flow (explore context → clarifying questions → propose approaches → present design → user approval). Changes to storage operations:

- After user approves design, creates a root epic bead:
  ```bash
  echo '<spec markdown>' | bd create "Feature: <title>" -t epic -p 1 --stdin --json
  ```
- Parses JSON output to extract the bead ID — this anchors the entire feature lifecycle
- Determines next daily increment by globbing `docs/beads/YYYY-MM-DD-*.md`
- Writes summary file to `docs/beads/{date}-{incr}-{bd-id}-{short-title}.md`
- Commits summary file to git
- Spec self-review reads back via `bd show <id> --json` instead of reading a file
- Passes the bead ID (not a file path) to writing-plans

### writing-plans/SKILL.md

Same decomposition process (file map → bite-sized tasks → TDD steps → self-review). Changes:

- Receives parent bead ID from brainstorming
- For each plan task, creates a bead and links it to the epic via `related`:
  ```bash
  echo '<task markdown>' | bd create "Task N: <name>" -p 1 --stdin --json
  bd dep add <new-task-id> <root-bead-id> --type related
  ```
- Sets sequential `blocks` dependencies between tasks:
  ```bash
  bd dep add <task-2-id> <task-1-id>
  ```
- Note: The exact mechanism for creating hierarchical IDs (`bd-a3f8.1`) vs flat IDs needs verification via `bd create --help` during implementation. The dependency graph works regardless of ID scheme.
- Parses JSON output from `bd create --json` to reliably extract new bead IDs
- Self-review reads tasks via `bd show <id> --json` instead of scanning a markdown file
- Execution handoff passes the root bead ID
- Recommends `executing-plans` (inline execution) as the default. Subagent-driven-development is available as an alternative but not the primary recommendation.

### executing-plans/SKILL.md

Replaces the "read plan file, parse checkboxes" loop with beads-native execution:

1. `bd ready --parent <root-id> --json` — get next unblocked task scoped to this feature
2. `bd show <id> --json` — read task content (steps, code, verification commands)
3. `bd update <id> --claim` — mark in_progress (atomic assignment)
4. Execute steps from task body
5. After each step completes, post progress: `bd comments add <id> "Step N complete"`
6. `bd close <id> --reason "Done"` — mark complete, unblocks dependents
7. Repeat until `bd ready --parent <root-id> --json` returns empty

No TodoWrite for tracking — beads is the tracker. Progress visible in beads-ui in real time. Step-level progress is persisted via comments, enabling recovery if execution is interrupted mid-task.

### subagent-driven-development/SKILL.md

Same dispatch model (fresh subagent per task + two-stage review). Changes:

- Controller gets task list from `bd ready --parent <root-id> --json` / `bd show <id> --json` instead of parsing a plan file
- Passes task body content to implementer subagent (subagent never queries beads directly)
- On completion, controller runs `bd close <id> --reason "Done"` instead of updating TodoWrite
- Review status recorded as comments: `bd comments add <id> "Spec review: PASS"` / `bd comments add <id> "Code quality review: PASS"`

### finishing-a-development-branch/SKILL.md

Added responsibilities:

- Enforces bead ID in all commit messages: `feat: <feature name> (<root-bead-id>)`
- After merge/PR, closes the root epic bead: `bd close <root-id> --reason "All tasks complete, merged"`

### using-superpowers/SKILL.md

Updated bootstrap to reflect that spec/plan operations use beads. Skill discovery and invocation logic unchanged.

## `bd` Detection and Error Handling

Every beads-native skill starts with:

```bash
which bd && bd --version
```

**`bd` not found:** Skill stops. Prints install instructions pointing to https://github.com/gastownhall/beads. No fallback to markdown — this plugin is beads-only.

**No beads database:** Skill checks that `bd` can connect to a database (local `.beads/`, `BEADS_DIR`, or remote server). If not, skill prompts user to confirm before running `bd init`. The skills do not assume or force a specific beads mode — they work with whatever `bd` is configured to talk to (local embedded, local server, remote via SSH tunnel).

**`bd` command fails mid-workflow:** Skill stops and surfaces the error to the user.

### Interruption Recovery

If a workflow is interrupted (session ends, crash, network error), the agent recovers by querying beads state on the next session:

1. **Find the root bead ID:** Glob `docs/beads/*-bd-*.md` — the bead ID is in the filename.
2. **Spec created but no tasks yet:** `bd show <root-id> --json` shows the epic with no children. Writing-plans picks up from here.
3. **Some tasks created, some deps missing:** `bd ready --parent <root-id> --json` still works — tasks without blockers show as ready. Agent can add missing deps before continuing.
4. **Task claimed but not completed:** `bd show <task-id> --json` shows `in_progress`. Agent reads comments to see which steps completed. Resumes from the next uncompleted step.
5. **Summary file not committed:** Agent checks for the file, creates it if missing.

The key principle: beads state is always queryable. The agent never needs to reconstruct state from memory or markdown files.

## Assumptions

- **Single agent at a time.** One agent works on a feature at a time. Embedded mode is sufficient. The design is concurrent-friendly (atomic claiming, scoped queries, step comments) but concurrent multi-agent execution is not tested or promised.
- **Hard cutover.** Existing markdown specs/plans in `docs/superpowers/specs/` and `docs/superpowers/plans/` are not migrated. They remain as historical artifacts. New work uses beads.
- **No assumption about beads mode.** Skills work with whatever `bd` is configured to use — local embedded, local server, remote server via SSH tunnel, shared DB across projects. The skills just call `bd` and let it handle connectivity.

## Acceptance Criteria

### Happy path
1. `brainstorming` skill creates a root epic bead (`-t epic`) with spec content and a summary markdown file
2. `writing-plans` skill creates task beads with `related` links to root and `blocks` deps between sequential tasks
3. `executing-plans` skill drives work via `bd ready --parent <id> --json` / `bd update --claim` / `bd close --reason` loop
4. `subagent-driven-development` skill dispatches per-task subagents using bead content from `bd show --json`
5. All code commits include bead IDs in commit messages, enforced by `finishing-a-development-branch`
6. `finishing-a-development-branch` closes the root epic bead after merge/PR
7. Summary files follow `docs/beads/{date}-{incr}-{bd-id}-{short-title}.md` naming and are immutable
8. The 8 unchanged skills work as before
9. Progress is visible in beads-ui in real time during execution
10. `writing-plans` recommends `executing-plans` as the default execution method

### Edge cases
11. Skills detect missing `bd` and print install instructions without crashing
12. Skills detect missing beads database (no `.beads/`, no `BEADS_DIR`, no remote) and prompt for `bd init`
13. `bd ready --parent <id>` correctly scopes to one feature when multiple features are in progress
14. Interrupted execution resumes correctly: agent queries beads state, reads step-progress comments, continues from last completed step
15. Root epic bead is never claimed — only task beads are claimed and executed
16. All `bd` commands use `--json` for machine-readable output parsing
