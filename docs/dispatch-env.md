# Dispatch environment — superpowers-beads plugin

Static facts for dispatched implementers and reviewers. Task-specific facts live in the bead.

## Repo layout

- `skills/<name>/SKILL.md` — one skill each; the title line carries the word budget.
- `agents/*.md` — subagent charters shipped as system prompts.
- `hooks/` — PreToolUse/PostToolUse guards; `hooks/hooks.json` wires them.
- `tests/claude-code/*.sh` — deterministic hook and script tests; `tests/skill-evals/<skill>/` — pressure scenarios with a `CREATION-LOG.md`.
- `docs/beads/` — immutable spec summaries; `docs/CONTEXT.md` — domain glossary.
- `FORK-CHANGELOG.md` — release history; every entry states the net `skills/` word delta.

## bd invocation

Run `bd` from the repo root only (`/Users/rustam/Projects/superpowers`); the worktree shares the same `.bd/bd.db`. Executors `export BD_ACTOR=executor` before any bd write. Scratch files go in `.bd/.scratch/` at the repo root.

## Test commands

Deterministic suite (run from the worktree root):

```
cd tests/claude-code && for t in test-completion-gate test-gate-lint test-fail-streak-guard test-review-package; do ./$t.sh; done
```

The live runner `tests/claude-code/run-skill-tests.sh` invokes the Claude CLI and takes minutes per test; it is the controller's gate, never an implementer's.

## Worktree rules

Edit only inside the worktree named in your prompt. Never `git stash`. Never push. Commit on the worktree branch with a message stating what changed and why.
