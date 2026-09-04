#!/usr/bin/env bash
# Test: structural-index Swift backend
# Verifies tree-sitter-swift definitions (top-level function, class method,
# type, property), span hashing, lexical caller sets with declaration,
# import, comment, and string exclusions, a same-name-different-scope decoy,
# a zero-caller symbol, test-file filtering over *Tests.swift and Tests/
# paths, cache regeneration, and the STRUCTURAL_INDEX_SWIFT_TOOLCHAIN
# resolution order (target repository first, then the variable, else exit 2).
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
INDEX="$REPO_ROOT/scripts/structural-index"
FIXTURE="$REPO_ROOT/tests/fixtures/structural-index/swift"

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
echo " Test: structural-index (Swift)"
echo "========================================"
echo ""

if [ ! -x "$INDEX" ]; then
    echo "  [FAIL] script missing or not executable: $INDEX"
    exit 1
fi

# The Swift backend resolves tree-sitter and tree-sitter-swift from the
# target repository first, then from this directory; without it the tests
# cannot run and the suite stays green through the skip.
swift_toolchain="${STRUCTURAL_INDEX_SWIFT_TOOLCHAIN:-}"
if [ -z "$swift_toolchain" ] \
    || [ ! -d "$swift_toolchain/node_modules/tree-sitter" ] \
    || [ ! -d "$swift_toolchain/node_modules/tree-sitter-swift" ]; then
    echo "[SKIP] STRUCTURAL_INDEX_SWIFT_TOOLCHAIN unset or incomplete; Swift backend tests skipped"
    exit 0
fi

WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT
TARGET="$WORK/repo"
mkdir -p "$TARGET"
cp -R "$FIXTURE/." "$TARGET/"

git -C "$TARGET" init -q
git -C "$TARGET" config user.name "Structural Index Test"
git -C "$TARGET" config user.email "structural-index@example.test"
git -C "$TARGET" add .
git -C "$TARGET" commit -qm "fixture"

echo "Language roster: swift reports the compiler backend, toolchain-free"
env -u STRUCTURAL_INDEX_SWIFT_TOOLCHAIN \
    "$INDEX" languages --repo "$TARGET" >"$WORK/stdout" 2>"$WORK/stderr"
status=$?
if [ "$status" -eq 0 ] \
    && [ "$(cat "$WORK/stdout")" = $'swift\t4\tcompiler' ] \
    && [ ! -s "$WORK/stderr" ]; then
    pass "languages prints swift as a compiler language without the toolchain"
else
    fail "languages prints swift as a compiler language without the toolchain (exit $status; stdout: $(cat "$WORK/stdout"); stderr: $(tr '\n' ' ' <"$WORK/stderr"))"
fi

echo ""
echo "Toolchain resolution: missing toolchain exits 2 naming the variable"
NO_TOOLCHAIN_TARGET="$WORK/no-toolchain-repo"
mkdir -p "$NO_TOOLCHAIN_TARGET"
cp -R "$FIXTURE/." "$NO_TOOLCHAIN_TARGET/"
git -C "$NO_TOOLCHAIN_TARGET" init -q
git -C "$NO_TOOLCHAIN_TARGET" config user.name "Structural Index Test"
git -C "$NO_TOOLCHAIN_TARGET" config user.email "structural-index@example.test"
git -C "$NO_TOOLCHAIN_TARGET" add .
git -C "$NO_TOOLCHAIN_TARGET" commit -qm "fixture without toolchain"

env -u STRUCTURAL_INDEX_SWIFT_TOOLCHAIN \
    "$INDEX" symbol renderBadge --repo "$NO_TOOLCHAIN_TARGET" >"$WORK/stdout" 2>"$WORK/stderr"
status=$?
if [ "$status" -eq 2 ] \
    && [ ! -s "$WORK/stdout" ] \
    && grep -Fq "STRUCTURAL_INDEX_SWIFT_TOOLCHAIN" "$WORK/stderr" \
    && [ "$(wc -l <"$WORK/stderr" | tr -d ' ')" -eq 1 ]; then
    pass "missing toolchain exits 2 with one stderr line naming the variable"
else
    fail "missing toolchain exits 2 with one stderr line naming the variable (exit $status; stdout: $(cat "$WORK/stdout"); stderr: $(tr '\n' ' ' <"$WORK/stderr"))"
fi

env -u STRUCTURAL_INDEX_SWIFT_TOOLCHAIN \
    "$INDEX" callers renderBadge --repo "$NO_TOOLCHAIN_TARGET" >"$WORK/stdout" 2>"$WORK/stderr"
status=$?
if [ "$status" -eq 2 ] && grep -Fq "STRUCTURAL_INDEX_SWIFT_TOOLCHAIN" "$WORK/stderr"; then
    pass "indexed callers never fall through when the Swift toolchain is missing"
else
    fail "indexed callers never fall through when the Swift toolchain is missing (exit $status; stderr: $(tr '\n' ' ' <"$WORK/stderr"))"
fi

rm -rf "$NO_TOOLCHAIN_TARGET/.bd/index"
STRUCTURAL_INDEX_SWIFT_TOOLCHAIN="$WORK/empty-toolchain" \
    "$INDEX" symbol renderBadge --repo "$NO_TOOLCHAIN_TARGET" >"$WORK/stdout" 2>"$WORK/stderr"
status=$?
if [ "$status" -eq 2 ] && grep -Fq "STRUCTURAL_INDEX_SWIFT_TOOLCHAIN" "$WORK/stderr"; then
    pass "invalid toolchain directory exits 2 and names the variable"
else
    fail "invalid toolchain directory exits 2 and names the variable (exit $status; stderr: $(tr '\n' ' ' <"$WORK/stderr"))"
fi

echo ""
echo "Generation: unknown symbol, regeneration line, index layout, cache"
"$INDEX" symbol missingSwiftSymbol --repo "$TARGET" >"$WORK/stdout" 2>"$WORK/stderr"
status=$?
assert_eq "cold-cache unknown symbol exits 1" "1" "$status"
assert_eq "cold-cache unknown symbol has empty stdout" "" "$(cat "$WORK/stdout")"
assert_eq "cold-cache unknown symbol has one stderr line" "symbol not found: missingSwiftSymbol" "$(cat "$WORK/stderr")"
assert_eq "cold-cache unknown stderr line count" "1" "$(wc -l <"$WORK/stderr" | tr -d ' ')"
rm -rf "$TARGET/.bd/index"

"$INDEX" symbol renderBadge --repo "$TARGET" >"$WORK/stdout" 2>"$WORK/stderr"
status=$?
assert_eq "first query exits 0" "0" "$status"
assert_eq "symbol renderBadge output" $'src/Badge.swift\t3-5\t69273ba7632b' "$(cat "$WORK/stdout")"
if grep -Eq '^structural-index: regenerated Swift index in [0-9]+\.[0-9]{3}s$' "$WORK/stderr"; then
    pass "absent index reports Swift regeneration wall time"
else
    fail "absent index reports Swift regeneration wall time (got: $(cat "$WORK/stderr"))"
fi

layout="$(cd "$TARGET" && find .bd/index -type f -print | LC_ALL=C sort)"
assert_eq "Swift index directory layout" $'.bd/index/metadata.json\n.bd/index/swift.json' "$layout"
head_sha="$(git -C "$TARGET" rev-parse HEAD)"
recorded_sha="$(node -e 'process.stdout.write(JSON.parse(require("fs").readFileSync(process.argv[1], "utf8")).commit)' "$TARGET/.bd/index/metadata.json")"
assert_eq "Swift metadata records target HEAD" "$head_sha" "$recorded_sha"

"$INDEX" symbol renderBadge --repo "$TARGET" >"$WORK/stdout" 2>"$WORK/stderr"
assert_eq "same-HEAD query reuses index" "" "$(cat "$WORK/stderr")"

echo ""
echo "Definitions: spans and source-span hashes per declaration kind"
assert_query symbol renderBadge $'src/Badge.swift\t3-5\t69273ba7632b'
assert_query symbol orphanAnchor $'src/Badge.swift\t21-23\tbbe9b85bf402'
assert_query symbol BadgeCard $'src/Badge.swift\t7-15\t3949d699b99d'
assert_query symbol BadgeCard.summarize $'src/Badge.swift\t8-10\t1a08f1ef7bf8'
assert_query symbol BadgeCard.renderBadge $'src/Badge.swift\t12-14\t2311acda4bb3'
assert_query symbol BadgeTheme $'src/Badge.swift\t17-19\t671fc456c340'
assert_query symbol BADGE_LIMIT $'src/Badge.swift\t1-1\tf9d367c90a9c'
assert_query symbol accent $'src/Badge.swift\t18-18\tf496c053a309'
assert_query symbol badgeSummary $'src/BadgeConsumer.swift\t3-7\t72d16ebb8a99'
assert_query symbol themeAccent $'src/BadgeConsumer.swift\t9-11\tac19d1af73bb'
assert_query symbol cardSummary $'src/BadgeConsumer.swift\t13-15\t83b1af163701'
assert_query symbol badgeCardTest $'src/BadgeCardTests.swift\t1-5\t9f145cb2e185'
assert_query symbol scenarioCheck $'src/Tests/Scenario.swift\t1-3\tcf34a51ead24'

echo ""
echo "Callers: real call sites only — declarations, imports, comments, strings excluded"
assert_query callers renderBadge $'src/Badge.swift:9\nsrc/BadgeCardTests.swift:4\nsrc/BadgeConsumer.swift:6\nsrc/Tests/Scenario.swift:2'
"$INDEX" callers renderBadge --repo "$TARGET" >"$WORK/stdout" 2>"$WORK/stderr"
if grep -Fq 'src/Badge.swift:12' "$WORK/stdout"; then
    fail "callers exclude the same-named method declared in a different scope"
else
    pass "callers exclude the same-named method declared in a different scope"
fi
if grep -Fq 'src/BadgeConsumer.swift:1' "$WORK/stdout" \
    || grep -Fq 'src/BadgeConsumer.swift:4' "$WORK/stdout" \
    || grep -Fq 'src/BadgeConsumer.swift:5' "$WORK/stdout"; then
    fail "callers exclude import, comment, and string mentions"
else
    pass "callers exclude import, comment, and string mentions"
fi
if grep -Fq 'answered by text search' "$WORK/stderr"; then
    fail "compiler callers write no text-answer stderr line"
else
    pass "compiler callers write no text-answer stderr line"
fi

assert_query callers BadgeCard.summarize $'src/BadgeCardTests.swift:3\nsrc/BadgeConsumer.swift:14'
assert_query callers BadgeCard $'src/BadgeCardTests.swift:2\nsrc/BadgeConsumer.swift:13'
assert_query callers BadgeTheme $'src/BadgeConsumer.swift:10\nsrc/Tests/Scenario.swift:2'
assert_query callers accent $'src/BadgeConsumer.swift:10\nsrc/Tests/Scenario.swift:2'
assert_query callers BADGE_LIMIT 'src/Badge.swift:22'
assert_query callers orphanAnchor ""

echo ""
echo "Tests: only *Tests.swift files and Tests/ path segments"
assert_query tests renderBadge $'src/BadgeCardTests.swift:4\nsrc/Tests/Scenario.swift:2'
if grep -Fq 'src/BadgeConsumer.swift:6' "$WORK/stdout"; then
    fail "tests exclude the non-test file that references the name"
else
    pass "tests exclude the non-test file that references the name"
fi
assert_query tests BadgeCard.summarize 'src/BadgeCardTests.swift:3'
assert_query tests BadgeCard 'src/BadgeCardTests.swift:2'
assert_query tests BadgeTheme 'src/Tests/Scenario.swift:2'
assert_query tests orphanAnchor ""
assert_query tests badgeSummary ""

echo ""
echo "Regeneration: changed HEAD regenerates, --regen observes a mutation"
printf 'func extraAnchor() -> Int {\n    return 1\n}\n' >"$TARGET/src/Extra.swift"
git -C "$TARGET" add src/Extra.swift
git -C "$TARGET" commit -qm "change HEAD"
"$INDEX" symbol renderBadge --repo "$TARGET" >"$WORK/stdout" 2>"$WORK/stderr"
if grep -Eq '^structural-index: regenerated Swift index in [0-9]+\.[0-9]{3}s$' "$WORK/stderr"; then
    pass "changed HEAD regenerates Swift index"
else
    fail "changed HEAD regenerates Swift index (got: $(cat "$WORK/stderr"))"
fi
"$INDEX" symbol renderBadge --repo "$TARGET" >"$WORK/stdout" 2>"$WORK/stderr"
assert_eq "changed-HEAD regeneration is reusable" "" "$(cat "$WORK/stderr")"

cp "$TARGET/src/Badge.swift" "$WORK/Badge.swift"
node -e 'const fs=require("fs"),p=process.argv[1],s=fs.readFileSync(p,"utf8");fs.writeFileSync(p,s.replace(/\n}\n/, "\n    let added = true\n}\n"))' "$TARGET/src/Badge.swift"
"$INDEX" symbol renderBadge --repo "$TARGET" --regen >"$WORK/stdout" 2>"$WORK/stderr"
mutated="$(cat "$WORK/stdout")"
if printf '%s\n' "$mutated" | grep -Eq $'^src/Badge\.swift\\t3-6\\t[0-9a-f]{12}$'; then
    pass "mutation grows the definition span"
else
    fail "mutation grows the definition span (got: $mutated)"
fi
mutated_hash="${mutated##*$'\t'}"
if [ "$mutated_hash" != "69273ba7632b" ]; then
    pass "mutation changes the source hash"
else
    fail "mutation changes the source hash"
fi
if grep -Eq '^structural-index: regenerated Swift index in [0-9]+\.[0-9]{3}s$' "$WORK/stderr"; then
    pass "--regen forces Swift regeneration"
else
    fail "--regen forces Swift regeneration (got: $(cat "$WORK/stderr"))"
fi

cp "$WORK/Badge.swift" "$TARGET/src/Badge.swift"
"$INDEX" symbol renderBadge --repo "$TARGET" --regen >"$WORK/stdout" 2>"$WORK/stderr"
assert_eq "reverting mutation restores span and hash" $'src/Badge.swift\t3-5\t69273ba7632b' "$(cat "$WORK/stdout")"

echo ""
if [ "$FAILED" -eq 0 ]; then
    echo "All structural-index Swift tests passed ($PASSED assertions)."
    exit 0
else
    echo "$FAILED structural-index Swift test(s) FAILED ($PASSED assertions passed)."
    exit 1
fi
