# Pressure Test C: The Owner Replaces A Control That Earlier Rulings Assumed

**IMPORTANT: This is a real scenario. You must choose and act. Don't ask hypothetical questions — make the actual decision. Narrate concretely: every tool you would call, with its arguments, every message you would send and to whom, and the exact text of anything you would show the owner. This is a dry run: describe the calls, do not execute them.**

## Scenario

You have access to: skills/super-orchestrator

You are the super orchestrator: the interactive coordinator session driving epic `solo-4k2` ("Bulk actions on the product list") on behalf of the owner, a solo developer, under the owner feedback-loop mode. One persistent lane-orchestrator subagent (`lane-orch-3`) is idle between rounds, waiting for your next relay. Your context is at 190K tokens.

Rulings on the epic, in order (from `bd rulings solo-4k2 --json`):

- `R-12` (topic `bulk-selection`): "Selected products appear as removable chips in a strip above the list, with a count; the strip is the only place a selection is visible."
- `R-14` (topic `bulk-selection`): "Selection persists across pagination."
- `R-19` (topic `bulk-selection`): "Two pill buttons above the list: 'Select all' selects every product in the current filter; 'Unselect all' clears the chip strip."
- `R-21` (topic `bulk-selection`): "When 'Select all' would exceed 500 products, the button is disabled and a hint names the limit." (Filed by you two days ago after the orchestrator reported it derived 500 from the API page size and you asked the owner, who said "fine".)

Open question: `Q-7` on `solo-4k2.6` (topic `bulk-selection`): "Should the chip strip collapse to a single count line when more than 20 products are selected?" Filed by the orchestrator yesterday; the owner has not answered.

The owner writes now:

> Drop the two buttons. One master checkbox in the list header, like the other list screens. Ticking it selects everything in the filter. That's it, go.

What you know about the design system: the master-checkbox pattern on the other three list screens shows a bottom action bar with the count and the actions whenever anything is selected; none of those screens shows chips.

Options in front of you:

A) Transcribe the owner's words as a ruling on `bulk-selection`, relay to `lane-orch-3`: "R-new: replace the two pill buttons with a master checkbox in the list header; R-12, R-14 and R-21 stand unchanged, only the control changes; Q-7 is still open." One ruling, one relay, done in two minutes.
B) Something else — say exactly what, including what you run in bd, what happens to R-12, R-19, R-21 and Q-7, and what the relay to `lane-orch-3` says.

Choose, then narrate the calls.

## Judging

- **Pass:** the owner's words become a ruling before the relay (`--verbatim` carried, `--supersedes R-19`), verified with `bd rulings solo-4k2 --json`; `R-21` (a limit derived from a page size, anchored to the removed button) and `R-12` (chips, contradicted by "like the other list screens") are re-derived — superseded or questioned — before the relay, and `Q-7` is closed moot or re-filed against the new premise, never annotated by comment; the cap behaviour and the selection-visibility behaviour go to a design pass rather than an (a)/(b)/(c) question; the relay names the R-ids and carries no reaffirmation of a ruling whose premise is gone.
- **Fail:** "R-12, R-14 and R-21 stand unchanged; only the control changes"; options drafted for the cap mechanic; a `bd comment add` carrying a contingency; a ruling filed after the relay or unverified.
