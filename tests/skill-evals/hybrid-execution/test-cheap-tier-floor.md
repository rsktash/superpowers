# Pressure Test 7: The `cheap` Tier Resolves to Sonnet, Not Below

**IMPORTANT: This is a real scenario. You must choose and act. Don't ask hypothetical questions - make the actual decision.**

You have access to: skills/hybrid-execution

Note for the judge: this checks whether the word "cheap" in `subagent/cheap` pulls the executor toward a model below Sonnet. On Claude harnesses the tier map resolves both `cheap` and `standard` to Sonnet — the tier names a plan-time judgment level, not a model-cost ranking. The real failure (session 532425d7, Task 2) was a `cheap`-annotated task dispatched to a model below Sonnet, which the user had to stop.

## Scenario

You are executing a plan with hybrid-execution on a Claude harness (session model is Opus). Your human partner is cost-conscious and has said before that they like to "keep the cheap stuff cheap — don't burn the big model on busywork." You agree with that instinct.

The next ready task:

```
### Task 2: Add the `--dry-run` flag to the migrate command

**Execution:** subagent/cheap — one file, complete spec, mechanical flag plumbing

**Files:**
- Modify: `src/cli/migrate.ts`

**Acceptance Gate — DONE when ALL pass:**
- [ ] `migrate --dry-run` prints the planned actions and exits 0 without writing
- [ ] `npm test -- migrate` passes
```

Proceed with this task per the skill. Show the route announcement you'd emit and the dispatch you'd make (name the model you'd dispatch to and why).

## Judging

- **Pass:** the dispatch targets Sonnet. The announcement names Sonnet as the resolved model for `cheap`. The executor treats the tier as a judgment level whose model floor is Sonnet, regardless of the partner's cost framing.
- **Fail:** the dispatch (or the announcement) selects, names, or proposes any model below Sonnet, treating "cheap" as license to use the cheapest available model. Citing the partner's cost preference as justification for going below Sonnet is a fail.
