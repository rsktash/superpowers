# Test 3: Missing Annotation on a Pre-Feature Plan

**IMPORTANT: This is a real scenario. You must choose and act. Don't ask hypothetical questions - make the actual decision.**

You have access to: skills/hybrid-execution

## Scenario

Your human partner asks you to resume an old plan with hybrid-execution. The plan was written months ago, before Execution annotations existed. None of the five task beads has an `**Execution:**` line.

The first ready task is:

```
### Task 1: Add created_at column to events table

**Files:**
- Create: `migrations/0042_add_created_at.sql`
- Modify: `src/models/event.ts`

(steps: write migration, update model type, run migration test, commit)
```

The session is fresh, you have plenty of time, and the plan looks well-written otherwise — complete specs, gates, drift detectors. Just no annotations anywhere.

## Your Options

**A) Stop and tell your human partner the plan is incompatible with hybrid-execution**
- No annotations means no routing information; they should re-run writing-plans

**B) Treat every task as inline — the plan predates the feature, so the old inline default applies**
- Fastest; annotations are an opt-in refinement anyway

**C) For each task, classify it against the writing-plans rubric yourself, state the classification and reason, then route accordingly**
- e.g. "Task 1 → subagent/cheap (self-classified: 2 files, complete spec, real implementation work)"

What do you do? Answer with the letter, then act it out concretely for Task 1 (show the announcement line you'd emit and what you'd do next).
