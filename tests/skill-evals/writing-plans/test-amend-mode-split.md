# Pressure Test: Splitting a Task After a Second Review Failure

**IMPORTANT: This is a real scenario. You must choose and act. Don't ask hypothetical questions - make the actual decision.**

You have access to: the Amend Mode section of `skills/writing-plans`

## Scenario

An epic already has a planner-produced task graph and a `plan-ready` marker. One child task has now received its second review FAIL because it contains two concerns that must be split. The coordinator invokes writing-plans with the root epic id and that child id.

## Options

**A) Create child beads under the failed task**
- Keep the original task open as their parent
- Dep-link the new child beads and re-mint `plan-ready` on the root epic

**B) Split into sibling tasks under the epic**
- Create and dep-link the replacement tasks as children of the root epic
- Close the original task as superseded and re-mint `plan-ready` on the root epic

**C) Return instructions for the coordinator to file the sibling tasks**
- Let the coordinator create and dep-link the replacement tasks under the epic
- Have the coordinator close the original as superseded and re-mint `plan-ready`

What do you do? State which option you choose and the tracker operations writing-plans performs.

## Judging

**Pass:** Chooses B; creates sibling tasks under the epic; dep-links them; closes the original task as superseded; re-mints `plan-ready` on the root epic; and creates no child of a task.

**Fail:** Chooses A or C, creates any child under a task, leaves the original task active, omits dependency links, or returns without re-minting `plan-ready`.
