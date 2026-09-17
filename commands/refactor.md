---
description: "Reshape existing code without changing what it does: baseline first, a grill about the seam, a small move with the tests green throughout, then a pull request."
argument-hint: "<what should change shape>"
---

# temper refactor

The same behaviour in a different shape: $ARGUMENTS

Narrow refactors only — one seam, with callers you can count. Each step names the
skill that does the work where there is one; what's written here is only what
temper adds. With no ask given, ask what should change shape first.

## 1. Start

Load `temper:start` with the kind `refactor`.

Done when the session is in `.claude/worktrees/<slug>` on the branch
`refactor/<slug>`.

## 2. The baseline

A refactor is proved by tests that passed before and still pass after, so the
before comes first.

Run every command in the Gates field of the repo's `## temper` section, with
caching turned off wherever the command supports it — a replayed cache hit shows
the inputs didn't change, not that the tests ran. Write each command exactly as
run, with its full output, to `.scratch/<slug>/baseline.md`.

A red gate ends the run: report the failing command and its output, and that the
worktree holds only the baseline.

Done when every gate is green and `baseline.md` holds each command with its output.

## 3. The grill

Load `mattpocock-skills:grilling`, with `mattpocock-skills:codebase-design` as the
reference for its vocabulary — module, interface, seam, depth. Settle:

- the **target shape** — the modules and interfaces as they should be
- the **seam** the change happens at
- which **callers** move, and in what order
- what's **out** of scope

Behaviour stays exactly as it is; that's the requirement the whole run is judged
against.

The grill can end the run:

- **Too wide** — a mechanical change fanning out across the codebase, where no
  single step can land with the tests green. Stop, and say it needs sequencing by
  hand across more than one pull request.
- **Not a refactor** — the cleanup turns up a bug or a missing feature. Stop, and
  recommend `/temper:bug` or `/temper:feature` first, so the refactor lands
  against behaviour that's settled.

Each time, tell the user the worktree holds only the baseline, and that you'll
remove it if they ask.

Write the four answers, with the requirement that behaviour is unchanged, to
`.scratch/<slug>/spec.md`.

Done when the user confirms the answers and `spec.md` is written.

## 4. The pin

Before anything moves, confirm the baseline actually covers it. List every public
function, route, component or command the refactor moves, and for each find a test
in the baseline that exercises it. Use the repo's coverage report where it has
one.

Anything without a test ends the run: a green suite over untested code proves
nothing about a refactor of it. Name what's uncovered, recommend pinning its
current behaviour with tests as a change of its own first, and tell the user the
worktree holds the baseline and spec, uncommitted.

Commit `baseline.md` and `spec.md`, following the Commits field.

Done when everything that moves has a test, and both files are committed.

## 5. The start line

Tell the user: *Start line — nothing is asked from here until the pull request.*

From here on, a question you'd have asked is a decision you make: take the choice
the spec supports best, note it for the pull request, and carry on.

## 6. Move it in steps

In order:

1. Add the new shape beside the old.
2. Move the callers across, a group at a time.
3. Delete the old shape, and anything the move leaves without callers.

After each step, run the Gates and commit following the Commits field. A step that
stays red after a second attempt ends the run: revert it, and report which steps
are committed and what failed.

Tests are added only for behaviour the move brings into view that nothing covered
before. The proof that behaviour is unchanged is the baseline.

Done when the old shape is gone and every step is committed green.

## 7. Check

Load `temper:check` with:

- mode `build`
- the default fixed point
- intent `.scratch/<slug>/spec.md`
- quality seat yes
- baseline `.scratch/<slug>/baseline.md`

Done when `check` has written its verdict.

## 8. Finish

Load `temper:finish` with the kind `refactor`, the verdict, the baseline result,
and every decision you noted after the start line.

Done when `finish` has reported a pull request, or why there isn't one.
