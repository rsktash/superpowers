#!/usr/bin/env bash
# Test: structural-index Kotlin backend
# Verifies tree-sitter-kotlin definitions (top-level function, class method,
# type, constant), span hashing, lexical caller sets with declaration,
# import, comment, and string exclusions, a same-name-different-scope decoy,
# a zero-caller symbol, test-file filtering over *Test.kt and src/*Test/
# paths, cache regeneration, and the STRUCTURAL_INDEX_KOTLIN_TOOLCHAIN
# resolution order (target repository first, then the variable, else exit 2).
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
INDEX="$REPO_ROOT/scripts/structural-index"
FIXTURE="$REPO_ROOT/tests/fixtures/structural-index/kotlin"

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
echo " Test: structural-index (Kotlin)"
echo "========================================"
echo ""

if [ ! -x "$INDEX" ]; then
    echo "  [FAIL] script missing or not executable: $INDEX"
    exit 1
fi

# The Kotlin backend resolves tree-sitter and tree-sitter-kotlin from the
# target repository first, then from this directory; without it the tests
# cannot run and the suite stays green through the skip.
kotlin_toolchain="${STRUCTURAL_INDEX_KOTLIN_TOOLCHAIN:-}"
if [ -z "$kotlin_toolchain" ] \
    || [ ! -d "$kotlin_toolchain/node_modules/tree-sitter" ] \
    || [ ! -d "$kotlin_toolchain/node_modules/tree-sitter-kotlin" ]; then
    echo "[SKIP] STRUCTURAL_INDEX_KOTLIN_TOOLCHAIN unset or incomplete; Kotlin backend tests skipped"
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

echo "Language roster: kotlin reports the compiler backend, toolchain-free"
env -u STRUCTURAL_INDEX_KOTLIN_TOOLCHAIN \
    "$INDEX" languages --repo "$TARGET" >"$WORK/stdout" 2>"$WORK/stderr"
status=$?
if [ "$status" -eq 0 ] \
    && [ "$(cat "$WORK/stdout")" = $'kotlin\t4\tcompiler' ] \
    && [ ! -s "$WORK/stderr" ]; then
    pass "languages prints kotlin as a compiler language without the toolchain"
else
    fail "languages prints kotlin as a compiler language without the toolchain (exit $status; stdout: $(cat "$WORK/stdout"); stderr: $(tr '\n' ' ' <"$WORK/stderr"))"
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

env -u STRUCTURAL_INDEX_KOTLIN_TOOLCHAIN \
    "$INDEX" symbol renderBadge --repo "$NO_TOOLCHAIN_TARGET" >"$WORK/stdout" 2>"$WORK/stderr"
status=$?
if [ "$status" -eq 2 ] \
    && [ ! -s "$WORK/stdout" ] \
    && grep -Fq "STRUCTURAL_INDEX_KOTLIN_TOOLCHAIN" "$WORK/stderr" \
    && [ "$(wc -l <"$WORK/stderr" | tr -d ' ')" -eq 1 ]; then
    pass "missing toolchain exits 2 with one stderr line naming the variable"
else
    fail "missing toolchain exits 2 with one stderr line naming the variable (exit $status; stdout: $(cat "$WORK/stdout"); stderr: $(tr '\n' ' ' <"$WORK/stderr"))"
fi

env -u STRUCTURAL_INDEX_KOTLIN_TOOLCHAIN \
    "$INDEX" callers renderBadge --repo "$NO_TOOLCHAIN_TARGET" >"$WORK/stdout" 2>"$WORK/stderr"
status=$?
if [ "$status" -eq 2 ] && grep -Fq "STRUCTURAL_INDEX_KOTLIN_TOOLCHAIN" "$WORK/stderr"; then
    pass "indexed callers never fall through when the Kotlin toolchain is missing"
else
    fail "indexed callers never fall through when the Kotlin toolchain is missing (exit $status; stderr: $(tr '\n' ' ' <"$WORK/stderr"))"
fi

rm -rf "$NO_TOOLCHAIN_TARGET/.bd/index"
STRUCTURAL_INDEX_KOTLIN_TOOLCHAIN="$WORK/empty-toolchain" \
    "$INDEX" symbol renderBadge --repo "$NO_TOOLCHAIN_TARGET" >"$WORK/stdout" 2>"$WORK/stderr"
status=$?
if [ "$status" -eq 2 ] && grep -Fq "STRUCTURAL_INDEX_KOTLIN_TOOLCHAIN" "$WORK/stderr"; then
    pass "invalid toolchain directory exits 2 and names the variable"
else
    fail "invalid toolchain directory exits 2 and names the variable (exit $status; stderr: $(tr '\n' ' ' <"$WORK/stderr"))"
fi

echo ""
echo "Generation: unknown symbol, regeneration line, index layout, cache"
"$INDEX" symbol missingKotlinSymbol --repo "$TARGET" >"$WORK/stdout" 2>"$WORK/stderr"
status=$?
assert_eq "cold-cache unknown symbol exits 1" "1" "$status"
assert_eq "cold-cache unknown symbol has empty stdout" "" "$(cat "$WORK/stdout")"
assert_eq "cold-cache unknown symbol has one stderr line" "symbol not found: missingKotlinSymbol" "$(cat "$WORK/stderr")"
assert_eq "cold-cache unknown stderr line count" "1" "$(wc -l <"$WORK/stderr" | tr -d ' ')"
rm -rf "$TARGET/.bd/index"

"$INDEX" symbol renderBadge --repo "$TARGET" >"$WORK/stdout" 2>"$WORK/stderr"
status=$?
assert_eq "first query exits 0" "0" "$status"
assert_eq "symbol renderBadge output" $'src/Badge.kt\t5-7\t2c29a0936485' "$(cat "$WORK/stdout")"
if grep -Eq '^structural-index: regenerated Kotlin index in [0-9]+\.[0-9]{3}s$' "$WORK/stderr"; then
    pass "absent index reports Kotlin regeneration wall time"
else
    fail "absent index reports Kotlin regeneration wall time (got: $(cat "$WORK/stderr"))"
fi

layout="$(cd "$TARGET" && find .bd/index -type f -print | LC_ALL=C sort)"
assert_eq "Kotlin index directory layout" $'.bd/index/kotlin.json\n.bd/index/metadata.json' "$layout"
head_sha="$(git -C "$TARGET" rev-parse HEAD)"
recorded_sha="$(node -e 'process.stdout.write(JSON.parse(require("fs").readFileSync(process.argv[1], "utf8")).commit)' "$TARGET/.bd/index/metadata.json")"
assert_eq "Kotlin metadata records target HEAD" "$head_sha" "$recorded_sha"

"$INDEX" symbol renderBadge --repo "$TARGET" >"$WORK/stdout" 2>"$WORK/stderr"
assert_eq "same-HEAD query reuses index" "" "$(cat "$WORK/stderr")"

echo ""
echo "Definitions: spans and source-span hashes per declaration kind"
assert_query symbol renderBadge $'src/Badge.kt\t5-7\t2c29a0936485'
assert_query symbol BadgeCard.summarize $'src/Badge.kt\t16-18\td8bf719c7d9a'
assert_query symbol BadgeCard.renderBadge $'src/Badge.kt\t20-22\tb8be52aac3b7'
assert_query symbol BadgeRenderer.render $'src/Badge.kt\t10-10\t7d159d3b863b'
assert_query symbol BadgeRenderer $'src/Badge.kt\t9-11\tc6d643dee55f'
assert_query symbol BadgeCard $'src/Badge.kt\t13-23\t105abe7ea977'
assert_query symbol BadgeTheme $'src/Badge.kt\t25-27\t3b852239d76e'
assert_query symbol BADGE_LIMIT $'src/Badge.kt\t3-3\t7aa088ca0adc'
assert_query symbol orphanAnchor $'src/Badge.kt\t29-29\tde271773bf7f'
assert_query symbol badgeSummary $'src/BadgeConsumer.kt\t5-9\t3e2ad10b2145'
assert_query symbol themeAccent $'src/BadgeConsumer.kt\t11-11\ta627c5be1173'
assert_query symbol cardSummary $'src/BadgeConsumer.kt\t13-15\teb70d51a2866'
assert_query symbol badgeCardTest $'src/BadgeCardTest.kt\t3-10\t7d4403de2430'
assert_query symbol scenarioCheck $'src/BadgeTest/Scenario.kt\t3-5\tc56a9bd1d11a'

echo ""
echo "Callers: real call sites only — declarations, imports, comments, strings excluded"
assert_query callers renderBadge $'src/Badge.kt:17\nsrc/BadgeCardTest.kt:9\nsrc/BadgeConsumer.kt:8\nsrc/BadgeTest/Scenario.kt:4'
"$INDEX" callers renderBadge --repo "$TARGET" >"$WORK/stdout" 2>"$WORK/stderr"
if grep -Fq 'src/Badge.kt:20' "$WORK/stdout"; then
    fail "callers exclude the same-named method declared in a different scope"
else
    pass "callers exclude the same-named method declared in a different scope"
fi
if grep -Fq 'src/BadgeConsumer.kt:3' "$WORK/stdout" \
    || grep -Fq 'src/BadgeConsumer.kt:6' "$WORK/stdout" \
    || grep -Fq 'src/BadgeConsumer.kt:7' "$WORK/stdout"; then
    fail "callers exclude import, comment, and string mentions"
else
    pass "callers exclude import, comment, and string mentions"
fi
if grep -Fq 'answered by text search' "$WORK/stderr"; then
    fail "compiler callers write no text-answer stderr line"
else
    pass "compiler callers write no text-answer stderr line"
fi

assert_query callers BadgeCard.summarize $'src/BadgeCardTest.kt:8\nsrc/BadgeConsumer.kt:14'
assert_query callers BadgeRenderer.render 'src/Badge.kt:17'
assert_query callers BadgeRenderer $'src/Badge.kt:13\nsrc/BadgeCardTest.kt:4\nsrc/BadgeConsumer.kt:13'
assert_query callers BadgeCard $'src/BadgeCardTest.kt:7\nsrc/BadgeConsumer.kt:14'
assert_query callers BadgeTheme $'src/BadgeConsumer.kt:11\nsrc/BadgeTest/Scenario.kt:4'
assert_query callers BADGE_LIMIT 'src/Badge.kt:29'
assert_query callers orphanAnchor ""

echo ""
echo "Tests: only *Test.kt files and src/*Test/ path segments"
assert_query tests renderBadge $'src/BadgeCardTest.kt:9\nsrc/BadgeTest/Scenario.kt:4'
if grep -Fq 'src/BadgeConsumer.kt:8' "$WORK/stdout"; then
    fail "tests exclude the non-test file that references the name"
else
    pass "tests exclude the non-test file that references the name"
fi
assert_query tests BadgeCard.summarize 'src/BadgeCardTest.kt:8'
assert_query tests BadgeRenderer 'src/BadgeCardTest.kt:4'
assert_query tests orphanAnchor ""

echo ""
echo "Regeneration: changed HEAD regenerates, --regen observes a mutation"
printf 'package fixture\n\nfun extraAnchor(): Int = 1\n' >"$TARGET/src/Extra.kt"
git -C "$TARGET" add src/Extra.kt
git -C "$TARGET" commit -qm "change HEAD"
"$INDEX" symbol renderBadge --repo "$TARGET" >"$WORK/stdout" 2>"$WORK/stderr"
if grep -Eq '^structural-index: regenerated Kotlin index in [0-9]+\.[0-9]{3}s$' "$WORK/stderr"; then
    pass "changed HEAD regenerates Kotlin index"
else
    fail "changed HEAD regenerates Kotlin index (got: $(cat "$WORK/stderr"))"
fi
"$INDEX" symbol renderBadge --repo "$TARGET" >"$WORK/stdout" 2>"$WORK/stderr"
assert_eq "changed-HEAD regeneration is reusable" "" "$(cat "$WORK/stderr")"

cp "$TARGET/src/Badge.kt" "$WORK/Badge.kt"
node -e 'const fs=require("fs"),p=process.argv[1],s=fs.readFileSync(p,"utf8");fs.writeFileSync(p,s.replace(/\n}\n/, "\n    val added = true\n}\n"))' "$TARGET/src/Badge.kt"
"$INDEX" symbol renderBadge --repo "$TARGET" --regen >"$WORK/stdout" 2>"$WORK/stderr"
mutated="$(cat "$WORK/stdout")"
if printf '%s\n' "$mutated" | grep -Eq $'^src/Badge\.kt\\t5-8\\t[0-9a-f]{12}$'; then
    pass "mutation grows the definition span"
else
    fail "mutation grows the definition span (got: $mutated)"
fi
mutated_hash="${mutated##*$'\t'}"
if [ "$mutated_hash" != "2c29a0936485" ]; then
    pass "mutation changes the source hash"
else
    fail "mutation changes the source hash"
fi
if grep -Eq '^structural-index: regenerated Kotlin index in [0-9]+\.[0-9]{3}s$' "$WORK/stderr"; then
    pass "--regen forces Kotlin regeneration"
else
    fail "--regen forces Kotlin regeneration (got: $(cat "$WORK/stderr"))"
fi

cp "$WORK/Badge.kt" "$TARGET/src/Badge.kt"
"$INDEX" symbol renderBadge --repo "$TARGET" --regen >"$WORK/stdout" 2>"$WORK/stderr"
assert_eq "reverting mutation restores span and hash" $'src/Badge.kt\t5-7\t2c29a0936485' "$(cat "$WORK/stdout")"

echo ""
if [ "$FAILED" -eq 0 ]; then
    echo "All structural-index Kotlin tests passed ($PASSED assertions)."
    exit 0
else
    echo "$FAILED structural-index Kotlin test(s) FAILED ($PASSED assertions passed)."
    exit 1
fi
