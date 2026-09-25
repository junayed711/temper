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

The default branch is as the `start` skill defines it. A temper branch is a local
branch named `feat/*`, `fix/*`, `refactor/*` or `worktree-*`.

## 1. Where you are

`git rev-parse --path-format=absolute --git-dir --git-common-dir` prints two paths.
In the main checkout they're the same. If they differ, you're inside a worktree:
stop, and tell the user to run this from the project's main checkout, since git
can't remove the worktree a session is standing in.

Any branch, a dirty tree and a missing `.claude/temper.md` are all fine. This
command never commits.

Done when you're in the main checkout.

## 2. Bring origin up to date

`git fetch --no-prune origin`, so "landed" is judged against the default branch as
it is on the remote now. `--no-prune` matters: with `fetch.prune` or
`remote.origin.prune` set, a plain fetch deletes the tracking refs of branches the
remote has dropped. If the fetch fails, say so and carry on against the last
fetched state.

Then check whether pull request checks can run: `gh auth status` succeeds and
`gh pr list --limit 1` works in this repo. If either fails, PR checks are off for
this run. Say so; step 4 then treats anything that needs a PR to decide as Live.

Done when the fetch has run or failed, and you know whether PR checks are on.

## 3. Find the candidates

`git worktree list --porcelain` gives one record per worktree: its path, a
`HEAD <sha>` line, then `branch refs/heads/<name>` or `detached`, and `locked` or
`prunable` when they apply. From it and
`git branch --list --format='%(refname:short)'`, take:

- every worktree whose path is under this checkout's `.claude/worktrees/`
- every temper branch

A worktree and the branch it has checked out are one item, whatever the branch is
called. A worktree with a detached HEAD is an item with no branch. A temper branch
that no worktree under `.claude/worktrees/` has checked out is an item of its own.
The main checkout, the default branch and every other branch are never candidates,
and are never shown, unless a worktree under `.claude/worktrees/` has one checked
out.

If there are none, say the project has nothing to clean up, and stop.

Done when you have the list of items.

## 4. Sort each item

Below, the tip is the sha on the `HEAD` line of the item's worktree record, or the
branch when it has no worktree. Never resolve it from inside the worktree's
folder, which may be gone. Check the states in this order; the first that matches
is the item's state. Record the reason in a few words.

1. **Live**: kept, never offered. Any of:
   - the worktree is marked `locked`
   - the worktree's folder exists and `git -C <path> status --porcelain` prints
     anything
   - its branch isn't a temper branch: "on a branch temper didn't make"
   - its branch is checked out in a worktree other than the item's own, including
     the main checkout: another record in the porcelain output has
     `branch refs/heads/<branch>`
   - `git rev-list <tip> --not --remotes=origin` prints anything: commits that
     exist nowhere else, even when the PR merged. The one exception: PR checks are
     on and `gh pr list --head <branch> --state merged --json headRefOid` gives the
     tip itself, so that commit is on GitHub.
   - PR checks are on and `gh pr list --head <branch> --state open` finds one
   - any check above fails or can't run: "couldn't check <what>"
2. **Landed**: PR checks are on and `gh pr list --head <branch> --state merged`
   finds one; or PR checks are off and
   `git merge-base --is-ancestor <tip> origin/<default branch>` succeeds.
3. **Abandoned**: PR checks are on and `gh pr list --head <branch> --state closed`
   finds one that didn't merge.
4. **Empty**: `git merge-base --is-ancestor <tip> origin/<default branch>`
   succeeds, so it holds nothing that isn't already on the default branch.
5. **Live**, for everything left: commits of its own with no PR or, with PR checks
   off, a PR state that couldn't be checked.

Then the worktrees marked `prunable`, meaning their folder is gone. That changes
only what happens to git's record of the folder; the item keeps the state it got
above. If that state is Landed or Empty, the item is **Orphaned**, with a reason
such as "folder gone, empty". Otherwise add "folder gone" to its state, as in
"Abandoned, folder gone", and it's treated as that state.

Done when every item has a state and a reason.

## 5. Ask once

Show one table of every item: number, worktree path (or `—`), branch (or
`detached`), state and reason. Order it Landed, Empty, Orphaned, Abandoned, then
Live. Number the Landed, Empty, Orphaned and Abandoned items from 1; Live items
get no number. Landed, Empty and Orphaned items are the ticked ones. Say which
numbers are ticked.

If no item has a number, say there's nothing to offer and stop without asking.

Otherwise ask one question, single-select, with these options in this order:

- **Remove the N ticked**, where N is how many are ticked, marked recommended.
  Leave it out when none are ticked.
- **Also remove the M abandoned**, only when there are Abandoned items. When none
  are ticked, it reads **Remove the M abandoned**.
- **Remove nothing**.

The user can instead answer with item numbers of their own. Those numbers are the
picked items. Ignore any number that isn't in the table or belongs to a Live
item, and say which you ignored.

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
failed or couldn't be checked, including a fetch that failed, PR checks that were
off, and any item numbers that were ignored.

Done when the report is in front of the user.
