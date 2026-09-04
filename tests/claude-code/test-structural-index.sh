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
MIXED_FIXTURE="$REPO_ROOT/tests/fixtures/structural-index/mixed"

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

echo "Language roster: tracked counts, metadata, cache, and toolchain independence"
MIXED_TARGET="$WORK/mixed-repo"
mkdir -p "$MIXED_TARGET"
cp -R "$MIXED_FIXTURE/." "$MIXED_TARGET/"
git -C "$MIXED_TARGET" init -q
git -C "$MIXED_TARGET" config user.name "Structural Index Test"
git -C "$MIXED_TARGET" config user.email "structural-index@example.test"
git -C "$MIXED_TARGET" add .
git -C "$MIXED_TARGET" commit -qm "mixed fixture"

mixed_roster=$'typescript\t1\tcompiler\ngo\t1\tcompiler\nkotlin\t3\tnone\nswift\t3\tnone\npython\t4\tnone\nother\t3\tnone'
"$INDEX" languages --repo "$MIXED_TARGET" --regen >"$WORK/stdout" 2>"$WORK/stderr"
status=$?
assert_eq "mixed languages regeneration exits 0" "0" "$status"
assert_eq "mixed languages prints the ordered tracked roster" "$mixed_roster" "$(cat "$WORK/stdout")"

"$INDEX" languages --repo "$MIXED_TARGET" >"$WORK/stdout" 2>"$WORK/stderr"
status=$?
assert_eq "mixed languages cache hit exits 0" "0" "$status"
assert_eq "mixed languages cache hit is byte-identical" "$mixed_roster" "$(cat "$WORK/stdout")"
assert_eq "mixed languages cache hit is silent" "" "$(cat "$WORK/stderr")"

metadata="$MIXED_TARGET/.bd/index/metadata.json"
expected_metadata_roster='[{"id":"typescript","count":1,"backend":"compiler"},{"id":"go","count":1,"backend":"compiler"},{"id":"kotlin","count":3,"backend":"none"},{"id":"swift","count":3,"backend":"none"},{"id":"python","count":4,"backend":"none"},{"id":"other","count":3,"backend":"none"}]'
if [ -f "$metadata" ]; then
    recorded_roster="$(node -e 'process.stdout.write(JSON.stringify(JSON.parse(require("fs").readFileSync(process.argv[1], "utf8")).roster))' "$metadata")"
else
    recorded_roster="missing metadata"
fi
assert_eq "metadata records the complete roster" "$expected_metadata_roster" "$recorded_roster"

if [ -f "$metadata" ]; then
    node -e 'const fs=require("fs"),p=process.argv[1],m=JSON.parse(fs.readFileSync(p,"utf8"));delete m.roster;fs.writeFileSync(p,`${JSON.stringify(m, null, 2)}\n`)' "$metadata"
fi
"$INDEX" languages --repo "$MIXED_TARGET" >"$WORK/stdout" 2>"$WORK/stderr"
status=$?
if [ -f "$metadata" ]; then
    restored_roster="$(node -e 'process.stdout.write(JSON.stringify(JSON.parse(require("fs").readFileSync(process.argv[1], "utf8")).roster))' "$metadata")"
else
    restored_roster="missing metadata"
fi
if [ "$status" -eq 0 ] \
    && [ "$(cat "$WORK/stdout")" = "$mixed_roster" ] \
    && [ "$restored_roster" = "$expected_metadata_roster" ]; then
    pass "missing metadata roster regenerates the same roster"
else
    fail "missing metadata roster regenerates the same roster (exit $status; stdout: $(cat "$WORK/stdout"); roster: $restored_roster; stderr: $(tr '\n' ' ' <"$WORK/stderr"))"
fi

echo ""
echo "Uncovered languages: compiler precedence and text answers"
"$INDEX" callers renderBadge --repo "$MIXED_TARGET" >"$WORK/stdout" 2>"$WORK/stderr"
status=$?
assert_eq "indexed callers query exits 0" "0" "$status"
assert_eq "indexed callers exclude uncovered-language text hits" "" "$(cat "$WORK/stdout")"
if ! grep -Fq 'answered by text search' "$WORK/stderr"; then
    pass "indexed callers write no text-answer stderr line"
else
    fail "indexed callers write no text-answer stderr line (got: $(cat "$WORK/stderr"))"
fi

"$INDEX" callers kotlinOnlyMarker --repo "$MIXED_TARGET" >"$WORK/stdout" 2>"$WORK/stderr"
status=$?
assert_eq "Kotlin text callers exit 0" "0" "$status"
assert_eq "Kotlin text callers use sorted word-boundary hits" $'src/BadgeTest/BadgeScenario.kt:3\nsrc/kotlin/BadgeScreen.kt:3\nsrc/kotlin/BadgeScreen.kt:5\nsrc/kotlin/BadgeScreenTest.kt:3' "$(cat "$WORK/stdout")"
assert_eq "Kotlin text callers explain the fallback" "structural-index: callers kotlinOnlyMarker answered by text search over 13 files in kotlin, swift, python, other" "$(cat "$WORK/stderr")"
if ! grep -Fq 'package.json:' "$WORK/stdout"; then
    pass "text callers require a word boundary"
else
    fail "text callers require a word boundary (got: $(cat "$WORK/stdout"))"
fi

"$INDEX" symbol kotlinOnlyMarker --repo "$MIXED_TARGET" >"$WORK/stdout" 2>"$WORK/stderr"
status=$?
assert_eq "uncovered symbol exits 1" "1" "$status"
assert_eq "uncovered symbol has empty stdout" "" "$(cat "$WORK/stdout")"
assert_eq "uncovered symbol explains the missing backend" $'symbol not found: kotlinOnlyMarker\nstructural-index: no definition backend for kotlin, swift, python, other; not searched' "$(cat "$WORK/stderr")"

"$INDEX" tests kotlinOnlyMarker --repo "$MIXED_TARGET" >"$WORK/stdout" 2>"$WORK/stderr"
status=$?
assert_eq "Kotlin text tests exit 0" "0" "$status"
assert_eq "Kotlin text tests use *Test.kt and src/*Test/ paths" $'src/BadgeTest/BadgeScenario.kt:3\nsrc/kotlin/BadgeScreenTest.kt:3' "$(cat "$WORK/stdout")"

"$INDEX" tests swiftOnlyMarker --repo "$MIXED_TARGET" >"$WORK/stdout" 2>"$WORK/stderr"
status=$?
assert_eq "Swift text tests exit 0" "0" "$status"
assert_eq "Swift text tests use *Tests.swift and Tests/ paths" $'src/swift/BadgeViewTests.swift:6\nsrc/swift/Tests/BadgeScenario.swift:6' "$(cat "$WORK/stdout")"

"$INDEX" tests python_only_marker --repo "$MIXED_TARGET" >"$WORK/stdout" 2>"$WORK/stderr"
status=$?
assert_eq "Python text tests exit 0" "0" "$status"
assert_eq "Python text tests use test_*.py, *_test.py, and tests/ paths" $'src/python/badge_test.py:6\nsrc/python/test_badge.py:6\nsrc/python/tests/badge_scenario.py:6' "$(cat "$WORK/stdout")"

"$INDEX" callers otherOnlyMarker --repo "$MIXED_TARGET" >"$WORK/stdout" 2>"$WORK/stderr"
status=$?
assert_eq "other text callers exit 0" "0" "$status"
assert_eq "other text callers remain covered" "package.json:4" "$(cat "$WORK/stdout")"

for query in callers tests; do
    "$INDEX" "$query" nowhereTextMarker --repo "$MIXED_TARGET" >"$WORK/stdout" 2>"$WORK/stderr"
    status=$?
    assert_eq "$query nowhere text name exits 1" "1" "$status"
    assert_eq "$query nowhere text name has empty stdout" "" "$(cat "$WORK/stdout")"
    assert_eq "$query nowhere text name has one stderr line" "symbol not found: nowhereTextMarker" "$(cat "$WORK/stderr")"
done

NO_TOOLCHAIN_TARGET="$WORK/no-toolchain-repo"
mkdir -p "$NO_TOOLCHAIN_TARGET"
cp -R "$FIXTURE/." "$NO_TOOLCHAIN_TARGET/"
git -C "$NO_TOOLCHAIN_TARGET" init -q
git -C "$NO_TOOLCHAIN_TARGET" config user.name "Structural Index Test"
git -C "$NO_TOOLCHAIN_TARGET" config user.email "structural-index@example.test"
git -C "$NO_TOOLCHAIN_TARGET" add .
git -C "$NO_TOOLCHAIN_TARGET" commit -qm "fixture without toolchain"
ts_count="$(git -C "$NO_TOOLCHAIN_TARGET" ls-files '*.ts' '*.tsx' | wc -l | tr -d ' ')"
tracked_count="$(git -C "$NO_TOOLCHAIN_TARGET" ls-files | wc -l | tr -d ' ')"
other_count=$((tracked_count - ts_count))
typescript_roster="$(printf 'typescript\t%s\tcompiler\nother\t%s\tnone' "$ts_count" "$other_count")"
env -u STRUCTURAL_INDEX_TYPESCRIPT_PACKAGE \
    "$INDEX" languages --repo "$NO_TOOLCHAIN_TARGET" >"$WORK/stdout" 2>"$WORK/stderr"
languages_status=$?
if [ "$languages_status" -eq 0 ] \
    && [ "$(cat "$WORK/stdout")" = "$typescript_roster" ] \
    && [ ! -s "$WORK/stderr" ]; then
    pass "languages needs no TypeScript toolchain"
else
    fail "languages needs no TypeScript toolchain (exit $languages_status; stdout: $(cat "$WORK/stdout"); stderr: $(tr '\n' ' ' <"$WORK/stderr"))"
fi

env -u STRUCTURAL_INDEX_TYPESCRIPT_PACKAGE \
    "$INDEX" symbol triple --repo "$NO_TOOLCHAIN_TARGET" >"$WORK/stdout" 2>"$WORK/stderr"
symbol_status=$?
if [ "$symbol_status" -eq 2 ] \
    && [ ! -s "$WORK/stdout" ] \
    && grep -Fq "STRUCTURAL_INDEX_TYPESCRIPT_PACKAGE" "$WORK/stderr" \
    && [ "$(wc -l <"$WORK/stderr" | tr -d ' ')" -eq 1 ]; then
    pass "symbol still requires the TypeScript toolchain"
else
    fail "symbol still requires the TypeScript toolchain (exit $symbol_status; stdout: $(cat "$WORK/stdout"); stderr: $(tr '\n' ' ' <"$WORK/stderr"))"
fi

rm -rf "$NO_TOOLCHAIN_TARGET/.bd/index"
env -u STRUCTURAL_INDEX_TYPESCRIPT_PACKAGE \
    "$INDEX" callers triple --repo "$NO_TOOLCHAIN_TARGET" >"$WORK/stdout" 2>"$WORK/stderr"
callers_status=$?
if [ "$callers_status" -eq 2 ] \
    && [ ! -s "$WORK/stdout" ] \
    && grep -Fq "STRUCTURAL_INDEX_TYPESCRIPT_PACKAGE" "$WORK/stderr" \
    && [ "$(wc -l <"$WORK/stderr" | tr -d ' ')" -eq 1 ]; then
    pass "indexed callers never fall through when the TypeScript toolchain is missing"
else
    fail "indexed callers never fall through when the TypeScript toolchain is missing (exit $callers_status; stdout: $(cat "$WORK/stdout"); stderr: $(tr '\n' ' ' <"$WORK/stderr"))"
fi

repo_backends="$("$INDEX" languages --repo "$REPO_ROOT" 2>"$WORK/stderr" | cut -f1,3)"
status=$?
expected_repo_backends=$'typescript\tcompiler\ngo\tcompiler\nkotlin\tnone\nswift\tnone\npython\tnone\nother\tnone'
if [ "$status" -eq 0 ] && [ "$repo_backends" = "$expected_repo_backends" ]; then
    pass "repository roster contains every language and backend"
else
    fail "repository roster contains every language and backend (exit $status; output: $repo_backends; stderr: $(tr '\n' ' ' <"$WORK/stderr"))"
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
