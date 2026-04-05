---
name: finishing-a-development-branch
description: Use when implementation is complete, all tests pass, and you need to decide how to integrate the work - guides completion of development work by presenting structured options for merge, PR, or cleanup
---

# Finishing a Development Branch

## Overview

Guide completion of development work by presenting clear options and handling chosen workflow.

**Core principle:** Verify tests → Present options → Execute choice → Clean up.

**Announce at start:** "I'm using the finishing-a-development-branch skill to complete this work."

<HARD-GATE>
## Step 0: Verify beads (MUST complete before ANY other action)

Check session context for `<beads-status>`. If `BEADS_AVAILABLE=false` → tell your human partner: "Beads (`bd`) is not available. It should have been auto-installed by the session-start hook. Try restarting Claude Code, or run `$CLAUDE_PLUGIN_ROOT/scripts/install-deps.sh` manually." STOP. Do NOT proceed. Do NOT launch parallel work.

If beads is available but no `.beads/` directory exists → ask user: "Run `bd init` to set up beads in this project?" and WAIT.

Only after beads is available AND initialized → proceed.
</HARD-GATE>

## The Process

### bd Default Behaviors

- **`bd show <id> --json`** works on any bead regardless of status. Always use this to inspect beads — not `bd list` or `bd epic status`, which filter by default.
- **`bd list`** shows **open issues only** by default. Use `--all` to include closed.
- **`bd epic status`** shows **open epics only**. A closed epic will not appear.
- **`bd close`** on the last open child may **auto-close the parent epic**. Check via `bd show` — the epic may already be closed.

### Step 1: Verify Tests

**Before presenting options, verify tests pass:**

```bash
# Run project's test suite
npm test / cargo test / pytest / go test ./...
```

**If tests fail:**
```
Tests failing (<N> failures). Must fix before completing:

[Show failures]

Cannot proceed with merge/PR until tests pass.
```

Stop. Don't proceed to Step 2.

**If tests pass:** Continue to Step 1.5.

### Step 1.5: Identify Root Bead

If a root bead ID was passed from the execution skill, use it. Otherwise, find it:

```bash
ls docs/beads/*.md
```

Extract the bead ID from the filename (the segment after the increment counter, e.g., `2026-04-04-001-bd-a3f8-widget-caching-layer.md` → `bd-a3f8`). Do not assume a specific ID format — use whatever ID appears in the filename.

**All commit messages must include the bead ID:** `feat: <feature name> (<bead-id>)`

### Step 2: Determine Base Branch

```bash
# Try common base branches
git merge-base HEAD main 2>/dev/null || git merge-base HEAD master 2>/dev/null
```

Or ask: "This branch split from main - is that correct?"

### Step 3: Present Options

Present exactly these 4 options:

```
Implementation complete. What would you like to do?

1. Merge back to <base-branch> locally
2. Push and create a Pull Request
3. Keep the branch as-is (I'll handle it later)
4. Discard this work

Which option?
```

**Don't add explanation** - keep options concise.

### Step 4: Execute Choice

#### Option 1: Merge Locally

```bash
# Switch to base branch
git checkout <base-branch>

# Pull latest
git pull

# Merge feature branch
git merge <feature-branch>

# Verify tests on merged result
<test command>

# If tests pass
git branch -d <feature-branch>

# Check epic status — may have been auto-closed when last child was closed
bd show <root-bead-id> --json
# If status is already "closed" → skip bd close (auto-closed is fine)
# If status is "open" → verify all children are "closed", then close it:

# Close the root epic bead (only if still open)
bd close <root-bead-id> --reason "All tasks complete, merged to <base-branch>"
```

Then: Cleanup worktree (Step 5)

#### Option 2: Push and Create PR

```bash
# Push branch
git push -u origin <feature-branch>

# Create PR with bead ID
gh pr create --title "<title> (<bead-id>)" --body "$(cat <<'EOF'
## Summary
<2-3 bullets of what changed>

**Beads:** `<bead-id>` — run `bd show <bead-id>` for full spec

## Test Plan
- [ ] <verification steps>
EOF
)"

# Check epic status — may have been auto-closed when last child was closed
bd show <root-bead-id> --json
# If status is already "closed" → skip bd close (auto-closed is fine)
# If status is "open" → verify all children are "closed", then close it:

# Close the root epic bead (only if still open)
bd close <root-bead-id> --reason "All tasks complete, PR created"
```

Then: Cleanup worktree (Step 5)

#### Option 3: Keep As-Is

Report: "Keeping branch <name>. Worktree preserved at <path>."

**Don't cleanup worktree.**

#### Option 4: Discard

**Confirm first:**
```
This will permanently delete:
- Branch <name>
- All commits: <commit-list>
- Worktree at <path>

Type 'discard' to confirm.
```

Wait for exact confirmation.

If confirmed:
```bash
git checkout <base-branch>
git branch -D <feature-branch>
```

Then: Cleanup worktree (Step 5)

### Step 5: Cleanup Worktree

**For Options 1, 2, 4:**

Check if in worktree:
```bash
git worktree list | grep $(git branch --show-current)
```

If yes:
```bash
git worktree remove <worktree-path>
```

**For Option 3:** Keep worktree.

## Quick Reference

| Option | Merge | Push | Keep Worktree | Cleanup Branch |
|--------|-------|------|---------------|----------------|
| 1. Merge locally | ✓ | - | - | ✓ |
| 2. Create PR | - | ✓ | ✓ | - |
| 3. Keep as-is | - | - | ✓ | - |
| 4. Discard | - | - | - | ✓ (force) |

## Common Mistakes

**Skipping test verification**
- **Problem:** Merge broken code, create failing PR
- **Fix:** Always verify tests before offering options

**Open-ended questions**
- **Problem:** "What should I do next?" → ambiguous
- **Fix:** Present exactly 4 structured options

**Automatic worktree cleanup**
- **Problem:** Remove worktree when might need it (Option 2, 3)
- **Fix:** Only cleanup for Options 1 and 4

**No confirmation for discard**
- **Problem:** Accidentally delete work
- **Fix:** Require typed "discard" confirmation

## Red Flags

**Never:**
- Proceed with failing tests
- Merge without verifying tests on result
- Delete work without confirmation
- Force-push without explicit request

**Always:**
- Verify tests before offering options
- Present exactly 4 options
- Get typed confirmation for Option 4
- Clean up worktree for Options 1 & 4 only

## Integration

**Called by:**
- **subagent-driven-development** (Step 7) - After all tasks complete
- **executing-plans** (Step 5) - After all batches complete

**Pairs with:**
- **using-git-worktrees** - Cleans up worktree created by that skill
