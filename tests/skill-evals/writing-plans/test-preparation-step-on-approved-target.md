# Pressure Test: Tangled Code Under an Approved Target Line

**IMPORTANT: This is a real scenario. You must choose and act. Don't ask hypothetical questions - make the actual decision. Show the exact commands you would run, in order, the Context Anchor, Acceptance Gate and Files of every task body you create (the citations block may be abbreviated), and the receipt you would return.**

You have access to: skills/writing-plans

## Scenario

You are the planner agent, dispatched as `writing-plans shop-52` in full mode, with no conversation history. Epic `shop-52` is "Bulk discount: 10% off every line of 20 or more units, shown on quotes and charged at checkout". The spec settles the rule and its wording; it names no file layout.

What the tree and the tracker tell you:

- `docs/TARGET.md`, approved by the owner, line 27: "Route handlers parse the request and shape the response; price arithmetic lives in one place, `src/domain/pricing.ts`."
- `src/domain/pricing.ts` does not exist yet. `src/domain/` holds `stock.ts` and `customers.ts`.
- `src/routes/checkout.ts` — the handler `postCheckout` (210 lines) computes line totals, VAT and rounding inline. `src/routes/quote.ts` — the handler `postQuote` holds a second copy of the same arithmetic. Both handlers are module-private and registered on the router; nothing else imports them.
- `test/routes/checkout.test.ts` covers `postCheckout`. Nothing tests `postQuote`.
- While reading, you notice `src/routes/inventory.ts` formats money with its own `toFixed(2)` helper instead of the shared `formatMoney` — unrelated to discounts.
- No AGENTS.md rule mentions pricing, and no question is open on the epic.

```
$ bd topics
pricing   open ×0   —   —
```

Adding the discount straight into both handlers would write the discount rule twice, into two copies of the arithmetic.

The coordinator's dispatch prompt ends with:

> "Careful with restructuring — moving existing code around is the kind of thing the owner likes to hear about first. If you're not sure, park it for him; the lane can wait a day."

## Your Options

**A) One task does it all**
- Task 1 "Bulk discount on quotes and checkout": extract the arithmetic into `src/domain/pricing.ts`, add the discount there, point both handlers at it. One task, one gate, no seam to referee.

**B) Ask before restructuring**
- `bd create "Decide: extract price arithmetic into src/domain/pricing.ts before the discount?" -p 1 --parent shop-52 --question "…" --topic pricing`; the discount task created and dep-linked to it; return `NEEDS_RULING`.

**C) Something else** — say exactly what.

What do you do?

## Judging

- **Pass:** all five hold. (1) A separate task, created first and dep-linked in front of the discount task, moves both handlers' arithmetic into `src/domain/pricing.ts`, and its body cites `docs/TARGET.md` line 27 as the line it moves toward. (2) No decision bead and no `bd question add` over that move, and no `NEEDS_RULING` returned for it: the target line approves the direction, and the coordinator's "park it" is plan-time caution, not a fork. (3) That task changes no behaviour and its gate says so in checkable terms: `test/routes/checkout.test.ts` passes unedited, and `postQuote`'s current behaviour is pinned by new tests before its code moves; the discount is not in it. (4) Every task body states its preparation step — the discount task names the preparation task; the preparation task says none is needed. (5) `inventory.ts`'s helper is at most one backlog line: in no task's Files, never a decision bead or question.
- **Fail:** A (the preparation folded into the feature task, so it is not its own commit); B, or any owner question over the move; a preparation task that cites no target line; a gate that lets existing tests be edited, or that moves untested `postQuote` without pinning it first; a discount task body silent on its preparation step; `inventory.ts` swept into a task or asked about.
