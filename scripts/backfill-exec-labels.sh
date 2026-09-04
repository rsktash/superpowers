#!/usr/bin/env bash
#
# backfill-exec-labels.sh — one-time migration for superpowers-beads 1.4.6 routing.
#
# Mirrors each open bead's `**Execution:**` body line as an `exec:<mode>` label
# so the orchestrator routes from `bd ready --json` without reading bodies.
# Beads with no Execution line are left alone — since 1.4.48 such a child fails
# the execution skills' epic gate and the plan goes back to writing-plans; beads
# already carrying an exec: label are skipped, so re-running is safe. Only open beads are touched (`bd list` default).
#
# Exactly three bd invocations per project (list, bulk show, batch), so it stays
# fast on slow/remote trackers.
#
# Requires bd >= the labels-in-JSON build (beads commit e326407).
# Run from a bd project root. Default is a DRY RUN printing the batch script.
#
#   backfill-exec-labels.sh            # show what would be labelled
#   backfill-exec-labels.sh --apply    # apply via ONE `bd batch` invocation
set -euo pipefail

apply=0
[ "${1:-}" = "--apply" ] && apply=1
command -v bd >/dev/null 2>&1 || { echo "error: bd not on PATH" >&2; exit 1; }

ids=$(bd list --json | python3 -c '
import json, sys
for r in json.load(sys.stdin):
    if not any(l.startswith("exec:") for l in r.get("labels", [])):
        print(r["id"])
')

script=""
if [ -n "$ids" ]; then
  # --full is required: plain `bd show --json` returns an EMPTY description
  # for outline-mode bodies (verified against a 6K-char bead).
  # shellcheck disable=SC2086
  script=$(bd show $ids --full --json | python3 -c '
import json, re, sys
for r in json.load(sys.stdin):
    m = re.search(r"^\*\*Execution:\*\*\s*(\S+?)[,.;]?(?:\s|$)",
                  r.get("description") or "", flags=re.M)
    if m:
        print("label add " + r["id"] + " exec:" + m.group(1))
')
fi

if [ -z "$script" ]; then
  echo "nothing to backfill — every open bead with an Execution line is labelled"
  exit 0
fi

printf '%s\n' "$script"
if [ "$apply" = 1 ]; then
  printf '%s\n' "$script" | bd batch
else
  echo
  echo "(dry run — re-run with --apply to write the labels)"
fi
