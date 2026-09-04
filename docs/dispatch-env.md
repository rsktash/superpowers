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

The deterministic suite needs the `go` toolchain on `PATH`, `STRUCTURAL_INDEX_TYPESCRIPT_PACKAGE` exported to a directory holding `lib/typescript.js`, for example: `export STRUCTURAL_INDEX_TYPESCRIPT_PACKAGE=/Users/rustam/Projects/zanjir/server/node_modules/typescript`, `STRUCTURAL_INDEX_KOTLIN_TOOLCHAIN` exported to a directory holding `node_modules/tree-sitter` (the tree-sitter 0.21.1 binding) and `node_modules/tree-sitter-kotlin` (the 0.3.8 grammar), for example: `export STRUCTURAL_INDEX_KOTLIN_TOOLCHAIN=/Users/rustam/Projects/superpowers/.bd/.scratch/index-trial-kotlin/npm-tree-sitter` — an `npm install --prefix <dir> tree-sitter@0.21.1 tree-sitter-kotlin@0.3.8` produces exactly that shape; without the variable `test-structural-index-kotlin.sh` prints one `[SKIP]` line naming it and exits 0 — and `STRUCTURAL_INDEX_SWIFT_TOOLCHAIN` exported to a directory holding `node_modules/tree-sitter` (the tree-sitter 0.22.1 binding) and `node_modules/tree-sitter-swift` (the 0.7.1 grammar), for example: `export STRUCTURAL_INDEX_SWIFT_TOOLCHAIN=/Users/rustam/Projects/superpowers/.bd/.scratch/index-trial-swift/npm-tree-sitter` — an `npm install --prefix <dir> tree-sitter@0.22.1 tree-sitter-swift@0.7.1` produces exactly that shape. Without the variable `test-structural-index-swift.sh` prints one `[SKIP]` line naming it and exits 0.

```
cd tests/claude-code && for t in test-completion-gate test-gate-lint test-fail-streak-guard test-review-package test-structural-index test-structural-index-kotlin test-structural-index-swift test-map-check; do ./$t.sh; done
```

The live runner `tests/claude-code/run-skill-tests.sh` invokes the Claude CLI and takes minutes per test; it is the controller's gate, never an implementer's.

## Structural index

Run the TypeScript and Go structural index from the plugin worktree:

```
scripts/structural-index symbol <name> --repo <root> [--regen]
scripts/structural-index callers <name> --repo <root> [--regen]
scripts/structural-index tests <name> --repo <root> [--regen]
scripts/structural-index languages --repo <root>
```

`symbol` prints one tab-separated `<file>\t<start>-<end>\t<hash>` line per definition. `callers` and `tests` print one `<file>:<line>` reference per line; `tests` limits those references to test files — `*.test.*`, `*.spec.*`, and `__tests__` paths for TypeScript, `*_test.go` files for Go. Paths are relative to `<root>`, and the hash is the first 12 hexadecimal characters of SHA-256 over the definition span's source bytes. An unknown symbol exits 1, leaves stdout empty, and writes `symbol not found: <name>` as one stderr line.

`languages` prints one line per language the target repository tracks: `<id>`, its tracked file count, and its backend, tab-separated, ordered typescript, go, kotlin, swift, python, other — backend `compiler` for typescript, go, kotlin, and swift, `none` for python and other. A name whose definitions live only in `none` languages still gets `callers` and `tests` answers, produced by word-boundary text search and marked by one stderr line, quoted exactly: `structural-index: <query> <name> answered by text search over <n> files in <ids>`. A `symbol` query in the same position prints `symbol not found: <name>` followed by `structural-index: no definition backend for <ids>; not searched` — a text answer's grade, never a missing symbol.

Each language is generated only when the target repository tracks files of that language: `<root>/.bd/index/typescript.json` for `*.ts`/`*.tsx`, `<root>/.bd/index/go.json` for `*.go`, `<root>/.bd/index/kotlin.json` for `*.kt`/`*.kts`, `<root>/.bd/index/swift.json` for `*.swift`, plus `<root>/.bd/index/metadata.json`. The metadata records the target repository's HEAD and the indexed languages. An absent index or changed HEAD regenerates and reports per-language wall time on stderr; reuse on the same HEAD is silent, and `--regen` forces regeneration. The TypeScript package is resolved from a tracked package directory inside the target repository, then from `STRUCTURAL_INDEX_TYPESCRIPT_PACKAGE`; when neither holds one, the CLI exits 2 and names the variable. The Go backend runs Go's own go/parser + go/types through the `go` toolchain on PATH. The Kotlin backend runs tree-sitter (0.21.1) with the tree-sitter-kotlin (0.3.8) grammar, resolved the same way: `node_modules/tree-sitter` and `node_modules/tree-sitter-kotlin` under a tracked package directory inside the target repository first, then the `STRUCTURAL_INDEX_KOTLIN_TOOLCHAIN` directory; when neither holds them, the CLI exits 2 and names the variable. The Swift backend runs tree-sitter (0.22.1) with the tree-sitter-swift (0.7.1) grammar, resolved the same way: `node_modules/tree-sitter` and `node_modules/tree-sitter-swift` under a tracked package directory inside the target repository first, then the `STRUCTURAL_INDEX_SWIFT_TOOLCHAIN` directory; when neither holds them, the CLI exits 2 and names the variable.

## map-check

Run the exploration-map freshness check from the plugin worktree:

```
scripts/map-check <epic-id> <task-id> --repo <root>
```

`<task-id>` resolves to a task number: its trailing `.N` segment or a bare number. The script reads `<root>/docs/beads/<epic-id>.map.md`, selects the rows whose Task cell is that number plus seam rows (`N→M` or `M→N`), compares each plan-time hash with `scripts/structural-index symbol` at HEAD, and prints exactly one line per selected row, preceded by one header line per language the index does not cover. Freshness is computed, never written. The Hash cell accepts exactly two forms: 12 hex characters (the plan-time symbol hash) or the literal token `new` (a symbol this plan creates); any other cell — a `file:`-prefixed one included — exits 2 with one stderr line naming the offending row. The seven line shapes:

- `fresh <symbol> <file>:<start>-<end>` — the current hash equals the plan-time hash.
- `STALE <symbol> <file>:<start>-<end> (<old> → <new>, changed by <sha>)` — a different hash resolves; `<sha>` is the newest commit touching the current span (`git log -L`).
- `CHECK <symbol> <file>:<start>-<end> (calls <stale-symbol>)` — a fresh row whose current span references a symbol named by a STALE row; one hop only.
- `GONE <symbol> <file> (no definition at HEAD; removed or renamed, file last changed by <sha>)` — the index reports no definition in the row's file.
- `NEW <symbol> <file> (not yet created)` or `NEW <symbol> <file>:<start>-<end> (created since planning)` — a `new` row before and after the symbol exists; no hash comparison.
- `seam <N→M> <note>` — the seam row's Note cell.
- `unindexed <id> <n> files (callers and tests by text search; no definition rows)` — one header line per language whose backend is `none` and whose tracked count is above zero (`other` excluded), in roster order, printed before any row line.

Rows of other tasks print nothing. Any mix of these lines exits 0. A missing or unparseable map file exits 2 with one stderr line naming the path. A `structural-index` failure or an invalid argument exits 1 with one stderr line — an error at dispatch, never an absent map: the coordinator stops on it instead of filling the Exploration Map slot with "no map file".

## Worktree rules

Edit only inside the worktree named in your prompt. Never `git stash`. Never push. Commit on the worktree branch with a message stating what changed and why.
