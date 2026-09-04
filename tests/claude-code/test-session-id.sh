#!/usr/bin/env bash
# Test: session-id hook
# Verifies the SessionStart hook appends exactly one
# `export BD_SESSION_ID=<id>` line to $CLAUDE_ENV_FILE per session id,
# stays silent on stdout on every run, and fails open (exit 0, no write)
# on every input it cannot use.
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
HOOK="$REPO_ROOT/hooks/session-id"

FAILED=0

pass() { echo "  [PASS] $1"; }
fail() { echo "  [FAIL] $1"; FAILED=$((FAILED + 1)); }

echo "========================================"
echo " Test: session-id"
echo "========================================"
echo ""

if [ ! -x "$HOOK" ]; then
    echo "  [FAIL] hook missing or not executable: $HOOK"
    exit 1
fi

# session_start_payload <session_id>
session_start_payload() {
    local session="$1"
    jq -cn --arg session "$session" \
        '{session_id: $session, hook_event_name: "SessionStart", source: "startup"}'
}

run_hook_in() {
    # run_hook_in <workdir> <env_file_or_empty> <payload>
    local workdir="$1"
    local env_file="$2"
    local payload="$3"
    if [ -n "$env_file" ]; then
        (cd "$workdir" && export CLAUDE_ENV_FILE="$env_file" && printf '%s' "$payload" | "$HOOK")
    else
        (cd "$workdir" && unset CLAUDE_ENV_FILE && printf '%s' "$payload" | "$HOOK")
    fi
}

echo "Test (a): session_id present -- one export line appears, stdout empty, exit 0"
WORKDIR=$(mktemp -d)
ENV_FILE=$(mktemp)
: > "$ENV_FILE"
SID="sess-aaa-111"
out=$(run_hook_in "$WORKDIR" "$ENV_FILE" "$(session_start_payload "$SID")")
rc=$?
if [ "$rc" -eq 0 ]; then
    pass "exit 0"
else
    fail "exit 0 (got $rc)"
fi
if [ -z "$out" ]; then
    pass "stdout empty"
else
    fail "stdout empty (got: $out)"
fi
count=$(grep -cF "export BD_SESSION_ID=${SID}" "$ENV_FILE" || true)
if [ "$count" -eq 1 ]; then
    pass "exactly one export BD_SESSION_ID line carrying the id"
else
    fail "exactly one export BD_SESSION_ID line carrying the id (found $count)"
fi
rm -rf "$WORKDIR" "$ENV_FILE"

echo ""
echo "Test (b): session_id absent from payload -- no line written, exit 0, stdout empty"
WORKDIR=$(mktemp -d)
ENV_FILE=$(mktemp)
: > "$ENV_FILE"
payload_no_id=$(jq -cn '{hook_event_name: "SessionStart", source: "startup"}')
out=$(run_hook_in "$WORKDIR" "$ENV_FILE" "$payload_no_id")
rc=$?
if [ "$rc" -eq 0 ]; then
    pass "exit 0"
else
    fail "exit 0 (got $rc)"
fi
if [ -z "$out" ]; then
    pass "stdout empty"
else
    fail "stdout empty (got: $out)"
fi
if [ ! -s "$ENV_FILE" ]; then
    pass "no BD_SESSION_ID line written"
else
    fail "no BD_SESSION_ID line written (got: $(cat "$ENV_FILE"))"
fi
rm -rf "$WORKDIR" "$ENV_FILE"

echo ""
echo "Test (c): empty stdin -- no line written, exit 0, stdout empty"
WORKDIR=$(mktemp -d)
ENV_FILE=$(mktemp)
: > "$ENV_FILE"
out=$(run_hook_in "$WORKDIR" "$ENV_FILE" "")
rc=$?
if [ "$rc" -eq 0 ]; then
    pass "exit 0"
else
    fail "exit 0 (got $rc)"
fi
if [ -z "$out" ]; then
    pass "stdout empty"
else
    fail "stdout empty (got: $out)"
fi
if [ ! -s "$ENV_FILE" ]; then
    pass "no BD_SESSION_ID line written"
else
    fail "no BD_SESSION_ID line written (got: $(cat "$ENV_FILE"))"
fi
rm -rf "$WORKDIR" "$ENV_FILE"

echo ""
echo "Test (d): unparseable stdin -- no line written, exit 0, stdout empty"
WORKDIR=$(mktemp -d)
ENV_FILE=$(mktemp)
: > "$ENV_FILE"
out=$(run_hook_in "$WORKDIR" "$ENV_FILE" "not json at all {{{")
rc=$?
if [ "$rc" -eq 0 ]; then
    pass "exit 0"
else
    fail "exit 0 (got $rc)"
fi
if [ -z "$out" ]; then
    pass "stdout empty"
else
    fail "stdout empty (got: $out)"
fi
if [ ! -s "$ENV_FILE" ]; then
    pass "no BD_SESSION_ID line written"
else
    fail "no BD_SESSION_ID line written (got: $(cat "$ENV_FILE"))"
fi
rm -rf "$WORKDIR" "$ENV_FILE"

echo ""
echo "Test (e): CLAUDE_ENV_FILE unset -- no failure under set -u, exit 0, stdout empty"
WORKDIR=$(mktemp -d)
SID="sess-bbb-222"
out=$(run_hook_in "$WORKDIR" "" "$(session_start_payload "$SID")")
rc=$?
if [ "$rc" -eq 0 ]; then
    pass "exit 0 with CLAUDE_ENV_FILE unset"
else
    fail "exit 0 with CLAUDE_ENV_FILE unset (got $rc)"
fi
if [ -z "$out" ]; then
    pass "stdout empty with CLAUDE_ENV_FILE unset"
else
    fail "stdout empty with CLAUDE_ENV_FILE unset (got: $out)"
fi
rm -rf "$WORKDIR"

echo ""
echo "Test (f): a second run under the same id does not double the line; a later run under a different id appends its own"
WORKDIR=$(mktemp -d)
ENV_FILE=$(mktemp)
: > "$ENV_FILE"
SID="sess-ccc-333"
run_hook_in "$WORKDIR" "$ENV_FILE" "$(session_start_payload "$SID")" >/dev/null
out=$(run_hook_in "$WORKDIR" "$ENV_FILE" "$(session_start_payload "$SID")")
rc=$?
if [ "$rc" -eq 0 ]; then
    pass "exit 0 on repeat run"
else
    fail "exit 0 on repeat run (got $rc)"
fi
if [ -z "$out" ]; then
    pass "stdout empty on repeat run"
else
    fail "stdout empty on repeat run (got: $out)"
fi
count=$(grep -cF "export BD_SESSION_ID=${SID}" "$ENV_FILE" || true)
if [ "$count" -eq 1 ]; then
    pass "repeat run under the same id does not double the line"
else
    fail "repeat run under the same id does not double the line (found $count)"
fi
OTHER_SID="sess-ddd-444"
run_hook_in "$WORKDIR" "$ENV_FILE" "$(session_start_payload "$OTHER_SID")" >/dev/null
count_other=$(grep -cF "export BD_SESSION_ID=${OTHER_SID}" "$ENV_FILE" || true)
if [ "$count_other" -eq 1 ]; then
    pass "a later run under a different id appends its own line"
else
    fail "a later run under a different id appends its own line (found $count_other)"
fi
count_first=$(grep -cF "export BD_SESSION_ID=${SID}" "$ENV_FILE" || true)
if [ "$count_first" -eq 1 ]; then
    pass "the first id's line is still present exactly once"
else
    fail "the first id's line is still present exactly once (found $count_first)"
fi
rm -rf "$WORKDIR" "$ENV_FILE"

echo ""
echo "Test (g): hooks/session-start stays unwired in hooks/hooks.json"
HOOKS_JSON="$REPO_ROOT/hooks/hooks.json"
if jq -e '[.hooks[][] | .hooks[]?.command // empty] | map(select(test("session-start"))) | length == 0' "$HOOKS_JSON" >/dev/null 2>&1; then
    pass "no hooks.json entry invokes hooks/session-start"
else
    fail "no hooks.json entry invokes hooks/session-start"
fi

echo ""
echo "========================================"
if [ "$FAILED" -eq 0 ]; then
    echo "STATUS: PASSED"
    exit 0
else
    echo "STATUS: FAILED ($FAILED failure(s))"
    exit 1
fi
