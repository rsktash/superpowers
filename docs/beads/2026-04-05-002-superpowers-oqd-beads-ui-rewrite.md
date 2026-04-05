# beads-ui Frontend Rewrite (React + Tailwind)

**Bead:** `superpowers-oqd`

Full frontend rewrite of beads-ui from lit-html to React + Tailwind CSS, keeping the existing Express + WebSocket backend. Fixes 4 known bugs (empty epics page, broken code blocks, status filter logic, no markdown preview) while adding virtual scrolling, keyboard navigation, Cmd+K search, and a clean visual design. Three views: Board (Kanban dashboard, default), List (filterable/searchable/groupable table), and Detail (markdown reader with per-section editing via pencil icons and Edit/Preview toggle).

**Key decisions:**
- Vite for bundling, TypeScript for client code
- Shiki for syntax-highlighted code blocks
- Board as default/home view (dashboard)
- Detail view: preview mode default, per-section edit buttons (not whole-page edit mode)
- Server changes minimal — only fix list-adapters.js epics query

**Acceptance criteria:**
1. Board renders Kanban with real-time WebSocket updates
2. List supports filter/search/grouping with virtual scrolling
3. Detail renders markdown with syntax-highlighted code blocks
4. Section editing with Edit/Preview toggle on all markdown fields
5. All 4 original bugs resolved
6. Performance: 500+ issues without lag
