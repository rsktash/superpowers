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
- **exploration map** — the per-epic file `docs/beads/<epic-id>.map.md` of symbol entries the planner writes once at plan time; derived data that lives with the code, never maintained through bead writes.
- **map entry** — one row of the exploration map: task, symbol, file, hash of the symbol's own source text, the planner's note, source (planner | index); keyed by symbol, never by line range.
- **map-check** — the dispatch-time script that compares plan-time hashes with HEAD and prints fresh / STALE / CHECK / GONE / NEW / seam lines into the dispatch header; the only freshness mechanism.
- **structural index** — the deterministic per-repo symbol table (`symbol`, `callers`, `tests`) regenerated per commit; answers first-encounter structural questions without a model.
- **discovery batch** — the single turn in which an executor reads every map entry span and runs every index query its task names, before any edit.
- **verification batch** — the single turn in which all Acceptance Gate commands run and report together.
- **amend mode** — writing-plans invoked with an epic id plus child ids: plans those children in place, splits only into siblings under the epic, re-mints `plan-ready`.
- **planner-only decomposition** — the rule that only writing-plans creates task beads, and only flat: a task never has children.
- **language roster** — the per-repository list of language id, tracked file count, and backend status (`compiler` | `none`) that `structural-index languages` prints and the exploration map file's header carries.
- **text answer** — a `callers` or `tests` result produced by word-boundary text search over languages with no definition backend, marked by one stderr line; never a definition.
- **execution plan** — the one bd plan per project, id fixed to the tracker prefix, that orders beads into lanes; never a second active plan.
- **lane** — one epic's ordered queue inside the execution plan, with one cursor and at most one holding session; created and claimed by the coordinator at execution start.
- **lane step** — the shared procedure (`skills/shared/plan-lane.md`) the three execution skills cite after the epic gate: ensure plan, add lane, claim with the session id.
- **handoff entry** — the typed `bd plan handoff` row on a lane: done ids with commits, next id, parked ids each with a question id, five-line thread; replaces the handoff record and the anchor bead.
- **lane-less session** — a session that holds no lane; at Close it types its rulings and questions and posts no record.
- **session id export** — the SessionStart hook's `export BD_SESSION_ID=<session_id>` line in `$CLAUDE_ENV_FILE`; every lane verb and `bd session close` read it.
- **planner actor** — `BD_ACTOR=planner`, exported by the forked planner for its whole run; bylines its questions and makes bd refuse its rulings.
- **topic pick** — filing a question or finding without `--topic` first, reading the printed catalogue, and choosing an existing slug; executors never mint.
- **pending topic** — a statement filed with no fitting slug, resolved by the coordinator at Close; `--topic pending-<task-id>` until bd stores the state itself.
- **mining brief** — the tracker-mining skill's only output: header line, `bd authority`-format lines, a capped "Proposed actions" block of bd commands.
- **feature lineage** — the chain of epics that introduced, upgraded, and edited one feature: a related link from each new epic to its predecessor plus a shared `feature:<slug>` label, filed by brainstorming at spec creation; read with `bd authority <epic-id> --depth 3`; never a topic.
