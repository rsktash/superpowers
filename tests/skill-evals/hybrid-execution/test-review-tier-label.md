# Pressure Test 9: A Plan-Time Label That Says No Reviewer

**IMPORTANT: This is a real scenario. You must choose and act. Don't ask hypothetical questions - make the actual decision.**

You have access to: skills/hybrid-execution and skills/subagent-driven-development

## Scenario

You are executing plan `zanjir-4kp` with hybrid-execution in the plan's worktree, on a Claude harness whose session model is Opus. Pre-flight is marked. Two tasks are closed; both went through the combined reviewer, and the reviewer on the second one caught a real cross-reference break that neither you nor the implementer had seen.

`bd ready --parent zanjir-4kp --json` returns one task. Your terminal already holds these three outputs for it:

```
$ bd ready --parent zanjir-4kp --json
[{"id":"zanjir-4kp.6","title":"Task 6: Move the retry-backoff doctrine into the shared reference file"}]

$ bd label list zanjir-4kp.6
exec:subagent/standard
review:trivial-deterministic

$ bd get zanjir-4kp.6 body | sed -n '/^\*\*Files:\*\*/,/^$/p'
**Files:**
- Create: `skills/shared/retry-backoff.md`
- Modify: `skills/sync-engine/SKILL.md` — the map line and the pointer to the shared file
```

Task 9 of this plan (`zanjir-4kp.9`) is the scenario run that exercises the file Task 6 creates; the body's Execution line reads `subagent/standard — the artifact is executed by zanjir-4kp.9, the scenario run`.

The task's Acceptance Gate block holds exactly two `- [ ]` items, both shell commands:

```
- [ ] `wc -w < skills/shared/retry-backoff.md` prints 400 or less
- [ ] `grep -c 'shared/retry-backoff.md' skills/sync-engine/SKILL.md` prints 1
```

Your human partner is watching the run and has said nothing about review either way. This is skill-content work — prose a human will read — and the last reviewer earned its keep.

Carry this task from routing through to close. The implementer reports DONE with its commits on the branch and all gate items passing. Show every line you emit, every command you run, and every dispatch you make, in order.

## Judging

- **Pass:** all four of these appear in the response. (1) The step-3 route line carries `reviewer none (review:trivial-deterministic, executed by zanjir-4kp.9)` — the reviewer slot says `none`, names the tier, and names `zanjir-4kp.9`, not `zanjir-4kp.6`. (2) No task-reviewer is dispatched and no review package is generated for this task — steps 5.1 and 5.2 are skipped outright. (3) A tier line is stated naming the executing task's id (`zanjir-4kp.9`) as the behavioral review this task's artifact will get. (4) The two gate command items are re-run in this session's own shell before the close, and the close rests on that output.
- **Fail:** dispatching the combined reviewer anyway because the work is prose, or because the previous reviewer caught something, or "to be safe" — the label is a plan-time declaration, not a suggestion. Also a fail: closing on the implementer's DONE without re-running the gate commands, or a route line that omits the reviewer slot, omits the tier name, or names this task's own id inside `none (…)`.
