---
name: reshape
description: "Moves code to a new shape without changing what it does: confirms tests cover what moves, then moves it in steps with the gates green after each. Load when a temper command tells you to."
---

# Reshape

The same behaviour in a different shape. The slug is as the `start` skill defines
it.

## What the caller gives you

- The **spec**: `.scratch/<slug>/spec.md`, uncommitted, saying the target shape,
  the seam, which callers move, what's out of scope, and that behaviour stays
  exactly as it is.
- The **baseline**: `.scratch/<slug>/baseline.md`, uncommitted.
- The **scope** — `whole`, for a refactor done in one run, or `ticket`, for one
  step of a larger refactor planned as tickets.

## 1. The pin

Before anything moves, confirm the baseline actually covers it. List every public
function, route, component or command this run moves or deletes, and for each find
a test in the baseline that exercises it. Use the repo's coverage report where it
has one.

Anything without a test ends the run: a green suite over untested code proves
nothing about a refactor of it. Name what's uncovered, recommend pinning its
current behaviour with tests as a change of its own first, and tell the user the
worktree holds the baseline and spec, uncommitted.

Commit `baseline.md` and `spec.md`, following the Commits field of the repo's
`.claude/temper.md`.

Done when everything that moves has a test, and both files are committed.

## 2. The start line

Tell the user: *Start line — nothing is asked from here until the pull request.*

From here on, a question you'd have asked is a decision you make: take the choice
the spec supports best, note it for the pull request, and carry on.

## 3. Move it in steps

With the scope `whole`, in order:

1. Add the new shape beside the old.
2. Move the callers across, a group at a time.
3. Delete the old shape, and anything the move leaves without callers.

With the scope `ticket`, only the moves the spec names, in that same order. A
ticket that deletes the old shape first confirms nothing still calls it; if
something does, the ticket isn't ready, and the run ends saying which callers are
left.

Where a step turns on what a library actually does now — what a call takes, what
it renamed, what it removed — settle it with `temper:docs` before the step. A
move made against a misremembered API changes behaviour, which is the one thing
a reshape may not do.

After each step, run the Gates and commit following the Commits field. A step that
stays red after a second attempt ends the run: revert it, and report which steps
are committed and what failed.

Tests are added only for behaviour the move brings into view that nothing covered
before, or that the spec's acceptance criteria ask for. The proof that behaviour is
unchanged is the baseline.

Done when every move the scope covers is committed green.
