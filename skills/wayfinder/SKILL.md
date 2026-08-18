---
name: wayfinder
description: Use when a loose idea is too big for one session and wrapped in fog — the route to a spec, decision, or migration is not visible yet, and open decisions outnumber plannable tasks
---

# Wayfinder — budget 1100 words

(Adapted for bd from mattpocock/skills `wayfinder`, MIT, © Matt Pocock.)

A loose idea has arrived — bigger than one session, and the way to the **destination** isn't visible. Wayfinding charts the way as a shared map on bd, then works its **decision tickets** — questions whose resolution is a decision, not slices of a build — one at a time until the route is clear.

Naming the destination is the first act of charting; it fixes the scope and shapes every ticket. It might be a spec to hand to brainstorming/writing-plans, a decision to lock, or a change made in place.

**Plan, don't do.** Each ticket resolves a decision; the map is done when nothing is left to decide before someone goes and builds. The pull to just do the work is the signal you've reached the map's edge — hand off to the normal spec → plan → execution cycle. A single unresolved fork inside an otherwise-clear plan needs only writing-plans' decision bead, not a map; wayfinder is for fog that spans sessions.

**Refer by name.** In everything the human reads, call the map and its tickets by their titles — the bead id rides beside the name, never stands in for it. A wall of bare ids is illegible.

**bd conventions:** Read `skills/shared/bd-defaults.md` before using any bd commands.

## The Map

One epic bead, labeled `wayfinder:map`:

```bash
bd create "<effort name>" -t epic -p 1 -l wayfinder:map --body-file .bd/.scratch/map.md --json
```

Tickets are its child beads. Blocking uses bd's native deps (`bd dep add <blocked> <blocker>`); the **frontier** — open, unblocked tickets — is `bd ready --parent <map-id>`.

The map body is an **index, not a store** — the whole effort at low resolution, loaded once per session. A decision lives in exactly one place (its ticket's resolution comment); the map gists and links:

```markdown
## Destination
<what reaching the end looks like — one or two lines; every session orients to this first>

## Notes
<domain; skills every session should consult; standing preferences for this effort>

## Decisions so far
- <closed ticket title> (#<id>) — <one-line gist of the answer>

## Not yet specified
<fog: in-scope questions not yet sharp enough to ticket>

## Out of scope
- <gist> — <why ruled past the destination>
```

## Tickets

A child bead whose body is one question, sized to one fresh session:

```markdown
## Question
<the decision or investigation this ticket resolves>
```

Label each `wayfinder:<type>`. Claim before any work — `bd update <id> --status=in_progress --assignee "$(git config user.name) / <model>"` — so concurrent sessions skip it; an open, unclaimed ticket is takeable.

Every type is either **HITL** — worked with the human, who speaks for themselves (never answer their side of the exchange) — or **AFK**, agent-alone:

- **research** (AFK): surface a fact a decision waits on — docs, third-party APIs, knowledge outside the working directory. Resolved by a subagent.
- **prototype** (HITL): raise the discussion's fidelity with a cheap concrete artifact to react to — an outline, a stub, a mockup via brainstorming's visual companion. Link the artifact from the ticket.
- **discussion** (HITL): conversation — the default. One question at a time, per brainstorming's question discipline.
- **task** (HITL or AFK): manual work a decision is blocked on — provisioning access, moving data so its shape can be seen. The one type that does rather than decides; it earns its place by unblocking a decision. Its answer records what was done and the facts later tickets depend on.

## Fog of war

Chart only what you can see. Beyond the live tickets lies the fog — decisions you can tell are coming but can't pin down. **Fog or ticket?** — can you state the question precisely now (not: answer it now)? Sharp → ticket, even if blocked. Dim → one loose line in Not yet specified; don't pre-slice fog into ticket-sized pieces — one patch may graduate into several tickets, or none.

Fog gathers only toward the destination. Work consciously ruled past it goes to **Out of scope** and never graduates. A live ticket exposed as out of scope is closed and gisted there — it stays out of Decisions so far, which records only the route actually walked.

## Charting (first session)

1. **Name the destination** with the human — question until it fits one or two lines.
2. **Map the frontier, breadth-first**: fan across the whole space, surfacing the open decisions and the first takeable steps. If no fog surfaces — the journey fits one session — stop and offer brainstorming instead; no map needed.
3. **Create the map** epic (body template above, Decisions-so-far empty, fog sketched into Not yet specified).
4. **Create the specifiable tickets** as children — sequentially (parallel creates collide) — then wire blocking edges in a second pass (`bd dep add` needs both ids).
5. **Fire research subagents** for the research tickets, in parallel; findings land as resolution comments.
6. Stop — charting is one session's work; it hand-resolves nothing.

## Working the map (every later session)

Resolve **one ticket per session** (research tickets excepted — they batch).

1. Load the map — `bd show <map-id>` plus body — the low-res view; zoom into related closed tickets on demand, never all of them.
2. Choose: the ticket the human named, else the first frontier ticket from `bd ready --parent <map-id>`. Claim it first.
3. Resolve it per its type, consulting the skills the map's Notes name.
4. **Graduate before closing:** create any newly-specifiable tickets and wire their edges FIRST; then record the answer (`bd comment add <id> "<resolution>"`), close the ticket, and update the map body (append the gist to Decisions so far, clear graduated fog from Not yet specified). **Why first:** `bd close` auto-closes a parent when its last open child closes — closing the map's last ticket while fog remains silently closes the epic and buries the effort.
5. A resolution that invalidates other tickets updates or closes them; one that exposes a ticket past the destination rules it out of scope.

The map is done when frontier and fog are both empty — the way is clear. Hand the destination onward: its Decisions-so-far index is the raw material for brainstorming's spec or writing-plans' tasks.
