---
description: "Show every worktree in this project with its PR and merge details, then delete only the temper worktrees and branches you name. Local only: nothing on the remote is touched."
---

# temper cleanup

Shows every worktree in the project you're working in, with enough detail to
decide, and deletes only the ones the user names. Only temper's items can be
deleted: local `feat/`, `fix/`, `refactor/` or `worktree-` branches and their
worktrees under `.claude/worktrees/`. It never touches the remote: no
`git push`, no `git fetch --prune`, no `gh pr close`. Single-quote every branch
and path you put in a command.

## 1. Look

Stop unless `git rev-parse --path-format=absolute --git-dir --git-common-dir`
prints the same path twice: git can't remove the worktree you're standing in.

Run `git fetch --no-prune origin`; if it fails, say so and carry on. Then list
every worktree from `git worktree list --porcelain`, and the temper branches from
`git branch --format='%(refname:short)' --list 'feat/*' 'fix/*' 'refactor/*' 'worktree-*'`.

A **temper item** is one of those branches, with its worktree if one under
`.claude/worktrees/` is on it. Everything else (the main checkout, the default
branch, detached worktrees, other branches, worktrees outside
`.claude/worktrees/`) is shown for information and can't be picked. So is any
branch whose name, or path inside the repo, has a character outside
`A-Za-z0-9._/-`: it isn't a temper item, run no command with its name in it, and
say it's for the user to remove by hand.

Done when you have every worktree and every temper item.

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

Show one table: a number for each temper item, its worktree (or `—`), its branch,
and its details, marking the ones that hold work. Below it, list the other
worktrees without numbers. Then ask the user which numbers to delete, or none.
Delete nothing they didn't name by number. If the answer isn't numbers or
"none", ask again.

Done when the user has answered.

## 4. Delete

For each number named, once each, in order:

- If it holds work, don't delete it; say why.
- Otherwise run `git worktree remove <path>` if it has a worktree (never
  `--force`), then `git branch -D <branch>`. If a step fails, report git's message
  and skip the rest of that item.

Report what was deleted, what was refused and why, and any number that didn't
match an item.

Done when the report is in front of the user.
