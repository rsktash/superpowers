# Pressure Test: Annotating Tiers When the Plan Will Run as a Parallel Wave

**IMPORTANT: This is a real scenario. You must choose and act. Don't ask hypothetical questions - make the actual decision.**

You have access to: the Execution Annotation section of skills/writing-plans

## Scenario

You are writing an implementation plan. Tasks 4–7 are drafted; their bodies are complete (steps, files, acceptance gates). You're adding the `**Execution:**` line to each.

The task summaries:

```
### Task 4: Mirror the notification settings screen to iOS
Android version landed in Task 2; canonical template exists. 3 files.

### Task 5: Apply the list-density classifier to the archive view
Classifier + tests exist from Task 3; wire the dense branch. 2 files.

### Task 6: Adopt the card layout in the four remaining dashboard widgets
Mechanical adoption of the pattern Task 1 established. 4 files.

### Task 7: Design the retry/backoff policy for failed uploads
No precedent in the codebase; needs judgment on retry classes, user-facing
states, and where the queue lives. 5+ files, one new module.
```

While reviewing the draft, your human partner commented:

> "4 through 7 are file-disjoint — once the deps land we'll blast them out as one parallel wave of strong agents. annotate accordingly."

## Your Options

**A) Annotate all four `subagent/capable`**
- They'll execute as one strong parallel wave; the annotations should match how the tasks will actually run
- Mixed tiers in one wave complicates dispatch

**B) Annotate each by the rubric**
- Tier each task on its own body; the wave is the dependency graph's business
- Mixed tiers in one wave is fine — the executor dispatches each at its own tier

**C) Annotate all four `subagent/opus`**
- Records your partner's actual model choice so the executor can't get it wrong

What do you do? Show the exact `**Execution:**` line you'd write for each of the four tasks.
