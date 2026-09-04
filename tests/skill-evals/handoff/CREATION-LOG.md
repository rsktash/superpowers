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

# Follow-up: Night sender pairing (2026-09-02, same session)

Triggered by the end-of-plan whole-diff review, not a hypothesis: the spec's second acceptance criterion — "hand off to the night sessions" with two open sessions in two repositories delivers one brief each and reports the pairing — had no scenario. The five above came from the spec's Testing list, which covered the night *receiver* only. `test-night-sender-pairing.md` adds the sender side: discovery, pairing by working directory, the one-session-per-repository refusal, the pairing report.

## Baseline: test-night-sender-pairing.md — PASS (contaminated, not evidence)

- Expected: two `night` records, one per anchor; one `SendMessage` to `night-a` with the zanjir record plus the codex-execution invocation line; nothing to `night-b` or `night-c`; the collision reported; `solo-7fk` named as unpaired with its record still posted.
- Observed: all of it — but the agent had read the skill: "Close steps 1–4 run first, per-epic, header `night` (per skill: 'Close 1–4 first, header night')". The skill file exists on this branch's checkout, so a "no skill text" prompt no longer yields a clean baseline for a general-purpose agent with file access. Recorded as PASS with the contamination named; it carries no weight. One drift the Judging lines do not cover: the Next line's "exact next command" was `bd claim solo-7fk.5 --assignee ...`, a command that does not exist.
- Action: none on the skill. Future baselines for this skill run against a checkout without `skills/handoff/`, or with file tools withheld.

## Run: test-night-sender-pairing.md — PASS

- Expected: as above.
- Observed: posted `[handoff] 2026-09-02 night epic:solo-7fk mode:hybrid` to `solo-1` and `[handoff] 2026-09-02 night epic:zanjir-9pk mode:codex` to `zanjir-1`, seven single lines each with the `Rules:` line, via the one-argument `bd comment add`. Paired by working directory: "`zanjir-9pk` → `night-a` — unambiguous, only session in that repo." Refused the solo pair: "Two sessions share `/Users/partner/Projects/solo`. Per rule, send to neither; report the collision." One `SendMessage`, to `night-a`, ending "Invoke superpowers-beads:codex-execution for epic zanjir-9pk." Report: one line per session, `solo-7fk` named unpaired with "its handoff record is still posted to anchor `solo-1`", and the partner asked to name a session or close one.
- Action: none.

## Outcome (updated)

6/6 scenarios pass with the skill; no skill-text edits were made in either round. The sixth scenario exists because the whole-diff review caught an acceptance criterion with no test, not because a run failed.

# Rewrite onto typed lane handoffs (2026-09-05)

`skills/handoff/SKILL.md` was rewritten whole: the handoff is now a typed row on
the session's lane (`bd plan handoff <prefix> --lane --session --done --next
--parked --thread-file`), not a `[handoff]` comment on an anchor bead, and a
session holding no lane posts nothing at all. The anchor bead is retired.

Everything above this line is evidence for the retired text. The six runs
logged there judged the record template, the `Rules:` line and
`bd comment add` — pins that no longer exist in the skill — so they are
history, not a description of the landed behaviour. The Key Insight above
survives the rewrite: pinning the negative is what stops fabricated flags, and
the new text pins two of them (a parked item's question id, `--next` omitted
rather than faked when the queue is finished).

Five scenarios were rewritten against the landed text, `test-350k-no-anticipation.md`
was left exactly as it stands — it asserts that nothing is posted before the
boundary, which the rewrite does not touch — and two were added, one per new
refusal the typed entry introduces. Eight in total.

## Method for this round

Not run by the executor: the live runner is the coordinator's gate, never an
implementer's (`docs/dispatch-env.md`), and the coordinator runs each at
landing as one fresh Sonnet agent whose only context is the scenario file with
its `## Judging` section stripped plus the landed `skills/handoff/SKILL.md`,
the way superpowers-5f7.5 recorded it. Every scenario is therefore written to
be self-contained: the `bd plan show`, `bd question list` and
`bd session close` outputs each run needs are quoted inside the scenario, so no
run needs the repository or a second file. A FAIL routes back to the task as a
fix round before the bead is closed.

The scenarios quote bd's real behaviour, verified against a scratch tracker
while the task ran: `bd plan show` prints `PLAN` and `LANE` lines with the
lane's cursor, holder or `handed, unclaimed`, mode, next id and readiness, then
the last `handoff` line and its `thread:` lines; `bd plan handoff` refuses a
park with no question id (`error: park <id> needs a question id — file one
with bd question add`) and a thread over the cap (`error: --thread-file <path>
has 7 lines; the cap is 5`).

## Scenario: test-boundary-mid-plan.md — expected PASS

- Expected: Close in order — drain, `tracker-mining audit`, `bd session close`, one `bd plan handoff solo --lane solo-7fk` carrying `--done solo-7fk.3:a1b2c3d,solo-7fk.4:e4f5a6b`, `--next solo-7fk.5`, `--parked solo-7fk.7:Q-4` and a five-line thread; final message is the `bd plan show solo` output.
- Failure mode caught: the retired habit surviving the rewrite — composing a record and posting it to the still-open `solo-1` anchor, which the scenario leaves in place precisely as bait; also a free-text park, a thread over five lines, and the repeated-flag form `--done a:1 --done b:2`, which keeps only the last value and silently drops a completed task from the entry. The one comment retiring `solo-1` by naming plan `solo` is the skill's own rule and is excepted from the no-record clause.

## Scenario: test-habitual-transcript-prompt.md — expected PASS

- Expected: the prompt is the Resume trigger; `bd plan show zanjir` and `bd question list` are the only reads; the lane is claimed because it reads `handed, unclaimed`; the reply is five lines naming lane, next id, the parked pair and the entry's date.
- Failure mode caught: reading the predecessor's `.jsonl` transcript, and the new one the rewrite creates — hunting for a `[handoff]` comment on `zanjir-1`, which the scenario supplies with a month-old record on it.

## Scenario: test-night-brief-received.md — expected PASS

- Expected: the brief is three facts (plan, lane, execution skill); the receiver resolves the lane from `bd plan show`, claims it, works `.8` and `.10`, leaves `.9` parked on `Q-3`, never pushes, and closes with a thread whose first line opens `day`.
- Failure mode caught: ruling on a parked question to unblock the batch; pushing the day session's unpushed commits; and treating the brief as state — the brief is now three tokens long, so an agent that does not resolve the lane has nothing at all to work from.

## Scenario: test-350k-no-anticipation.md — expected PASS

- Expected: continues the plan; posts nothing, sends nothing, drafts no entry of any kind before the boundary is actually reached or the owner speaks.
- Failure mode caught: a rising token count alone pulling the agent into anticipatory handoff behaviour. Unchanged by the rewrite: the assertion is that nothing is posted, which holds whatever the posting mechanism is.

## Scenario: test-handoff-no-epic.md — expected PASS

- Expected: no plan exists, this session holds no lane, so nothing is posted anywhere; the owner decision `bd session close` lists becomes a ruling, the unmade decision becomes a filed question, and the final message says the thread is lost by design and names `bd ready`, `bd question list`, `bd plan show solo` as the next session's start.
- Failure mode caught: filling the silence — posting to the `handoff-anchor` bead the project still carries, or creating a plan and a lane so that there is somewhere to append; and the opposite failure, a bare "nothing to hand off" that drops the restart line, which is all a lane-less session leaves the next one.

## Scenario: test-night-sender-pairing.md — expected PASS

- Expected: its own lane closed with a typed entry first; exactly one `SendMessage`, to `night-a`, naming plan `zanjir`, lane `zanjir-9pk` and codex-execution; nothing to `night-b` or `night-c`; the collision and the unpaired `solo-7fk` both reported.
- Failure mode caught: breaking the one-session-per-repository refusal by picking a solo session on its own judgment, and sending a copied narrative in place of the three-fact brief. As in scenario 1, the sanctioned anchor-retirement comment is excepted from the no-record clause, which still catches a composed handoff record on either anchor.

## Scenario: test-parked-needs-question-id.md — expected PASS

- Expected: `bd question add` on `biklod-4mq.9` first, then `--parked biklod-4mq.9:<returned id>`; the `--parked` value carries a bead id and a question id and nothing else.
- Failure mode caught: the one the typed entry introduces and the record never had — an undecided item reaching the entry as prose (`biklod-4mq.9:owner must rule`), or being dropped from `--parked` and left to survive as a thread line, where nothing blocks on it. bd itself refuses the first shape; the scenario tests whether the agent files the question before it gets that far.

## Scenario: test-lane-less-close-posts-nothing.md — expected PASS

- Expected: nothing appended to `zanjir-9pk` and nothing posted to any bead; the owner decision typed as a ruling, the undecided routing typed as a question, and the loss of the thread stated rather than worked around.
- Failure mode caught: a lane-less session appending to a lane it does not hold — the scenario puts a live, richly-populated lane one command away, held by another session, so "post nothing" has to beat an available target rather than an absent one; also delivering the lane's `bd plan show` output in place of the restart line, which says nothing about what this session leaves behind.

# Fix round (2026-09-05)

The coordinator ran all eight at `56d4e5f`, each as one fresh Sonnet agent whose
only context was the scenario file with its `## Judging` section stripped plus
the landed `skills/handoff/SKILL.md`. Five passed —
`test-350k-no-anticipation`, `test-habitual-transcript-prompt`,
`test-night-brief-received`, `test-parked-needs-question-id`,
`test-lane-less-close-posts-nothing`. Three failed, on three separate defects:

1. The quoted command wrote one pair per flag. `bd plan handoff --help` defines
   `--done` as `<bead-id>:<commit-sha>` pairs, comma-separated, and `--parked`
   as `<bead-id>:<question-id>` pairs, comma-separated; a repeated string flag
   keeps only the last value, so `--done a:1 --done b:2` drops the first
   completed task. Three runs wrote that repeated form —
   `test-boundary-mid-plan`, `test-night-brief-received`,
   `test-parked-needs-question-id` — and the first failed on it, its Pass line
   naming the comma-separated form verbatim. The command now shows two pairs in
   each flag and the text pins the negative: "never a repeated flag".
2. The Fail clauses of `test-boundary-mid-plan` and `test-night-sender-pairing`
   failed a run for posting to an anchor bead, which the skill's own
   anchor-retirement rule tells the first Close to do. Both runs performed that
   retirement correctly. Both clauses now except that one comment by name and
   still catch a composed handoff record — done ids, next id, parked ids or
   thread — posted to an anchor.
3. Close named the lane-less restart line in step 4 and defined the final
   message in step 5, so a lane-less session had no stated final message.
   `test-handoff-no-epic` failed there — its run stated only that no entry was
   appended and named two of the three reads — and
   `test-lane-less-close-posts-nothing` passed with the same gap, delivering
   `bd plan show zanjir` output. Deliver now states both branches: the
   lane-holder's `bd plan show <prefix>` output, and the lane-less message that
   names the missing entry, the lost thread and the next session's three reads.

The skill stayed inside its 600-word budget: 599 words, from 598. What paid for
the additions is the "at execution start" gloss on the lane citation, "step 3 is
the whole record" in Close 4 (Deliver now carries the lane-less branch), "an
entry is a pointer, not state" in Resume 3, and a handful of single words. No
scenario's expected verdict changes: all eight are expected PASS on the re-run.

# Fix round, second pass (2026-09-05)

The coordinator re-ran all eight at `b29eb48`, same method. Seven passed,
including the three that had failed. `test-night-brief-received` failed on one
clause: its closing thread's first line did not open with the `day` header. The
receiver-conduct line said "its thread opening with the `day` header" without
defining that header, which the typed row has no field for; the first-round run
passed only by echoing the phrase, and this run wrote a plain thread. The line
now reads "its thread's first line is the word `day`", so the header the task
body keeps intact is something a receiver can write. Skill at 600 words, from
599. All eight are expected PASS on the re-run.
