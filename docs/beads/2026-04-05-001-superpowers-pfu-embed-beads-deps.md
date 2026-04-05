# Embed beads and beads-ui in superpowers-beads plugin

**Bead:** `superpowers-vzq` (originally `superpowers-pfu`, recreated)

The superpowers-beads plugin currently requires users to install `bd` and `beads-ui` globally. LLMs reading install instructions from skills improvise badly — trying wrong package names and wasting tokens. This spec replaces that with a deterministic install script (`scripts/install-deps.sh`) that runs automatically via the session-start hook, downloads `bd` and `beads-ui` into `vendor/bin/`, and injects them onto PATH via `CLAUDE_ENV_FILE`. Global installs are detected and respected. Versions are pinned in `vendor/versions.json`.

**Key decisions:**
- `vendor/bin/` for plugin-local binaries, gitignored
- Session-start hook handles detection → install → PATH injection
- `bd` and `bdui` fail independently — missing UI doesn't block workflows
- Version bumps in manifest trigger re-install on next session

**Acceptance criteria:**
1. Fresh install auto-provisions `bd` and `beads-ui` without LLM involvement
2. Existing global installs are detected and used
3. Version pinning and upgrade via manifest
4. Graceful degradation on network failure
5. Idempotent install script
