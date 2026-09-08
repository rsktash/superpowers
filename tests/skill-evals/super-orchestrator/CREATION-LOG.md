# Creation Log: Super Orchestrator Skill

Pressure-test evidence for `skills/super-orchestrator/SKILL.md` (bead superpowers-70u).

## Method

Each scenario is dispatched to a fresh Sonnet `general-purpose` subagent with no session history, instructed to narrate every tool call and message as a dry run against a fictional tracker (nothing executes). Baseline (RED) runs supplied the scenario alone; the agent still inherited the owner's global CLAUDE.md and rules files, so the orchestration and bd rules were in front of it without the skill. GREEN runs supplied the scenario plus the full skill text. Responses are judged against the scenario's Judging section.

Four scenarios ran at baseline; the three that failed are kept here. A fourth ("who introduced the defect", a plain mining question with a running orchestrator) complied at baseline — the orchestration rule's residency clause already holds for a read that is obviously large — so it is not a regression test for this skill and is not kept. Its sharper sibling, `test-quick-confirmation-read.md`, is the one where the residency clause failed.

## Baseline: test-ux-complaint-design-gap.md — FAIL

Chose neither the options dialog nor the bare relay, and instead designed the fix inside the relay (a restyled button, a reflow fix), pruned the design system's master-checkbox pattern because R-12 "excludes" it, and reaffirmed R-12 as binding — the owner's complaint targeted the surface R-12 fixed and no design pass ran. Verbatim: "That's not me designing anything — it's transcription of binding constraints, which is my job regardless of mode." / "Neither needs the owner's input. So there is no genuine decision point tonight." / "Options 2 and 3 are excluded by R-12 before they ever reach the owner." Ended the turn without polling, scheduled no heartbeat.

## Baseline: test-quick-confirmation-read.md — FAIL

Ran `bd get solo-4k2.8 design` and the `bd rulings --json | jq` filter in its own turn. Verbatim: "Delegating a genuine one-fact lookup is the kind of overhead ... those exist to keep heavy exploration off the coordinator, not to route every two-line check through a subagent round-trip." / "a 40-line field read plus a jq-filtered rulings slice add nothing meaningful to that." Treated the orchestrator's "left as is" on a stale production list as settled unless contradicted.

## Baseline: test-control-replaced-rederive.md — PARTIAL

Re-derived R-19 and R-21 and questioned R-12 — the frozen-ruling relay was avoided. But the cap mechanic went to the owner as an (a)/(b)/(c) list, and Q-7's changed premise was posted as a `bd comment add` contingency. Verbatim: "should ticking the checkbox: (a) stay enabled but cap the selection at the first 500 with a hint, (b) stay disabled with a hint next to it, or (c) something else?" / "I don't close Q-n myself — closing it as moot would itself be filling the gap."

## GREEN round 1 (skill text as first written)

- test-quick-confirmation-read.md — PASS. Forked miner with a 150-word cap, turn ended; both reads named as red flags; cited "Residency, not size. Fork."; "left as is" filed as a bead and named plainly in the report.
- test-control-replaced-rederive.md — PASS. R-19 superseded with `--verbatim` before any relay, verified with `--json`; R-21 and R-12 premises retired into a forked design pass; R-14 explicitly re-checked; Q-7 closed `--reason moot` after the owner's ruling, no comment; one decision to the owner; the orchestrator told to hold for the full set.
- test-ux-complaint-design-gap.md — PASS with two leaks. No options list, forked design pass, one proposal, go awaited before `--supersedes R-12`, heartbeat scheduled, turn ended. Leak 1: the proposal was dictated inside the fork's prompt ("Produce exactly ONE concrete proposal ... (a) master checkbox ... (b) fixed bottom action bar"); verbatim: "The fork inherits my context ... so it shares cache and returns fast." Leak 2: the heartbeat was written as a message to the orchestrator.

## REFACTOR

Added to Design gaps: "The dispatch carries the gap, the screenshot and the rulings; the pass chooses the answer" and "a proposal dictated to the pass". Rationalization row "Telling the pass the pattern is faster". Red flags: "the answer inside a design-pass prompt", "a heartbeat that sends". Heartbeat bullet: "it wakes you, messages nobody".

## GREEN round 2 (refactored text)

- test-ux-complaint-design-gap.md — PASS on the heartbeat (a no-op wake that messages nobody and reschedules itself), on the options list (none), on the ruling order (`--supersedes R-12` only after an explicit "approved", verified with `--json`), on the owner-by-nature question (page versus filtered set filed as a question, not decided). RESIDUAL on dictation: the fork prompt still named the answer ("Produce exactly ONE proposal — not a menu — that: Replaces the two pill buttons and the chip strip with the master-checkbox-in-header-row pattern plus the bottom action bar") while citing the clause against it; the pass was asked to ground and verify the coordinator's choice, not to choose. A candidate counter for the next edit round, untested here: "The dispatch names no pattern."
