#!/usr/bin/env bash
# Test: review-package script
# Verifies it freezes a task's net diff (commit list, stat summary, full
# diff) into a file under .bd/.scratch/ and prints only the outfile path.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
SCRIPT="$REPO_ROOT/skills/subagent-driven-development/scripts/review-package"

FAILED=0

pass() { echo "  [PASS] $1"; }
fail() { echo "  [FAIL] $1"; FAILED=$((FAILED + 1)); }

echo "========================================"
echo " Test: review-package"
echo "========================================"
echo ""

if [ ! -x "$SCRIPT" ]; then
    echo "  [FAIL] script missing or not executable: $SCRIPT"
    exit 1
fi

# Set up a throwaway git repo with two commits.
TEST_DIR=$(mktemp -d "${TMPDIR:-/tmp}/review-package-test.XXXXXX")
trap 'rm -rf "$TEST_DIR"' EXIT

cd "$TEST_DIR"
TEST_DIR=$(pwd -P)  # resolve symlinks (e.g. macOS /tmp -> /private/tmp) to match git's toplevel path
git init --quiet
git config user.email "test@test.com"
git config user.name "Test User"

echo "line one" > file.txt
git add file.txt
git commit --quiet -m "Initial commit"
BASE=$(git rev-parse HEAD)

echo "line one" > file.txt
echo "added line" >> file.txt
git add file.txt
git commit --quiet -m "Add a second line"
HEAD_REV=$(git rev-parse HEAD)

echo "Test 1: default outfile is produced and printed as the only stdout line"
STDOUT_OUTPUT=$("$SCRIPT" "$BASE" "$HEAD_REV")
LINE_COUNT=$(echo "$STDOUT_OUTPUT" | wc -l | tr -d ' ')
if [ "$LINE_COUNT" -eq 1 ]; then
    pass "stdout is exactly one line"
else
    fail "stdout is exactly one line (got $LINE_COUNT lines: $STDOUT_OUTPUT)"
fi

OUTFILE="$STDOUT_OUTPUT"

if [ -f "$OUTFILE" ]; then
    pass "outfile exists at printed path"
else
    fail "outfile exists at printed path ($OUTFILE)"
fi

case "$OUTFILE" in
    "$TEST_DIR"/.bd/.scratch/review-*..*.diff)
        pass "outfile path follows .bd/.scratch/review-<base7>..<head7>.diff convention"
        ;;
    *)
        fail "outfile path follows .bd/.scratch/review-<base7>..<head7>.diff convention (got $OUTFILE)"
        ;;
esac

echo ""
echo "Test 2: outfile contains commit subject and a diff addition line"
if grep -q "Add a second line" "$OUTFILE"; then
    pass "outfile contains commit subject"
else
    fail "outfile contains commit subject"
fi

if grep -q "^+added line" "$OUTFILE"; then
    pass "outfile contains +-prefixed diff line"
else
    fail "outfile contains +-prefixed diff line"
fi

echo ""
echo "Test 3: custom OUTFILE argument is honored"
CUSTOM_OUT="$TEST_DIR/custom-review.diff"
STDOUT_CUSTOM=$("$SCRIPT" "$BASE" "$HEAD_REV" "$CUSTOM_OUT")
if [ "$STDOUT_CUSTOM" = "$CUSTOM_OUT" ] && [ -f "$CUSTOM_OUT" ]; then
    pass "custom outfile path honored and printed"
else
    fail "custom outfile path honored and printed (got $STDOUT_CUSTOM)"
fi

echo ""
echo "Test 4: bad ref exits 2"
set +e
"$SCRIPT" "not-a-real-ref" "$HEAD_REV" >/tmp/review-package-bad-ref.out 2>&1
BAD_REF_EXIT=$?
set -e
if [ "$BAD_REF_EXIT" -eq 2 ]; then
    pass "bad ref exits 2"
else
    fail "bad ref exits 2 (got exit $BAD_REF_EXIT)"
fi
rm -f /tmp/review-package-bad-ref.out

echo ""
echo "Test 5: wrong arg count exits 2"
set +e
"$SCRIPT" "$BASE" >/tmp/review-package-argcount.out 2>&1
ARGCOUNT_EXIT=$?
set -e
if [ "$ARGCOUNT_EXIT" -eq 2 ]; then
    pass "wrong arg count exits 2"
else
    fail "wrong arg count exits 2 (got exit $ARGCOUNT_EXIT)"
fi
rm -f /tmp/review-package-argcount.out

echo ""
echo "========================================"
if [ "$FAILED" -eq 0 ]; then
    echo "STATUS: PASSED"
    exit 0
else
    echo "STATUS: FAILED ($FAILED failure(s))"
    exit 1
fi
