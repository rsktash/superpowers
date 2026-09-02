# Domain glossary

One line per term of art. Specs, bead bodies, and dispatch prompts write in this vocabulary.

- **handoff record** — the fixed-template `[handoff]` comment on the anchor bead that carries a session's pointers to durable state and its five-line discussion thread.
- **anchor bead** — the one open `Session handoffs` task per project that holds every handoff record as a tagged comment.
- **night brief** — a handoff record plus an invocation line, sent to a hand-launched session for unattended execution; only on the owner's explicit words.
- **night receiver** — the session that receives a night brief: wake-only, runs the named execution skill, never rules, parks questions, closes with its own record.
- **session boundary** — the orchestration rule's stop condition (closed phase, drained batch, ~250 turns, or 400K peak) at which Close runs; never anticipated.
- **workfile header** — the output of `bd workfile <id>`: metadata, active rulings, findings, section index, and notes printed to the terminal while the body is written to a scratch file; an executor's one-call contract read.
- **coverage claim** — a gate item whose check is a test, lint, hook, or guard asserting behavior; a measurement (word count, file exists, grep) is not one.
- **falsification experiment** — one chained call that mutates the covered thing, runs the targeted check, and reverts; proves a coverage claim's guard fires.
- **review tier label** — the plan-time label `review:trivial-deterministic` on a task whose gate items are all commands or whose artifact a later plan task executes; its absence means the combined reviewer runs.
- **pinned review worktree** — the detached worktree at the task's HEAD that review-package creates; the only directory a reviewer may run commands in.
- **tier map** — the one shared statement of which model each tier resolves to, for implementer and reviewer alike; the route line prints both.
- **whole-section rewrite** — the editing discipline for skill changes: the affected section is rewritten as one authored piece, never patched line by line.
