# bd CLI Conventions

These defaults cause subtle bugs if you assume otherwise.

## New defaults that bite (read this first)

- **`bd show <id>` outlines long descriptions.** When the description is ≥ 2 KB, `bd show` (text and `--json`) prints an *outline* of the markdown `##` headings with line ranges instead of the body. To read the body, pass `--full`, `--section <slug>`, `--lines START-END`, `--head N`, or `--tail N`. **Reviewers and self-review loops MUST use `--full` or `bd get <id> description`** — otherwise they are reviewing the table of contents, not the spec.
- **`bd show --json` no longer embeds comments by default.** It returns `"comments_count": N` only. To get the old shape with comment bodies, pass `--include comments` (other opt-ins: `--include labels,deps,all`).
- **`bd ready --json` and `bd list --json` are slim DTOs.** Default fields: `{id, title, status, priority, issue_type, assignee}`. Anything reading `.description`, timestamps, or metadata from these outputs must pass `--full` to restore the previous shape.

## Cheat sheet

| I want… | Use this |
|---|---|
| Single field, raw, no jq | `bd get <id> <field>` |
| Full description body | `bd show <id> --full`  *or*  `bd get <id> description` |
| One markdown section of the description | `bd show <id> --section <slug>` *or* `bd get <id> description --section <slug>` |
| First/last N lines of the description | `bd show <id> --head N`  /  `bd show <id> --tail N` |
| A line range | `bd show <id> --lines START-END` (also `START-`, `-END`, or `N`) |
| Several beads in one call | `bd show id1 id2 id3 --full` |
| Child task list | `bd children <id>` (not `bd show`) |
| Ready list — just IDs / titles | `bd ready` (text) or `bd ready --json` (slim) |
| Ready list — full Issue rows | `bd ready --json --full` |
| Truncate stdout safely | `bd show <id> --max-bytes N` |
| Limit how many ready rows | `bd ready --limit N` (also `-n N`) |
| Inspect a closed epic body | `bd show <epic-id> --full` (default would outline) |

`bd get` field names: `id, title, status, priority, type, assignee, owner, description, design, accept, notes, parent, deps, rdeps, labels, comments-count, created_at, updated_at, closed_at, close_reason`. Note `accept` (not `acceptance_criteria`) and `comments-count` (count only — for comment bodies use `bd comments <id>` or `bd show <id> --include comments`).

## Other defaults to remember

- **`bd list`** shows **open issues only** by default. Use `--all` to include closed, or `--status=closed` for closed only.
- **`bd ready`** excludes in_progress, blocked, deferred, and hooked issues. It returns only truly claimable open work. An empty JSON array `[]` means no ready work remains.
- **`bd epic status`** shows **open epics only**. Closed epics do not appear. Use `bd show <epic-id> --full` to inspect a closed epic.
- **`bd show <id>`** works on any bead regardless of status (open, closed, etc.). This is the reliable way to inspect any bead — just remember the outline default for long descriptions.
- **`bd close`** on the last open child of an epic may **auto-close the parent epic**. Do not assume the epic is still open after closing all children.
- **`bd create --parent`** assigns sequential hierarchical IDs (e.g., `.1`, `.2`, `.3`). Create child beads **sequentially**, not in parallel — parallel creates can fail due to ID conflicts.

## Content updates — ALWAYS use file-based workflow

All scratch files MUST be created in `.bd/.scratch/` at the project root. Never create temp files anywhere else in the repo.

**Naming:** `.bd/.scratch/<issue-id>-<field>.md` (e.g., `abc-q34-body.md`, `abc-q34-design.md`, `task-1.md`)

**Cleanup:** Delete the scratch file immediately after the bd command succeeds.

Write content to `.bd/.scratch/<issue-id>-<field>.md`, use Edit tool for diffs, then:
```bash
bd create --body-file .bd/.scratch/file.md          # create with description from file
bd update <id> --body-file .bd/.scratch/file.md     # update description
bd update <id> --design-file .bd/.scratch/file.md   # update design field
```

Do NOT use `notes` field — no `--notes-file` flag exists. Put content in `description` or `design` instead.

Do NOT use inline `--design="..."` or `--description="..."` for content longer than one line. Always use file-based updates.

Do NOT use `--stdin` for piping content. Use `--body-file` instead — it enables Edit tool diffs for review.

After `bd update --body-file`, verify with `bd get <id> description` (raw, never outlined). Run `bd update` and `bd close` as separate Bash calls — don't `&&`-chain them.

## Attachments

Bead content may embed images and files via custom URI schemes. These render in web UIs but `bd show` outputs raw markdown. When a bead references images relevant to your work, resolve them to local files and view them before proceeding.
