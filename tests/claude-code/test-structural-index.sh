#!/usr/bin/env bash
# Test: structural-index TypeScript and Go backends
# Verifies exact definitions, semantic caller sets, test-only filtering,
# cache regeneration, unknown-symbol behavior, and source-span hashing
# over both fixtures.
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
INDEX="$REPO_ROOT/scripts/structural-index"
FIXTURE="$REPO_ROOT/tests/fixtures/structural-index/ts"

FAILED=0
PASSED=0

pass() { echo "  [PASS] $1"; PASSED=$((PASSED + 1)); }
fail() { echo "  [FAIL] $1"; FAILED=$((FAILED + 1)); }

assert_eq() {
    local label="$1" expected="$2" actual="$3"
    if [ "$actual" = "$expected" ]; then
        pass "$label"
    else
        fail "$label (expected: $(printf '%q' "$expected"), got: $(printf '%q' "$actual"))"
    fi
}

assert_query() {
    local query="$1" symbol="$2" expected="$3" target="${4:-$TARGET}"
    local out err status
    out="$WORK/stdout"
    err="$WORK/stderr"
    "$INDEX" "$query" "$symbol" --repo "$target" >"$out" 2>"$err"
    status=$?
    if [ "$status" -ne 0 ]; then
        fail "$query $symbol exits 0 (got $status; stderr: $(tr '\n' ' ' <"$err"))"
        return
    fi
    assert_eq "$query $symbol output" "$expected" "$(cat "$out")"
}

echo "========================================"
echo " Test: structural-index"
echo "========================================"
echo ""

if [ ! -x "$INDEX" ]; then
    echo "  [FAIL] script missing or not executable: $INDEX"
    exit 1
fi

WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT
TARGET="$WORK/repo"
mkdir -p "$TARGET"
cp -R "$FIXTURE/." "$TARGET/"

typescript_package="${STRUCTURAL_INDEX_TYPESCRIPT_PACKAGE:-}"
if [ ! -f "$typescript_package/lib/typescript.js" ]; then
    echo "  [FAIL] TypeScript package unavailable; set STRUCTURAL_INDEX_TYPESCRIPT_PACKAGE"
    exit 1
fi
mkdir -p "$TARGET/server/node_modules"
ln -s "$typescript_package" "$TARGET/server/node_modules/typescript"

git -C "$TARGET" init -q
git -C "$TARGET" config user.name "Structural Index Test"
git -C "$TARGET" config user.email "structural-index@example.test"
git -C "$TARGET" add .
git -C "$TARGET" commit -qm "fixture"

# Unknown-symbol behavior is identical when generation is required: the cache
# may be created, but the command still emits exactly the one error line.
"$INDEX" symbol missingSymbol --repo "$TARGET" >"$WORK/stdout" 2>"$WORK/stderr"
status=$?
assert_eq "cold-cache unknown symbol exits 1" "1" "$status"
assert_eq "cold-cache unknown symbol has empty stdout" "" "$(cat "$WORK/stdout")"
assert_eq "cold-cache unknown symbol has one stderr line" "symbol not found: missingSymbol" "$(cat "$WORK/stderr")"
assert_eq "cold-cache unknown stderr line count" "1" "$(wc -l <"$WORK/stderr" | tr -d ' ')"
rm -rf "$TARGET/.bd/index"

# The first query proves absent-index regeneration and the definition contract.
"$INDEX" symbol unused --repo "$TARGET" >"$WORK/stdout" 2>"$WORK/stderr"
status=$?
assert_eq "first query exits 0" "0" "$status"
assert_eq "symbol unused output" $'src/unused.ts\t1-3\t6594898741b7' "$(cat "$WORK/stdout")"
if grep -Eq '^structural-index: regenerated TypeScript index in [0-9]+\.[0-9]{3}s$' "$WORK/stderr"; then
    pass "absent index reports regeneration wall time"
else
    fail "absent index reports regeneration wall time (got: $(cat "$WORK/stderr"))"
fi

layout="$(cd "$TARGET" && find .bd/index -type f -print | LC_ALL=C sort)"
assert_eq "index directory layout" $'.bd/index/metadata.json\n.bd/index/typescript.json' "$layout"
head_sha="$(git -C "$TARGET" rev-parse HEAD)"
recorded_sha="$(node -e 'process.stdout.write(JSON.parse(require("fs").readFileSync(process.argv[1], "utf8")).commit)' "$TARGET/.bd/index/metadata.json")"
assert_eq "metadata records target HEAD" "$head_sha" "$recorded_sha"

# The second query on the same HEAD reuses the generated files silently.
"$INDEX" symbol unused --repo "$TARGET" >"$WORK/stdout" 2>"$WORK/stderr"
assert_eq "same-HEAD query reuses index" "" "$(cat "$WORK/stderr")"

# One literal assertion per symbol per query. The dynamic-import and @shared
# expectations are the nine acceptance fixtures from R-23: seven
# suggestCadence calls, one startTaskSweep call, and one priceLine alias call.
assert_query symbol triple $'src/triple.ts\t1-3\td2073dcb235e'
assert_query symbol testOnly $'src/test-only.ts\t1-3\t9ec90cd937f1'
assert_query symbol UndoHistory.undo $'src/history.ts\t2-4\t8b6b06e3256a'
assert_query symbol StatusTimeline $'src/StatusTimeline.tsx\t1-5\tee9fb25e859b'
assert_query symbol PERMISSION_SECTIONS $'src/permissions.ts\t1-4\te5806a73d8df'
assert_query symbol suggestCadence $'src/task-sweep.ts\t1-3\tad445d667ec8'
assert_query symbol startTaskSweep $'src/task-sweep.ts\t5-7\t5cacac3406b4'
assert_query symbol priceLine $'shared/pricing.ts\t1-3\tdddcb9e6635a'

assert_query callers unused ""
assert_query callers triple $'src/caller-a.ts:3\nsrc/caller-b.ts:3\nsrc/caller-c.ts:3'
assert_query callers testOnly 'tests/test-only.test.ts:3'
assert_query callers UndoHistory.undo 'src/history-caller.ts:3'
assert_query callers StatusTimeline 'src/status-caller.tsx:3'
assert_query callers PERMISSION_SECTIONS $'tests/permissions.spec.ts:1\ntests/permissions.spec.ts:3'
assert_query callers suggestCadence $'tests/task-sweep.test.ts:3\ntests/task-sweep.test.ts:8\ntests/task-sweep.test.ts:13\ntests/task-sweep.test.ts:18\ntests/task-sweep.test.ts:23\ntests/task-sweep.test.ts:28\ntests/task-sweep.test.ts:33'
assert_query callers startTaskSweep 'tests/task-sweep.test.ts:38'
assert_query callers priceLine 'web-app/src/Retailer.ts:3'

assert_query tests unused ""
assert_query tests triple ""
assert_query tests testOnly 'tests/test-only.test.ts:3'
assert_query tests UndoHistory.undo ""
assert_query tests StatusTimeline ""
assert_query tests PERMISSION_SECTIONS $'tests/permissions.spec.ts:1\ntests/permissions.spec.ts:3'
assert_query tests suggestCadence $'tests/task-sweep.test.ts:3\ntests/task-sweep.test.ts:8\ntests/task-sweep.test.ts:13\ntests/task-sweep.test.ts:18\ntests/task-sweep.test.ts:23\ntests/task-sweep.test.ts:28\ntests/task-sweep.test.ts:33'
assert_query tests startTaskSweep 'tests/task-sweep.test.ts:38'
assert_query tests priceLine ""

# A changed target HEAD regenerates automatically, then reuses silently.
printf 'export const headChange = true;\n' >"$TARGET/src/head-change.ts"
git -C "$TARGET" add src/head-change.ts
git -C "$TARGET" commit -qm "change HEAD"
"$INDEX" symbol unused --repo "$TARGET" >"$WORK/stdout" 2>"$WORK/stderr"
if grep -Eq '^structural-index: regenerated TypeScript index in [0-9]+\.[0-9]{3}s$' "$WORK/stderr"; then
    pass "changed HEAD regenerates index"
else
    fail "changed HEAD regenerates index (got: $(cat "$WORK/stderr"))"
fi
"$INDEX" symbol unused --repo "$TARGET" >"$WORK/stdout" 2>"$WORK/stderr"
assert_eq "changed-HEAD regeneration is reusable" "" "$(cat "$WORK/stderr")"

# Forced regeneration observes a dirty-tree mutation to the symbol itself.
cp "$TARGET/src/unused.ts" "$WORK/unused.ts"
node -e 'const fs=require("fs"),p=process.argv[1],s=fs.readFileSync(p,"utf8");fs.writeFileSync(p,s.replace(/\n}\n$/, "\n  const added = true;\n}\n"))' "$TARGET/src/unused.ts"
"$INDEX" symbol unused --repo "$TARGET" --regen >"$WORK/stdout" 2>"$WORK/stderr"
mutated="$(cat "$WORK/stdout")"
if printf '%s\n' "$mutated" | grep -Eq $'^src/unused.ts\\t1-4\\t[0-9a-f]{12}$'; then
    pass "mutation grows the definition span"
else
    fail "mutation grows the definition span (got: $mutated)"
fi
mutated_hash="${mutated##*$'\t'}"
if [ "$mutated_hash" != "6594898741b7" ]; then
    pass "mutation changes the source hash"
else
    fail "mutation changes the source hash"
fi
if grep -Eq '^structural-index: regenerated TypeScript index in [0-9]+\.[0-9]{3}s$' "$WORK/stderr"; then
    pass "--regen forces regeneration"
else
    fail "--regen forces regeneration (got: $(cat "$WORK/stderr"))"
fi

cp "$WORK/unused.ts" "$TARGET/src/unused.ts"
"$INDEX" symbol unused --repo "$TARGET" --regen >"$WORK/stdout" 2>"$WORK/stderr"
assert_eq "reverting mutation restores span and hash" $'src/unused.ts\t1-3\t6594898741b7' "$(cat "$WORK/stdout")"

echo ""
echo "TypeScript package fallback: no package under the target repository"
FALLBACK_TARGET="$WORK/fallback-repo"
mkdir -p "$FALLBACK_TARGET"
cp -R "$FIXTURE/." "$FALLBACK_TARGET/"
git -C "$FALLBACK_TARGET" init -q
git -C "$FALLBACK_TARGET" config user.name "Structural Index Test"
git -C "$FALLBACK_TARGET" config user.email "structural-index@example.test"
git -C "$FALLBACK_TARGET" add .
git -C "$FALLBACK_TARGET" commit -qm "fixture without TypeScript package"

in_repo_triple="$("$INDEX" symbol triple --repo "$TARGET" 2>"$WORK/stderr")"
ln -s "$typescript_package" "$WORK/typescript-package"
(
    cd "$WORK" || exit
    STRUCTURAL_INDEX_TYPESCRIPT_PACKAGE=typescript-package \
        "$INDEX" symbol triple --repo "$FALLBACK_TARGET" >"$WORK/stdout" 2>"$WORK/stderr"
)
status=$?
if [ "$status" -eq 0 ] && [ "$(cat "$WORK/stdout")" = "$in_repo_triple" ]; then
    pass "relative environment fallback matches the in-repo symbol result"
else
    fail "relative environment fallback matches the in-repo symbol result (exit $status; stdout: $(cat "$WORK/stdout"); stderr: $(tr '\n' ' ' <"$WORK/stderr"))"
fi

rm -rf "$FALLBACK_TARGET/.bd/index"
env -u STRUCTURAL_INDEX_TYPESCRIPT_PACKAGE \
    "$INDEX" symbol triple --repo "$FALLBACK_TARGET" >"$WORK/stdout" 2>"$WORK/stderr"
status=$?
if [ "$status" -eq 2 ] \
    && [ ! -s "$WORK/stdout" ] \
    && grep -Fq "TypeScript package not found" "$WORK/stderr" \
    && grep -Fq "STRUCTURAL_INDEX_TYPESCRIPT_PACKAGE" "$WORK/stderr"; then
    pass "missing fallback exits 2 with empty stdout and fallback guidance"
else
    fail "missing fallback exits 2 with empty stdout and fallback guidance (exit $status; stdout: $(cat "$WORK/stdout"); stderr: $(tr '\n' ' ' <"$WORK/stderr"))"
fi

rm -rf "$FALLBACK_TARGET/.bd/index"
mkdir -p "$WORK/no-typescript-package"
STRUCTURAL_INDEX_TYPESCRIPT_PACKAGE="$WORK/no-typescript-package" \
    "$INDEX" symbol triple --repo "$FALLBACK_TARGET" >"$WORK/stdout" 2>"$WORK/stderr"
status=$?
if [ "$status" -eq 2 ] && grep -Fq "STRUCTURAL_INDEX_TYPESCRIPT_PACKAGE" "$WORK/stderr"; then
    pass "invalid fallback exits 2 and names the variable"
else
    fail "invalid fallback exits 2 and names the variable (exit $status; stderr: $(tr '\n' ' ' <"$WORK/stderr"))"
fi

echo ""
echo "Go fixture: the same CLI contract over the Go backend"
GO_FIXTURE="$REPO_ROOT/tests/fixtures/structural-index/go"
GO_TARGET="$WORK/go-repo"
mkdir -p "$GO_TARGET"
cp -R "$GO_FIXTURE/." "$GO_TARGET/"

git -C "$GO_TARGET" init -q
git -C "$GO_TARGET" config user.name "Structural Index Test"
git -C "$GO_TARGET" config user.email "structural-index@example.test"
git -C "$GO_TARGET" add .
git -C "$GO_TARGET" commit -qm "fixture"

# Unknown-symbol behavior is identical when Go generation is required.
"$INDEX" symbol missingGoSymbol --repo "$GO_TARGET" >"$WORK/stdout" 2>"$WORK/stderr"
status=$?
assert_eq "Go cold-cache unknown symbol exits 1" "1" "$status"
assert_eq "Go cold-cache unknown symbol has empty stdout" "" "$(cat "$WORK/stdout")"
assert_eq "Go cold-cache unknown symbol has one stderr line" "symbol not found: missingGoSymbol" "$(cat "$WORK/stderr")"
assert_eq "Go cold-cache unknown stderr line count" "1" "$(wc -l <"$WORK/stderr" | tr -d ' ')"
rm -rf "$GO_TARGET/.bd/index"

"$INDEX" symbol UnusedGuard --repo "$GO_TARGET" >"$WORK/stdout" 2>"$WORK/stderr"
status=$?
assert_eq "Go first query exits 0" "0" "$status"
assert_eq "symbol UnusedGuard output" $'guard.go\t3-5\t235c8b6d0041' "$(cat "$WORK/stdout")"
if grep -Eq '^structural-index: regenerated Go index in [0-9]+\.[0-9]{3}s$' "$WORK/stderr"; then
    pass "Go absent index reports regeneration wall time"
else
    fail "Go absent index reports regeneration wall time (got: $(cat "$WORK/stderr"))"
fi

go_layout="$(cd "$GO_TARGET" && find .bd/index -type f -print | LC_ALL=C sort)"
assert_eq "Go index directory layout" $'.bd/index/go.json\n.bd/index/metadata.json' "$go_layout"
go_head_sha="$(git -C "$GO_TARGET" rev-parse HEAD)"
go_recorded_sha="$(node -e 'process.stdout.write(JSON.parse(require("fs").readFileSync(process.argv[1], "utf8")).commit)' "$GO_TARGET/.bd/index/metadata.json")"
assert_eq "Go metadata records target HEAD" "$go_head_sha" "$go_recorded_sha"

"$INDEX" symbol UnusedGuard --repo "$GO_TARGET" >"$WORK/stdout" 2>"$WORK/stderr"
assert_eq "Go same-HEAD query reuses index" "" "$(cat "$WORK/stderr")"

# One literal assertion per symbol per query: spans, caller sets, test sets.
assert_query symbol UnusedGuard $'guard.go\t3-5\t235c8b6d0041' "$GO_TARGET"
assert_query symbol FormatBeadLine $'render.go\t3-5\t58da981d2dda' "$GO_TARGET"
assert_query symbol BeadCard.Status $'bead.go\t9-11\t6a80a1aebbd5' "$GO_TARGET"
assert_query symbol BeadStatus $'bead.go\t3-3\tdda4084765c9' "$GO_TARGET"
assert_query symbol ValidateStatus $'status.go\t3-5\tfe07fd81f43f' "$GO_TARGET"

assert_query callers UnusedGuard "" "$GO_TARGET"
assert_query callers FormatBeadLine $'board/board.go:6\ncaller_a.go:4\ncaller_b.go:4' "$GO_TARGET"
assert_query callers BeadCard.Status 'caller_a.go:4' "$GO_TARGET"
assert_query callers BeadStatus $'bead.go:6\nbead.go:9\nboard/board.go:5' "$GO_TARGET"
assert_query callers ValidateStatus 'status_test.go:6' "$GO_TARGET"

assert_query tests UnusedGuard "" "$GO_TARGET"
assert_query tests FormatBeadLine "" "$GO_TARGET"
assert_query tests BeadCard.Status "" "$GO_TARGET"
assert_query tests BeadStatus "" "$GO_TARGET"
assert_query tests ValidateStatus 'status_test.go:6' "$GO_TARGET"

# A changed target HEAD regenerates the Go index, then reuses silently.
printf 'package fixture\n\nfunc ExtraAnchor() bool {\n\treturn true\n}\n' >"$GO_TARGET/extra.go"
git -C "$GO_TARGET" add extra.go
git -C "$GO_TARGET" commit -qm "change HEAD"
"$INDEX" symbol UnusedGuard --repo "$GO_TARGET" >"$WORK/stdout" 2>"$WORK/stderr"
if grep -Eq '^structural-index: regenerated Go index in [0-9]+\.[0-9]{3}s$' "$WORK/stderr"; then
    pass "Go changed HEAD regenerates index"
else
    fail "Go changed HEAD regenerates index (got: $(cat "$WORK/stderr"))"
fi
"$INDEX" symbol UnusedGuard --repo "$GO_TARGET" >"$WORK/stdout" 2>"$WORK/stderr"
assert_eq "Go changed-HEAD regeneration is reusable" "" "$(cat "$WORK/stderr")"

# Forced regeneration observes a dirty-tree mutation to the symbol itself.
cp "$GO_TARGET/guard.go" "$WORK/guard.go"
node -e 'const fs=require("fs"),p=process.argv[1],s=fs.readFileSync(p,"utf8");fs.writeFileSync(p,s.replace(/\n}\n$/, "\n\tconst added = true\n}\n"))' "$GO_TARGET/guard.go"
"$INDEX" symbol UnusedGuard --repo "$GO_TARGET" --regen >"$WORK/stdout" 2>"$WORK/stderr"
go_mutated="$(cat "$WORK/stdout")"
if printf '%s\n' "$go_mutated" | grep -Eq $'^guard.go\\t3-6\\t[0-9a-f]{12}$'; then
    pass "Go mutation grows the definition span"
else
    fail "Go mutation grows the definition span (got: $go_mutated)"
fi
go_mutated_hash="${go_mutated##*$'\t'}"
if [ "$go_mutated_hash" != "235c8b6d0041" ]; then
    pass "Go mutation changes the source hash"
else
    fail "Go mutation changes the source hash"
fi
if grep -Eq '^structural-index: regenerated Go index in [0-9]+\.[0-9]{3}s$' "$WORK/stderr"; then
    pass "Go --regen forces regeneration"
else
    fail "Go --regen forces regeneration (got: $(cat "$WORK/stderr"))"
fi

cp "$WORK/guard.go" "$GO_TARGET/guard.go"
"$INDEX" symbol UnusedGuard --repo "$GO_TARGET" --regen >"$WORK/stdout" 2>"$WORK/stderr"
assert_eq "Go reverting mutation restores span and hash" $'guard.go\t3-5\t235c8b6d0041' "$(cat "$WORK/stdout")"

echo ""
if [ "$FAILED" -eq 0 ]; then
    echo "All structural-index tests passed ($PASSED assertions)."
    exit 0
else
    echo "$FAILED structural-index test(s) FAILED ($PASSED assertions passed)."
    exit 1
fi
