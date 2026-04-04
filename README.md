# Superpowers-Beads

A fork of [Superpowers](https://github.com/obra/superpowers) that replaces markdown-based spec/plan storage with [Beads](https://github.com/gastownhall/beads) as the single source of truth.

## What's Different

The original Superpowers stores specs and plans as markdown files in `docs/superpowers/specs/` and `docs/superpowers/plans/`. This fork replaces that with Beads — a distributed graph issue tracker built for AI agents.

### Key changes

- **Specs are beads.** The brainstorming skill creates a root epic bead (`bd create -t epic`) instead of writing a markdown file. The full spec lives in the bead body.
- **Plans are bead trees.** The writing-plans skill creates child beads for each task, linked with dependency graphs (`bd dep add`). No plan markdown file.
- **Execution is bead-driven.** The executing-plans skill uses `bd ready --parent` / `bd update --claim` / `bd close --reason` instead of parsing checkboxes in a file.
- **Progress is live.** Track everything in [beads-ui](https://github.com/mantoni/beads-ui) in real time.
- **Git stays searchable.** A lightweight summary file is committed to `docs/beads/` for each feature, and all commit messages include bead IDs.

### What's unchanged

9 skills are identical to the original Superpowers: TDD, systematic-debugging, git-worktrees, finishing-a-development-branch, writing-skills, requesting-code-review, receiving-code-review, verification-before-completion, dispatching-parallel-agents.

### Skills modified

| Skill | What changed |
|-------|-------------|
| brainstorming | Stores specs as epic beads, writes summary file to `docs/beads/` |
| writing-plans | Creates task beads with `bd dep add` dependencies instead of markdown plan |
| executing-plans | Drives work via `bd ready` / `bd update --claim` / `bd close --reason` loop |
| subagent-driven-development | Same dispatch model, beads for persistent tracking |
| finishing-a-development-branch | Closes root epic bead, enforces bead ID in commits and PRs |
| using-superpowers | Bootstrap mentions beads storage model |

## Important: Uninstall Original Superpowers First

This plugin replaces the original Superpowers. Having both installed causes duplicate skills with unpredictable behavior. Uninstall the original before installing this one:

```bash
/plugin uninstall superpowers
```

If both are installed, a warning will appear at the start of every session.

## Requirements

- [Beads CLI](https://github.com/gastownhall/beads) (`bd`) must be installed
- Initialize beads in your project: `bd init`
- Optional: [beads-ui](https://github.com/mantoni/beads-ui) for a web dashboard

## Installation

### Claude Code

```bash
/plugin install superpowers-beads
```

### From source

```bash
git clone https://github.com/rsktash/superpowers.git
cd superpowers
# Follow Claude Code plugin installation docs
```

## The Workflow

1. **brainstorming** — Refines ideas, creates spec as an epic bead, commits summary to `docs/beads/`
2. **writing-plans** — Decomposes spec into task beads with dependency ordering
3. **executing-plans** (recommended) — Executes tasks via `bd ready` loop with step-level progress comments
4. **finishing-a-development-branch** — Verifies all tasks closed, closes epic, merges/PRs with bead ID

### Summary file naming

```
docs/beads/{date}-{incr}-{bd-id}-{short-title}.md
```

Example: `docs/beads/2026-04-04-001-bd-a3f8-widget-caching-layer.md`

### Interruption recovery

If a session is interrupted, the next session recovers by:
1. Finding the root bead ID from `docs/beads/*-bd-*.md`
2. Querying `bd show <root-id> --json` for all task statuses
3. Reading step-progress comments on in-progress tasks
4. Resuming from where it left off

## Credits

This is a fork of [Superpowers](https://github.com/obra/superpowers) by [Jesse Vincent](https://blog.fsck.com). The original project and community:

- **Original repo**: https://github.com/obra/superpowers
- **Discord**: [Join](https://discord.gg/Jd8Vphy9jq) the Superpowers community
- **Blog post**: [Superpowers for Claude Code](https://blog.fsck.com/2025/10/09/superpowers/)

## License

MIT License — see LICENSE file for details.
