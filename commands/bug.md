---
description: "Fix a bug: a short grill, then Superpowers finds the root cause and fixes it test-first, then temper checks it and opens a pull request."
argument-hint: "<the symptom>"
---

# temper bug

Behaviour that exists and is wrong: $ARGUMENTS

Each step names the skill that does the work. Load it and follow it; what's
written here is only what temper adds. With no symptom given, ask for one first.

## 1. Start

Load `temper:start` with the kind `fix`.

Done when the session is in `.claude/worktrees/<slug>` on the branch `fix/<slug>`.

## 2. The grill

Load `mattpocock-skills:grilling`. A bug needs four answers:

- the **symptom** — what happens
- the **expected** behaviour — what should happen instead
- how to **reach** it
- what's **out** of scope

A cause the user suspects is a hypothesis for step 4 to test. Record it as one.

Where an answer turns on what a library actually does, settle it with
`temper:docs` before the next round, not from memory.

The grill can end the run. When the behaviour is working as designed, say so and
stop. When putting it right means new behaviour rather than a correction, stop and
recommend `/temper:feature`. Either way, tell the user the worktree is still empty
and that you'll remove it if they ask.

Write the four answers, and any hypothesis, to `.scratch/<slug>/spec.md`, and
commit it following the Commits field of the repo's `.claude/temper.md`.

Done when the user has confirmed the four answers and `spec.md` is committed.

## 3. The start line

Tell the user: *Start line — nothing is asked from here until the pull request.*

From here on, a question you'd have asked is a decision you make: take the choice
the spec supports best, note it for the pull request, and carry on.

## 4. Root cause, then the fix

Load `superpowers:systematic-debugging`, with `.scratch/<slug>/spec.md` as the
bug report it works from.

Where a hypothesis turns on what a library actually does, settle it with
`temper:docs` before testing it. A root cause that rests on a misremembered API
is a second bug.

It ends in one of three places:

- **Fixed** — a failing test first, then the fix, verified. Commit anything left
  uncommitted, following the Commits field. Keep the root cause, in two or three
  lines, for the pull request.
- **Three fixes failed** — at the point where the skill says to discuss the
  architecture with your human partner, this run stops instead. Report the root
  cause as far as it got, each attempt and why it failed, and what's committed.
- **The fix needs design** — a changed contract, a new module, a different data
  shape. Stop, and report that the work needs `/temper:feature`.

Done when the fix is committed, or the run has stopped with its report.

## 5. Check

Load `temper:check` with:

- mode `build`
- the default fixed point
- intent `.scratch/<slug>/spec.md`
- quality seat yes
- no baseline

Done when `check` has written its verdict.

## 6. Finish

Load `temper:finish` with the kind `fix`, the verdict, the root cause, and every
ruling: each decision you made after the start line, and whatever
`.scratch/<slug>/rulings.md` holds.

Done when `finish` has reported a pull request, or why there isn't one.
