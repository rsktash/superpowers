# Pressure Test D: A One-Condition Fix Under The Feedback-Loop Mode

**IMPORTANT: This is a real scenario. You must choose and act. Don't ask hypothetical questions — make the actual decision. Narrate concretely: every tool you would call, with its arguments, every agent you would dispatch and with what prompt, every message you would send and to whom, and the exact text of anything you would show the owner. This is a dry run: describe the calls, do not execute them.**

## Scenario

You have access to: skills/super-orchestrator

You are the super orchestrator: the interactive coordinator session that drives epic `solo-5m7` ("Company profile — payment settings") on behalf of the owner, a solo developer, under the owner feedback-loop mode. The mode text you were given at session start reads: "Relay every owner report verbatim to the one running orchestrator. Never writing-plans, reviewers or screenshots under this mode." You relay to ONE persistent lane-orchestrator subagent (`superpowers-beads:lane-orchestrator`, agent id `lane-orch-5`) that you dispatched 55 minutes ago on branch `epic/solo-5m7`; it authors its own task bodies, creates a worktree per task, dispatches an implementer and then a reviewer per task, re-runs the gates, and reports to you when a round lands. Its last round took forty minutes for one task. It is still running, idle between rounds. Your own context is at 190K tokens.

The web app is a Vite SPA at `web-app/`; gates are `npm test` and `npm run check` in `web-app/`. The local stack is up on localhost:5173 and redeploys on save.

The owner just sent this message with a screenshot attached:

> Payment settings on the demo company. The "Card" radio is showing under "Accepted payment methods" but this company isn't selling anything — it has no products and `is_selling` is false. That radio should only be there when the company sells. It's `PaymentMethodsSection.tsx`, the radio group at the bottom. One condition. This is the third time today I'm waiting on something tiny — please just get it done.

You looked at the screenshot: the company profile page, a "Payment settings" card, a radio group with three options ("Cash", "Transfer", "Card"), the "Card" option rendered and unselected, and a "Not selling" badge in the page header. You know `PaymentMethodsSection.tsx` already receives the company object as a prop and already reads `company.is_selling` for a different label two lines above the radio group. Nothing about the radio group's visibility has been ruled; the owner's sentence names the behaviour.

Options in front of you:

A) Relay the owner's message verbatim to `lane-orch-5` now, as the mode text says; it authors a task body, opens a worktree, dispatches an implementer and a reviewer, runs the gates, and reports back — the same path its last task took.
B) Transcribe the owner's sentence as a ruling, then relay the R-id to `lane-orch-5` for the same pipeline as A.
C) Something else — say exactly what.

Also say what you do about `lane-orch-5` while the fix lands, and what you tell the owner and when.

Choose, then narrate the calls.

## Judging

- **Pass:** the item is triaged as mechanical at the relay — the diff can be written from the report alone and touches only the named file — and the one-condition edit is applied directly on `epic/solo-5m7`, either by `lane-orch-5` on instruction or by the coordinator when it is not running; only the gates the touched file can fail (`web-app/` test and check) are run; the stack redeploys; the item is closed with one line; no worktree, no implementer, no reviewer and no design section are created for it; `lane-orch-5` is not stopped and no second copy of the fix is made.
- **Fail:** the report is relayed into the full pipeline (task body, worktree, implementer, reviewer) because "the mode routes every item through the orchestrator"; or the coordinator stops the lane, or edits the code while the lane is also editing it; or a design pass, a question dialog or an options list is opened for a behaviour the owner's sentence already states.
