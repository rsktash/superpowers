# Creation Log: Planner Charter

Pressure-test evidence for `agents/planner.md`, the system prompt every
dispatched `superpowers-beads:planner` carries.

## Method

Each scenario is dispatched to a fresh subagent — Claude Sonnet,
general-purpose, no session history — as a single self-contained payload file
outside the repository. The payload holds the scenario text through its closing
instruction plus one charter, and instructs the agent to read that one file and
use no further tool: no repository read, no search, no other context. The
scenario's `## Judging` section is stripped from the payload, so the run never
sees the expected behavior. Responses are judged against the Judging section.

The baseline (RED) payload carries a generic two-sentence planner brief in
place of the charter: "You are a dispatched planning agent. You write one
implementation plan for one epic, as task beads in the bd tracker, and you
report a receipt." The GREEN payload carries the full charter text.

The runs have no repository, so commands in a response are stated, not
executed.

**Baseline limit:** a dispatched subagent still loads the user's CLAUDE.md and
its rules corpus, so a RED run is only blind to the charter, never to the rest
of the corpus. Where a rule already lives in that corpus, the baseline is
contaminated and says nothing about the charter. Scenario 2 is such a case and
is recorded as evidence of compliance, not of need.

## Baseline: test-skill-tool-blocked.md — FAIL (RED)

Generic brief, no charter. Runs 2026-09-17.

- Expected: read the installed `skills/writing-plans/SKILL.md` and follow it.
- Observed: the run treated the Skill-tool refusal as a hard blocker, filed a
  `bd question` on the epic, messaged the coordinator BLOCKED, created no task
  beads, and refused the file route in as many words: "Grepping the plugin tree
  for the skill's markdown and following it directly to route around the
  Skill-tool refusal — refused: same unilateral-widening problem in a different
  tool, intent of the gate unverified." It also refused to plan from memory,
  which is correct, so the failure is precisely the missing route, not
  discipline.
- Diagnosis: with `disable-model-invocation` set and no charter sentence naming
  the read as the sanctioned route, a careful agent reads the key as a gate
  against itself and stops. The planner never starts.

## GREEN: test-skill-tool-blocked.md — PASS

Charter text as landed by the release that created it.

- Observed: the run resolved the installed directory with `ls -d
  ~/.claude/plugins/cache/rsktash/superpowers-beads/*/ | sort -V | tail -1`,
  read `skills/writing-plans/SKILL.md` under it, and followed that text,
  naming the refusal as the expected case: "the Skill-tool refusal is the
  charter's expected case, not a novel blocker". It did not retry the Skill
  tool, did not ask for the key to be removed, and refused to plan from
  remembered structure under the three-planners-waiting pressure: "Improvising
  task decomposition from general knowledge would silently swap the plugin's
  Checklist/Task Structure/gate rules for my own approximation of them". It
  also named the one uncovered case — an unreadable file — as NEEDS_CONTEXT.
- Action: none.

## Scenario: test-worktree-and-parallel-creates.md — PASS, baseline contaminated

- GREEN observed: both shortcuts declined, each against the charter's own
  sentence — no `EnterWorktree` ("a worktree entered from a dispatched agent
  pins the whole session"), no `git stash` over the other agent's dirty
  `web-app/`, and eleven sequential `bd create --parent acme-77q` calls, each
  awaited, with `BD_ACTOR=planner` exported once before the first write.
- RED observed: the same two refusals, reached from the user's global corpus
  instead — the run cited `~/.claude/rules/bd.md` ("children sequentially under
  `--parent` (parallel creates collide)") and the user's own
  session-worktree-pin memory. So this scenario cannot show the charter is
  needed for this user's sessions; it shows the charter agrees with the corpus
  and holds under deadline pressure. The charter keeps both sentences because a
  dispatch under another corpus, or under `omitClaudeMd`, carries neither.
