---
name: requesting-code-review
description: Use when completing tasks, implementing major features, or before merging to verify work meets requirements
---

# Requesting Code Review — budget 400 words

Dispatch superpowers-beads:code-reviewer subagent to catch issues before they cascade. The reviewer gets precisely crafted context for evaluation — never your session's history.

**Core principle:** Review early, review often.

## When to Request Review

**Mandatory:**
- After each task in subagent-driven development, at the tier that task's diff earns
- After completing major feature
- Before merge to main

**Optional but valuable:**
- When stuck (fresh perspective)
- Before refactoring (baseline check)
- After fixing complex bug

## How to Request

**1. Get git SHAs:**
```bash
BASE_SHA=<the commit the work under review started from — recorded before the work began>
# NEVER HEAD~1: it silently drops all but the last commit of a multi-commit task
HEAD_SHA=$(git rev-parse HEAD)
```

**2. Dispatch code-reviewer subagent:**

Use Task tool with superpowers-beads:code-reviewer type, fill template at `code-reviewer.md`

**Placeholders:**
- `{WHAT_WAS_IMPLEMENTED}` - What you just built
- `{PLAN_OR_REQUIREMENTS}` - What it should do
- `{BASE_SHA}` - Starting commit
- `{HEAD_SHA}` - Ending commit
- `{DESCRIPTION}` - Brief summary

**3. Act on feedback — triage by authority first:**
- A finding is a **defect** only if it cites the authority it violates: a gate item, a normative task clause, an explicit convention, an AGENTS.md rule, or a recorded owner ruling where no AGENTS.md covers the code. Severity ranks defects; it never converts a proposal into round content.
- Defects: one fix round carrying all of them. Proposals: one line on the backlog bead. An unapproved new pattern: one owner question, and no merge until it is answered.
- Push back if reviewer is wrong (with reasoning)

## Integration with Workflows

**Plan execution (subagent-driven-development / hybrid-execution / opencode-execution):** review per task at its own tier; the whole-diff review runs once at the end.

## Red Flags

**Never:**
- Skip a review the tier table calls for (a tier is chosen from the diff, never from a feeling that it's simple)
- Ignore Critical issues
- Proceed with unfixed Important issues
- Argue with valid technical feedback

