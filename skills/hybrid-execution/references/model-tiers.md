# Model Tiers — full reasoning

The map and the floor rule live in SKILL.md; this file holds the rationale,
for when a tier call is contested or genuinely unclear.

A tier names the **judgment a task demands, not model cost.** `cheap` and `standard` both resolve to exactly Sonnet — Sonnet is the floor, there is no cheaper tier; "cheap" never licenses anything below Sonnet however small the task or cost-conscious your partner. State any tier change, in either direction, as a visible override.

**The `standard` floor now sits just under the session tier.** The current Sonnet (Sonnet 5 today) is close to the session model, not well beneath it as earlier Sonnets were. So `capable` → the session model is reserved for tasks demanding genuine design judgment or broad codebase synthesis — it is **not** the safe default for "anything non-trivial." Multi-file integration, mechanical mirrors, and adoption of a landed/reviewed template all belong on `standard` → Sonnet; the narrowed gap means down-routing an inflated `capable` costs almost nothing in quality while saving the session model for where its edge actually shows. When you're genuinely unsure between `standard` and `capable`, pick `standard` — a fresh reviewed Sonnet subagent makes that the low-risk side. (The map stays version-agnostic: `standard` resolves to whatever the current Sonnet is; "Sonnet 5" is just today's concrete anchor.)
