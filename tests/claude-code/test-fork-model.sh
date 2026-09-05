#!/usr/bin/env bash
# Test: fork-model gate
# Verifies every skills/*/SKILL.md whose frontmatter carries `context: fork`
# also carries a `model:` line -- naming any file that does not -- and that
# the check can actually fail: a temporary fixture skill carrying
# `context: fork` with no `model:` line makes the check exit non-zero and
# name that file, with the fixture removed before the test returns on
# either path.
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

FAILED=0

pass() { echo "  [PASS] $1"; }
fail() { echo "  [FAIL] $1"; FAILED=$((FAILED + 1)); }

echo "========================================"
echo " Test: fork-model"
echo "========================================"
echo ""

# frontmatter_of <file> -- prints the YAML frontmatter lines (the delimiter
# lines excluded) of a SKILL.md file.
frontmatter_of() {
    awk 'NR==1 && $0=="---"{f=1; next} f && $0=="---"{exit} f{print}' "$1"
}

# check_fork_models <root> -- finds every <root>/skills/*/SKILL.md whose
# frontmatter carries `context: fork`, prints "missing model: <file>" for
# each that carries no `model:` line, and returns 1 if any were found.
check_fork_models() {
    local root="$1"
    local status=0
    local file fm
    while IFS= read -r file; do
        fm="$(frontmatter_of "$file")"
        if printf '%s\n' "$fm" | grep -q '^context: fork$'; then
            if ! printf '%s\n' "$fm" | grep -q '^model:'; then
                echo "missing model: $file"
                status=1
            fi
        fi
    done < <(find "$root" -type f -path '*/skills/*/SKILL.md' 2>/dev/null | sort)
    return $status
}

echo "Phase A: the real skills carrying context: fork all declare a model"
real_out="$(check_fork_models "$REPO_ROOT")"
real_status=$?
if [ "$real_status" -eq 0 ]; then
    pass "every skills/*/SKILL.md with context: fork carries a model: line"
else
    fail "every skills/*/SKILL.md with context: fork carries a model: line"
    echo "$real_out" | sed 's/^/    /'
fi

echo ""
echo "Phase B: the regime that can fail it -- a fixture missing model:"
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT
FIXTURE_DIR="$WORK/skills/fixture-fork"
FIXTURE_FILE="$FIXTURE_DIR/SKILL.md"
mkdir -p "$FIXTURE_DIR"
cat > "$FIXTURE_FILE" <<'EOF'
---
name: fixture-fork
description: A fixture skill with no model line
context: fork
---

# Fixture Fork
EOF

fixture_out="$(check_fork_models "$WORK")"
fixture_status=$?

if [ "$fixture_status" -ne 0 ]; then
    pass "fixture with context: fork and no model: line exits non-zero"
else
    fail "fixture with context: fork and no model: line exits non-zero"
fi

if printf '%s\n' "$fixture_out" | grep -qF "$FIXTURE_FILE"; then
    pass "the failing check names the fixture file"
else
    fail "the failing check names the fixture file"
    echo "$fixture_out" | sed 's/^/    /'
fi

rm -rf "$WORK"
trap - EXIT

if [ -e "$WORK" ]; then
    fail "fixture directory removed before the test returns"
else
    pass "fixture directory removed before the test returns"
fi

echo ""
if [ "$FAILED" -eq 0 ]; then
    echo "All fork-model tests passed."
    exit 0
else
    echo "$FAILED fork-model test(s) FAILED."
    exit 1
fi
