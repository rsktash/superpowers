# bd CLI Conventions

These defaults cause subtle bugs if you assume otherwise:

- **`bd list`** shows **open issues only** by default. Use `--all` to include closed, or `--status=closed` for closed only.
- **`bd ready`** excludes in_progress, blocked, deferred, and hooked issues. It returns only truly claimable open work. An empty JSON array `[]` means no ready work remains.
- **`bd epic status`** shows **open epics only**. Closed epics do not appear. Use `bd show <epic-id> --json` to inspect a closed epic.
- **`bd show <id> --json`** works on any bead regardless of status (open, closed, etc.). This is the reliable way to inspect any bead.
- **`bd close`** on the last open child of an epic may **auto-close the parent epic**. Do not assume the epic is still open after closing all children.
- **`bd create --parent`** assigns sequential hierarchical IDs (e.g., `.1`, `.2`, `.3`). Create child beads **sequentially**, not in parallel — parallel creates can fail due to ID conflicts.

## Content updates — ALWAYS use file-based workflow

Write content to `.beads/.scratch/<name>.md`, use Edit tool for diffs, then:
```bash
bd create --body-file .beads/.scratch/file.md          # create with description from file
bd update <id> --body-file .beads/.scratch/file.md     # update description
bd update <id> --design-file .beads/.scratch/file.md   # update design field
```

Do NOT use `notes` field — no `--notes-file` flag exists. Put content in `description` or `design` instead.

Do NOT use inline `--design="..."` or `--description="..."` for content longer than one line. Always use file-based updates.

Do NOT use `--stdin` for piping content. Use `--body-file` instead — it enables Edit tool diffs for review.
