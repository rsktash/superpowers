# superpowers-1ud — Handoff skill: session close, resume, night-session preparation

Half of solo and zanjir sessions open by reading the previous session's raw transcript, and those are the sessions that peak at 500K–800K tokens. The orchestration rule already demands "pointers to durable state, never a retelling" at the session boundary, but nothing produces those pointers or tells a fresh session where to find them. This spec adds one `handoff` skill with three procedures: Close writes a fixed-template record to a per-project anchor bead and delivers it as the final message or by SendMessage; Resume reads that record with one command and verifies only the beads it names; Night, on the owner's explicit words only, sends one brief per open session, one session per epic, and the receiving session runs the named execution skill unattended and closes with its own record.

## Key design decisions

- One anchor bead per project (`Session handoffs`) holds every record as a `[handoff]`-tagged comment; the epic gets no copy.
- Fixed template, 20-line hard cap, Thread section capped at 5 lines; every id must exist in bd.
- No transcript access, ever. A missing record means a durable-state report and the thread is lost.
- Nothing anticipatory: the skill fires only on the owner's words or when the boundary is actually reached.
- Night sessions are named explicitly by the owner and hand-launched; no scheduling. The receiver never adds rulings, parks questioned tasks, never pushes.
- One skill, three procedures, ~600-word budget. Execution skills, hooks, and using-superpowers are untouched.

## Acceptance criteria

- "resume" in a fresh session reaches a five-line status with one comment read and at most two verification reads, no transcript access.
- "hand off to the night sessions" with two sessions in two repositories delivers one brief each and reports the pairing.
- Five pressure tests under `tests/skill-evals/handoff/` pass; skill stays within budget; changelog states the word delta.
