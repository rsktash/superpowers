#!/usr/bin/env bash
# Test: gate-lint hook
# Verifies the PreToolUse hook denies bd create/update --body-file commands
# whose body's Acceptance Gate section contains mechanism-phrased checklist
# items, quoting the offending lines -- and stays silent for outcome-phrased
# gates, mechanism wording outside the gate section, and unrelated commands.
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
HOOK="$REPO_ROOT/hooks/gate-lint"

FAILED=0

pass() { echo "  [PASS] $1"; }
fail() { echo "  [FAIL] $1"; FAILED=$((FAILED + 1)); }

echo "========================================"
echo " Test: gate-lint"
echo "========================================"
echo ""

if [ ! -x "$HOOK" ]; then
    echo "  [FAIL] hook missing or not executable: $HOOK"
    exit 1
fi

WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

# bd_event <command>
bd_event() {
    jq -cn --arg cmd "$1" \
        '{hook_event_name: "PreToolUse", tool_name: "Bash", tool_input: {command: $cmd}}'
}

# --- fixture: mechanism-phrased gate item (the observed dontBreakRows form) ---
cat > "$WORK/bad.md" <<'EOF'
Context anchor prose.

**Acceptance Gate:**
- [ ] `dontBreakRows` is set so one position's row group is never split across a page
- [ ] test_render_invoice passes

**Drift Detectors:** none.
EOF

out="$(bd_event "bd update solo-x.1 --body-file $WORK/bad.md" | bash "$HOOK")"
if printf '%s' "$out" | jq -e '.hookSpecificOutput.permissionDecision == "deny"' >/dev/null 2>&1; then
    pass "mechanism gate item -> deny"
else
    fail "mechanism gate item -> deny (got: $out)"
fi
if printf '%s' "$out" | grep -q "dontBreakRows"; then
    pass "deny reason quotes the offending line"
else
    fail "deny reason quotes the offending line"
fi

# --- fixture: outcome-phrased gates; mechanism wording only in Steps ---
cat > "$WORK/good.md" <<'EOF'
**Acceptance Gate:**
- [ ] a 40-position invoice renders 3 pages; no position's rows are split across a page boundary
- [ ] invalid token returns 401 with ErrorResponse body

**Steps:**
- [ ] Step 1: dontBreakRows is set in the table def -> gate: [item 1]
EOF

out="$(bd_event "bd update solo-x.1 --body-file $WORK/good.md" | bash "$HOOK")"
if [ -z "$out" ]; then
    pass "outcome gates + mechanism in Steps -> silent"
else
    fail "outcome gates + mechanism in Steps -> silent (got: $out)"
fi

# --- gate section ended by a markdown heading, not a bold label ---
cat > "$WORK/heading.md" <<'EOF'
## Acceptance Gate
- [ ] the handler is wired into the router

## Steps
- [ ] wire it
EOF

out="$(bd_event "bd create \"t\" --body-file $WORK/heading.md" | bash "$HOOK")"
if printf '%s' "$out" | jq -e '.hookSpecificOutput.permissionDecision == "deny"' >/dev/null 2>&1; then
    pass "heading-style gate section is scanned; bd create matched"
else
    fail "heading-style gate section is scanned; bd create matched (got: $out)"
fi

# --- unrelated bash command ---
out="$(bd_event "git status" | bash "$HOOK")"
if [ -z "$out" ]; then
    pass "non-bd command -> silent"
else
    fail "non-bd command -> silent (got: $out)"
fi

# --- bd command without a body file ---
out="$(bd_event "bd update solo-x.1 -l exec:inline" | bash "$HOOK")"
if [ -z "$out" ]; then
    pass "bd without --body-file -> silent"
else
    fail "bd without --body-file -> silent (got: $out)"
fi

# --- missing body file fails open ---
out="$(bd_event "bd update solo-x.1 --body-file $WORK/nonexistent.md" | bash "$HOOK")"
if [ -z "$out" ]; then
    pass "unreadable body file -> fails open"
else
    fail "unreadable body file -> fails open (got: $out)"
fi

echo ""
if [ "$FAILED" -eq 0 ]; then
    echo "All gate-lint tests passed."
    exit 0
else
    echo "$FAILED gate-lint test(s) FAILED."
    exit 1
fi
