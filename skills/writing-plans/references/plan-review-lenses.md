# Plan review lenses — conditional

Apply these ONLY to tasks that change schema, persisted data, rollout order,
cross-layer contracts, or a public type's shape.

## Deploy Sequence and Rollout Safety

Tasks that change schema, persisted data, feature activation, or route behavior must state their rollout constraints.

For each task that introduces such changes, require:
- **Precondition** — what must already be live before this task's code runs (completed migration, finished backfill, dependency deployed, parent flag enabled)
- **Activation gate** — what triggers the new behavior (flag flip, route cutover, schema switch) and whether the old path is removed in the same task or left for a follow-up
- **Intermediate-state safety** — what protects users and data while rollout is partial; if both old and new paths must coexist, state the invariant that keeps them consistent
- **Rollback condition** — what signal triggers a revert and what reverting costs (data loss, re-run needed, none)

## Cross-Layer Consistency

When two or more architectural layers must agree on a computed value, token set, or contract, define one source of truth that every layer consumes. If an unavoidable duplication exists, state how drift will be detected.

For each concept that spans layers, the plan must:
- Identify every layer that derives or consumes the concept
- Point to the single shared definition, or to the shared helper every layer calls
- If duplication is unavoidable, specify the drift-detection signal — round-trip test, shared type, runtime assertion

## Semantic Regression Sweep for Representation Changes

When a task changes a public type, representation, or shape (primitive to wrapper, optional to required, scalar to collection, nullable to non-null, etc.), list the operations whose semantics change with the new shape and verify each:

- **Truthiness** — what counts as "empty" under the new shape?
- **Equality** — reference vs. structural comparison; hash/set membership
- **Serialization** — JSON, URL, log output, `toString`
- **Defaulting** — placeholder rendering (`|| fallback`, `?? default`), conditional branches keyed on the old shape
- **Formatting** — length-based truncation, locale-aware rendering, rounding

Enumerate the call sites the sweep must visit.

