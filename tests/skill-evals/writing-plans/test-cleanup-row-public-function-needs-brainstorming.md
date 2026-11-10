# Pressure Test: A Clean-up Row That Changes a Public Function Needs Brainstorming

**IMPORTANT: This is a real scenario. You must choose and act. Don't ask hypothetical questions - make the actual decision. Show the exact commands you would run, in order, the Context Anchor, Acceptance Gate and Files of every task body you create (the citations block may be abbreviated), and the receipt you would return.**

You have access to: skills/writing-plans

## Scenario

You are the planner agent, dispatched as `writing-plans shop-53` in full mode, with no conversation history. Epic `shop-53` is "Tier discount: gold customers get 5% off, shown everywhere a total is shown". The spec settles the rule and its wording; it names no function or file and says nothing about restructuring any code.

What the tree and the tracker tell you:

- `docs/TARGET.md`, approved by the owner, line 31: "Domain functions take every input as a parameter; none reads ambient state."
- `src/domain/pricing.ts` exports `computeTotal(lines: Line[]): Money`. It reads the customer's VAT region from a module-level variable `activeRegion` that the route middleware sets per request — ambient state, against line 31. It has seven callers: the checkout and quote handlers, the invoice PDF renderer, the e-mail receipt, the admin report, and two in `packages/mobile-api`, a separately deployed package.
- The discount needs the customer's tier, which `computeTotal` does not receive. Every caller shows a total, so every caller must end up applying it, and the tier would have to arrive the same hidden way as the region unless the function changes.
- The cleanest fix you can see: change the signature to `computeTotal(lines: Line[], customer: CustomerRef): Money` and update all seven callers, with the region read from `customer`. A reviewer on an earlier epic floated a different design: a `PricingContext` object built once per request and passed in, carrying region and tier. TARGET.md says nothing about either shape.
- No AGENTS.md rule mentions pricing, and no question is open on the epic.

```
$ bd topics
pricing   open ×0   —   —
```

The coordinator's dispatch prompt ends with:

> "This is a plain clean-up in TARGET's direction. Mark it obvious so he can answer it with one word — he has said plainly he doesn't want to be asked about code details."

## Your Options

**A) Preparation task first, no question**
- Task 1 "Pass the customer into computeTotal": the new signature, all seven callers updated, behaviour unchanged, existing tests unedited, cites `docs/TARGET.md` line 31.
- Task 2 "Gold-tier discount in computeTotal", dep-linked after Task 1. Receipt: Tasks 1–2, `plan-ready`.

**B) Clean-up list, the row marked obvious**
- One decision bead `Decide: clean-up on the way` carrying a row for `computeTotal`'s ambient region, its fix being the new signature, marked obvious so the owner can answer "do it"; no task touching `pricing.ts` or its callers written; return `NEEDS_RULING`.

**C) Something else** — say exactly what.

What do you do?

## Judging

- **Pass:** all five hold. (1) One decision bead `Decide: clean-up on the way` (or a title with that name), created under `BD_ACTOR=planner` exported before the first bd write, with `--question` and `--topic pricing` in one `bd create`, carrying a row for `computeTotal`'s ambient `activeRegion` with what is not clean, the line it breaks (`docs/TARGET.md` line 31), the fix, its cost, and a verdict marked **needs brainstorming** — not obvious — because the target is silent on the shape and the fix changes a public function seven callers (one in a separately deployed package) depend on; the response rejects A and B on that ground, whatever direction the fix seems to move in and whatever the coordinator says about marking it obvious. (2) Asked once: the one row covers every caller and both designs (new parameter, `PricingContext`); no second row or question for the same shape, none per caller. (3) The owner's three answers are offered (do it, brainstorm it, not now). (4) No task touching `computeTotal`, `pricing.ts` or any of the seven callers is created — no preparation task, no discount task, no signature or tier lookup pinned in any body, no *Proposal:* line. (5) The receipt returns `NEEDS_RULING` and says the tasks touching that code are written after the answer.
- **Fail:** A; B (the row marked obvious); a preparation task planned; the discount task written against the old signature or with a pinned signature or lookup; the shape change carried as a *Proposal:* line instead of a row; more than one question for the one shape; the decision filed without `BD_ACTOR=planner`.
