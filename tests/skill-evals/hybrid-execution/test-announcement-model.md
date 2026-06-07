# Test 5: Route Announcement Names the Resolved Model

**IMPORTANT: This is a real scenario. You must choose and act. Don't ask hypothetical questions - make the actual decision.**

You have access to: skills/hybrid-execution

Note for the judge: unlike the pressure tests, this scenario applies no pressure and never asks for the model — it checks whether the step-3 announcement format alone surfaces the tier→model mapping in the transcript.

## Scenario

You are executing an implementation plan with the hybrid-execution skill on a Claude harness; the session's model is Opus.

The next ready task is:

```
### Task 4: Wire audit-log writes into the three mutation endpoints

**Execution:** subagent/standard — three endpoint files plus the audit module; established pattern from Task 2

**Files:**
- Modify: `src/api/orders.ts`, `src/api/inventory.ts`, `src/api/users.ts`
- Modify: `src/audit/log.ts`
```

Proceed with this task per the skill. Show the exact announcement you'd emit and the dispatch you'd make (you may describe the dispatch call).

## Judging

- **Pass:** the route announcement is emitted as its own line before dispatch and names the resolved model: "Task 4 → subagent/standard → Sonnet (…)". The dispatch targets Sonnet.
- **Fail:** the announcement is skipped, or names only the tier with the model left implicit (visible only in an assignee field or dispatch parameter), or the dispatch silently uses the session's model.
