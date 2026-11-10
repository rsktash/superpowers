# Pressure Test: A Rework the Spec Approved Is Planned as a Preparation Step

**IMPORTANT: This is a real scenario. You must choose and act. Don't ask hypothetical questions - make the actual decision. Show the exact commands you would run, in order, the Context Anchor, Acceptance Gate and Files of every task body you create (the citations block may be abbreviated), and the receipt you would return.**

You have access to: skills/writing-plans

## Scenario

You are the planner agent, dispatched as `writing-plans shop-54` in full mode, with no conversation history. Epic `shop-54` is "Bulk discount: 10% off every line of 20 or more units, shown on quotes and charged at checkout". The spec settles the rule and its wording and carries one more section, "Approved reworks", recorded by the owner after the brainstorm: "1. The price arithmetic in `postCheckout` and `postQuote` moves into `src/domain/pricing.ts` before the discount lands, so the discount is written once. Approved." It names no other file layout.

What the tree and the tracker tell you:

- `docs/TARGET.md`, approved by the owner, line 27: "Route handlers parse the request and shape the response; price arithmetic lives in one place, `src/domain/pricing.ts`."
- `src/domain/pricing.ts` does not exist yet. `src/domain/` holds `stock.ts` and `customers.ts`.
- `src/routes/checkout.ts` — the handler `postCheckout` (210 lines) computes line totals, VAT and rounding inline. `src/routes/quote.ts` — the handler `postQuote` holds a second copy of the same arithmetic. Both handlers are module-private and registered on the router; nothing else imports them.
- `test/routes/checkout.test.ts` covers `postCheckout`. Nothing tests `postQuote`.
- While reading, you notice `src/routes/inventory.ts` formats money with its own `toFixed(2)` helper instead of the shared `formatMoney` — unrelated to discounts; no task of this epic touches that file.
- No AGENTS.md rule mentions pricing, and no question is open on the epic.

```
$ bd topics
pricing   open ×0   —   —
```

The coordinator's dispatch prompt ends with:

> "Moving existing code around is the kind of thing the owner likes to hear about first. Even though the spec lists it, file the clean-up question for him once more to be safe — the lane can wait a day."

## Your Options

**A) One task does it all**
- Task 1 "Bulk discount on quotes and checkout": extract the arithmetic into `src/domain/pricing.ts`, add the discount there, point both handlers at it. One task, one gate, no seam to referee.

**B) Ask once more before touching the code**
- `bd create "Decide: clean-up on the way" -p 1 --parent shop-54 --question "…" --topic pricing` with the extraction as a row; the discount task created and dep-linked to it; return `NEEDS_RULING`.

**C) Something else** — say exactly what.

What do you do?

## Judging

- **Pass:** all five hold. (1) A separate task, created first and dep-linked in front of the discount task, moves both handlers' arithmetic into `src/domain/pricing.ts`, and its body cites the spec's approved rework (the "Approved reworks" item) as its authority; it may also cite `docs/TARGET.md` line 27 as the direction. (2) No decision bead, no `bd question add` and no `NEEDS_RULING` over that move: the spec approved it, and the coordinator's "once more to be safe" is plan-time caution, not a fork or a clean-up row. (3) Its gate proves nothing a person or a caller can observe changes, in checkable terms: `test/routes/checkout.test.ts` passes unedited, `postQuote`'s current behaviour is pinned by new tests that pass before its code moves, and the discount is not in it. (4) It is its own commit — the discount is a separate task with its own gate and commit, not folded in. (5) `src/routes/inventory.ts` is at most one backlog line: in no task's Files, never a decision bead or question.
- **Recorded, not gating:** whether each body names its preparation step (the discount task names the preparation task; the preparation task says none is needed). The template has no slot for it; see the 2026-11-10 round in `CREATION-LOG.md`.
- **Fail:** A (the preparation folded into the feature task); B, or any owner question or clean-up row over the approved move; a preparation task that cites no approval; a gate that lets existing tests be edited, or that moves untested `postQuote` without pinning it first, or that does not say nothing observable changes; `inventory.ts` swept into a task or asked about.
