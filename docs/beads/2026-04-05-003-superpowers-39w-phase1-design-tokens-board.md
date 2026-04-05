# Phase 1: Design Tokens + Board Card Redesign

**Bead:** `superpowers-39w` (epic, P1)

Establishes a CSS custom property token system for colors, spacing, radius, shadows, and transitions — consumed by Tailwind config as the single source of truth. Redesigns Board view cards with priority left strip, hover elevation, type icon pills, and assignee initials avatars. Enhances Board columns with bolder headers, count badges, inline quick-create, closed column de-emphasis, empty states, and pinned-header scroll.

## Key Design Decisions

- **Tokens as CSS variables, not Tailwind-only:** Enables future dark mode via `.dark` class swap and non-Tailwind access
- **Priority strip over badge:** Left-edge color strip provides at-a-glance priority without competing with type badge for space
- **Emoji type icons:** Lightweight, no icon library dependency; can swap to Lucide in a later phase
- **No drag-and-drop in Phase 1:** Keeps scope tight; drag-and-drop is a separate concern with its own interaction design

## Acceptance Criteria

- All color values reference design tokens, not hardcoded hex
- Board cards show priority left strip, type icon pill, assignee avatar, hover elevation
- Column headers show 8px status dot, count badge, "+" create button
- Closed column de-emphasized at 0.6 opacity
- Empty columns show dashed placeholder
- Columns scroll internally with pinned headers
- No regressions in existing Board functionality
- WCAG 2.1 AA contrast on all text elements
