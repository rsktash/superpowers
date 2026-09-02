# Model Tiers — the shared doctrine

The one home for the tier doctrine. subagent-driven-development (Model
Selection) and hybrid-execution (Model Tiers) carry the map line and point
here; every rule below is stated once, in this file, for both skills alike.

## The map

Tiers are abstract — a concrete model is resolved from the tier at route time.
Your human partner's standing model policy (project memory, CLAUDE.md) always
overrides the default map: check it before resolving any tier. Absent a
policy, on Claude harnesses: `cheap` → Sonnet, `standard` → Sonnet, `capable`
→ the session's model. Model names are point-in-time and the map stays
version-agnostic — `standard` resolves to whatever the current Sonnet is;
"Sonnet 5" is only today's concrete anchor.

## What a tier measures — and the floor

A tier names the **judgment a task demands, not model cost.** Sonnet is the
floor: there is no cheaper tier, and `cheap` never licenses anything beneath
it, however small the task or cost-conscious your partner. State any tier
change, in either direction, as a visible override.

## Reserving `capable`

**The `standard` floor now sits just under the session tier.** The current
Sonnet (Sonnet 5 today) is close to the session model, not well beneath it as
earlier Sonnets were. So `capable` is reserved for tasks demanding genuine
design judgment or broad codebase synthesis — it is **not** the safe default
for "anything non-trivial." Multi-file integration, mechanical mirrors, and
adoption of a landed/reviewed template all belong on `standard`; the narrowed
gap means down-routing an inflated `capable` costs almost nothing in quality
while saving the session model for where its edge actually shows. When you are
genuinely unsure between `standard` and `capable`, pick `standard` — a fresh
reviewed Sonnet subagent makes that the low-risk side.

## The pinned contract

Down-routing presumes a pinned contract: a task whose steps leave a mechanism
or design fork to the executor is `capable` regardless of file count, however
mechanical the reason reads. Economize on the contract or on the executor —
never both in one task.

## The reviewer's model

A task's reviewer runs on the model the task's own tier resolves to through
the map above: a `standard` task gets a Sonnet reviewer, a `capable` task gets
the capable model. This is not the coordinator's free choice, and it does not
follow how hard the reviewer's job looks — the tier already measured the
judgment the work demands, and a reviewer weaker than the implementer cannot
check it. State the reviewer's model beside the implementer's in the
route line that announces the task (hybrid-execution, The Loop), or with the
tier line when a run states one (subagent-driven-development, Review Tier).
A task whose declared review tier dispatches no reviewer states `none` on that
route line, naming the tier and the task that executes the artifact.
