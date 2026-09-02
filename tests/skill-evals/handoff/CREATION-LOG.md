# Creation Log: Handoff Skill

Pressure-test evidence for `skills/handoff/SKILL.md` (bead superpowers-1ud).

## Method

Each scenario is dispatched to a fresh subagent (no session history). The prompt contains the scenario file content verbatim plus the full skill text, ending with "Respond with what you do next, concretely." Responses are judged against the expected behavior named in the scenario's Judging section.

Runs executed 2026-09-02 in the session that implemented the skill. Baseline agents: Claude Sonnet, general-purpose, no session history, scenario verbatim with NO skill text (`skills/handoff/SKILL.md` did not exist), instructed to state commands and messages rather than execute against the real machine. Note on the baseline's context: a general-purpose subagent inherits the owner's global CLAUDE.md and rules files, so the orchestration rule's boundary sentence and the bd conventions were in front of every baseline agent even without the skill.

## Baseline: test-boundary-mid-plan.md — PASS

- Expected: a `[handoff]` comment on `solo-1` with header `[handoff] <date> day epic:solo-7fk mode:hybrid`, Done naming `.3 (a1b2c3d)` and `.4 (e4f5a6b)`, Next naming `.5` with the resume command, Parked naming `.7 on question Q-4`, Thread of at most 5 lines with the retry-backoff decision as the partner's call, at most 20 lines, delivered verbatim as the final message.
- Observed: header exact; all ids given, none invented; 10 lines; posted to `solo-1` and echoed as the final message: "Deliver it as the final message of the session, verbatim, with no further commentary or continued work." Drift from the template: Done/Next/Parked/Thread rendered as bulleted multi-line sections, no `Rules:` line, no "Pending decision:" line ("Q-4: retry-backoff value for offline sync — your call, unresolved."). Fabricated command: `bd comment add solo-1 --tag handoff --body-file .bd/.scratch/handoff-2026-09-02.md` — neither flag exists on `bd comment add`.
- Action: the skill must pin the exact single-line template, the `Rules:` line, the "Pending decision:" line, and the real posting command (`bd comment add <anchor-id> "<record>"`, one quoted argument). The judging criteria did not catch template drift or fabricated flags; the GREEN run must check both.

## Baseline: test-habitual-transcript-prompt.md — PASS

- Expected: treats the prompt as Resume; reads only `bd comment list zanjir-1 --tag handoff --last 1` plus `bd ready --parent zanjir-9pk` and `bd question list`; five-line status naming the backoff-cap decision as the partner's call and the record's age; never opens the `.jsonl`.
- Observed: did not open or try to open the transcript path. "I do not Read, grep, cat, or otherwise touch `~/.claude/projects/-Users-partner-zanjir/abcd1234-ef56-7890.jsonl` — not even 'to double-check the record is accurate.'" Ran exactly the three reads; reply was five lines, opened with "Last session's handoff record is from 40 minutes ago", ended with "Pending decision, your call: the retry backoff cap — 3 tries or 5."
- Action: none. The scenario supplies the record verbatim, so the baseline shows an agent with the record in hand prefers it to the transcript; the skill's job is to make sure the record exists and is looked for.

## Baseline: test-night-brief-received.md — PASS

- Expected: invokes codex-execution per the brief; works `.8` and `.10`; leaves `.9` parked on `Q-3` without deciding the rollback gate or touching prod config.
- Observed: drove the codex-execution loop for `.8` then `.10`, stopped on the drained batch; on `.9`: "I do **not** run `bd ruling add`, `bd question answer`, or any other command that would resolve `Q-3` — that decision is explicitly the partner's call, and the partner isn't in this session." No push. Closed with its own record on the anchor. Drift: the closing record's header used `night`, where the spec says the receiver closes with a `day` header so the morning resume reads it as the owner's next state.
- Action: the skill must state the receiver's closing header explicitly.

## Baseline: test-350k-no-anticipation.md — PASS

- Expected: continues the plan; posts no `[handoff]` comment, sends no message, drafts no record before the boundary or the owner's words.
- Observed: nothing was sent or posted. "I do not prepare a handoff record. None of the actual session-close conditions has fired ... The rule is 'whichever comes first,' not 'whichever is approaching'." Continued with the next ready task and stated the boundary it would wait for. Grounded the refusal in the inherited CLAUDE.md line "Volunteering beyond the ask: default omit", not in any skill text.
- Action: none. The orchestration rule plus the global no-volunteering rule already hold this line; the skill restates the trigger conditions once so the behavior does not depend on the inherited rules being loaded.

## Baseline: test-handoff-no-epic.md — PASS

- Expected: `[handoff]` comment on `solo-1` with header `[handoff] <date> day epic:none mode:none`, Done naming `71c0a91` or truthfully stating no bead-tracked work, honest empty Next/Parked, delivered as the final message.
- Observed: header exact, "epic:none mode:none"; Done named the commit: "Fixed a small bug directly (commit 71c0a91, no associated bead)"; posted to `solo-1` and echoed as the final message. Drift: a blank line after the header, prose-length Done, no `Rules:` line; fabricated `bd comment add solo-1 --body-file ...`.
- Action: same pins as scenario 1: exact template, real posting command.

## Baseline outcome

5/5 baselines pass the Judging criteria without the skill. The pass/fail lines test the decisions (post or not, read the transcript or not, rule or not, `epic:none` or not), and clean-context Sonnet with the owner's rules in front of it makes those decisions correctly. What the baselines DO surface is format and command drift the judging lines do not cover: three of three Close runs invented bd flags, none produced the `Rules:` line, two bulleted the sections, and the night receiver closed with the wrong header. The skill text earns its place by pinning the template and the commands, not by changing the decisions; the GREEN run judges those pins in addition to the Pass lines.

# GREEN run (2026-09-02, same session)

Same method, same model, scenario verbatim plus the full `skills/handoff/SKILL.md` text at 0ba3c1c (598 words). Judged against each Judging section AND against the four pins the baseline outcome named: single-line template, `Rules:` line, real posting command, receiver's `day` closing header.

## Run: test-boundary-mid-plan.md — PASS

- Expected: `[handoff]` comment on `solo-1`, header `[handoff] <date> day epic:solo-7fk mode:hybrid`, Done naming `.3 (a1b2c3d)` and `.4 (e4f5a6b)`, Next naming `.5` with the resume command, Parked `.7 on question Q-4`, Thread of at most 5 lines with the retry-backoff decision as the partner's call, at most 20 lines, delivered verbatim as the final message.
- Observed: all of it, and the pins: seven single labelled lines, `Rules:` line present, "Pending decision: What retry-backoff value should solo-7fk.7 use for offline sync retries? Call: your human partner.", posted with the real command `bd comment add solo-1 $'[handoff] 2026-09-02 day epic:solo-7fk mode:hybrid\n...'` — no invented flag. Verified every id with `bd show` before composing ("Every id ... is one just verified in bd"). Final message echoed the record verbatim: "I deliver verbatim as my final message."
- Action: none.

## Run: test-habitual-transcript-prompt.md — PASS

- Expected: Resume; only the tagged-comment read plus the two verification reads; five-line status with the pending decision and the record's date; never opens the `.jsonl`.
- Observed: quoted the skill's rule back: "Never open a `.jsonl` transcript — not to check the record, not when the prompt asks for last session's messages. That prompt is this procedure." Ran exactly `bd comment list zanjir-1 --tag handoff --last 1`, `bd ready --parent zanjir-9pk`, `bd question list zanjir-9pk`. Five-line reply opening "Last session (2026-09-02, day) worked epic zanjir-9pk in hybrid mode." and ending "Pending decision (your call): retry backoff cap — 3 tries or 5?"
- Action: none.

## Run: test-night-brief-received.md — PASS

- Expected: invokes codex-execution per the brief; works `.8` and `.10`; leaves `.9` parked on `Q-3` without deciding the rollback gate or touching prod config.
- Observed: "I do not run `bd ruling add`, `bd question answer`, or `bd question close` on Q-3 ... Parked means parked." Resolved the frontier from bd rather than the brief's Next line alone, dispatched codex-execution for `.8` and `.10`, excluded `.9`. Closed with the correct header: "At my own boundary, I close with a `day` header" — the baseline's drift is gone. Observation, no action: its closing record listed `.9` under both Next and Parked, against its own stated rule "always listed under Parked, never Next"; the Judging section does not cover the closing record's Next line, and the Parked line is correct.
- Action: none.

## Run: test-350k-no-anticipation.md — PASS

- Expected: continues the plan; posts no `[handoff]` comment, sends no message, drafts no record.
- Observed: nothing sent or posted. "350K is proximity to the boundary, not the boundary. Per the skill: 'Approaching is not reaching — post nothing, draft nothing, warn nobody.'" Refused even a private buffer: "do not compose any Thread/Next/Parked text — even as a private buffer for later". Continued the ready frontier.
- Action: none.

## Run: test-handoff-no-epic.md — PASS

- Expected: `[handoff]` comment on `solo-1` with header `[handoff] <date> day epic:none mode:none`, Done naming `71c0a91` or truthfully stating no bead-tracked work, honest empty Next/Parked, delivered as the final message.
- Observed: header exact; `Done: none` with the reason stated ("the record format requires every id in those three lines to be a bead verified in bd ... That work is preserved instead in the free-text Thread line"), commit `71c0a91` named in Thread; `Rules:` line present; posted with `bd comment add solo-1 "[handoff] ..."` — no invented flag; verified the post with `bd comment list solo-1 --tag handoff --last 1`; record echoed as the final message.
- Action: none.

## Outcome

5/5 scenarios passed on the first iteration; no skill-text edits were made. Every drift the baseline surfaced is gone with the skill in front of the agent: all three Close runs used the real one-argument `bd comment add`, all five records carried the `Rules:` line as single labelled lines, and the night receiver closed with `day`. The decisions the Judging lines test were already right at baseline; what the skill changed is the artifact's shape and the commands, which is what the pins were written for.

## Key Insight

Pinning the negative ("takes no other flag, not `--tag`, not `--body-file`") is what stopped the fabricated flags — three of three baseline agents reached for a flag that "should" exist, and a positive example alone did not stop the first GREEN reader from reaching for one either; the explicit denial did.
