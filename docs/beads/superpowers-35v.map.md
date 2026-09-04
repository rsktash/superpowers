# superpowers-35v exploration map

Two-task sample written by Task 8: Task 5's landed fixture symbols and Task 6's planned Go fixture — a parse check under the map-check contract, not this epic's full map.

| Task | Symbol | File | Hash | Note | Source |
|------|--------|------|------|------|--------|
| 5 | suggestCadence | tests/fixtures/structural-index/ts/src/task-sweep.ts | ad445d667ec8 | task-sweep core; seven test-file callers | index |
| 5 | startTaskSweep | tests/fixtures/structural-index/ts/src/task-sweep.ts | 5cacac3406b4 | companion export; one test-file reference | index |
| 5 | triple | tests/fixtures/structural-index/ts/src/triple.ts | d2073dcb235e | called from three fixture files | index |
| 5 | unused | tests/fixtures/structural-index/ts/src/unused.ts | 6594898741b7 | zero callers by design; the suite's mutation check edits inside its span | index |
| 5 | testOnly | tests/fixtures/structural-index/ts/src/test-only.ts | 9ec90cd937f1 | referenced only from a test file | index |
| 5 | UndoHistory | tests/fixtures/structural-index/ts/src/history.ts | 159b2f2a3ccd | the class fixture | index |
| 5 | UndoHistory.undo | tests/fixtures/structural-index/ts/src/history.ts | 8b6b06e3256a | the class-method fixture | index |
| 5 | PERMISSION_SECTIONS | tests/fixtures/structural-index/ts/src/permissions.ts | e5806a73d8df | exported const; referenced from the spec file | index |
| 5 | priceLine | tests/fixtures/structural-index/ts/shared/pricing.ts | dddcb9e6635a | shared helper; called across the package boundary from web-app | index |
| 5 | StatusTimeline | tests/fixtures/structural-index/ts/src/StatusTimeline.tsx | ee9fb25e859b | the React component fixture | index |
| 5 | screen | tests/fixtures/structural-index/ts/src/status-caller.tsx | 5651fece767a | exported const rendering StatusTimeline | index |
| 5 | total | tests/fixtures/structural-index/ts/web-app/src/Retailer.ts | 6462e1b13817 | web-app const calling priceLine | index |
| 5 | cadenceOne | tests/fixtures/structural-index/ts/tests/task-sweep.test.ts | b3aaa2d50172 | test-file definition, no callers | index |
| 5 | cadenceTwo | tests/fixtures/structural-index/ts/tests/task-sweep.test.ts | 9dd9710d39eb | test-file definition, no callers | index |
| 5 | cadenceThree | tests/fixtures/structural-index/ts/tests/task-sweep.test.ts | dc7e3a843bb8 | test-file definition, no callers | index |
| 5 | cadenceFour | tests/fixtures/structural-index/ts/tests/task-sweep.test.ts | 6f3834e5d66f | test-file definition, no callers | index |
| 5 | cadenceFive | tests/fixtures/structural-index/ts/tests/task-sweep.test.ts | 7979b698ac21 | test-file definition, no callers | index |
| 5 | cadenceSix | tests/fixtures/structural-index/ts/tests/task-sweep.test.ts | 9f4bdd5b91a6 | test-file definition, no callers | index |
| 5 | cadenceSeven | tests/fixtures/structural-index/ts/tests/task-sweep.test.ts | e958213d84fb | test-file definition, no callers | index |
| 5 | sweepCase | tests/fixtures/structural-index/ts/tests/task-sweep.test.ts | 1e4790c07a6d | test-file definition, no callers | index |
| 5 | firstPermission | tests/fixtures/structural-index/ts/tests/permissions.spec.ts | b1f12aecb970 | spec-file const, no callers | index |
| 5→6 | seam: CLI output contract | — | — | Task 6's Go backend answers through the same CLI and must not change the output format scripts/structural-index prints | planner |
| 6 | FormatBeadLine | tests/fixtures/structural-index/go/render.go | new | function called from three Go fixture files | planner |
| 6 | UnusedGuard | tests/fixtures/structural-index/go/guard.go | new | function with zero callers | planner |
| 6 | BeadCard.Status | tests/fixtures/structural-index/go/bead.go | new | the method fixture | planner |
| 6 | BeadStatus | tests/fixtures/structural-index/go/bead.go | new | the type fixture | planner |
| 6 | ValidateStatus | tests/fixtures/structural-index/go/status.go | new | referenced only from a _test.go file | planner |
