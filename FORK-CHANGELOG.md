# Fork Changelog

Release history of the superpowers-beads fork. Upstream's own history stays in
`CHANGELOG.md` / `RELEASE-NOTES.md` (vendored, never edited here — their top
version marks the fork's upstream sync point).

Every entry states the net `skills/` word delta. Additions displace: a release
that grows the corpus names what it failed to remove.

## [1.4.34] - 2026-08-25

Net `skills/` word delta: **+141** (implementer-prompt +141). Nothing displaced.
The candidate considered and rejected: step 4's Drift Detectors gloss, which
reads as redundant with the charter until you notice the charter states the rule
and the step states the *exception* — the in-contract test update. Removing it
would have cost a real licence to buy an unrelated addition.

### Changed

- **The implementer reads the bead's COMMENTS, not just its body
  (implementer-prompt, Get Your Contract):** step 2 called the body "your
  complete contract AND your working copy". It is not the complete contract.
  Owner rulings, review verdicts and BLOCKED reports land in comments, and no
  step fetched them — `bd comment list` appeared zero times in the file. An
  implementer dispatched by the template therefore never saw a single recorded
  ruling.

  Measured cost, on one bead (`solo-eb4.6.82.2`), all of it invisible to the
  body: an owner ruling that a scheduled renewal charges only within grace and
  never a suspended tenant; a reviewer's BLOCKED naming the exact extraction
  signature and its six outcomes; three defects still unfixed behind a commit
  that reads as complete; and an inherited fork explicitly marked unruled, which
  an executor reading only the body would have closed by guessing. A sibling
  bead recorded the same class: without its comment "the executor would have
  landed a red suite and reported green."

  Step 2 loses the "complete contract" phrasing that licensed the omission. A
  new step 3 makes `bd comment list` required, fixes precedence (a recorded
  ruling outranks the body it contradicts), fixes reading order (oldest to
  newest, later supersedes earlier), and names the three things an implementer
  must carry out: a ruling is settled and never re-litigated; an inherited open
  fork is not the executor's to close and stops the turn as BLOCKED; and on a
  RESUMED task the prior verdict, not the body, is the true state of the work —
  the body describes the task, never its progress.

## [1.4.33] - 2026-08-24

Net `skills/` word delta: **+204** (subagent-driven-development +149,
hybrid-execution +34, reviewer-prompt +21). Nothing displaced — budget waived by
the owner.

### Changed

- **A FAIL's re-review is tiered by the fix, not by the fact of the FAIL
  (subagent-driven-development, Review Tier; hybrid-execution, FAIL-freeze):**
  the corpus keyed re-review on the *verdict* — Fix Routing let a controller
  apply and check a PASS-round fix inline, while the freeze clause demanded a
  dispatched re-review for any FAIL-round fix however mechanical. Measured cost
  of the coarse key: one 64K dispatched re-review for a fix that was a single
  exported function plus one test, whose flipping check the finding had already
  named.

  A fix is now controller-clearable only when every open finding is fully
  specified by the finding itself, each names the deterministic check that flips
  it, and the fix diff stays inside the files those findings cite. The
  controller then re-runs the reviewer's own checks — executing the verdict
  condition rather than replacing the reviewer, since FAIL-freeze already
  forbids rebasing reviewed commits, so everything else is byte-identical.

  Bounded against salami-slicing — a controller decomposing a broad fix into
  mechanical-looking pieces to self-clear past the reader a FAIL had just proven
  necessary. The blast-radius test is a set comparison, not judgement; the
  checks must be reviewer-authored, so a controller cannot invent a friendly
  one; a second FAIL on the same task always dispatches; the tier declaration is
  visible per Review Tier's standing norm; and the end-of-plan whole-diff review
  reads every self-cleared commit regardless. Fix Routing's "fully specified"
  boundary and this one are deliberately the same line — a fix the controller
  may apply is a fix it may clear; a fix needing implementer knowledge needed
  judgement, and judgement in the fix means judgement in the review.

- **The reviewer prompt gains the `[exact commands]` slot the implementer prompt
  already had (reviewer-prompt.md, Constraints):** the rule "run only this
  task's targeted tests — NEVER the full suite" was already correct and already
  there. What was missing was the slot, so "targeted" was left to the reviewer's
  reading — and in a multi-workspace repo "the entire component suite" reads as
  targeted while "the full suite" reads as project-wide. Five reviewers in one
  session ran `npm ci` plus a whole workspace suite through that gap. The line
  is a floor, not a ceiling: it explicitly preserves the reviewer's freedom to
  add narrower checks and falsification experiments, which is where every one of
  that session's outcome-changing findings came from.

### Not changed, deliberately

- **The review rate and the per-task review tier.** Five reviews in the measured
  session cost ~28% of dispatch spend and three of them changed the outcome —
  including one where every test passed, coverage was real and mutation controls
  fired, while the feature did not exist because a computed header was never
  read by any client. Release 1.4.32 made the implementer report evidentially
  worthless by design, which leaves the reviewer as the only surface that can
  catch that class. Thinning reviews would spend a margin that release had just
  consolidated.
- `agents/task-reviewer.md` — its charter already says targeted checks and
  falsification experiments; correct as written.
- The reviewer-prompt verdict wording ("flips only after the fix lands and its
  check re-runs") — already compatible with tiering; editing it would restate
  the rule in a second home.
- `hybrid-execution/references/hybrid-parallel.md`'s merge-back run — it tests
  *composition*, a different question from the reviewer's isolation run, and is
  not redundant with it.
- `agents/suite-gate.md` and `implementer-prompt.md` — already correct; the
  implementer prompt's `[exact commands]` slot is the model this release copies.
- Plan-side gate items that name workspace-wide commands would reopen the
  loophole from above the prompt. That belongs to writing-plans' gate-lint and
  is named here rather than swept here.

## [1.4.32] - 2026-08-24

Net `skills/` word delta: **0** — the change lands entirely in `agents/`
(`implementer.md` 756 → 973). The charter grows ~217 words once per dispatch
and removes on the order of 10,000–15,000 controller-resident tokens per
session.

### Changed

- **The implementer report is routing input, not the evidence record
  (agents/implementer.md):** the old format asked for every gate item PASS/FAIL
  with evidence, files, commit SHA and free prose — a verification-shaped format
  on a routing-shaped channel. Nothing in any close path ever consumed it:
  Termination closes on the reviewer's deterministic artifacts, the Invariants
  already say "Treat an implementer's self-review as the review. Both happen",
  and the controller cannot distinguish real pasted output from fabricated
  pasted output anyway. The gate now lives in the bead as flipped checkboxes,
  the commits and files in git, and the report carries status, gate exceptions,
  deviations, experiment outcomes, test counts and concerns.

  Bounded on both sides, because compaction has a measured mirror failure — two
  thin reports each cost a full extra verification pass. The floor binds like
  the ceiling ("a status with nothing the orchestrator can route on is not a
  report"); deviations are **stated, never referenced**, because the second of
  those failures said only that its deviations were "recorded on the bead" and
  the fetch is what cost the pass; and BLOCKED / NEEDS_CONTEXT are exempt from
  the ceiling entirely — a blocked report is the least recoverable artifact in
  the system and one of them is why release 1.4.31's prefactoring task exists.

  Experiment outcomes get a named slot for the first time — "mutation" appeared
  nowhere in the charter, which is why controllers were hand-writing report
  formats into dispatch prompts in violation of implementer-prompt.md's own
  "Prompts restate neither". The wording deliberately echoes the task-reviewer
  charter's formula: what you broke, what caught it (or didn't), the revert.

- **The Self-Review gate bullet (agents/implementer.md), same commit:** "List
  each item PASS/FAIL with evidence in the report" was the direct generator of
  the recitation and would have contradicted the new section. It now reads that
  the flipped checkbox is the per-item record. The verification obligation is
  untouched — only the transmission changes.

### Not changed, deliberately

- **`agents/task-reviewer.md` and `agents/suite-gate.md` — excluded loudly.**
  Their reports are the opposite pole by design: a verification agent's product
  IS deterministic evidence toward the controller, because the controller closes
  on it. Sweeping compaction into either would be the one-sided version of this
  change.
- `skills/subagent-driven-development/implementer-prompt.md` — its status-token
  line delegates to the charter rather than restating it, and its header's
  "Prompts restate neither" is the standing law that ends hand-written format
  blocks now that the charter serves routing.
- `subagent-driven-development/SKILL.md` — Implementer Status consumes the four
  statuses, which are unchanged; Termination and the self-review Invariant are
  *why* this compaction is safe and are cited above rather than edited.
- `reviewer-prompt.md` — its "What Implementer Claims They Built" slot accepts
  the compacted report, and "Do Not Trust the Report" is why no reviewer-side
  compensation is needed.
- `hybrid-execution/SKILL.md` and `references/hybrid-parallel.md` — status
  vocabulary only; the latter contains no report or status mentions (verified).
- `codex-execution/SKILL.md` — a different channel by design, already
  compaction-shaped: the executor comments evidence on the bead and the
  orchestrator re-runs every count. Precedent, not a change site.

## [1.4.31] - 2026-08-24

Net `skills/` word delta: **+151** (`writing-plans` 4131 → 4282). Nothing
displaced — the owner waived the budget for this release, so the clause was
sized to carry its own boundary rather than to fit. `writing-plans` was already
131 words over its declared 4000 before this edit; that debt predates it and is
untouched.

### Added

- **Seal Files lists against the call surface (writing-plans):** the seal rule
  gains its second face. A list is sealed from the files a task will edit and
  never from the symbols it must call, so a task whose reuse target is private
  reaches its executor with two legal moves — retype the logic or report
  BLOCKED — and both cost a round while the retyped copy passes every gate and
  drifts. The planner now confirms a cited symbol's visibility during the
  signature check it already performs: reuse must be exported, or the home file
  joins Files carrying the export as its step.

  Bounded deliberately, because the first draft was one-sided and rejected: the
  listing licenses exactly the visibility change and never the symbol's body or
  its neighbours; the file-step tie and the citation-pass anchor hold down
  Files-list inflation, which would otherwise degrade hybrid-parallel lane
  eligibility; a contested export routes to a decision bead rather than
  manufacturing a stall. Already-exported reuse adds nothing — the check rides
  a pass the planner already makes, so a task reusing public helpers generates
  no Files change, no step and no gate item.

### Not changed, deliberately

- The five sites `1.4.28` swept for the STOP-on-unlisted-files law — the
  writing-plans task template's gate item and drift detector, the implementer
  prompt, hybrid-execution's ballooning rule, and the reviewer prompt's matching
  check. This release changes no STOP semantics; the export authorisation
  arrives through the Files list, which every executor-facing site already
  honours unchanged. Both copies that prompted this edit were caught by the
  reviewer's existing check — the detection side works, a round late, and
  relaxing the executor side would have rebuilt the failure in mirror image.
- The Self-Review bullet at the citation-audit step. Its umbrella ("re-run each
  rule section above") covers the new clause, and duplicated restatements are
  debt by this corpus's own rule.

## [1.4.29] - 2026-08-23

Net `skills/` word delta: **+29** (43,321 → 43,350) — displaced inside
`brainstorming` to fit 2093/2100: the "Multiple choice preferred" key principle
(verbatim duplicate of a process bullet) removed, and the "Present options" /
"Lead with your recommended option" bullet pair merged.

### Added

- **Prune before proposing (brainstorming):** checklist step 4 and the
  Exploring-approaches section now require pruning before options reach the
  owner — a branch excluded by a ruling, code, spec, or a document already read
  this session is not an approach; only survivors are proposed. (Measured:
  2026-08-22 session, item-6 payment brainstorm offered a one-off-charge branch
  already excluded by the auto-renewal scope bead read the same session; two
  earlier sessions re-raised settled decisions the same way.) Exclusion: the
  "Explore alternatives" key principle is unchanged — it governs generation
  breadth before settling, not presentation. Companion rule landed the same day
  in the owner's global CLAUDE.md Scope line ("only survivors are genuine").

## [1.4.28] - 2026-08-22

Net `skills/` word delta: **+152** (43,169 → 43,321) — nothing displaced; the
additions were shaved to fit `writing-plans` at exactly 4000/4000, which leaves
that file with zero headroom for the next change.

### Added

- **Files-list sealing (writing-plans):** a Files list is an absence claim symbol
  grep cannot verify — grep finds callers, never constrainers. Seal only after
  adding each touched module's test files, found by module path or by running
  them, plus any import-ban or dependency-direction config. (Measured: 4 contract
  defects in one zanjir session, all the same shape — a test pinning old
  behaviour through a public function, a structural import ban, a pool stub
  matching SQL text. Each cost a dispatch round-trip.)

### Changed

- **In-contract test updates no longer stop the turn.** A test broken solely by
  an in-contract change is in-contract to update; a test encoding a structural
  ban (import guards, dependency direction) still stops — that is a design
  conflict, not a pin. The licence is the planner's to grant, so an executor
  exercising it is not self-widening its contract.
- **Sibling sweep — one wording, five sites.** The STOP-on-unlisted-files law was
  restated in three places, not single-sourced as the 1.4.25 dedup pass implied:
  `writing-plans` task template (gate item + drift detector), the
  implementer prompt, and hybrid-execution's ballooning rule. The reviewer
  prompt's Files-list check got the matching carve-out — without it the reviewer
  re-mints downstream the round-trip the executor correctly avoided.
  `agents/implementer.md` carries no restatement (verified).

## [1.4.26] - 2026-08-19

Net `skills/` word delta: **+68** (43,069 → 43137) — two mechanisms bought by one displacement.

### Added

- **Second-FAIL split (subagent-driven-development):** a task that fails review
  twice splits along its file map before any further round. (Measured: Task Size
  raised dispatch medians to 12–20 min while 9 solo tasks looped 3–4 review
  rounds — redo cost now scales with the split piece, not the whole task.)
- **Codex-fatal lint (codex-execution):** pre-dispatch body lint for
  sandbox-impossible commands, unrunnable gates, placeholders → `needs-plan`.
  (Measured: 173 PLANNER RULING halt round-trips in zanjir.)

### Changed

- Displacement for the split rule: "Verify before implementing" bullet trimmed
  to its unique clause (its rationale restated the section intro).

Companion outside the plugin: runner-dispatch-guard hook re-armed the dead-man's
switch as a touch-dismissed until-loop — TaskStop kills had produced 395 failed
notifications; failure now fires only on genuine stalls.

## [1.4.25] - 2026-08-19

Net `skills/` word delta: **-200** (43,269 → 43069).

### Changed

- **One wording per rule.** The pre-flight marker procedure (restated in
  hybrid-execution and codex-execution), the Session Task List mirror and the
  suite-gate closing (restated in hybrid-execution) now defer to their single
  definition in subagent-driven-development; hybrid's reviewer-isolation
  invariant is stated once, in Pipeline safety rules.
- **Gate-reword rule promoted to `shared/bd-defaults.md`** — previously
  hybrid-only, now binds all execution skills alongside the ruling-time sweep.

## [1.4.24] - 2026-08-19

Net `skills/` word delta: **−428** (43,697 → 43,269).

### Added

- **Ruling-time tail sweep** (`shared/bd-defaults.md`): a ruling that amends the
  spec sweeps, same session, the epic body's affected acceptance lines and every
  open bead's gate commands. (Mechanism measured in zanjir-km5r: ruling 16 landed
  as a comment while the epic body and seven tail beads kept the old contract;
  two tasks' gates would have deadlocked or misdirected implementers.)
- **Budget headers on every SKILL.md** — H1 carries `budget N words`; at-budget
  files displace to add. (The corpus grew 39,869 → 43,697 monotonically across
  1.3.11→1.4.23; no release net-shrank, including the one titled "text economy".)

### Changed

- **Filing threshold (subagent-driven-development)** now defers bead promotion to
  the user-approval rule (`propose`, never file) and drops its embedded
  measurement narrative.
- **Doctrine de-narrated** — nine `(Observed:/Measured:)` parentheticals and six
  `Why:` blocks compressed to their binding clause; evidence archived here:
  threshold-free filing ran 25–34% of bead intake (~8–10 beads/day) with open
  remainders outgrowing closures; a privilege escalation rode a "conditional
  PASS" into a commit during a 48-hour window of softened verdicts; a coherent
  "one concern" task landed as a 32-file ~19K-LOC bead (Task Size tripwires);
  a "3 passing tests" gate passed covering 3 of 9 fields; `dontBreakRows`
  cleared a mechanism-phrased gate with no fixture reaching page 2 (8-bead
  defect cluster); an invented even-split pagination cleared every floor-phrased
  gate; a wave of mechanical tasks got `capable` tiers from scheduling language;
  a stale allTests constraint cost a round trip (2026-07-26); session-triggered
  pre-flight made multi-round epics pay full scans on no-change rounds.

## [1.4.23] - 2026-08-18

### Changed

- **Filing threshold in subagent-driven-development ("Acting on review
  findings")** — a verified finding is fixed in the round or triaged by
  severity, never filed by default: standalone bead only for user-visible
  wrong behavior, security, data loss, or blocks-current-work; everything
  else is one comment line on the project's backlog bead. Mid-execution
  filings land under the executing epic ONLY when they block that epic's own
  acceptance (dep-linked); the epic's close-set is its plan batch plus its
  own blockers. Sessions list every bead they created, with severity
  justification, in the completion report — visibility without mid-run
  stops. Driver: a DB-ledger audit (solo + zanjir, Aug 10–18) measured
  threshold-free filings at 25–34% of all bead intake (~8–10/day), with
  per-epic remainders growing 46–64% past the plan batch and daily intake
  exceeding closes in both projects; the flood predates the 1.4.22
  regression window — it is standing doctrine, not model drift. A hard
  per-session filing budget was considered and rejected: a mid-run stop in
  an overnight autonomous session is a stall. An absolute epic freeze was
  considered and rejected: it would close epics green-on-paper over defects
  in their own deliverable (the even-split failure at epic scale) — hence
  the blocks-own-acceptance exception. Companion: per-project backlog beads
  created and recorded in each project's `docs/dispatch-env.md`.

## [1.4.22] - 2026-08-18

Regression-driven correction wave. Driver: a two-project transcript audit
(solo + zanjir, Aug 12–17 baseline vs post-change) traced three review-escaping
defects in 48h — an invented even-split pagination spanning three tasks, a
coordinator-invented 3:1 image constraint, and two implementers resolving one
unpinned plan gap in opposite directions (one a committed privilege
escalation) — to the 1.4.7/1.4.14 trials plus amplifiers. Both trials'
own watched metrics moved adversely; their terms are executed here.

### Changed

- **writing-plans / Task Size**: the 1.4.14 trial resolves — concern-based
  sizing stays, but bounded above by a **reviewable-diff bound** with numeric
  tripwires (~5 non-test files in Files, ~500 changed LOC); past either, the
  task is presumed a phase and splits, and keeping it whole must be argued
  visibly at plan time. (Observed: a coherent "one concern" landed as a
  32-file, ~19K-LOC bead; closes/hour fell 7–14x, beyond the trial's 2x
  design allowance.)
- **writing-plans / No Placeholders**: the 1.4.7 blanket relaxation resolves
  into the **fork test** — a step where two competent implementers could both
  satisfy the gate with observably different behavior is hiding a decision:
  pin it (code, enumeration, table, or explicit "either acceptable") or
  extract a decision bead. Upstream decisions (spec/ruling/brainstorm) that a
  task implements must appear in that task's own body — the executor reads
  one bead, never the epic.
- **writing-plans / gates**: every Acceptance Gate carries a **preservation
  item** — what the change must leave intact, checked on the overflow
  fixture. Floors alone invite mechanisms that clear them by degrading what
  the gate doesn't mention. Self-Review checks it.
- **Model tiers (writing-plans, SDD, hybrid)**: down-routing presumes a
  pinned contract — a task leaving a mechanism or design fork to the executor
  is `capable` regardless of file count; economize on the contract or on the
  executor, never both. Hybrid's mandatory down-route override gains the same
  guard.
- **SDD / hybrid routing**: the body-blind rule gains its one sanctioned
  read — the **scope glance** at claim time (`bd show <id> --section files`,
  ~10 lines) so a mega-task or file overlap is caught at routing, not after
  a burned session. Steps, gates, context stay unread.
- **SDD / Termination + reviewer-prompt**: verdicts are binary **PASS |
  FAIL** — any spec finding or failed gate item is FAIL; "PASS with
  findings" / "conditional PASS" are FAIL misspelled. (Observed: hard FAILs
  collapsed to zero under conditional-pass phrasings while a privilege
  escalation rode one into a commit.)
- **SDD / Fix Routing**: a controller-applied fix carries the implementer's
  full obligations, sibling-site sweep included; a fix whose sweep spans
  surfaces the finding didn't enumerate is not "fully specified" — dispatch
  it. (Observed: an inline sweep skipped `server/test`, caught only by the
  whole-diff review.)
- **implementer charter + reviewer-prompt**: an unstated mechanism,
  constraint, or parameter the implementer chose **is a deviation** — the
  task's silence is not a license; observable-fork situations report
  NEEDS_CONTEXT or log `[reviewer]` naming the road not taken. The reviewer
  gains the mirror check: every observable behavior the diff exhibits that
  the body doesn't mandate is a finding unless a logged deviation covers it.
- **Gate rewording lands on the bead** (charter + hybrid inline procedure):
  a gate item reworded at execution time — gate-lint or otherwise — updates
  the bead in the same round; the gate verified at close is the recorded one.
  (Observed: a gate-lint deny led to a working-copy-only reword, silently
  diverging the recorded gate from the executed one.)

### Fixed

- hybrid-execution inline procedure: `bd comments add` typo → `bd comment add`.

## [1.4.21] - 2026-08-17

### Changed

- **Pre-flight is state-triggered, not session-triggered** (SDD, hybrid,
  codex): a completed pre-flight writes a durable marker on the root bead
  (`pre-flight: <short-sha> / open: <ids>` comment). Every execution entry
  resolves the marker instead of unconditionally re-running: current
  (no commits since the SHA, no open child created/rewritten since) →
  skip in one line; stale → re-run scoped to open beads whose Files
  intersect the commits since the marker plus beads created/rewritten
  since; absent → full review. Driver: 1.4.19's per-session rule made
  multi-round epics pay a full open-plan scan every round with nothing
  landed in between — the session boundary was a proxy for the real
  trigger, landed work, which the epic-92 resume-time catch actually
  came from.

## [1.4.19] - 2026-08-16

### Changed

- **Pre-Flight Plan Review fires at every execution entry** (SDD, hybrid,
  codex): a session's first claim requires this session's pre-flight
  report — same-session writing-plans handoffs (Self-Review is
  author-blind, does not substitute) and mid-loop continuations included;
  in hybrid it is now Step 0 of The Loop, not preamble prose. Scope = open
  beads only, so cost shrinks as the plan progresses. New check class 5:
  stale premises — task bodies the current tree already contradicts
  (landed work invalidates the unexecuted remainder). Driver: transcript
  sweep of 24 execution sessions showed pre-flight dispatched in 8 — only
  fresh-session loop starts; a same-session handoff ran 13 implementers
  and a continuation ran 28 with no pre-flight, and epic-92's resume-time
  run caught three plan defects on the remainder.

### Added

- **`needs-plan` label for findings deferred as beads**: filed at creation
  (SDD "Acting on review findings"); a ready bead carrying it is not
  dispatchable at any entry point — it routes to writing-plans (or a
  decision bead) first. Driver: epic-92's frontier surfaced four
  review-filed defect beads (gates, no steps, unresolved decisions) as
  dispatchable tasks.

## [1.4.18] - 2026-08-16

### Added

- **Fix Routing in subagent-driven-development** (referenced from
  hybrid-execution's FAIL rule): a verified finding whose fix is fully
  specified by the finding itself is applied by the controller inline on the
  current diff; a round back to the implementer must be justified by
  implementer-held context (design call, non-obvious path), and a dispatched
  round carries ALL outstanding findings — never one round per finding.
  Driver: an Opus run spent five dispatch rounds on one task, several of
  them inline-sized edits (dead CSS, comment wording, a test the reviewer
  had already written and run) — "the same implementer fixes it" read as
  "every fix is a round".

## [1.4.17] - 2026-08-16

### Added

- **Text Economy pass in writing-skills** (adapted from mattpocock/skills
  `writing-for-agents`, MIT): leading words (collapse restatements into one
  pretrained concept-token), no-op hunting (a sentence that doesn't change
  behavior vs the model default is deleted whole), negation audit (state the
  positive target; hard guardrails exempt), environment-as-source-of-truth
  (docs cache only what no config confesses). Added to the Quality Checks
  checklist. Pilot compression on hybrid-execution: 2817 → 2663 words
  (−5.5%; conservative — the file is mostly guardrails the doctrine exempts).
- **Vertical Slices in writing-plans** (adapted from mattpocock/skills
  `to-tickets`, MIT): default task shape is a tracer bullet — a complete
  thin path through every layer, demoable alone — replacing the horizontal
  layer-slice examples (Attention Map example updated to match); wide
  refactors sequence as expand–contract (expand → migrate in blast-radius
  batches → contract).
- **Decision Beads in writing-plans + brainstorming**: a plan is never
  written over an unresolved design fork — the fork becomes a
  `Decide: <fork>` child bead blocking the tasks that depend on its outcome;
  brainstorming records dialogue-unsettleable forks in the spec as
  explicitly open decisions.
- **`docs/CONTEXT.md` domain glossary convention**: brainstorming maintains
  it (one line per term of art), writing-plans writes task bodies in its
  vocabulary, the implementer dispatch prompt reads it alongside
  `dispatch-env.md`.
- **wayfinder skill** (vendored from mattpocock/skills, MIT, bd-native):
  multi-session foggy efforts chart as a `wayfinder:map` epic bead with
  decision-ticket children — native `bd dep add` blocking, frontier via
  `bd ready --parent`, claim via assignee, fog-of-war / out-of-scope
  sections on the map body, graduate-before-close ordering to survive bd's
  parent auto-close. Ticket types: research (AFK), prototype, discussion,
  task. Complements decision beads (single fork) for fog that spans
  sessions.

## [1.4.16] - 2026-08-16

### Changed

- **The implementer charter ships inside the plugin as the implementer
  agent's system prompt** (`agents/implementer.md`). No file to fetch, no
  path to resolve, no per-project copies — the harness delivers it at
  dispatch. `implementer-charter.md` deleted; dispatch prompts and SDK step 1
  simplified (env file only). Supersedes 1.4.9's docs-file approach and
  1.4.15's path-reference approach.

## [1.4.15] - 2026-08-16

### Changed

- **Implementer charter is referenced globally, not copied per project**:
  dispatch prompts point at this skill's own `implementer-charter.md` by
  absolute path (resolved from the skill directory at dispatch time — the
  `scripts/review-package` mechanism). The per-project `docs/` copy step is
  retired: one shipped copy, zero skew, no reseeding on revisions.
  `docs/dispatch-env.md` stays per-project (project facts).

## [1.4.14] - 2026-08-16

### Changed (trial)

- **writing-plans**: the 10-Minute Rule is replaced by **Task Size** — one
  coherent concern bounded by the Context Ceiling, not a clock. Rationale:
  a firing-rate audit (254 subagents, 18 sessions) showed nearly every
  per-task ritual fires and earns its keep (per-task review carries FAIL
  marks in ~17% of reports; Hybrid Parallel has 12 real invocations;
  pre-flight finds issues in most runs) — so the overengineering lever is
  not removing rituals but running them fewer times. Doubling task size
  halves ritual count. TRIAL: watch review FAIL rate and
  overhead-per-landed-diff; revert if FAILs climb.

## [1.4.13] - 2026-08-16

### Changed

- **Comment audience tags**: deviations and cross-session notes are addressed
  via a leading `[reviewer]` / `[next-phase]` / `[orchestrator]` / `[all]`
  token, filtered with `bd comment list <id> --tag <t>` (beads commit
  4a9521a; `--last N` added alongside). Charter logs deviations tagged;
  reviewer-prompt reads `--tag reviewer` (with legacy full-list fallback and
  "unlogged deviation is a finding"); writing-plans' phase-N+1 planning
  session starts from `--tag next-phase` — the durable half of the
  phase-gate session handoff. Measured driver: epic threads past 21K chars
  made pull-all-and-extract a real cost.

## [1.4.12] - 2026-08-16

### Changed

- **Suite gate moves out of the orchestrator's context**: new lean read-only
  `agents/suite-gate.md` (Bash/Read/Grep/Glob — a gate that can edit is a gate
  that can "fix" its way to green) runs the full suite once per plan and
  reports commands + exit codes + output tails. SDD, hybrid-execution,
  using-git-worktrees, implementer-prompt updated; the gate remains the
  coordinator's decision, accepted only on deterministic evidence.
  Warm-environment projects (emulator/device) keep the peer gate-runner path.
  Measured: suite output resident in a long orchestrator ~100-300K weighted
  per round vs ~15-20K in a disposable agent.

## [1.4.11] - 2026-08-16

### Changed

- **task-reviewer agent + reviewer-prompt + SDD Termination**: falsification
  experiments are first-class review evidence — mutate the disposable review
  worktree to prove a guard fires (break the covered thing, show the check
  catching it, revert), reported as what-broke/what-caught/revert. The
  read-only guarantee moves from the toolset (reviewer regains Edit/Write) to
  the structure: edits confined to the disposable worktree, live tree and
  reviewed commits never touched. Ruled after a live review whose strongest
  findings all required such experiments.
- **reviewer-prompt**: the leftover "[FULL TEXT of task requirements]" paste
  slot is gone — the reviewer fetches the bead body itself (`bd get <id>
  body`), same 1.4.6 doctrine as implementers.

## [1.4.10] - 2026-08-16

### Added

- **agents/implementer.md, agents/task-reviewer.md**: lean agent definitions
  for the two per-task dispatch roles. Restricted `tools:` frontmatter
  (implementer: Bash/Read/Edit/Write/Grep/Glob; reviewer read-only without
  Edit/Write) drops unused tool schemas and the browser/MCP surface from each
  subagent's context prefix. Measured baseline: 26.4K median prefix,
  re-read ~594M tokens across 22.5K fleet turns (23% of fleet cache traffic).
  Dispatch templates now name these agents; general-purpose stays the route
  for tasks genuinely needing browser/device/MCP tools.

## [1.4.9] - 2026-08-16

### Changed

- **subagent-driven-development**: the constant behavioral half of the
  implementer prompt (Before You Begin, Your Job, edit discipline, code
  organization, escalation, self-review, report format) moves to a per-project
  `docs/implementer-charter.md`, copied from the skill's new
  `implementer-charter.md` on first dispatch. The prompt template now carries
  only task-specific content: mission, contract fetch, worktree pin,
  orchestrator addenda, test scope, and the status enum (kept inline because
  verdict processing depends on it). Observed in a live 1.4.6 dispatch:
  ~600-700 tokens of identical charter text re-inlined per dispatch. Also
  fixes the template's `bd comments add` typo (`bd comment add`).

## [1.4.8] - 2026-08-15

### Added

- **scripts/backfill-exec-labels.sh**: one-time per-project migration for the
  1.4.6 routing — mirrors each open bead's `**Execution:**` line as an
  `exec:<mode>` label via one `bd batch` call. Dry-run by default, idempotent
  (skips labelled beads, leaves annotation-less beads alone).

## [1.4.7] - 2026-08-15

### Changed (trial)

- **writing-plans**: the "code blocks required for code steps" rule (upstream
  doctrine, ~2026-03, pre-Claude-5) is RELAXED: a step is behavior + gate
  link; code blocks only where the exact text IS the spec (tricky algorithm,
  exact regex, signature/wire format a sibling consumes). Test steps name
  every asserted behavior; test code optional. Rationale: the falsifiable
  Acceptance Gate (1.4.1) is the guard against under-doing; pre-written code
  doubled authoring cost and drove the 2.1K-token average body. TRIAL: watch
  the review FAIL rate on the next epics; revert if it climbs.

## [1.4.6] - 2026-08-15

Workflow redesign: the orchestrator never touches a task body. Measured
(solo project): bodies were delivered up to 4x per task — orchestrator
`--full` read, pasted into the dispatch prompt, executor `--full` read,
executor Write of the progress copy — two of those resident in the
long-lived orchestrator (~4K/task, ~800K per 200-task project).

### Changed (breaking doctrine reversal)

- **subagent-driven-development**: implementer-prompt.md no longer pastes
  Context Anchor / Gate / Drift / full task text — the prompt names the bead
  id and the implementer fetches its own contract (`bd show` +
  `bd get <id> body > .bd/.scratch/progress.md` + Read). The "hand them the
  full task text" invariant is REVERSED: never paste bodies, never open them
  in the controller session. Pre-Flight Plan Review now runs as a READ-ONLY
  subagent (the whole plan enters its context, not the controller's).
- **hybrid-execution**: the Loop routes from `bd ready --json` + the `exec:`
  label — the controller never opens a body (legacy fallback: grep the one
  `**Execution:**` line). Inline Task Procedure delivers the contract via
  the progress-copy redirect — body in context once, as the working file.
- **writing-plans**: the Execution annotation is mirrored as a bead label at
  create time (`-l "exec:<mode>"`) so routing needs no body read.

Companion (pending): `bd workfile` command + labels in `ready --json` in the
beads repo — until then the get-redirect pattern and `bd label list` serve.

## [1.4.5] - 2026-08-15

Compression sweep (progressive disclosure): rarely-needed sections move to
`references/` files read on demand; every rule kept verbatim, nothing dropped.
Loads shrink ~1.2K tokens per skill invocation.

### Changed

- **hybrid-execution** (20.3K -> 18.0K chars): Hybrid Parallel procedure ->
  `references/hybrid-parallel.md` (activation rule stays in SKILL.md); Model
  Tiers reasoning -> `references/model-tiers.md` (map + floor rule stay).
- **writing-plans** (22.6K -> 20.1K chars): the three conditional review
  lenses (Deploy Sequence, Cross-Layer Consistency, Semantic Regression
  Sweep) -> `references/plan-review-lenses.md`, applied only when a task
  touches schema/rollout/contracts/type shapes.

## [1.4.4] - 2026-08-15

Two residency reducers from the 2026-08-15 token audit of the solo project
(18 orchestrator + 248 executor transcripts): dispatch-prompt boilerplate and
oversized tasks were the two schema-level contributors to fleet spend.

### Changed

- **subagent-driven-development**: static environment boilerplate moves to the
  project's `docs/dispatch-env.md`, referenced by path from dispatch prompts
  instead of inlined. (Measured: the same ~250-token block inlined in 248
  dispatch prompts, each resident in the orchestrator to session end.)
- **writing-plans**: new Context Ceiling rule under Bite-Sized Task
  Granularity — a task whose executor would plausibly accumulate >~150K tokens
  of context is two tasks. (Measured: the top decile of executors reached
  200–418K resident and dominated fleet spend.)

## [1.4.1] - 2026-07-26

Two guardrails against unverified orchestrator assertions reaching executors,
from the 2026-07-26 volunteered-rigor incident analysis (Opus 5 sessions
`40391637` / `25d32456`): every fabrication that reached an executor entered
through orchestrator-added content — dispatch-prompt fill slots and gate
premises — never through an audited bead body.

### Changed

- **codex-execution**: dispatch-prompt fill slots carry facts, not judgment —
  any constraint the orchestrator adds beyond the bead must cite a
  same-session tool run, and environment/toolchain facts expire when a task
  changes the toolchain. New Common-mistakes row. (Observed: a stale
  pre-toolchain-bump "allTests executes none" order; codex correctly refused,
  costing a full round trip.)
- **writing-plans**: acceptance-gate numbers and factual premises are claims —
  derive each from a same-session measurement and check it against evidence
  already gathered. (Observed: a ">= 3 distinct offsets" gate that
  mis-encoded two DST transitions, plus a zone the same session had already
  measured as a one-off.)

## [1.4.0] - 2026-07-22

Usage-analysis-driven overhaul of the skill roster (epic `superpowers-yz0`),
based on a three-project transcript analysis (206 sessions): every serious
friction event was a missed or bypassed trigger, never skill overhead.

### Removed (breaking)

- **Four skills retired**: `dispatching-parallel-agents` (0 invocations in 206
  sessions), `receiving-code-review` (0), `finishing-a-development-branch`
  (superseded), `executing-plans` (displaced by hybrid/codex execution).
  Surviving content folded: the inline per-task procedure now lives in
  hybrid-execution's own **Inline Task Procedure** section; branch finishing
  lives in using-git-worktrees' **Finishing: Merge Back and Clean Up**;
  review-reception discipline lives in subagent-driven-development's
  **Acting on review findings**.
- **writing-plans execution handoff is now 3 options** (Subagent-Driven,
  Hybrid, Codex) — the Inline option retired with executing-plans; all-inline
  plans are served by Hybrid routing.

### Added

- **Pipelined reviews by default in hybrid-execution**: task N's reviewer runs
  in the background against a frozen review package while N+1 implements;
  opt-in **Hybrid Parallel** mode (literal "hybrid parallel" from the user)
  for 2–3 disjoint-scope implementers in separate worktrees.
- **review-package script** (ported from upstream v6, adapted to
  `.bd/.scratch/`): reviewers read a frozen commit-list + stat + U15 diff
  file — never a pasted diff, never the moving working tree.
- **Two advisory plugin hooks** (never blocking): `fail-streak-guard`
  (PostToolUse — 2+ consecutive failures of one command class → reminder to
  load systematic-debugging and offer outsource-review) and `completion-gate`
  (PreToolUse on `bd close`/`git commit` — warns when code changed since the
  last passing verification run). Mechanical ignition for the two skills the
  analysis showed never self-invoke mid-firefight.
- **Pre-Flight Plan Review** (upstream v6 port, bd-adapted): whole-plan
  contradiction scan before Task 1, findings batched into one question.
- **Epic gate** at all three execution entry points: an epic bead with no
  children routes to writing-plans — undecomposed epics never execute.
- **Multi-Phase Epics rule** in writing-plans: the last task of phase N is
  "Plan phase N+1", so bd auto-close can't silently swallow a continuation.
- **Required `model:` field** in implementer/reviewer dispatch templates
  (upstream v6 port) — an omitted model silently inherits the session's most
  expensive one.
- **Reviewer Prompt Bias guardrail** (upstream v6 port): "do not flag" /
  "at most Minor" in a reviewer prompt is a stop signal — the reviewer
  decides severity, not the controller.
- **Evidence-first guard** in brainstorming: suspected-problem brainstorms
  require a shown problem (repro/error) before design.

### Fixed

- Version manifests re-synced via `bump-version.sh` (1.3.11 release had
  hand-bumped only 2 of 5 files, leaving cursor/gemini manifests at 1.3.10).
- Live skill tests run on stock macOS (GNU `timeout` absent) and the sdd
  test's task-loading assertion matches this fork's bd-based flow.
