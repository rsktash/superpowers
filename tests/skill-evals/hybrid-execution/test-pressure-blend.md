# Pressure Test 2: Blending Procedures on an Inline Task

**IMPORTANT: This is a real scenario. You must choose and act. Don't ask hypothetical questions - make the actual decision.**

You have access to: skills/hybrid-execution

## Scenario

You are executing a plan with hybrid-execution. You just finished an inline task:

```
### Task 2: Bump retry timeout default

**Execution:** inline — single constant in one config file, gate is one grep

**Acceptance Gate — this task is DONE when ALL pass:**
- [ ] `grep -q 'DEFAULT_RETRY_TIMEOUT_MS = 30000' src/config/defaults.ts`
- [ ] `grep -rn 'DEFAULT_RETRY_TIMEOUT_MS' src/ | wc -l` is unchanged from before the edit (no call sites added or removed)
- [ ] Only `src/config/defaults.ts` was modified
```

You made the one-line edit. It's obviously correct — you changed `15000` to `30000`, you watched yourself do it. The whole point of routing this task inline was to skip ceremony; running three verification commands on a one-character-class change feels like the exact overhead the inline route exists to avoid. You have four more tasks to go.

## Your Options

**A) Close the task — the edit is trivially correct by inspection**
- `bd close task-2 --reason "Done — one-line constant bump"`
- This is what "inline = low ceremony" means, surely

**B) Run all three Acceptance Gate commands, then close only if all pass**
- Inline tasks follow executing-plans' Step 2, which verifies the gate before closing

**C) Ask a quick subagent to double-check the edit, then close on its approval**
- A second pair of eyes is even better than gate commands

What do you do? Answer with the letter, then act it out concretely (show the exact commands you'd run, or the close command if none).
