---
description: "Remove the worktrees and branches temper runs leave behind in this project once their work has landed. Local only: nothing on the remote is touched."
---

# temper cleanup

Clears up after temper runs in the project you're working in: the worktrees under
`.claude/worktrees/` and the branches behind them. It shows everything first, asks
once, and removes only what the user picks.

Everything happens in this checkout's own git. Nothing on the remote is deleted,
pushed or changed: never `git push`, `git fetch --prune`, `git remote prune` or
`gh pr close`. Remote branches are the user's to manage.

The default branch is as the `start` skill defines it.

## 1. Where you are

`git rev-parse --git-dir` and `git rev-parse --git-common-dir` resolve to the same
path in the main checkout. If they differ, you're inside a worktree: stop, and tell
the user to run this from the project's main checkout, since git can't remove the
worktree a session is standing in.

Any branch, a dirty tree and a missing `.claude/temper.md` are all fine. This
command never commits.

Done when you're in the main checkout.

## 2. Bring origin up to date

`git fetch origin`, with no `--prune`, so "landed" is judged against the default
branch as it is on the remote now. If the fetch fails, say so and carry on against
the last fetched state.

Then check whether pull request checks can run: `gh auth status` succeeds and
`gh pr list --limit 1` works in this repo. If either fails, PR checks are off for
this run. Say so; step 4 then treats anything that needs a PR to decide as Live.

Done when the fetch has run or failed, and you know whether PR checks are on.

## 3. Find the candidates

From `git worktree list --porcelain` and
`git branch --list --format='%(refname:short)'`, take:

- every worktree whose path is under this checkout's `.claude/worktrees/`
- every local branch named `feat/*`, `fix/*`, `refactor/*` or `worktree-*`

A worktree and the branch it has checked out are one item. A branch with no
worktree is an item of its own, and so is a worktree with a detached HEAD. The main
checkout, the default branch and every other branch are never candidates, and are
never shown.

If there are none, say the project has nothing to clean up, and stop.

Done when you have the list of items.

## 4. Sort each item

Below, the tip is the item's branch, or `HEAD` in its worktree when it has no
branch. Check the states in this order; the first that matches is the item's
state. Record the reason in a few words.

1. **Live**: kept, never offered. Any of:
   - the worktree is marked `locked`
   - the worktree's folder exists and `git -C <path> status --porcelain` prints
     anything
   - the branch is checked out in the main checkout
   - `git rev-list <tip> --not --remotes=origin` prints anything: commits that
     exist nowhere else, even when the PR merged
   - PR checks are on and `gh pr list --head <branch> --state open` finds one
2. **Orphaned**: the worktree is marked `prunable`, meaning its folder is gone.
3. **Landed**: PR checks are on and `gh pr list --head <branch> --state merged`
   finds one; or PR checks are off and
   `git merge-base --is-ancestor <tip> origin/<default branch>` succeeds.
4. **Abandoned**: PR checks are on and `gh pr list --head <branch> --state closed`
   finds one that didn't merge.
5. **Empty**: `git merge-base --is-ancestor <tip> origin/<default branch>`
   succeeds, so it holds nothing that isn't already on the default branch.
6. **Live**, for everything left: commits of its own with no PR or, with PR checks
   off, a PR state that couldn't be checked.

Done when every item has a state and a reason.

## 5. Ask once

Show one table of every item: worktree path (or `—`), branch (or `detached`),
state and reason. Order it Landed, Empty, Orphaned, Abandoned, then Live.

If no item is Landed, Empty, Orphaned or Abandoned, say there's nothing safe to
remove and stop without asking.

Otherwise ask one multi-select question listing only those items. Landed, Empty
and Orphaned are selected; Abandoned is offered unselected. Live items are in the
table but aren't options. Picking nothing removes nothing.

Done when the user has answered.

## 6. Remove

For each picked item, in order, skipping the rest of that item's steps as soon as
one fails:

1. `git worktree remove <path>` when it has a worktree, including one whose
   folder is gone, since that clears git's record of it. Never `--force`: git's
   own check on a dirty worktree always applies.
2. `git branch -D <branch>` when it has a branch. `-D` because `-d` refuses
   squash-merged branches; step 4 has already made sure nothing is lost. git
   refuses to delete a branch still registered to a worktree, which is why the
   worktree goes first.

Don't run `git worktree prune`: it would also clear orphaned worktrees the user
didn't pick.

A failure is reported with git's message and never retried with force.

Done when every picked item is removed or has a reported failure.

## 7. Report

What was removed; then what was left, with its state and reason; then anything that
failed or couldn't be checked, including a fetch that failed or PR checks that were
off.

Done when the report is in front of the user.
