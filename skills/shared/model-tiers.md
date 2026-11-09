# Model Tiers — the shared doctrine

The one home for the tier doctrine. subagent-driven-development (Model
Selection) and hybrid-execution (Model Tiers) carry the map line and point
here; every rule below is stated once, in this file, for both skills alike.

## The map

Tiers are abstract — a concrete model is resolved from the tier at route time.
Your human partner's standing model policy (project memory, CLAUDE.md) always
overrides the default map: check it before resolving any tier. Absent a
policy, on Claude harnesses: `cheap` → Sonnet, `standard` → Sonnet, `capable`
→ the session's model.

## What a tier measures — and the floor

A tier names the **judgment a task demands, not model cost.** Sonnet is the
floor: there is no cheaper tier, and `cheap` never licenses anything beneath
it, however small the task or cost-conscious your partner. State any tier
change, in either direction, as a visible override.

## Reserving `capable`

`capable` is reserved for tasks demanding genuine design judgment or broad codebase synthesis — never the default for "anything non-trivial". Multi-file integration, mechanical mirrors and adoption of a landed/reviewed template are `standard`. Unsure between the two → `standard`.

## The pinned contract

Down-routing presumes a pinned contract: a task whose steps leave a mechanism
or design fork to the executor is `capable` regardless of file count, however
mechanical the reason reads. Economize on the contract or on the executor —
never both in one task.

## The reviewer's model

A task's reviewer runs on the model the task's own tier resolves to through
the map above: a `standard` task gets a Sonnet reviewer, a `capable` task gets
the capable model. It never follows how hard the review looks. State the reviewer's model beside the implementer's in the
route line that announces the task (hybrid-execution, The Loop), or with the
tier line when a run states one (subagent-driven-development, Review Tier).
A task whose declared review tier dispatches no reviewer states `none` on that
route line, naming the tier and the task that executes the artifact.
