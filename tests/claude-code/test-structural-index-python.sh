#!/usr/bin/env bash
# Test: structural-index Python backend
# Verifies ast + symtable definitions (module-level function, class method,
# class, module-level constant), span hashing over the definition span's
# source bytes, semantic caller sets with declaration, comment, string,
# import-statement, locally-shadowed, and same-name-different-scope
# exclusions, symtable's imported-name exemption, a zero-caller symbol,
# test-file filtering over test_*.py, *_test.py, and tests/ paths, cache
# regeneration, and the STRUCTURAL_INDEX_PYTHON_TOOLCHAIN resolution order
# (target repository virtual environment first, then the variable, else
# exit 2) per R-35 and R-31.
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
INDEX="$REPO_ROOT/scripts/structural-index"
FIXTURE="$REPO_ROOT/tests/fixtures/structural-index/python"

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
echo " Test: structural-index (Python)"
echo "========================================"
echo ""

if [ ! -x "$INDEX" ]; then
    echo "  [FAIL] script missing or not executable: $INDEX"
    exit 1
fi

# The Python backend resolves the interpreter from the target repository's
# own virtual environment first, then from this directory; without it the
# tests cannot run and the suite stays green through the skip.
python_toolchain="${STRUCTURAL_INDEX_PYTHON_TOOLCHAIN:-}"
if [ -z "$python_toolchain" ] || [ ! -f "$python_toolchain/bin/python3" ]; then
    echo "[SKIP] STRUCTURAL_INDEX_PYTHON_TOOLCHAIN unset or incomplete; Python backend tests skipped"
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

echo "Language roster: python reports the compiler backend, toolchain-free"
env -u STRUCTURAL_INDEX_PYTHON_TOOLCHAIN \
    "$INDEX" languages --repo "$TARGET" >"$WORK/stdout" 2>"$WORK/stderr"
status=$?
if [ "$status" -eq 0 ] \
    && [ "$(cat "$WORK/stdout")" = $'python\t5\tcompiler' ] \
    && [ ! -s "$WORK/stderr" ]; then
    pass "languages prints python as a compiler language without the toolchain"
else
    fail "languages prints python as a compiler language without the toolchain (exit $status; stdout: $(cat "$WORK/stdout"); stderr: $(tr '\n' ' ' <"$WORK/stderr"))"
fi

echo ""
echo "Toolchain resolution: repository virtual environment first, then the variable, else exit 2"
VENV_TARGET="$WORK/venv-repo"
mkdir -p "$VENV_TARGET"
cp -R "$FIXTURE/." "$VENV_TARGET/"
printf 'structurally-indexed==0\n' >"$VENV_TARGET/requirements.txt"
system_python="$(command -v python3)"
mkdir -p "$VENV_TARGET/.venv/bin"
ln -s "$system_python" "$VENV_TARGET/.venv/bin/python3"
git -C "$VENV_TARGET" init -q
git -C "$VENV_TARGET" config user.name "Structural Index Test"
git -C "$VENV_TARGET" config user.email "structural-index@example.test"
git -C "$VENV_TARGET" add .
git -C "$VENV_TARGET" commit -qm "fixture with its own virtual environment"

env -u STRUCTURAL_INDEX_PYTHON_TOOLCHAIN \
    "$INDEX" symbol renderBadge --repo "$VENV_TARGET" >"$WORK/stdout" 2>"$WORK/stderr"
status=$?
if [ "$status" -eq 0 ] && [ "$(cat "$WORK/stdout")" = $'src/badge.py\t4-5\t2fd9fcdf0ab2' ]; then
    pass "the repository virtual environment resolves the interpreter"
else
    fail "the repository virtual environment resolves the interpreter (exit $status; stdout: $(cat "$WORK/stdout"); stderr: $(tr '\n' ' ' <"$WORK/stderr"))"
fi

NO_TOOLCHAIN_TARGET="$WORK/no-toolchain-repo"
mkdir -p "$NO_TOOLCHAIN_TARGET"
cp -R "$FIXTURE/." "$NO_TOOLCHAIN_TARGET/"
git -C "$NO_TOOLCHAIN_TARGET" init -q
git -C "$NO_TOOLCHAIN_TARGET" config user.name "Structural Index Test"
git -C "$NO_TOOLCHAIN_TARGET" config user.email "structural-index@example.test"
git -C "$NO_TOOLCHAIN_TARGET" add .
git -C "$NO_TOOLCHAIN_TARGET" commit -qm "fixture without toolchain"

env -u STRUCTURAL_INDEX_PYTHON_TOOLCHAIN \
    "$INDEX" symbol renderBadge --repo "$NO_TOOLCHAIN_TARGET" >"$WORK/stdout" 2>"$WORK/stderr"
status=$?
if [ "$status" -eq 2 ] \
    && [ ! -s "$WORK/stdout" ] \
    && grep -Fq "STRUCTURAL_INDEX_PYTHON_TOOLCHAIN" "$WORK/stderr" \
    && [ "$(wc -l <"$WORK/stderr" | tr -d ' ')" -eq 1 ]; then
    pass "missing toolchain exits 2 with one stderr line naming the variable"
else
    fail "missing toolchain exits 2 with one stderr line naming the variable (exit $status; stdout: $(cat "$WORK/stdout"); stderr: $(tr '\n' ' ' <"$WORK/stderr"))"
fi

env -u STRUCTURAL_INDEX_PYTHON_TOOLCHAIN \
    "$INDEX" callers renderBadge --repo "$NO_TOOLCHAIN_TARGET" >"$WORK/stdout" 2>"$WORK/stderr"
status=$?
if [ "$status" -eq 2 ] && grep -Fq "STRUCTURAL_INDEX_PYTHON_TOOLCHAIN" "$WORK/stderr"; then
    pass "indexed callers never fall through when the Python toolchain is missing"
else
    fail "indexed callers never fall through when the Python toolchain is missing (exit $status; stderr: $(tr '\n' ' ' <"$WORK/stderr"))"
fi

rm -rf "$NO_TOOLCHAIN_TARGET/.bd/index"
STRUCTURAL_INDEX_PYTHON_TOOLCHAIN="$WORK/empty-toolchain" \
    "$INDEX" symbol renderBadge --repo "$NO_TOOLCHAIN_TARGET" >"$WORK/stdout" 2>"$WORK/stderr"
status=$?
if [ "$status" -eq 2 ] && grep -Fq "STRUCTURAL_INDEX_PYTHON_TOOLCHAIN" "$WORK/stderr"; then
    pass "invalid toolchain directory exits 2 and names the variable"
else
    fail "invalid toolchain directory exits 2 and names the variable (exit $status; stderr: $(tr '\n' ' ' <"$WORK/stderr"))"
fi

echo ""
echo "Generation: unknown symbol, regeneration line, index layout, cache"
"$INDEX" symbol missingPythonSymbol --repo "$TARGET" >"$WORK/stdout" 2>"$WORK/stderr"
status=$?
assert_eq "cold-cache unknown symbol exits 1" "1" "$status"
assert_eq "cold-cache unknown symbol has empty stdout" "" "$(cat "$WORK/stdout")"
assert_eq "cold-cache unknown symbol has one stderr line" "symbol not found: missingPythonSymbol" "$(cat "$WORK/stderr")"
assert_eq "cold-cache unknown stderr line count" "1" "$(wc -l <"$WORK/stderr" | tr -d ' ')"
rm -rf "$TARGET/.bd/index"

"$INDEX" symbol renderBadge --repo "$TARGET" >"$WORK/stdout" 2>"$WORK/stderr"
status=$?
assert_eq "first query exits 0" "0" "$status"
assert_eq "symbol renderBadge output" $'src/badge.py\t4-5\t2fd9fcdf0ab2' "$(cat "$WORK/stdout")"
if grep -Eq '^structural-index: regenerated Python index in [0-9]+\.[0-9]{3}s$' "$WORK/stderr"; then
    pass "absent index reports Python regeneration wall time"
else
    fail "absent index reports Python regeneration wall time (got: $(cat "$WORK/stderr"))"
fi

layout="$(cd "$TARGET" && find .bd/index -type f -print | LC_ALL=C sort)"
assert_eq "Python index directory layout" $'.bd/index/metadata.json\n.bd/index/python.json' "$layout"
head_sha="$(git -C "$TARGET" rev-parse HEAD)"
recorded_sha="$(node -e 'process.stdout.write(JSON.parse(require("fs").readFileSync(process.argv[1], "utf8")).commit)' "$TARGET/.bd/index/metadata.json")"
assert_eq "Python metadata records target HEAD" "$head_sha" "$recorded_sha"

"$INDEX" symbol renderBadge --repo "$TARGET" >"$WORK/stdout" 2>"$WORK/stderr"
assert_eq "same-HEAD query reuses index" "" "$(cat "$WORK/stderr")"

echo ""
echo "Definitions: spans and source-span hashes per declaration kind"
assert_query symbol renderBadge $'src/badge.py\t4-5\t2fd9fcdf0ab2'
assert_query symbol orphanAnchor $'src/badge.py\t16-17\tf3af0a987fce'
assert_query symbol BadgeCard $'src/badge.py\t8-13\t20a0f99b5cbd'
assert_query symbol BadgeCard.summarize $'src/badge.py\t9-10\t7d5f5edd0c4b'
assert_query symbol BadgeCard.renderBadge $'src/badge.py\t12-13\t3448dd38c716'
assert_query symbol BADGE_LIMIT $'src/badge.py\t1-1\t703741124109'

echo ""
echo "Callers: real call sites only — declarations, comments, strings, imports, shadows, and other-scope names excluded"
assert_query callers renderBadge $'src/badge_test.py:2\nsrc/badge.py:10\nsrc/consumer.py:4\nsrc/consumer.py:19\nsrc/test_badge.py:2\nsrc/tests/scenario.py:2'
"$INDEX" callers renderBadge --repo "$TARGET" >"$WORK/stdout" 2>"$WORK/stderr"
if grep -Fq 'src/badge.py:12' "$WORK/stdout"; then
    fail "callers exclude the same-named method declared in a different scope"
else
    pass "callers exclude the same-named method declared in a different scope"
fi
if grep -Fq 'src/consumer.py:13' "$WORK/stdout"; then
    fail "callers exclude the locally shadowed call site"
else
    pass "callers exclude the locally shadowed call site"
fi
if grep -Fq 'src/consumer.py:2' "$WORK/stdout" \
    || grep -Fq 'src/consumer.py:3' "$WORK/stdout" \
    || grep -Fq 'src/consumer.py:17' "$WORK/stdout" \
    || grep -Fq 'src/consumer.py:23' "$WORK/stdout"; then
    fail "callers exclude comment, string, import-statement, and attribute-call mentions"
else
    pass "callers exclude comment, string, import-statement, and attribute-call mentions"
fi
if ! grep -Fq 'src/consumer.py:19' "$WORK/stdout"; then
    fail "callers keep the imported-name call site (symtable exemption)"
else
    pass "callers keep the imported-name call site (symtable exemption)"
fi
if grep -Fq 'answered by text search' "$WORK/stderr"; then
    fail "compiler callers write no text-answer stderr line"
else
    pass "compiler callers write no text-answer stderr line"
fi

assert_query callers BadgeCard.summarize 'src/test_badge.py:11'
assert_query callers BadgeCard.renderBadge $'src/badge_test.py:7\nsrc/consumer.py:23'
assert_query callers BadgeCard $'src/badge_test.py:6\nsrc/test_badge.py:10'
assert_query callers BADGE_LIMIT $'src/badge.py:17\nsrc/consumer.py:8\nsrc/test_badge.py:6'
assert_query callers orphanAnchor ""

echo ""
echo "Tests: only test_*.py files, *_test.py files, and tests/ path segments"
assert_query tests renderBadge $'src/badge_test.py:2\nsrc/test_badge.py:2\nsrc/tests/scenario.py:2'
if grep -Fq 'src/consumer.py:4' "$WORK/stdout"; then
    fail "tests exclude the non-test file that references the name"
else
    pass "tests exclude the non-test file that references the name"
fi
assert_query tests BadgeCard $'src/badge_test.py:6\nsrc/test_badge.py:10'
assert_query tests BadgeCard.summarize 'src/test_badge.py:11'
assert_query tests BADGE_LIMIT 'src/test_badge.py:6'
assert_query tests orphanAnchor ""

echo ""
echo "Regeneration: changed HEAD regenerates, --regen observes a mutation"
printf 'def extraAnchor():\n    return 1\n' >"$TARGET/src/extra.py"
git -C "$TARGET" add src/extra.py
git -C "$TARGET" commit -qm "change HEAD"
"$INDEX" symbol renderBadge --repo "$TARGET" >"$WORK/stdout" 2>"$WORK/stderr"
if grep -Eq '^structural-index: regenerated Python index in [0-9]+\.[0-9]{3}s$' "$WORK/stderr"; then
    pass "changed HEAD regenerates Python index"
else
    fail "changed HEAD regenerates Python index (got: $(cat "$WORK/stderr"))"
fi
"$INDEX" symbol renderBadge --repo "$TARGET" >"$WORK/stdout" 2>"$WORK/stderr"
assert_eq "changed-HEAD regeneration is reusable" "" "$(cat "$WORK/stderr")"

cp "$TARGET/src/badge.py" "$WORK/badge.py"
node -e 'const fs=require("fs"),p=process.argv[1],s=fs.readFileSync(p,"utf8");fs.writeFileSync(p,s.replace("    return \"[{}]\".format(label)", "    wrapped = \"[{}]\".format(label)\n    return wrapped"))' "$TARGET/src/badge.py"
"$INDEX" symbol renderBadge --repo "$TARGET" --regen >"$WORK/stdout" 2>"$WORK/stderr"
mutated="$(cat "$WORK/stdout")"
if printf '%s\n' "$mutated" | grep -Eq $'^src/badge\.py\\t4-6\\t[0-9a-f]{12}$'; then
    pass "mutation grows the definition span"
else
    fail "mutation grows the definition span (got: $mutated)"
fi
mutated_hash="${mutated##*$'\t'}"
if [ "$mutated_hash" != "2fd9fcdf0ab2" ]; then
    pass "mutation changes the source hash"
else
    fail "mutation changes the source hash"
fi
if grep -Eq '^structural-index: regenerated Python index in [0-9]+\.[0-9]{3}s$' "$WORK/stderr"; then
    pass "--regen forces Python regeneration"
else
    fail "--regen forces Python regeneration (got: $(cat "$WORK/stderr"))"
fi

cp "$WORK/badge.py" "$TARGET/src/badge.py"
"$INDEX" symbol renderBadge --repo "$TARGET" --regen >"$WORK/stdout" 2>"$WORK/stderr"
assert_eq "reverting mutation restores span and hash" $'src/badge.py\t4-5\t2fd9fcdf0ab2' "$(cat "$WORK/stdout")"

echo ""
if [ "$FAILED" -eq 0 ]; then
    echo "All structural-index Python tests passed ($PASSED assertions)."
    exit 0
else
    echo "$FAILED structural-index Python test(s) FAILED ($PASSED assertions passed)."
    exit 1
fi
