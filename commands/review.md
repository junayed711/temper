---
description: "Review work that already exists: gates, the full review panel and verification, reported as a verdict. Changes nothing."
argument-hint: "[fixed point: a commit, branch or tag — default: the merge-base with the default branch]"
---

# temper review

Work that already exists: $ARGUMENTS

Run from inside the worktree or checkout that holds the work. This command reports;
the work stays exactly as it is — nothing is committed, pushed or deleted.

## 1. Where you are

The default branch is as the `start` skill defines it. If `git branch --show-current`
prints it, stop: there's no work of its own on the default branch to review, so tell
the user to run this from the branch they want reviewed.

Done when you're on a branch other than the default branch.

## 2. The fixed point

What the user passed, or with nothing passed, the merge-base with
`origin/<default branch>`. Confirm it resolves with `git rev-parse`, and that
`git diff <fixed point>...HEAD` isn't empty. An empty diff means there's nothing to
review: say so and stop.

Done when the fixed point resolves and the diff has changes in it.

## 3. The intent

With the slug as the `start` skill defines it, look for `.scratch/<slug>/spec.md`.
If temper built this branch, that's the intent, and `.scratch/<slug>/baseline.md`,
if it exists, is the baseline.

Without a spec, ask the user one line: *What should this change do, and what must it
not do?*

Done when you have a spec path or the user's line.

## 4. The start line

Tell the user: *Start line — the review runs from here without asking anything.*

## 5. Check

Load `temper:check` with:

- mode `review`
- the fixed point from step 2
- the intent from step 3 — the spec's path, or the user's line
- quality seat yes
- the baseline, if step 3 found one

Done when `check` has written its verdict.

## 6. Report

Give the user the verdict. Lead with anything blocking, then what didn't block, then
what went unchecked.

Done when the verdict is in front of the user.
