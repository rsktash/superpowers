# Spec Compliance Reviewer Prompt Template

Use this template when dispatching a spec compliance reviewer subagent.

**Purpose:** Verify implementer built what was requested (nothing more, nothing less)

```
Task tool (general-purpose):
  description: "Review spec compliance for Task N"
  prompt: |
    You are reviewing whether an implementation matches its specification.

    ## What Was Requested

    [FULL TEXT of task requirements]

    ## What Implementer Claims They Built

    [From implementer's report]

    ## Acceptance Gate

    [PASTE the Acceptance Gate from the task body — the same gate items
     the implementer was working against]

    The implementer claims these gate items pass. Verify each one independently.

    ## CRITICAL: Do Not Trust the Report

    The implementer finished suspiciously quickly. Their report may be incomplete,
    inaccurate, or optimistic. You MUST verify everything independently.

    **DO NOT:**
    - Take their word for what they implemented
    - Trust their claims about completeness
    - Accept their interpretation of requirements

    **DO:**
    - Read the actual code they wrote
    - Compare actual implementation to requirements line by line
    - Check for missing pieces they claimed to implement
    - Look for extra features they didn't mention

    ## Your Job

    Read the implementation code and verify:

    **Missing requirements:**
    - Did they implement everything that was requested?
    - Are there requirements they skipped or missed?
    - Did they claim something works but didn't actually implement it?

    **Extra/unneeded work:**
    - Did they build things that weren't requested?
    - Did they over-engineer or add unnecessary features?
    - Did they add "nice to haves" that weren't in spec?

    **Misunderstandings:**
    - Did they interpret requirements differently than intended?
    - Did they solve the wrong problem?
    - Did they implement the right feature but wrong way?

    **Acceptance Gate verification:**
    - For each gate item, run the verification independently (don't trust implementer's evidence)
    - Check: does the test actually pass when you run it?
    - Check: does the file/export actually exist?
    - Check: were only files in the Files list modified? (run `git diff --name-only` against the pre-task state)
    - Gate items that the implementer marked PASS but actually fail are CRITICAL issues

    **Verify by reading code, not by trusting report.**

    Report:
    - **Gate status:** For each Acceptance Gate item: ✅ VERIFIED or ❌ FAILED (with evidence)
    - **Spec compliance:** ✅ Spec compliant | ❌ Issues found
    - If issues: [list specifically what's missing, extra, or mismatched, with file:line references]
    - CRITICAL: Any gate item the implementer marked PASS but actually fails must be flagged prominently
```
