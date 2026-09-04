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
cd tests/claude-code && for t in test-completion-gate test-gate-lint test-fail-streak-guard test-review-package test-structural-index test-map-check; do ./$t.sh; done
```

The live runner `tests/claude-code/run-skill-tests.sh` invokes the Claude CLI and takes minutes per test; it is the controller's gate, never an implementer's.

## Structural index

Run the TypeScript and Go structural index from the plugin worktree:

```
scripts/structural-index symbol <name> --repo <root> [--regen]
scripts/structural-index callers <name> --repo <root> [--regen]
scripts/structural-index tests <name> --repo <root> [--regen]
```

`symbol` prints one tab-separated `<file>\t<start>-<end>\t<hash>` line per definition. `callers` and `tests` print one `<file>:<line>` reference per line; `tests` limits those references to test files — `*.test.*`, `*.spec.*`, and `__tests__` paths for TypeScript, `*_test.go` files for Go. Paths are relative to `<root>`, and the hash is the first 12 hexadecimal characters of SHA-256 over the definition span's source bytes. An unknown symbol exits 1, leaves stdout empty, and writes `symbol not found: <name>` as one stderr line.

Each language is generated only when the target repository tracks files of that language: `<root>/.bd/index/typescript.json` for `*.ts`/`*.tsx`, `<root>/.bd/index/go.json` for `*.go`, plus `<root>/.bd/index/metadata.json`. The metadata records the target repository's HEAD and the indexed languages. An absent index or changed HEAD regenerates and reports per-language wall time on stderr; reuse on the same HEAD is silent, and `--regen` forces regeneration. The TypeScript package is resolved from a tracked package directory inside the target repository; the Go backend runs Go's own go/parser + go/types through the `go` toolchain on PATH.

## map-check

Run the exploration-map freshness check from the plugin worktree:

```
scripts/map-check <epic-id> <task-id> --repo <root>
```

`<task-id>` resolves to a task number: its trailing `.N` segment or a bare number. The script reads `<root>/docs/beads/<epic-id>.map.md`, selects the rows whose Task cell is that number plus seam rows (`N→M` or `M→N`), compares each plan-time hash with `scripts/structural-index symbol` at HEAD, and prints exactly one line per selected row. Freshness is computed, never written. The Hash cell accepts exactly two forms: 12 hex characters (the plan-time symbol hash) or the literal token `new` (a symbol this plan creates); any other cell — a `file:`-prefixed one included — exits 2 with one stderr line naming the offending row. The six line shapes:

- `fresh <symbol> <file>:<start>-<end>` — the current hash equals the plan-time hash.
- `STALE <symbol> <file>:<start>-<end> (<old> → <new>, changed by <sha>)` — a different hash resolves; `<sha>` is the newest commit touching the current span (`git log -L`).
- `CHECK <symbol> <file>:<start>-<end> (calls <stale-symbol>)` — a fresh row whose current span references a symbol named by a STALE row; one hop only.
- `GONE <symbol> <file> (no definition at HEAD; removed or renamed, file last changed by <sha>)` — the index reports no definition in the row's file.
- `NEW <symbol> <file> (not yet created)` or `NEW <symbol> <file>:<start>-<end> (created since planning)` — a `new` row before and after the symbol exists; no hash comparison.
- `seam <N→M> <note>` — the seam row's Note cell.

Rows of other tasks print nothing. Any mix of these lines exits 0. A missing or unparseable map file exits 2 with one stderr line naming the path.

## Worktree rules

Edit only inside the worktree named in your prompt. Never `git stash`. Never push. Commit on the worktree branch with a message stating what changed and why.
