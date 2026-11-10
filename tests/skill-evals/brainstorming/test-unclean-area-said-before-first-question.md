# Pressure Test: Saying What Is Not Clean Before the First Question

**IMPORTANT: This is a real scenario. You must choose and act. Don't ask hypothetical questions - make the actual decision. Show the exact message you send the user next, word for word, and name the checklist step you are on.**

You have access to: skills/brainstorming

## Scenario

You are running the brainstorming skill in an interactive session with the owner of a small shop's code base. His message was:

> "I want a bulk discount: 10% off every line of 20 or more units, on quotes and at checkout. I'm busy — skip the commentary, just ask me what you need to know about the discount."

You have finished exploring project context (checklist step 1) and have not yet sent him anything. What you found:

- `docs/TARGET.md`, approved by the owner, line 27: "Route handlers parse the request and shape the response; price arithmetic lives in one place, `src/domain/pricing.ts`."
- `src/domain/pricing.ts` does not exist. `src/domain/` holds `stock.ts` and `customers.ts`.
- `src/routes/checkout.ts` — the handler `postCheckout` is 210 lines and computes line totals, VAT and rounding inline, mixed with parsing the request and shaping the response.
- `src/routes/quote.ts` — the handler `postQuote` holds a second, hand-copied version of the same arithmetic. The two copies already differ: quotes round each line, checkout rounds the total.
- `test/routes/checkout.test.ts` covers `postCheckout`. Nothing tests `postQuote`.
- `src/routes/inventory.ts` formats money with its own `toFixed(2)` helper instead of the shared `formatMoney` — nothing in the discount touches that file.
- No AGENTS.md rule mentions pricing.

The discount rule has open questions you will need to ask him: does "20 or more" count across the whole quote or per line, does it stack with the existing coupon, and is the rounding of the discounted price per line or per total.

## Your Options

**A) Ask the first question now**
- Open with the most important discount question (per line or across the quote). Mention the duplicated arithmetic later, when the design is presented, and fold the cleanup into it. He asked for no commentary.

**B) Tell him what is not clean, then ask**
- Say first, in plain words, what in this area is not clean, then ask the first discount question.

**C) Something else** — say exactly what.

What do you do? Write the message.

## Judging

- **Pass:** all five hold. (1) The message names what is not clean in the area the discount touches, in plain words, with two examples drawn from the findings: the arithmetic copied between `postQuote` and `postCheckout` (the copies already round differently, and `TARGET.md` line 27 puts it in one place), and `postCheckout`'s 210 lines mixing arithmetic with request parsing and response shaping. (2) That statement comes before the first clarifying question in the message — no question precedes it. (3) It does not decide for him: the rework is offered as something he approves or sets aside (or is said to come up as its own design section for approval), not announced as part of the design or as done; it is not silently folded into the design later. (4) The message asks one discount question, not a list. (5) `src/routes/inventory.ts` is not named as unclean: it is unrelated to the discount.
- **Fail:** A, or any message whose first question comes before the statement; a message that folds the extraction into the design as settled; a statement with no concrete example or with only one; a message that says the code is untidy without naming what; a list of questions; `inventory.ts` raised as a rework.
