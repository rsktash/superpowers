#!/usr/bin/env bash
# Test: fail-streak-guard hook
# Verifies the PostToolUse hook injects an advisory additionalContext once a
# Bash command class has failed CC_FAIL_STREAK_MAX (default 2) times in a
# row, resets on success or a different command class, ignores non-Bash
# tools, and fails open on garbage/empty input.
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
HOOK="$REPO_ROOT/hooks/fail-streak-guard"

FAILED=0

pass() { echo "  [PASS] $1"; }
fail() { echo "  [FAIL] $1"; FAILED=$((FAILED + 1)); }

echo "========================================"
echo " Test: fail-streak-guard"
echo "========================================"
echo ""

if [ ! -x "$HOOK" ]; then
    echo "  [FAIL] hook missing or not executable: $HOOK"
    exit 1
fi

STATE_DIR="${TMPDIR:-/tmp}/cc-fail-streak"

# event <session> <command> <exit_code_or_empty> [tool_name]
event() {
    local session="$1"
    local command="$2"
    local exit_code="$3"
    local tool="${4:-Bash}"

    if [ -n "$exit_code" ]; then
        jq -cn --arg session "$session" --arg cmd "$command" --arg tool "$tool" --argjson ec "$exit_code" \
            '{session_id: $session, hook_event_name: "PostToolUse", tool_name: $tool, tool_input: {command: $cmd}, tool_response: {exit_code: $ec}}'
    else
        jq -cn --arg session "$session" --arg cmd "$command" --arg tool "$tool" \
            '{session_id: $session, hook_event_name: "PostToolUse", tool_name: $tool, tool_input: {command: $cmd}, tool_response: {}}'
    fi
}

reset_state() {
    rm -rf "$STATE_DIR"
}

echo "Test (a): two failures, same class -> additionalContext fires"
reset_state
SESSION="fsg-test-a"
out1=$(event "$SESSION" "pytest -n4 tests/x" 1 | "$HOOK")
out2=$(event "$SESSION" "pytest tests/y" 1 | "$HOOK")
if [ -z "$out1" ]; then
    pass "first failure: no output"
else
    fail "first failure: no output (got: $out1)"
fi
if echo "$out2" | grep -q "fail-streak-guard"; then
    pass "second failure (same class): output contains fail-streak-guard"
else
    fail "second failure (same class): output contains fail-streak-guard (got: $out2)"
fi

echo ""
echo "Test (b): failure, success, failure (same class) -> no output on last"
reset_state
SESSION="fsg-test-b"
b1=$(event "$SESSION" "npm test" 1 | "$HOOK")
b2=$(event "$SESSION" "npm test" 0 | "$HOOK")
b3=$(event "$SESSION" "npm test" 1 | "$HOOK")
if [ -z "$b1" ] && [ -z "$b2" ] && [ -z "$b3" ]; then
    pass "failure, success, failure: no output on any step"
else
    fail "failure, success, failure: no output on any step (got: b1=[$b1] b2=[$b2] b3=[$b3])"
fi

echo ""
echo "Test (c): two failures, different classes -> no output"
reset_state
SESSION="fsg-test-c"
c1=$(event "$SESSION" "npm test" 1 | "$HOOK")
c2=$(event "$SESSION" "git commit" 1 | "$HOOK")
if [ -z "$c1" ] && [ -z "$c2" ]; then
    pass "different classes: no output"
else
    fail "different classes: no output (got: c1=[$c1] c2=[$c2])"
fi

echo ""
echo "Test (d): garbage/empty input -> exit 0, no output"
reset_state
d1_out=$(printf '' | "$HOOK")
d1_exit=$?
d2_out=$(printf 'not json at all {{{' | "$HOOK")
d2_exit=$?
if [ "$d1_exit" -eq 0 ] && [ -z "$d1_out" ]; then
    pass "empty input: exit 0, no output"
else
    fail "empty input: exit 0, no output (exit=$d1_exit, out=[$d1_out])"
fi
if [ "$d2_exit" -eq 0 ] && [ -z "$d2_out" ]; then
    pass "garbage input: exit 0, no output"
else
    fail "garbage input: exit 0, no output (exit=$d2_exit, out=[$d2_out])"
fi

echo ""
echo "Test (e): non-Bash tool failures -> no output"
reset_state
SESSION="fsg-test-e"
e1=$(event "$SESSION" "irrelevant" 1 "Edit" | "$HOOK")
e2=$(event "$SESSION" "irrelevant" 1 "Edit" | "$HOOK")
if [ -z "$e1" ] && [ -z "$e2" ]; then
    pass "non-Bash tool: no output"
else
    fail "non-Bash tool: no output (got: e1=[$e1] e2=[$e2])"
fi

reset_state

echo ""
echo "========================================"
if [ "$FAILED" -eq 0 ]; then
    echo "STATUS: PASSED"
    exit 0
else
    echo "STATUS: FAILED ($FAILED failure(s))"
    exit 1
fi
