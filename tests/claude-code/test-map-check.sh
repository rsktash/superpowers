#!/usr/bin/env bash
# Test: map-check script
# Verifies task-row and seam-row selection, both Hash cell forms, all six
# line shapes (fresh / STALE / CHECK / GONE / NEW / seam), commit
# attribution via git log, one-hop CHECK seeding, exit codes (0, 1, 2),
# tracker-free operation (no bd on PATH, no bd in the script), and the
# unindexed-language header lines (roster order, other excluded, none
# when every language is indexed, exit 1 when the languages query fails).
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
MAP_CHECK="$REPO_ROOT/scripts/map-check"
INDEX="$REPO_ROOT/scripts/structural-index"
FIXTURE="$REPO_ROOT/tests/fixtures/structural-index/ts"
MIXED_FIXTURE="$REPO_ROOT/tests/fixtures/structural-index/mixed"

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

assert_status() {
    local label="$1" expected="$2" actual="$3"
    if [ "$actual" -eq "$expected" ]; then
        pass "$label"
    else
        fail "$label (expected exit $expected, got $actual)"
    fi
}

assert_grep() {
    local label="$1" pattern="$2" text="$3"
    if printf '%s\n' "$text" | grep -q "$pattern"; then
        pass "$label"
    else
        fail "$label (no match for: $pattern)"
    fi
}

assert_not_grep() {
    local label="$1" pattern="$2" text="$3"
    if printf '%s\n' "$text" | grep -q "$pattern"; then
        fail "$label (unexpected match for: $pattern)"
    else
        pass "$label"
    fi
}

echo "========================================"
echo " Test: map-check"
echo "========================================"
echo ""

if [ ! -x "$MAP_CHECK" ]; then
    echo "  [FAIL] script missing or not executable: $MAP_CHECK"
    exit 1
fi
if grep -q bd "$MAP_CHECK"; then
    fail "script contains no bd invocation (grep)"
else
    pass "script contains no bd invocation (grep)"
fi

WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT
TARGET="$WORK/repo"
mkdir -p "$TARGET"
cp -R "$FIXTURE/." "$TARGET/"

# Keep a TypeScript package inside the target repo so the repository-first
# resolution path stays covered.
typescript_package="${STRUCTURAL_INDEX_TYPESCRIPT_PACKAGE:-}"
if [ ! -f "$typescript_package/lib/typescript.js" ]; then
    echo "  [FAIL] TypeScript package unavailable; set STRUCTURAL_INDEX_TYPESCRIPT_PACKAGE"
    exit 1
fi
mkdir -p "$TARGET/server/node_modules"
ln -s "$typescript_package" "$TARGET/server/node_modules/typescript"

# map-check must run with bd absent from PATH: it never touches the tracker.
SANDBOX_BIN="$WORK/bin"
mkdir -p "$SANDBOX_BIN"
ln -s "$(command -v git)" "$SANDBOX_BIN/git"
ln -s "$(command -v node)" "$SANDBOX_BIN/node"
if ! command -v go >/dev/null 2>&1; then
    echo "  [FAIL] go toolchain unavailable; see docs/dispatch-env.md"
    exit 1
fi
ln -s "$(command -v go)" "$SANDBOX_BIN/go"
if PATH="$SANDBOX_BIN" command -v bd >/dev/null 2>&1; then
    fail "sandbox PATH excludes bd"
else
    pass "sandbox PATH excludes bd"
fi

# Planted map: task-1 rows (five 12-hex, one new), one seam row, task-2 rows.
mkdir -p "$TARGET/docs/beads"
cat >"$TARGET/docs/beads/map-epic.map.md" <<'EOF'
# map-epic exploration map

| Task | Symbol | File | Hash | Note | Source |
|------|--------|------|------|------|--------|
| 1 | suggestCadence | src/task-sweep.ts | ad445d667ec8 | mutated in a later phase | index |
| 1 | cadenceOne | tests/task-sweep.test.ts | b3aaa2d50172 | calls suggestCadence | index |
| 1 | unused | src/unused.ts | 6594898741b7 | unrelated row | index |
| 1 | StatusTimeline | src/StatusTimeline.tsx | ee9fb25e859b | deleted in a later phase | index |
| 1 | screen | src/status-caller.tsx | 5651fece767a | calls StatusTimeline, which never seeds CHECK | index |
| 1 | createdLater | src/created-later.ts | new | created by this plan | planner |
| 1→2 | seam: line kinds | — | — | Task 2 consumes the six line kinds | planner |
| 2 | priceLine | shared/pricing.ts | dddcb9e6635a | other task row | index |
| 2 | triple | src/triple.ts | d2073dcb235e | other task row | index |
EOF

map_text="$(cat "$TARGET/docs/beads/map-epic.map.md")"
assert_grep "planted map carries a seam row" '^| 1→2 ' "$map_text"
assert_grep "planted map carries a new row" '| new |' "$map_text"
assert_grep "planted map carries task-2 rows" '^| 2 |' "$map_text"

git -C "$TARGET" init -q
git -C "$TARGET" config user.name "Map Check Test"
git -C "$TARGET" config user.email "map-check@example.test"
git -C "$TARGET" add .
git -C "$TARGET" commit -qm "fixture with planted map"

run_map_check() {
    local epic="$1" task="$2"
    MAP_OUT="$(PATH="$SANDBOX_BIN" "$MAP_CHECK" "$epic" "$task" --repo "$TARGET" 2>"$WORK/stderr")"
    MAP_STATUS=$?
}

echo ""
echo "Phase A: planted HEAD — 12-hex rows fresh, NEW not yet created, seam echo"
run_map_check map-epic map-epic.1
assert_status "task id with trailing .N exits 0" 0 "$MAP_STATUS"
MAP_A="$MAP_OUT"
assert_eq "planted HEAD prints five fresh, one NEW, one seam line in map order" \
    "fresh suggestCadence src/task-sweep.ts:1-3
fresh cadenceOne tests/task-sweep.test.ts:1-4
fresh unused src/unused.ts:1-3
fresh StatusTimeline src/StatusTimeline.tsx:1-5
fresh screen src/status-caller.tsx:3-3
NEW createdLater src/created-later.ts (not yet created)
seam 1→2 Task 2 consumes the six line kinds" \
    "$MAP_A"
assert_eq "every 12-hex task-1 row prints fresh" "5" "$(printf '%s\n' "$MAP_A" | grep -c '^fresh ')"
assert_grep "new row prints NEW not yet created" \
    '^NEW createdLater src/created-later.ts (not yet created)$' "$MAP_A"
assert_not_grep "task-2 rows never print for task 1: priceLine" 'priceLine' "$MAP_A"
assert_not_grep "task-2 rows never print for task 1: triple" 'triple' "$MAP_A"
assert_not_grep "fully indexed clone prints no unindexed header line" '^unindexed' "$MAP_A"

run_map_check map-epic 1
assert_status "bare-number task id exits 0" 0 "$MAP_STATUS"
assert_eq "bare-number task id selects the same rows" "$MAP_A" "$MAP_OUT"

run_map_check map-epic 2
assert_status "task-2 run exits 0" 0 "$MAP_STATUS"
assert_eq "task-2 run prints its own rows plus the M→N seam" \
    "seam 1→2 Task 2 consumes the six line kinds
fresh priceLine shared/pricing.ts:1-3
fresh triple src/triple.ts:1-3" \
    "$MAP_OUT"

echo ""
echo "Phase C: committed mutation — STALE with mutating sha, CHECK on the caller"
cat >"$TARGET/src/task-sweep.ts" <<'EOF'
export function suggestCadence(value: number): number {
  return value + 2;
}

export function startTaskSweep(): void {
  return;
}
EOF
git -C "$TARGET" add src/task-sweep.ts
git -C "$TARGET" commit -qm "mutate suggestCadence"
MSHA="$(git -C "$TARGET" log -1 --format=%h)"
run_map_check map-epic map-epic.1
assert_status "mutation phase exits 0" 0 "$MAP_STATUS"
MAP_C="$MAP_OUT"
assert_eq "mutation phase prints STALE, CHECK, fresh, NEW, seam in map order" \
    "$(printf 'STALE suggestCadence src/task-sweep.ts:1-3 (ad445d667ec8 → e5647c632a4e, changed by %s)
CHECK cadenceOne tests/task-sweep.test.ts:1-4 (calls suggestCadence)
fresh unused src/unused.ts:1-3
fresh StatusTimeline src/StatusTimeline.tsx:1-5
fresh screen src/status-caller.tsx:3-3
NEW createdLater src/created-later.ts (not yet created)
seam 1→2 Task 2 consumes the six line kinds' "$MSHA")" \
    "$MAP_C"
assert_grep "STALE row carries the mutating commit sha" "changed by $MSHA" "$MAP_C"
assert_grep "caller's row is CHECK naming the stale symbol" \
    '^CHECK cadenceOne tests/task-sweep.test.ts:1-4 (calls suggestCadence)$' "$MAP_C"
assert_grep "unrelated row stays fresh" '^fresh unused src/unused.ts:1-3$' "$MAP_C"

echo ""
echo "Phase D: committed deletion — GONE with deleting sha, no CHECK seeded"
git -C "$TARGET" rm -q src/StatusTimeline.tsx
git -C "$TARGET" commit -qm "delete StatusTimeline"
DSHA="$(git -C "$TARGET" log -1 --format=%h)"
run_map_check map-epic map-epic.1
assert_status "deletion phase exits 0" 0 "$MAP_STATUS"
MAP_D="$MAP_OUT"
assert_eq "deletion phase prints GONE while everything else holds" \
    "$(printf 'STALE suggestCadence src/task-sweep.ts:1-3 (ad445d667ec8 → e5647c632a4e, changed by %s)
CHECK cadenceOne tests/task-sweep.test.ts:1-4 (calls suggestCadence)
fresh unused src/unused.ts:1-3
GONE StatusTimeline src/StatusTimeline.tsx (no definition at HEAD; removed or renamed, file last changed by %s)
fresh screen src/status-caller.tsx:3-3
NEW createdLater src/created-later.ts (not yet created)
seam 1→2 Task 2 consumes the six line kinds' "$MSHA" "$DSHA")" \
    "$MAP_D"
assert_grep "GONE row carries the deleting commit sha" "file last changed by $DSHA" "$MAP_D"
assert_grep "GONE seeds no CHECK: the row calling it stays fresh" \
    '^fresh screen src/status-caller.tsx:3-3$' "$MAP_D"
assert_not_grep "no CHECK line names the gone symbol" 'CHECK.*StatusTimeline' "$MAP_D"

echo ""
echo "Phase E: committed creation — NEW created since planning with its span"
cat >"$TARGET/src/created-later.ts" <<'EOF'
export function createdLater(): string {
  return "created";
}
EOF
git -C "$TARGET" add src/created-later.ts
git -C "$TARGET" commit -qm "add createdLater"
run_map_check map-epic map-epic.1
assert_status "creation phase exits 0" 0 "$MAP_STATUS"
MAP_E="$MAP_OUT"
assert_eq "creation phase swaps the new row to its created form" \
    "$(printf 'STALE suggestCadence src/task-sweep.ts:1-3 (ad445d667ec8 → e5647c632a4e, changed by %s)
CHECK cadenceOne tests/task-sweep.test.ts:1-4 (calls suggestCadence)
fresh unused src/unused.ts:1-3
GONE StatusTimeline src/StatusTimeline.tsx (no definition at HEAD; removed or renamed, file last changed by %s)
fresh screen src/status-caller.tsx:3-3
NEW createdLater src/created-later.ts:1-3 (created since planning)
seam 1→2 Task 2 consumes the six line kinds' "$MSHA" "$DSHA")" \
    "$MAP_E"
assert_grep "new row prints NEW created since planning with its span" \
    '^NEW createdLater src/created-later.ts:1-3 (created since planning)$' "$MAP_E"

echo ""
echo "Phase F: unindexed languages — header lines precede every row line"
MIXED_TARGET="$WORK/mixed-repo"
mkdir -p "$MIXED_TARGET"
cp -R "$MIXED_FIXTURE/." "$MIXED_TARGET/"
git -C "$MIXED_TARGET" init -q
git -C "$MIXED_TARGET" config user.name "Map Check Test"
git -C "$MIXED_TARGET" config user.email "map-check@example.test"
git -C "$MIXED_TARGET" add .
git -C "$MIXED_TARGET" commit -qm "mixed fixture"

rb_line="$("$INDEX" symbol renderBadge --repo "$MIXED_TARGET")"
rb_file="$(printf '%s\n' "$rb_line" | cut -f1)"
rb_span="$(printf '%s\n' "$rb_line" | cut -f2)"
rb_hash="$(printf '%s\n' "$rb_line" | cut -f3)"

mkdir -p "$MIXED_TARGET/docs/beads"
cat >"$MIXED_TARGET/docs/beads/mixed-epic.map.md" <<EOF
# mixed-epic exploration map

| Task | Symbol | File | Hash | Note | Source |
|------|--------|------|------|------|--------|
| 1 | renderBadge | $rb_file | $rb_hash | fresh row in an indexed language | index |
| 1 | kotlinOnlyMarker | src/kotlin/BadgeScreen.kt | new | a symbol whose only home is uncovered | planner |
| 1→2 | seam: header placement | — | — | row lines follow the headers | planner |
EOF
git -C "$MIXED_TARGET" add docs
git -C "$MIXED_TARGET" commit -qm "mixed map"

PATH="$SANDBOX_BIN" "$MAP_CHECK" mixed-epic 1 --repo "$MIXED_TARGET" >"$WORK/stdout" 2>"$WORK/stderr"
MAP_STATUS=$?
assert_status "mixed-epic run exits 0" 0 "$MAP_STATUS"
assert_eq "mixed run prints one header per uncovered language in roster order, then the unchanged row lines" \
    "unindexed kotlin 3 files (callers and tests by text search; no definition rows)
unindexed swift 3 files (callers and tests by text search; no definition rows)
unindexed python 4 files (callers and tests by text search; no definition rows)
fresh renderBadge $rb_file:$rb_span
NEW kotlinOnlyMarker src/kotlin/BadgeScreen.kt (not yet created)
seam 1→2 row lines follow the headers" \
    "$(cat "$WORK/stdout")"
assert_eq "exactly three header lines print on the mixed clone" "3" "$(grep -c '^unindexed ' "$WORK/stdout")"
assert_not_grep "other never prints a header line" '^unindexed other' "$(cat "$WORK/stdout")"

echo ""
echo "Phase F2: a kotlin-only repository — header line then seam line, exit 0"
KOTLIN_TARGET="$WORK/kotlin-repo"
mkdir -p "$KOTLIN_TARGET/src" "$KOTLIN_TARGET/docs/beads"
printf 'class BadgeScreen {\n    fun render() = "badge"\n}\n' >"$KOTLIN_TARGET/src/BadgeScreen.kt"
printf 'class BadgeScreenTest {\n    fun probe() = BadgeScreen().render()\n}\n' >"$KOTLIN_TARGET/src/BadgeScreenTest.kt"
cat >"$KOTLIN_TARGET/docs/beads/kotlin-epic.map.md" <<'EOF'
# kotlin-epic exploration map

| Task | Symbol | File | Hash | Note | Source |
|------|--------|------|------|------|--------|
| 1→2 | seam: only row | — | — | no indexed language is not an error | planner |
EOF
git -C "$KOTLIN_TARGET" init -q
git -C "$KOTLIN_TARGET" config user.name "Map Check Test"
git -C "$KOTLIN_TARGET" config user.email "map-check@example.test"
git -C "$KOTLIN_TARGET" add .
git -C "$KOTLIN_TARGET" commit -qm "kotlin-only fixture"

PATH="$SANDBOX_BIN" "$MAP_CHECK" kotlin-epic 1 --repo "$KOTLIN_TARGET" >"$WORK/stdout" 2>"$WORK/stderr"
MAP_STATUS=$?
assert_status "kotlin-only run exits 0" 0 "$MAP_STATUS"
assert_eq "kotlin-only run prints the kotlin header then the seam line" \
    "unindexed kotlin 2 files (callers and tests by text search; no definition rows)
seam 1→2 no indexed language is not an error" \
    "$(cat "$WORK/stdout")"

echo ""
echo "Phase F3: a languages query failure exits 1 with one stderr line"
EMPTY_TARGET="$WORK/empty-repo"
mkdir -p "$EMPTY_TARGET/docs/beads"
cat >"$EMPTY_TARGET/docs/beads/empty-epic.map.md" <<'EOF'
# empty-epic exploration map

| Task | Symbol | File | Hash | Note | Source |
|------|--------|------|------|------|--------|
| 1→2 | seam: only row | — | — | zero-commit repository | planner |
EOF
git -C "$EMPTY_TARGET" init -q
PATH="$SANDBOX_BIN" "$MAP_CHECK" empty-epic 1 --repo "$EMPTY_TARGET" >"$WORK/stdout" 2>"$WORK/stderr"
MAP_STATUS=$?
assert_status "languages query failure exits 1" 1 "$MAP_STATUS"
assert_eq "languages query failure leaves stdout empty" "" "$(cat "$WORK/stdout")"
assert_eq "languages query failure prints one stderr line" "1" "$(wc -l <"$WORK/stderr" | tr -d ' ')"
assert_grep "languages failure stderr names the failed query" 'structural-index languages failed' "$(cat "$WORK/stderr")"

echo ""
echo "Phase G: a file:-prefixed Hash cell exits 2 naming the row"
printf '| 1 | triple | src/triple.ts | file:d2073dcb235e | whole-file fallback | index |\n' \
    >>"$TARGET/docs/beads/map-epic.map.md"
run_map_check map-epic map-epic.1
assert_status "file:-prefixed Hash cell exits 2" 2 "$MAP_STATUS"
assert_eq "invalid Hash cell leaves stdout empty" "" "$MAP_OUT"
assert_eq "invalid Hash cell prints one stderr line" "1" "$(wc -l <"$WORK/stderr" | tr -d ' ')"
assert_grep "invalid Hash stderr names the offending row" 'triple' "$(cat "$WORK/stderr")"
assert_grep "invalid Hash stderr names the offending cell" 'file:d2073dcb235e' "$(cat "$WORK/stderr")"

echo ""
echo "Phase H: missing and unparseable map files exit 2 naming the path"
run_map_check no-such-epic 1
assert_status "missing map file exits 2" 2 "$MAP_STATUS"
assert_eq "missing map leaves stdout empty" "" "$MAP_OUT"
assert_eq "missing map prints one stderr line" "1" "$(wc -l <"$WORK/stderr" | tr -d ' ')"
assert_grep "missing map stderr names the path" 'docs/beads/no-such-epic.map.md' "$(cat "$WORK/stderr")"

printf 'not a table\n' >"$TARGET/docs/beads/broken-epic.map.md"
run_map_check broken-epic 1
assert_status "unparseable map file exits 2" 2 "$MAP_STATUS"
assert_eq "unparseable map leaves stdout empty" "" "$MAP_OUT"
assert_eq "unparseable map prints one stderr line" "1" "$(wc -l <"$WORK/stderr" | tr -d ' ')"
assert_grep "unparseable map stderr names the path" 'docs/beads/broken-epic.map.md' "$(cat "$WORK/stderr")"

echo ""
echo "Phase I: an index failure or a bad --repo exits 1, never 2"
BROKEN="$WORK/broken"
mkdir -p "$BROKEN/src" "$BROKEN/docs/beads"
printf 'export function lonely() { return 1; }\n' >"$BROKEN/src/lonely.ts"
printf '| Task | Symbol | File | Hash | Note | Source |\n|---|---|---|---|---|---|\n| 1 | lonely | src/lonely.ts | 0123456789ab | no typescript package here | index |\n' \
    >"$BROKEN/docs/beads/broken-index.map.md"
git -C "$BROKEN" init -q
git -C "$BROKEN" config user.name "Map Check Test"
git -C "$BROKEN" config user.email "map-check@example.test"
git -C "$BROKEN" add -A
git -C "$BROKEN" commit -q -m "tracked TypeScript, no compiler"
env -u STRUCTURAL_INDEX_TYPESCRIPT_PACKAGE PATH="$SANDBOX_BIN" \
    "$MAP_CHECK" broken-index 1 --repo "$BROKEN" >"$WORK/stdout" 2>"$WORK/stderr"
MAP_STATUS=$?
assert_status "structural-index failure exits 1" 1 "$MAP_STATUS"
assert_eq "structural-index failure leaves stdout empty" "" "$(cat "$WORK/stdout")"
assert_grep "structural-index failure stderr names the failed query" 'structural-index symbol lonely failed' "$(cat "$WORK/stderr")"

PATH="$SANDBOX_BIN" "$MAP_CHECK" map-epic 1 --repo "$WORK/no-such-repo" >"$WORK/stdout" 2>"$WORK/stderr"
MAP_STATUS=$?
assert_status "bad --repo exits 1" 1 "$MAP_STATUS"
assert_eq "bad --repo leaves stdout empty" "" "$(cat "$WORK/stdout")"
assert_eq "bad --repo prints one stderr line" "1" "$(wc -l <"$WORK/stderr" | tr -d ' ')"

PATH="$SANDBOX_BIN" "$MAP_CHECK" map-epic 1 >"$WORK/stdout" 2>"$WORK/stderr"
MAP_STATUS=$?
assert_status "missing --repo exits 1" 1 "$MAP_STATUS"
PATH="$SANDBOX_BIN" "$MAP_CHECK" map-epic abc --repo "$TARGET" >"$WORK/stdout" 2>"$WORK/stderr"
MAP_STATUS=$?
assert_status "task id without a number exits 1" 1 "$MAP_STATUS"

echo ""
if [ "$FAILED" -eq 0 ]; then
    echo "All map-check tests passed ($PASSED assertions)."
    exit 0
else
    echo "$FAILED map-check test(s) FAILED ($PASSED assertions passed)."
    exit 1
fi
