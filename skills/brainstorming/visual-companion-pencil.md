# Visual Companion Guide — Pencil

Design mockups, wireframes, and visual options using the Pencil MCP tools (.pen files).

## When to Use

Decide per-question, not per-session. The test: **would the user understand this better by seeing it than reading it?**

**Use Pencil** when the content itself is visual:

- **UI mockups** — wireframes, layouts, navigation structures, component designs
- **Architecture diagrams** — system components, data flow, relationship maps
- **Side-by-side visual comparisons** — comparing two layouts, two color schemes, two design directions
- **Design polish** — when the question is about look and feel, spacing, visual hierarchy

**Use the terminal** when the content is text or tabular:

- **Requirements and scope questions** — "what does X mean?", "which features are in scope?"
- **Conceptual A/B/C choices** — picking between approaches described in words
- **Tradeoff lists** — pros/cons, comparison tables
- **Technical decisions** — API design, data modeling, architectural approach selection
- **Clarifying questions** — anything where the answer is words, not a visual preference

A question *about* a UI topic is not automatically a visual question. "What kind of wizard do you want?" is conceptual — use the terminal. "Which of these wizard layouts feels right?" is visual — use Pencil.

## Getting Started

1. Load the Pencil schema and check editor state:
   - `get_editor_state({ include_schema: true })`
2. Open or create a .pen file for the brainstorming session:
   - `open_document("new")` for a fresh canvas
   - Or open an existing file if the project has one
3. Load relevant guidelines:
   - `get_guidelines()` to see available guides and styles
   - Load a style guide if the project has a visual direction

## The Loop

1. **Create the visual** — use `batch_design` to build mockups, wireframes, or diagrams on the canvas. Keep each call to 25 operations max; split larger designs across multiple calls.

2. **Verify the result** — use `get_screenshot` to capture the created design. Always review the screenshot for visual errors, misalignment, or glitches before showing the user.

3. **Export for the user** — use `export_nodes` to export the design as PNG so the user can see it. Tell the user where the exported file is.

4. **Tell the user what to look at and end your turn:**
   - Give a brief text summary of what's on the canvas (e.g., "Created 3 layout options for the dashboard")
   - Ask them to respond in the terminal with their preference

5. **Iterate or advance** — if feedback changes the current design, update it with `batch_design`. Only move to the next question when the current step is validated.

6. Repeat until done.

## Working With Components

When the .pen file has a design system with reusable components:

1. **Discover components** — use `batch_get` with `{ reusable: true }` to list available components
2. **Use components** — insert instances with `I(parent, { type: "ref", ref: "ComponentName" })`
3. **Customize instances** — use `U()` to update properties on instance descendants

## Presenting Options

When showing A/B/C choices:

- Create each option as a separate frame on the canvas
- Use `find_empty_space_on_canvas` to position them side by side
- Label each option clearly (A, B, C)
- Export all options and present them together

## Design Tips

- **Scale fidelity to the question** — wireframes for layout, polish for polish questions
- **Label the question on each mockup** — "Which layout feels more professional?" not just unlabeled screens
- **Iterate before advancing** — if feedback changes current design, update it before moving on
- **2-4 options max** per question
- **Keep mockups simple** — focus on layout and structure, not pixel-perfect design

## File Management

- Use a single .pen file per brainstorming session
- Organize designs into separate frames per question/topic
- Use `find_empty_space_on_canvas` to avoid overlapping content
- Export final approved designs for reference during implementation
