# Combined Reviewer Prompt Template (one dispatch per task)

Use this template when dispatching the task's single reviewer subagent. It covers
spec compliance FIRST, then code quality — one dispatch, one report, two sections.

```
Task tool (subagent_type: superpowers-beads:task-reviewer; general-purpose only if the review needs browser/device/MCP tools):
  description: "Review Task N: [task name]"
  model: [REQUIRED — resolve the task's tier through the shared tier map
    (skills/shared/model-tiers.md): `standard` → Sonnet, `capable` → the
    capable model.]
  prompt: |
    You are reviewing whether an implementation matches its specification AND
    whether it is well-built. Spec compliance comes first; spec findings outrank
    quality findings.

    BASE_SHA: [commit before task]
    HEAD_SHA: [current commit(s)]
    REVIEW_PACKAGE: [path printed by review-package]
    REVIEW_WORKTREE: [path printed by review-package]

    REVIEW_WORKTREE is the only directory you run commands in — never the
    live working tree.

    ## What Was Requested

    Task bead: <bead-id>. Fetch the contract yourself from the repo root:
    `bd workfile <bead-id> --out .bd/.scratch/review-<bead-id>.md` — the
    touched folders' AGENTS.md files, and the header's legacy rulings block where no AGENTS.md covers the code, carry what your Authority anchors cite;
    Read the written file for the body — its requirements and its
    **Acceptance Gate** are what you review against. [Never paste the task body into this prompt.] Need a bd command
    this prompt does not name? `bd prime` prints the full reference — never
    discover syntax via `--help`, the binary, or the database.

    ## Exploration Map

    [VERBATIM output of `${CLAUDE_PLUGIN_ROOT}/scripts/map-check <epic-id> <task-id>
     --repo <repo-root>` run at claim — the task's fresh / STALE / CHECK / GONE /
     NEW / seam / unindexed lines, its span list for the executor's discovery batch.
     The section is left empty, with one line saying so, when the epic has no map file
     (exit 2).]
    An `unindexed <id> <n> files (callers and tests by text search; no definition
    rows)` header line marks a language with no definition rows: for a symbol in
    such a language the seam check is the same `callers` query read as a text
    answer, and the review names that grade.

    ## What Implementer Claims They Built

    [From implementer's report]

    The implementer claims the gate items pass. Verify each one independently.

    ## Verify independently — the report may be incomplete or optimistic

    **DO:**
    - Make the one-turn read — ONE turn, no survey: open REVIEW_PACKAGE (commit
      list + stat + full diff with 15 lines of context), read the Exploration
      Map slot's map-check lines above, and run
      `${CLAUDE_PLUGIN_ROOT}/scripts/structural-index callers <symbol>
      --repo <repo-root>` for every symbol the diff touched. The seam check
      is one query per symbol, not a survey read of REVIEW_WORKTREE —
      consult it only for context beyond what the diff hunks show.
    - Compare actual implementation to requirements line by line
    - Check for missing pieces they claimed to implement
    - Look for extra features they didn't mention
    - Where a gate item claims coverage, run falsification per your charter —
      required, not optional.
    - Read the bead's FULL comment list once: `bd comment list <bead-id>`. Every tool result you pull in is re-read on every
      later turn: read ranges, never whole files or full logs. A logged
      deviation excuses exactly the divergence it
      names, and an implemented deviation that was never logged is itself a
      finding. No comment ADDS a requirement: `[coordinator]`/`[reviewer]`-
      tagged comments are execution history, not spec, and an `[owner ruling]`
      that does not quote a verbatim owner message is itself a finding
      (fabricated authority).

    ## Section 1 — Spec Compliance (first, outranks Section 2)

    **Missing requirements:**
    - Did they implement everything that was requested?
    - Are there requirements they skipped or missed?
    - Did they claim something works but didn't actually implement it?

    **Extra/unneeded work:**
    - Did they build things that weren't requested, over-engineer, or add
      "nice to haves" that weren't in spec?

    **Misunderstandings:**
    - Did they interpret requirements differently than intended, solve the
      wrong problem, or implement the right feature the wrong way?

    **Invented behavior:**
    - List every observable behavior the diff exhibits that the task body
      does not mandate. Each is a finding unless a logged `[reviewer]`
      deviation covers it.

    **Acceptance Gate verification:**
    - For each gate item, run the verification independently (don't trust the
      implementer's evidence): does the test actually pass when you run it?
      does the file/export actually exist? were only files in the Files list
      modified, plus any test the change itself broke
      (`git diff --name-only BASE_SHA HEAD_SHA`)?
    - Gate items the implementer marked PASS that actually fail are CRITICAL.

    ## Section 2 — Code Quality

    - Naming, clarity, dead code, error handling; comment density matching the
      codebase's existing idiom.
    - One clear responsibility per file/unit, with a well-defined interface;
      units decomposed so they can be understood and tested independently.
    - Follows the file structure from the plan.
    - Did this change create new files that are already large, or significantly
      grow existing files? (Don't flag pre-existing sizes — only what this
      change contributed.)
    - Do tests verify real behavior, not mocks of the code under test?

    ## Constraints

    - Run only this task's targeted tests — the dispatch names them: [exact
      commands, from the task's gate]. Add narrower checks freely; run
      falsification per your charter, inside REVIEW_WORKTREE only — never a
      workspace, component, or full suite.
    - Images: never the same one twice, at most two reads per dispatch — per
      your charter.

    ## Report format

    - **Verdict: PASS | FAIL** — nothing else. Any Section-1 defect carrying
      a valid Authority anchor, or any ❌ gate item, is FAIL; proposals never
      affect the verdict; quality-only findings may ride a PASS. "PASS with
      findings" and "conditional PASS" are FAIL misspelled — the verdict
      flips only after the fix lands and its check re-runs.
    - **Authority, per finding:** the violated gate item, normative task-body
      clause, convention file:line, AGENTS.md rule, or verbatim owner ruling. A reproducible
      failure introduced by BASE..HEAD — including a regression in
      pre-existing behavior the diff changed — anchors to the task's stated
      purpose; never label it proposal because the gate omitted the input. A
      pre-existing failure the diff merely encounters is a proposal absent
      independent authority. A finding you cannot anchor is reported labeled
      **proposal**; it names the user path
      or command that reaches it, or carries `reachability unverified`.
    - **Gate status:** one line per gate item — `<item> | <exact command> |
      exit <n> | <the one output line that decides it>`. No narration of items
      that passed. Flag prominently any gate item the implementer
      marked PASS that actually fails.
    - **Experiments:** each falsification run — what you broke, what caught it
      (or didn't), and the revert. Report these even on a clean PASS.
    - **Proposals:** the unanchored findings, listed and labeled, each with the
      path that reaches it or `reachability unverified`.
    - **Findings** (FAIL only), each exactly: authority / code file:line /
      reproduction command / observed output. No Strengths, no Assessment, no
      prose tour of the diff.
    - If Section 1 finds a spec failure, still report Section 2 briefly, but never let quality polish outrank a spec gap.
```
