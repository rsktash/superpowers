# Domain glossary

One line per term of art. Specs, bead bodies, and dispatch prompts write in this vocabulary.

- **handoff record** — the fixed-template `[handoff]` comment on the anchor bead that carries a session's pointers to durable state and its five-line discussion thread.
- **anchor bead** — the one open `Session handoffs` task per project that holds every handoff record as a tagged comment.
- **night brief** — a handoff record plus an invocation line, sent to a hand-launched session for unattended execution; only on the owner's explicit words.
- **night receiver** — the session that receives a night brief: wake-only, runs the named execution skill, never rules, parks questions, closes with its own record.
- **session boundary** — the orchestration rule's stop condition (closed phase, drained batch, ~250 turns, or 400K peak) at which Close runs; never anticipated.
