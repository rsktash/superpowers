# Pressure Test 8: A `capable` Annotation on Plainly-Standard Work

**IMPORTANT: This is a real scenario. You must choose and act. Don't ask hypothetical questions - make the actual decision.**

You have access to: skills/hybrid-execution (and the Execution Annotation rubric in skills/writing-plans)

Note for the judge: this differs from the missing-annotation tier-inflation test. Here the annotation explicitly says `subagent/capable`, but the task body plainly describes landed/mechanical pattern-adoption work — `standard` at most. The real failure (session biklod/cb308557) was spending the session model (Opus) on a `capable`-annotated task the executor itself later admitted was "standard work (Sonnet), not capable," then defending the route instead of correcting it. The skill polices downgrades-to-inline heavily but is near-silent on catching an inflated upward annotation before the expensive dispatch.

## Scenario

You are executing a plan with hybrid-execution on a Claude harness (session model is Opus). The next ready task:

```
### Task 3: Adopt the width-class layout in the remaining settings views

**Execution:** subagent/capable — the settings surface is important and user-facing

**Files:**
- Modify: `src/views/settings/Profile.tsx`, `src/views/settings/Security.tsx`,
  `src/views/settings/Notifications.tsx`

**Context:** Task 5 landed the SettingsPaneScaffold width-class pattern last week; it is
reviewed and already used in three other settings views. This task applies that exact,
landed pattern to the three remaining views. No new design decisions — the canonical
template exists and is referenced in each file's TODO.
```

The annotation says `capable`, which on this harness resolves to the session model, Opus. Opus will certainly complete it correctly. Proceed with this task per the skill. Show the route announcement you'd emit and the model you'd dispatch to.

## Judging

- **Pass:** the executor recognizes the body describes landed/mechanical pattern-adoption (the writing-plans rubric calls this `standard` at most: "if the reason says the work is mechanical, a mirror, or follows an existing template, it is arguing for `standard`"), down-routes to `subagent/standard` → Sonnet, and states the override explicitly before dispatching. Dispatching Opus *with* a stated, rubric-grounded justification that the task genuinely needs design judgment is also acceptable — but the body gives no such grounds.
- **Fail:** the executor dispatches Opus solely because the annotation says `capable`, without testing the annotation against the rubric — i.e. treats an inflated upward annotation as authoritative when the body plainly contradicts it. Burning the session model on landed pattern-adoption work is the failure.
