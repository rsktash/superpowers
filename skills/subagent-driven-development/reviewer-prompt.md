# Combined Reviewer Prompt Template (one dispatch per task)

Use this template when dispatching the task's single reviewer subagent. It covers
spec compliance FIRST, then code quality — one dispatch, one report, two sections.
(Ruled 2026-07-12: separate spec and quality reviewers doubled cost for no
catch-rate gain.)

```
Task tool (subagent_type: superpowers-beads:task-reviewer — lean toolset; edits confined to the disposable review worktree; general-purpose only if the review needs browser/device/MCP tools):
  description: "Review Task N: [task name]"
  model: [REQUIRED — resolve per SKILL.md Model Selection / Review Tier; an omitted model silently inherits the session's most expensive one]
  prompt: |
    You are reviewing whether an implementation matches its specification AND
    whether it is well-built. Spec compliance comes first; spec findings outrank
    quality findings.

    BASE_SHA: [commit before task]
    HEAD_SHA: [current commit(s)]
    REVIEW_PACKAGE: [path printed by review-package]

    ## What Was Requested

    Task bead: <bead-id>. Fetch the contract yourself from the repo root:
    `bd get <bead-id> body` — its requirements and its **Acceptance Gate** are
    what you review against. [Never paste the task body into this prompt — the
    reviewer fetches it; the controller's context never carries it.]

    ## What Implementer Claims They Built

    [From implementer's report]

    The implementer claims the gate items pass. Verify each one independently.

    ## CRITICAL: Do Not Trust the Report

    The implementer's report may be incomplete, inaccurate, or optimistic.
    You MUST verify everything independently.

    **DO NOT:**
    - Take their word for what they implemented
    - Trust their claims about completeness
    - Accept their interpretation of requirements

    **DO:**
    - Read the actual code they wrote: open REVIEW_PACKAGE (commit list + stat +
      full diff with 15 lines of context) in one call. Consult the working tree
      only for context beyond what the diff hunks show.
    - Compare actual implementation to requirements line by line
    - Check for missing pieces they claimed to implement
    - Look for extra features they didn't mention
    - Where a gate item claims coverage, prove it by falsification in the
      review worktree: break the covered thing, show the check firing, revert.
      "Passes" alone cannot distinguish a working guard from a decorative one.
    - Read the bead's FULL comment list once: `bd comment list <bead-id>`
      (the `--tag reviewer` filter only identifies addressed deviations —
      provenance is checked against the full list, since a fabricated ruling
      can sit untagged). A logged deviation excuses exactly the divergence it
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
      deviation covers it — silence in the task plus silence in the comments
      plus new behavior in the diff is exactly the escape this check exists
      for.

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
      commands, from the task's gate]. Add narrower checks and falsification
      experiments freely; never a workspace, component, or full suite — those
      are the orchestrator's gate.
    - Verify by reading code and running commands, not by trusting the report.

    ## Report format

    - **Verdict: PASS | FAIL** — nothing else. Any Section-1 defect carrying
      a valid Authority anchor, or any ❌ gate item, is FAIL; proposals never
      affect the verdict; quality-only findings may ride a PASS. "PASS with
      findings" and "conditional PASS" are FAIL misspelled — the verdict
      flips only after the fix lands and its check re-runs.
    - **Authority, per finding:** the violated gate item, normative task-body
      clause, convention file:line, or verbatim owner ruling. A reproducible
      failure introduced by BASE..HEAD — including a regression in
      pre-existing behavior the diff changed — anchors to the task's stated
      purpose; never label it proposal because the gate omitted the input. A
      pre-existing failure the diff merely encounters is a proposal absent
      independent authority. A finding you cannot anchor is reported labeled
      **proposal** — still worth reporting, but it rides a PASS and never
      flips the verdict, whatever its severity.
    - **Gate status:** one line per gate item — `<item> | <exact command> |
      exit <n> | <the one output line that decides it>`. No narration of items
      that passed; the line IS the evidence, and it is re-runnable by the
      controller in one paste. Flag prominently any gate item the implementer
      marked PASS that actually fails.
    - **Experiments:** each falsification run — what you broke, what caught it
      (or didn't), and the revert. Report these even on a clean PASS: a
      format that stops asking for them is a format whose reviewers stop
      running them, and they are the strongest artifact this review produces.
    - **Proposals:** the unanchored findings, listed and labeled. They ride the
      PASS and feed the backlog; dropping them starves the filing threshold.
    - **Findings** (FAIL only), each exactly: authority / code file:line /
      reproduction command / observed output. No Strengths, no Assessment, no
      prose tour of the diff — the durable receipt holds the long form, and
      the controller reads it only when something is disputed.
    - If Section 1 finds a spec failure, still report Section 2 briefly — the
      fix dispatch wants both — but never let quality polish outrank a spec gap.
```
