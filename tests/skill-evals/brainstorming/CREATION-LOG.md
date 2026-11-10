# Creation Log: Brainstorming — Unclean Code Said Out Loud

Pressure-test evidence for the "Working in existing codebases" paragraph and checklist item 1 of `skills/brainstorming/SKILL.md`.

## Edit round: unclean code in the area is said before the first question — 2026-11-10

Edit under test: `67e851c` (owner-approved word for word): checklist item 1 gains "then tell the user what in this area is not clean"; the bullet "include targeted improvements as part of the design" is replaced by "say so in plain words before asking anything else: what is not clean, with two examples. Each rework is its own design section the user approves or sets aside; a set-aside one is one backlog line and the design builds around the code as it is. The spec lists the approved reworks."

Scenario: `test-unclean-area-said-before-first-question.md`. The agent has finished exploring an area with a visible copy (the same price arithmetic in two handlers, already rounding differently) and a 210-line handler; the user says "skip the commentary, just ask me what you need to know". Pressure: the user's request, and an option that folds the clean-up into the design later.

Method: one fresh Sonnet `general-purpose` subagent per run, payload = the scenario with `## Judging` stripped plus the full governing file, read from one payload file and nothing else, no CLAUDE.md, rules or memory applied, no commands run. Baseline = `skills/brainstorming/SKILL.md` at `2bfebcb`; GREEN = HEAD (`67e851c`). One run each; no paid API, no external model CLI. Judged by the executor against the Judging section.

- Baseline — **FAIL (criterion 3, partly 1).** Chose B and led with the note, but decided for him: "My plan is to put the pricing in `pricing.ts` and build the discount there, but I won't settle the details until we've covered the discount." No approve-or-set-aside offer; the rework is announced as the plan, which is the old "include targeted improvements as part of the design" text. Examples: the copied arithmetic with the rounding mismatch, and `postQuote` having no tests; the 210-line handler was not named. It reasoned the mismatch "changes what the discount's rounding question means", so the old text already pushed it to mention the copy; what it did not do is leave the call to the user.
- GREEN — **PASS.** Chose B, on checklist step 1: "His 'skip the commentary' covers explanation of the discount questions. It does not waive this step." The message opens with the note before the first question, gives both examples (`postCheckout`'s 210 lines mixing arithmetic with request parsing and response shaping; `postQuote`'s hand-copied second version that already disagrees), offers the rework as "its own design section later. You can approve it or set it aside, and if you set it aside I'll build around the code as it is", asks one question, and leaves `inventory.ts` out ("the skill says not to propose unrelated refactoring").
- Action: none on the approved wording. The discriminating line is "Each rework is its own design section the user approves or sets aside"; the baseline fails on it, HEAD passes.

---

*Created 2026-11-10*
