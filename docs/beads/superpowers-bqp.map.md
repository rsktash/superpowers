# superpowers-bqp exploration map

Language roster at the planning commit `ac2c18d`, from `scripts/structural-index languages --repo /Users/rustam/Projects/superpowers`: typescript 41 files compiler, go 9 files compiler, kotlin 7 files compiler, swift 7 files compiler, python 10 files compiler, other 269 files none — 343 tracked files. Every compiler-backed file is a test fixture; no task of this plan touches one.

Every file this plan edits is Markdown, shell or JSON, all of which fall in `other`, whose backend is `none`. The index resolves no definition in any of them, so under R-B none earns a map row and each task's Files list plus its citations block is its only record; every `callers` question in this plan's discovery batches is a text answer, and each task body says so. What remains is the seam rows: the interfaces one task lands and the next reads from the tree.

| Task | Symbol | File | Hash | Note | Source |
|------|--------|------|------|------|--------|
| 1→2 | seam: the session id export | — | — | Task 1 lands `export BD_SESSION_ID=<session_id>` in `$CLAUDE_ENV_FILE`; the lane step reads `$BD_SESSION_ID` for its claim and handoff and defines no fallback of its own | planner |
| 1→10 | seam: the deterministic suite loop | — | — | Task 1 adds `tests/claude-code/test-session-id.sh`; the loop line naming it lives only in `docs/dispatch-env.md`, which Task 10 owns — Task 1 does not edit that file | planner |
| 2→4 | seam: the lane step's contract | — | — | `skills/shared/plan-lane.md` owns ensure-plan, lane add and claim; handoff's Close and Resume cite that file in one sentence and repeat none of its commands | planner |
| 2→7 | seam: two edit sites in one file pair | — | — | Task 2 adds a citing sentence after each skill's `**Epic gate:**` paragraph; Task 7 rewrites the Fix Routing bullet, the re-review tier paragraph and hybrid's frontier bullet — the same two files, disjoint passages, Task 2 first so neither pays twice inside the word budgets | planner |
| 3→4 | seam: the miner's name and jobs | — | — | handoff's Resume and Close name `tracker-mining` and the two jobs they use, `triage` and `audit`; the job names come from the skill Task 3 landed, never invented at the citing site | planner |
| 3→6 | seam: the fork-skill population | — | — | Task 6's test enumerates every `skills/*/SKILL.md` carrying `context: fork`; Tasks 3 and 5 are the only two such files, and Task 3's frontmatter already declares its model | planner |
| 5→6 | seam: frontmatter against prose | — | — | Task 5 rewrites the Decision Beads section and touches no frontmatter; Task 6 adds the one `model:` line and touches no prose — the same file, two disjoint regions | planner |
| 5→8 | seam: the topic rule's two homes | — | — | the planner's version lives in writing-plans (planner may mint), the executor's in the five charter and prompt files (never mints); neither restates the other, and both cite R-40 | planner |
| 6→10 | seam: the deterministic suite loop | — | — | Task 6 adds `tests/claude-code/test-fork-model.sh`; Task 10 is what puts it in the loop line, for the same reason as the 1→10 seam | planner |
| 4→11 | seam: the changelog's word delta | — | — | Task 11 measures the net `skills/` delta over what every earlier task landed and states one sentence per component; it edits no skill to make a sentence true | planner |
