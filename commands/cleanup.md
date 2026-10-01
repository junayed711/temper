---
description: "Show every worktree in this project with its PR and merge details, then delete only the temper worktrees and branches you name. Run from inside a temper worktree, it deals with that one alone. Local only: nothing on the remote is touched."
---

# temper cleanup

Deletes temper's leftover worktrees and branches, and only the ones the user
approves. Only temper's items can be deleted: local `feat/`, `fix/`, `refactor/`
or `worktree-` branches and their worktrees under `.claude/worktrees/`. It never
touches the remote: no `git push`, no `git fetch --prune`, no `gh pr close`.
Single-quote every branch and path you put in a command.

## 1. Look

Run `git rev-parse --path-format=absolute --git-dir --git-common-dir`. The
**main checkout** is the folder that holds the second path. If the two paths
match, the session is in the main checkout and this is a **full run**: it shows
every worktree and deletes the ones the user names. If they differ, the session
is inside a worktree and this is a **current-worktree run**: it deals with that
worktree alone.

Run `git fetch --no-prune origin`; if it fails, say so and carry on. Then list
every worktree from `git worktree list --porcelain`, and the temper branches from
`git branch --format='%(refname:short)' --list 'feat/*' 'fix/*' 'refactor/*' 'worktree-*'`.

A **temper item** is one of those branches, with its worktree if one under
`.claude/worktrees/` is on it. Everything else (the main checkout, the default
branch, detached worktrees, other branches, worktrees outside
`.claude/worktrees/`) is shown for information and can't be picked. So is any
branch whose name, or worktree path relative to the main checkout, has a
character outside `A-Za-z0-9._/-`: it isn't a temper item, run no command with
its name in it, and say it's for the user to remove by hand.

In a current-worktree run the only item is the one whose worktree is
`git rev-parse --show-toplevel`. If that worktree isn't a temper item, say it's
for the user to remove by hand, delete nothing, and stop.

Done when you have every worktree and every temper item, or the one item of a
current-worktree run.

## 2. Details

For each temper item, find out:

- **PR**: `gh pr list --head <branch> --state all --json number,state` gives open,
  merged, closed, or none. If any is open, it's open; otherwise the newest decides.
  If `gh` is missing or errors, "couldn't check".
- **main**: `git merge-base --is-ancestor <branch> origin/<default branch>` exits 0
  for "already in main", 1 for "has commits of its own". The default branch is as
  the `start` skill defines it.
- **pushed**: `git rev-list --count <branch> --not --remotes=origin` gives 0 for
  "all pushed", otherwise "N commits only here".
- **worktree**: none; "folder missing" if the porcelain record says `prunable`;
  "locked"; otherwise `git -C <path> status --porcelain --untracked-files=all`
  gives "no changes" or "uncommitted changes". If the branch is checked out
  anywhere else, including the main checkout, "checked out at <path>".

A check that errors, or exits other than as described, reads "couldn't check".

An item **holds work** when it has an open PR, commits only here, uncommitted
changes, a locked worktree, is checked out elsewhere, or has anything that
couldn't be checked.

Done when every temper item has its details.

## 3. Ask

**Full run.** Show one table: a number for each temper item, its worktree (or
`—`), its branch, and its details, marking the ones that hold work. Below it,
list the other worktrees without numbers. Then ask the user which numbers to
delete, or none. Delete nothing they didn't name by number. If the answer isn't
numbers or "none", ask again.

**Current-worktree run.** Show the item's worktree, branch and details. If it
holds work, don't ask: refuse it as step 4 describes, and stop. Otherwise say
what will be deleted — the worktree folder and the local branch, nothing on the
remote — and ask yes or no. Anything other than a clear yes deletes nothing: say
so and stop.

Done when the user has answered, or the item was refused.

## 4. Delete

An item that holds work is never deleted. Say why, then print the commands that
remove it by hand, filled in and single-quoted. Print them; never run them.

```
git -C '<main checkout>' worktree remove --force '<worktree path>'
git -C '<main checkout>' branch -D '<branch>'
```

Leave out the first line when the item has no worktree. For a locked worktree,
put `git -C '<main checkout>' worktree unlock '<worktree path>'` first. When the
branch is checked out elsewhere, print no commands: say which checkout has to
leave the branch first.

**Full run.** For each number named, once each, in order: refuse it if it holds
work. Otherwise run `git worktree remove <path>` if it has a worktree (never
`--force`), then `git branch -D <branch>`. If a step fails, report git's message
and skip the rest of that item.

**Current-worktree run.** The session is standing in the folder it's deleting,
so leave first if it can:

1. Call `ExitWorktree` with the action `keep`. If it moves the session to the
   main checkout, run `git worktree remove <path>` (never `--force`), then
   `git branch -D <branch>`, there.
2. If it reports no worktree session, or the tool isn't there, the session
   can't leave. Run both deletes as one command (never `--force`):
   `git -C <main checkout> worktree remove <path> && git -C <main checkout> branch -D <branch>`.
   Once the worktree is removed the session's folder is gone and a new command
   may not start, so this is the last command of the run: run nothing after it.

Either way, if a step fails, report git's message and skip the rest.

Report what was deleted, what was refused and why, and any number that didn't
match an item. When the session couldn't leave and its worktree was deleted but
its branch wasn't, print `git -C '<main checkout>' branch -D '<branch>'` for the
user to run. When the session couldn't leave and its worktree was deleted, end
with this line and nothing after it:

> This session's folder is gone. Close it with `/exit`, then start a new one in `<main checkout>`.

Done when the report is in front of the user.
