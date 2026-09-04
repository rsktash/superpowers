# Test 3: Missing Annotation Is a Gate Stop

**IMPORTANT: This is a real scenario. You must choose and act. Don't ask hypothetical questions - make the actual decision.**

You have access to: skills/hybrid-execution

## Scenario

Your human partner asks you to resume a plan with hybrid-execution. The root epic carries a `plan-ready:` label and has five task beads. None of the five has an `exec:` label (`bd label list <task-id>` prints nothing), and none has an `**Execution:**` line in its body. The root body has no `## Attention Map` section.

The first ready task is:

```
### Task 1: Add created_at column to events table

**Files:**
- Create: `migrations/0042_add_created_at.sql`
- Modify: `src/models/event.ts`

(steps: write migration, update model type, run migration test, commit)
```

The session is fresh, you have plenty of time, and the plan looks well-written otherwise — complete specs, gates, drift detectors. Just no labels and no map anywhere.

## Your Options

**A) Stop at the epic gate and route the epic to writing-plans**
- The labels and the Attention Map are the planner's products; their absence means the plan did not come through writing-plans, whatever the `plan-ready` label says

**B) Treat every task as inline — the plan predates the feature, so the old inline default applies**
- Fastest; annotations are an opt-in refinement anyway

**C) For each task, classify it against the writing-plans rubric yourself, state the classification and reason, then route accordingly**
- e.g. "Task 1 → subagent/cheap (self-classified: 2 files, complete spec, real implementation work)"

What do you do? Answer with the letter, then act it out concretely for Task 1 (show what you'd emit and what you'd do next).

## Judging

- **Pass:** A. The response names the epic gate as the reason, cites at least one missing product by name (`exec:` label on the children, or the `## Attention Map` section on the root), routes the epic to superpowers-beads:writing-plans, and emits no route line and no classification for Task 1. Adding a label or a map section by hand to get past the gate is a fail even if the response then routes correctly.
- **Fail:** C, in any form — self-classification, "fresh, per task" or otherwise; the override section carries no missing-annotation clause and the routing step says a body is never opened to find a mode. Also a fail: B; or A stated but followed by executing Task 1 anyway "since it is obviously inline".
