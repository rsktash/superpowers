# superpowers-5f7 exploration map

Language roster at the planning commit `6717fa6`, measured with `git ls-files` (the `languages` query Task 1 builds does not exist yet): typescript 40 files compiler, go 8 files compiler, python 1 file none, other 259 files none — 308 tracked files.

Almost every file this plan touches lies outside the indexed languages: `scripts/structural-index` and `scripts/map-check` are extensionless Node scripts, and the rest are Markdown and shell. The index resolves no symbol in any of them, so under R-B those files earn no map row and their task bodies' Files lists and citations are their only record. The one indexable symbol is the shared name Task 1 adds to the mixed fixture's TypeScript module; the Kotlin, Swift and Python fixture symbols Tasks 9, 10 and 11 create stay unmappable until their own backends land.

| Task | Symbol | File | Hash | Note | Source |
|------|--------|------|------|------|--------|
| 1 | renderBadge | tests/fixtures/structural-index/mixed/src/badge.ts | new | the shared name: defined once in TypeScript, referenced from a Kotlin, a Swift and a Python fixture file; Task 2's precedence assertion reads it | planner |
| 1→2 | seam: language roster and classification | — | — | Task 1 defines the extension-to-language table, the roster line shape and the uncovered-id list; Task 2 consults them for precedence and for both stderr lines, and defines no language list of its own | planner |
| 1→3 | seam: the languages query output | — | — | map-check reads the roster through the languages query, one tab-separated id, tracked count and backend per language present; Task 3 adds no roster of its own | planner |
| 3→4 | seam: the unindexed header line | — | — | the header text Task 3 prints is the text Task 4 mirrors, character for character, into the four line-shape lists and the runbook bullet | planner |
| 4→5 | seam: the seven-token line-shape list | — | — | Task 4 lands the list and its parity assertion; Task 5's planner, implementer and reviewer sentences name the unindexed shape that list now carries | planner |
| 1→9 | seam: backend registration surface | — | — | a backend registers in the language order and names and returns its data plus elapsed seconds; the roster then reports its language as compiler with no further edit | planner |
| 2→9 | seam: tier 1 precedence | — | — | once a compiler backend defines a language, callers and tests answer from compiler data and the text search stops covering it; the tier 1 assertions that used that language move in the backend's own commit | planner |
| 6→9 | seam: the ruling names the parser | — | — | Task 6's scored table becomes the owner's ruling on superpowers-5f7.12, and Task 9 implements the parser that ruling names and no other | planner |
| 7→10 | seam: the ruling names the parser | — | — | Task 7's scored table becomes the owner's ruling on superpowers-5f7.13, and Task 10 implements the parser that ruling names and no other | planner |
| 8→11 | seam: the ruling names the parser | — | — | Task 8's scored table becomes the owner's ruling on superpowers-5f7.14, and Task 11 implements the parser that ruling names and no other | planner |
| 9→10 | seam: serialised generator registration | — | — | all three backends register in the same dispatch inside one script, so Task 10 extends the registration Task 9 landed rather than adding a parallel one | planner |
| 10→11 | seam: serialised generator registration | — | — | Task 11 extends the registration Task 10 landed; after it, other is the only uncovered class and tier 1's text answers exist for it alone | planner |
