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
cd tests/claude-code && for t in test-completion-gate test-gate-lint test-fail-streak-guard test-review-package test-structural-index; do ./$t.sh; done
```

The live runner `tests/claude-code/run-skill-tests.sh` invokes the Claude CLI and takes minutes per test; it is the controller's gate, never an implementer's.

## Structural index

Run the TypeScript structural index from the plugin worktree:

```
scripts/structural-index symbol <name> --repo <root> [--regen]
scripts/structural-index callers <name> --repo <root> [--regen]
scripts/structural-index tests <name> --repo <root> [--regen]
```

`symbol` prints one tab-separated `<file>\t<start>-<end>\t<hash>` line per definition. `callers` and `tests` print one `<file>:<line>` reference per line; `tests` limits those references to `*.test.*`, `*.spec.*`, and `__tests__` paths. Paths are relative to `<root>`, and the hash is the first 12 hexadecimal characters of SHA-256 over the definition span's source bytes. An unknown symbol exits 1, leaves stdout empty, and writes `symbol not found: <name>` as one stderr line.

The generated files are `<root>/.bd/index/metadata.json` and `<root>/.bd/index/typescript.json`. The metadata records the target repository's HEAD. An absent index or changed HEAD regenerates it and reports wall time on stderr; reuse on the same HEAD is silent, and `--regen` forces regeneration. The TypeScript package is resolved from a tracked package directory inside the target repository.

## Worktree rules

Edit only inside the worktree named in your prompt. Never `git stash`. Never push. Commit on the worktree branch with a message stating what changed and why.
