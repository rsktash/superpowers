# bd CLI Conventions

## Output defaults

- **`bd show <id>` outlines long descriptions.** When the description is ≥ 2 KB, `bd show` (text and `--json`) prints an *outline* of the markdown `##` headings with line ranges instead of the body. To read the body, pass `--full`, `--section <slug>`, `--lines START-END`, `--head N`, or `--tail N`. **Reviewers and self-review loops MUST use `--full` or `bd get <id> description`**.
- **`bd show --json` omits comment bodies** (`"comments_count": N` only); pass `--include comments` (other opt-ins: `--include labels,deps,all`).
- **`bd ready --json` and `bd list --json` are slim DTOs.** Default fields: `{id, title, status, priority, issue_type, assignee}`. Anything reading `.description`, timestamps, or metadata from these outputs must pass `--full`.

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

`bd get` field names: `id, title, status, priority, type, assignee, owner, description, design, accept, notes, parent, deps, rdeps, labels, comments-count, created_at, updated_at, closed_at, close_reason`. Note `accept` (not `acceptance_criteria`) and `comments-count` (count only — for comment bodies use `bd comments <id>` or `bd show <id> --include comments`).

## Typed records — questions, findings, legacy rulings

Decisions live in the folder AGENTS.md files; an open one is a typed question. Comments carry narrative, status, and evidence only — nothing binding.

- `bd rulings <id>` — the legacy rulings on a bead, resolved through its parents. They bind only where no AGENTS.md covers the code; elsewhere they are extraction material. Run it before recommending from, claiming, or executing such a bead.
- No ruling is filed: bd refuses `bd ruling add` and `bd question answer --ruling` for every actor. `bd ruling retire` runs only from the owner's interactive terminal; an agent that finds a stale ruling files a finding.
- `bd question add <id> "<text>"` — an unresolved decision. The bead leaves `bd ready` until the question ends: `bd question close <q-id> --commit <sha>` (the owner-approved AGENTS.md commit that answers it), `bd question answer <q-id> --finding <id>` (a finding answers a question a verifiable fact resolved — forks end only in an AGENTS.md commit) or `bd question close <q-id> --reason moot|duplicate|superseded --note "<why>"`. Filing is open to all actors; answer and close refuse `BD_ACTOR=executor` — an executor cannot unblock its own bead.
- `bd question list` — the open blocked frontier.
- `bd finding add <id> "<text>" [--evidence "<refs>"]` — an evidence-backed observation or deviation.
- **Topic pick.** Both add commands require `--topic <slug>`; omit it and bd prints the catalogue for the bead's areas and refuses — read it and pick an existing slug, never mint one; none fits → the pending placeholder below; the coordinator resolves it at Close.
- **Pending placeholder slug.** Derive it from the task id: lowercase the task id, turn every character outside `[a-z0-9]` into a hyphen, collapse runs of hyphens into one, prefix `pending-`, and trim the result to bd's 48-character slug limit. `proj-x1.8` becomes `pending-proj-x1-8`.

Executors export `BD_ACTOR=executor` before any bd write; coordinators set `coordinator` or leave it unset.

## Other defaults to remember

- **`bd list`** shows **open issues only** by default. Use `--all` to include closed, or `--status=closed` for closed only.
- **`bd ready`** excludes in_progress, blocked, deferred, and hooked issues. An empty JSON array `[]` means no ready work remains.
- **`bd epic status`** shows **open epics only**. Closed epics do not appear. Use `bd show <epic-id> --full` to inspect a closed epic.
- **`bd close`** on the last open child of an epic may **auto-close the parent epic**. Do not assume the epic is still open after closing all children.
- **`bd create --parent`** assigns sequential hierarchical IDs (e.g., `.1`, `.2`, `.3`). Create child beads **sequentially**, not in parallel.

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

Do NOT use `--stdin` for piping content. Use `--body-file` instead.

After `bd update --body-file`, verify with `bd get <id> description` (raw, never outlined). Run `bd update` and `bd close` as separate Bash calls — don't `&&`-chain them.

An AGENTS.md edit that amends the spec sweeps, same session, the epic body's affected acceptance lines and every open bead's gate commands.

A gate item reworded at execution time lands on the bead in the same round (`bd update --body-file`) — the gate verified at close is the recorded one, never a private working-copy variant.

## Attachments

Bead content may embed images and files via custom URI schemes. These render in web UIs but `bd show` outputs raw markdown. When a bead references images relevant to your work, resolve them to local files and view them before proceeding.
