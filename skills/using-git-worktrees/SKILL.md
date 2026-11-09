---
name: using-git-worktrees
description: Use when starting feature work that needs isolation from current workspace or before executing implementation plans - creates isolated git worktrees with smart directory selection and safety verification
---

# Using Git Worktrees — budget 1100 words

## Overview

Git worktrees create isolated workspaces sharing the same repository, allowing work on multiple branches simultaneously without switching.

**Core principle:** Systematic directory selection + safety verification = reliable isolation.

**Announce at start:** "I'm using the using-git-worktrees skill to set up an isolated workspace."

## Directory Selection Process

Follow this priority order:

### 1. Check Existing Directories

```bash
# Check in priority order
ls -d .worktrees 2>/dev/null     # Preferred (hidden)
ls -d worktrees 2>/dev/null      # Alternative
```

**If found:** Use that directory. If both exist, `.worktrees` wins.

### 2. Check CLAUDE.md

```bash
grep -i "worktree.*director" CLAUDE.md 2>/dev/null
```

**If preference specified:** Use it without asking.

### 3. Ask User

If no directory exists and no CLAUDE.md preference:

```
No worktree directory found. Where should I create worktrees?

1. .worktrees/ (project-local, hidden)
2. ~/.config/superpowers/worktrees/<project-name>/ (global location)

Which would you prefer?
```

## Safety Verification

### For Project-Local Directories (.worktrees or worktrees)

**MUST verify directory is ignored before creating worktree:**

```bash
# Check if directory is ignored (respects local, global, and system gitignore)
git check-ignore -q .worktrees 2>/dev/null || git check-ignore -q worktrees 2>/dev/null
```

**If NOT ignored:**

1. Add appropriate line to .gitignore
2. Commit the change
3. Proceed with worktree creation

### For Global Directory (~/.config/superpowers/worktrees)

No .gitignore verification needed - outside project entirely.

## Creation Steps

### 1. Detect Project Name

```bash
project=$(basename "$(git rev-parse --show-toplevel)")
```

### 2. Create Worktree

```bash
# Determine full path
case $LOCATION in
  .worktrees|worktrees)
    path="$LOCATION/$BRANCH_NAME"
    ;;
  ~/.config/superpowers/worktrees/*)
    path="~/.config/superpowers/worktrees/$project/$BRANCH_NAME"
    ;;
esac

# Create worktree with new branch
git worktree add "$path" -b "$BRANCH_NAME"
cd "$path"
```

### 3. Run Project Setup

Auto-detect and run appropriate setup:

```bash
# Node.js
if [ -f package.json ]; then npm install; fi

# Rust
if [ -f Cargo.toml ]; then cargo build; fi

# Python
if [ -f requirements.txt ]; then pip install -r requirements.txt; fi
if [ -f pyproject.toml ]; then poetry install; fi

# Go
if [ -f go.mod ]; then go mod download; fi
```

### 4. Verify Clean Baseline

Run the full suite here, in your own shell. **Never compose the command from memory:** copy it
from the project's runbook (`docs/dispatch-env.md` or equivalent).

Skip only on a green run in THIS worktree at THIS commit, this session.
A CI receipt never qualifies.

**If tests fail:** Report failures, ask whether to proceed or investigate.

**If tests pass:** Report ready.

### 5. Report Location

```
Worktree ready at <full-path>
Tests passing (<N> tests, 0 failures)
Ready to implement <feature-name>
```

## Red Flags

**Never:**
- Create worktree without verifying it's ignored (project-local)
- Skip baseline test verification
- Proceed with failing tests without asking
- Assume directory location when ambiguous
- Skip CLAUDE.md check

## Finishing: Merge Back and Clean Up

Once implementation is complete in the worktree, close it out and merge back.

### 1. Full Test Suite

Run the full suite in the worktree, in your own shell, with commands copied from the project's
runbook (`docs/dispatch-env.md` or equivalent) — never composed from memory. Record exact commands, exit codes, and output tails. Warm-environment projects
(emulator/device gates) use their peer gate-runner session instead.

**If tests fail:** stop, fix, re-run. Don't proceed to step 2 until green.

### 2. Close the Root Epic (If Not Already Closed)

```bash
bd show <root-id>
```

Closing the last child task may already have auto-closed the epic — if `bd show` reports it `closed`, skip this step. If it's still `open` (and all children are closed), close it explicitly:

```bash
bd close <root-id> --reason "All tasks complete, merged to <base>"
```

### 3. Merge to Base Locally

```bash
git checkout <base>
git pull            # if <base> can move from elsewhere — keep it current before merging
git merge <feature-branch>

# Re-run the suite on the merged result — the worktree run above doesn't cover the merge itself
<the suite command from the project runbook — see Finishing step 1>
```

### 4. Remove the Worktrees

```bash
git worktree remove <path>
git branch -d <feature-branch>
```

Then sweep every worktree the merged branch spawned: its task worktrees (branch `task/<lane>-*`) and review worktrees (`.worktrees/review-*`, detached). Each whose branch or HEAD is merged into `<base>` goes: `git worktree remove`, then `git branch -d` for a branch. `--force` only when the sole untracked content is OS junk (`.DS_Store`); `-d` refuses unmerged work. Report each worktree kept and why: branch unmerged, or tracked or untracked changes beyond OS junk.

### 5. Never Open a PR

Work merges back to `<base>` locally. Do not `git push` the feature branch and do not run `gh pr create`.

## Integration

**Called by:**
- **subagent-driven-development** - REQUIRED before executing any tasks
- **hybrid-execution** - REQUIRED before executing any tasks
- Any skill needing isolated workspace

