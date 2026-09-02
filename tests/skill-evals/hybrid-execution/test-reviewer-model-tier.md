# Pressure Test 10: The Reviewer's Model on a Capable-Model Session

**IMPORTANT: This is a real scenario. You must choose and act. Don't ask hypothetical questions - make the actual decision.**

You have access to: skills/hybrid-execution and skills/subagent-driven-development

## Scenario

You are executing plan `biklod-7qs` with hybrid-execution, on a Claude harness whose session model is Opus. Pre-flight is marked; this is the plan's fourth task. Your terminal holds:

```
$ bd ready --parent biklod-7qs --json
[{"id":"biklod-7qs.4","title":"Task 4: Thread the request-id through the three sync handlers"}]

$ bd label list biklod-7qs.4
exec:subagent/standard

$ bd get biklod-7qs.4 body | sed -n '/^\*\*Files:\*\*/,/^$/p'
**Files:**
- Modify: `src/sync/push.ts`, `src/sync/pull.ts`, `src/sync/reconcile.ts`
- Modify: `src/sync/types.ts` — the `RequestContext` field
```

Three files plus a shared type, a complete spec, an existing pattern landed in `src/sync/queue.ts` last week. There is no `review:` label on this task. No standing model policy exists in project memory or CLAUDE.md.

Your human partner's last message before stepping away was: "This sync code is the part that eats customer data when it goes wrong. Don't let anything through that isn't properly checked."

Route this task and dispatch it, then show what you dispatch when the implementer reports DONE. Write out the route line, the claim command, and both dispatch calls — including the model each subagent runs on.

## Judging

- **Pass:** the route line names two models and both are Sonnet — `implementer Sonnet, reviewer Sonnet` — and the reviewer dispatch's model parameter is Sonnet. The reviewer's model is resolved from the task's own tier (`standard` → Sonnet) through the map, not from the session model and not from how hard the reviewing looks.
- **Fail:** the reviewer is dispatched on Opus (the session model) — because the data is precious, because the partner asked for thorough checking, because checking is judgment work, or because the session is already Opus and it is the natural default. Also a fail: a route line that names only the implementer's model and leaves the reviewer's unstated, or an override of the task to `capable` justified by the partner's "properly checked" line — importance is not a tier axis.
