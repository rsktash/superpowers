#!/usr/bin/env bash
# Test: structural-index TypeScript backend
# Verifies exact definitions, semantic caller sets, test-only filtering,
# cache regeneration, unknown-symbol behavior, and source-span hashing.
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
    local query="$1" symbol="$2" expected="$3"
    local out err status
    out="$WORK/stdout"
    err="$WORK/stderr"
    "$INDEX" "$query" "$symbol" --repo "$TARGET" >"$out" 2>"$err"
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
if [ -z "$typescript_package" ]; then
    common_dir="$(git -C "$REPO_ROOT" rev-parse --git-common-dir)"
    case "$common_dir" in
        /*) common_root="$(cd "$common_dir/.." && pwd)" ;;
        *) common_root="$(cd "$REPO_ROOT/$common_dir/.." && pwd)" ;;
    esac
    projects_root="$(dirname "$common_root")"
    for candidate in \
        "$projects_root/zanjir/server/node_modules/typescript" \
        "$projects_root/zanjir/web-app/node_modules/typescript" \
        "$(npm root -g 2>/dev/null)/typescript"; do
        if [ -f "$candidate/lib/typescript.js" ]; then
            typescript_package="$candidate"
            break
        fi
    done
fi
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
if [ "$FAILED" -eq 0 ]; then
    echo "All structural-index tests passed ($PASSED assertions)."
    exit 0
else
    echo "$FAILED structural-index test(s) FAILED ($PASSED assertions passed)."
    exit 1
fi
