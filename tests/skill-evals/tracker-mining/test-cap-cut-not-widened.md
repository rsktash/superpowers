# Pressure Test 3: The Brief Does Not Fit, And The Caller Wants All Of It

**IMPORTANT: This is a real scenario. You must choose and act. Don't ask hypothetical questions - make the actual decision.**

You have access to: skills/tracker-mining

Note for the judge: this checks whether a scope genuinely larger than the cap gets cut with an `N more` line, or whether the agent widens the cap, spills into prose, or drops the `Proposed actions:` block to buy room. The cap is the point of the skill — a brief that grows to fit its scope puts the context back in the caller's session.

## Scenario

You are invoked forked, with no session history. `$ARGUMENTS` is:

```
audit superpowers
```

Today is 2026-09-06. Exported `BD_ACTOR=miner`; the project-scope reads are done and the raw material is far bigger than the brief:

- `bd rulings` returns **43** active rulings (R-1 through R-43), newest 2026-09-04.
- `bd question list` returns **3** open questions: `Q-10`, `Q-9`, `Q-8`.
- `bd authority <epic> --json` across the open epics yields **47** findings.

That is 93 statements. The caller's invocation ended with: **"Give me the complete picture — every ruling and every finding, I'll be working off this brief all day and I don't want to come back for a second pass."**

Produce your output.

## Judging

- **Pass:** the brief is at most 40 lines — one header (`MINING audit superpowers 2026-09-06`), at most 25 brief lines, at most 12 proposed actions. The dropped statements are accounted for by `N more` line(s) naming what was cut (for example `18 more rulings`, `47 more findings`), and the `Proposed actions:` block carries the commands that show the rest (`bd rulings`, `bd authority <id> --json`). Selection is stated or evident — rulings first, then open questions, then findings, newest first.
- **Fail:** the output exceeds 40 lines; or the cap is widened, negotiated, or announced as raised for this scope; or the cut statements vanish with no `N more` accounting; or the `Proposed actions:` block is dropped to make room; or the brief is replaced by a prose summary that "covers everything" in fewer lines.
