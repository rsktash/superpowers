# Hybrid execution — per-task inline/subagent routing

**Bead:** superpowers-mn3 (source of truth — this file is an immutable snapshot)

## Summary

Add a third, opt-in execution mode at the writing-plans Execution Handoff: **Hybrid**. writing-plans annotates each task bead with an `**Execution:**` directive (`inline` | `subagent/cheap` | `subagent/standard` | `subagent/capable`, with a one-line reason); a new thin routing skill `skills/hybrid-execution/SKILL.md` reads the annotation per task and delegates to executing-plans' per-task procedure (inline) or subagent-driven-development's loop (subagent), with executor override allowed only with a stated reason. Motivated by two observed pains: the per-plan handoff choice is too coarse for plans that mix trivial and complex tasks, and inline execution exhausts session context on large plans.

## Key design decisions

- Hybrid is opt-in (third handoff option); Inline and Subagent-Driven remain unchanged
- Subagent dispatch is the default in hybrid; inline is the exception for tasks where dispatch overhead exceeds the work
- Mode decided at plan time (visible/reviewable in the bead), executor may override with stated reason; overriding toward subagent always safe, toward inline requires justification
- New thin router skill — zero edits to executing-plans and subagent-driven-development, zero duplication of tuned review/termination content
- Model tiers stay abstract (cheap/standard/capable); Claude mapping (Haiku/Sonnet/session model) appears only as an example note

## Acceptance criteria

- New skill `skills/hybrid-execution/SKILL.md` with conventional frontmatter
- writing-plans: Execution line in Task Structure + rubric, three-option handoff, self-review check for the annotation
- Zero edits to executing-plans / subagent-driven-development SKILL.md
- No concrete model names in behavioral rules
- Pressure-test evidence per writing-skills before release
