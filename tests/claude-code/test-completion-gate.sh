#!/usr/bin/env bash
# Test: completion-gate hook
# Verifies the hook (registered on both PreToolUse and PostToolUse) tracks
# per-session last_edit / last_verify timestamps and injects an advisory
# additionalContext on a PreToolUse `bd close` / `git commit` event when code
# changed since the last passing verification run. Always permissionDecision
# "allow" -- advisory only, never blocks.
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
HOOK="$REPO_ROOT/hooks/completion-gate"

FAILED=0

pass() { echo "  [PASS] $1"; }
fail() { echo "  [FAIL] $1"; FAILED=$((FAILED + 1)); }

echo "========================================"
echo " Test: completion-gate"
echo "========================================"
echo ""

if [ ! -x "$HOOK" ]; then
    echo "  [FAIL] hook missing or not executable: $HOOK"
    exit 1
fi

STATE_ROOT="${TMPDIR:-/tmp}/cc-completion-gate"

reset_state() {
    rm -rf "$STATE_ROOT"
}

# edit_event <session> <file_path> [tool_name]
edit_event() {
    local session="$1"
    local file_path="$2"
    local tool="${3:-Edit}"
    jq -cn --arg session "$session" --arg path "$file_path" --arg tool "$tool" \
        '{session_id: $session, hook_event_name: "PostToolUse", tool_name: $tool, tool_input: {file_path: $path}, tool_response: {}}'
}

# verify_event <session> <command> <exit_code>
verify_event() {
    local session="$1"
    local command="$2"
    local exit_code="$3"
    jq -cn --arg session "$session" --arg cmd "$command" --argjson ec "$exit_code" \
        '{session_id: $session, hook_event_name: "PostToolUse", tool_name: "Bash", tool_input: {command: $cmd}, tool_response: {exit_code: $ec}}'
}

# commit_event <session> <command>
commit_event() {
    local session="$1"
    local command="$2"
    jq -cn --arg session "$session" --arg cmd "$command" \
        '{session_id: $session, hook_event_name: "PreToolUse", tool_name: "Bash", tool_input: {command: $cmd}}'
}

echo "Test (a): code edit (.py) then git commit PreToolUse -> context injected"
reset_state
SESSION="cg-test-a"
edit_event "$SESSION" "src/foo.py" | "$HOOK" >/dev/null
sleep 0.05
out=$(commit_event "$SESSION" "git commit -m 'x'" | "$HOOK")
if echo "$out" | grep -q "completion-gate"; then
    pass "code edit then commit: context injected containing completion-gate"
else
    fail "code edit then commit: context injected containing completion-gate (got: $out)"
fi
if echo "$out" | jq -e '.hookSpecificOutput.permissionDecision == "allow"' >/dev/null 2>&1; then
    pass "code edit then commit: permissionDecision is allow"
else
    fail "code edit then commit: permissionDecision is allow (got: $out)"
fi

echo ""
echo "Test (b): code edit, passing pytest, then commit -> silent"
reset_state
SESSION="cg-test-b"
edit_event "$SESSION" "src/foo.py" | "$HOOK" >/dev/null
sleep 0.05
verify_event "$SESSION" "pytest tests/test_foo.py" 0 | "$HOOK" >/dev/null
sleep 0.05
out=$(commit_event "$SESSION" "git commit -m 'x'" | "$HOOK")
if [ -z "$out" ]; then
    pass "edit then passing verify then commit: silent"
else
    fail "edit then passing verify then commit: silent (got: $out)"
fi

echo ""
echo "Test (c): doc-only edit (.md) then commit -> silent"
reset_state
SESSION="cg-test-c"
edit_event "$SESSION" "README.md" | "$HOOK" >/dev/null
sleep 0.05
out=$(commit_event "$SESSION" "git commit -m 'docs'" | "$HOOK")
if [ -z "$out" ]; then
    pass "doc-only edit then commit: silent"
else
    fail "doc-only edit then commit: silent (got: $out)"
fi

echo ""
echo "Test (d): commit with no prior events -> silent"
reset_state
SESSION="cg-test-d"
out=$(commit_event "$SESSION" "git commit -m 'x'" | "$HOOK")
if [ -z "$out" ]; then
    pass "commit with no prior events: silent"
else
    fail "commit with no prior events: silent (got: $out)"
fi

echo ""
echo "Test (e): garbage/empty input -> exit 0, no output"
reset_state
e1_out=$(printf '' | "$HOOK")
e1_exit=$?
e2_out=$(printf 'not json at all {{{' | "$HOOK")
e2_exit=$?
if [ "$e1_exit" -eq 0 ] && [ -z "$e1_out" ]; then
    pass "empty input: exit 0, no output"
else
    fail "empty input: exit 0, no output (exit=$e1_exit, out=[$e1_out])"
fi
if [ "$e2_exit" -eq 0 ] && [ -z "$e2_out" ]; then
    pass "garbage input: exit 0, no output"
else
    fail "garbage input: exit 0, no output (exit=$e2_exit, out=[$e2_out])"
fi

echo ""
echo "Test (f): edit AFTER a passing verify, then commit -> fires (last_verify older than last_edit)"
# bash's [ -nt ] has whole-SECOND resolution (not sub-second), so the two
# touches being compared must straddle a second boundary.
reset_state
SESSION="cg-test-f"
edit_event "$SESSION" "src/foo.py" | "$HOOK" >/dev/null
sleep 0.05
verify_event "$SESSION" "pytest tests/test_foo.py" 0 | "$HOOK" >/dev/null
sleep 1.1
edit_event "$SESSION" "src/bar.py" | "$HOOK" >/dev/null
sleep 0.05
out=$(commit_event "$SESSION" "git commit -m 'x'" | "$HOOK")
if echo "$out" | grep -q "completion-gate"; then
    pass "edit after passing verify then commit: fires"
else
    fail "edit after passing verify then commit: fires (got: $out)"
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
