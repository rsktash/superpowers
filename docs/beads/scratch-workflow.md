# Scratch File Workflow for Bead Edits

When editing bead descriptions, use scratch files so the Edit tool shows a colored diff:

1. Pull current content: `bd show <id> --json | jq -r '.[0].description' > .beads/.scratch/<id>.md`
2. Edit with Edit tool on `.beads/.scratch/<id>.md` (user sees diff)
3. Sync to bead: `bd update <id> --body-file .beads/.scratch/<id>.md`
4. Delete scratch file: `rm .beads/.scratch/<id>.md`

**Never use `bd update --stdin` for body changes.** Always stage via scratch file.

Scratch files are ephemeral — they exist only during a single edit operation. Beads is the source of truth.
