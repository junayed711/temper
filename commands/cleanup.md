---
description: "Remove the worktrees and branches temper runs leave behind in this project once their work has landed. Local only: nothing on the remote is touched."
---

# temper cleanup

Removes finished temper runs from the project you're working in: worktrees under
`.claude/worktrees/` and local `feat/`, `fix/`, `refactor/` or `worktree-`
branches. It only removes what is clearly done, asks once, and never touches the
remote: no `git push`, no `git fetch --prune`, no `gh pr close`. Single-quote every
branch and path you put in a command.

## 1. Look

Stop unless `git rev-parse --path-format=absolute --git-dir --git-common-dir`
prints the same path twice: git can't remove the worktree you're standing in.

Run `git fetch --no-prune origin`; if it fails, say so and carry on. List the
candidates from `git worktree list --porcelain` and `git branch --list`. Leave out
anything whose branch name or path has a character outside `A-Za-z0-9._/-`, and
say so; those are for the user to remove by hand.

Done when you have the candidates.

## 2. Sort

An item is **done** when all of these hold:

- its PR merged (`gh pr list --head <branch> --state merged` finds one) or its
  branch is already on the default branch
  (`git merge-base --is-ancestor <branch> origin/<default branch>`, with the
  default branch as the `start` skill defines it). Without `gh`, use the second
  test alone.
- `git rev-list <branch> --not --remotes=origin` prints nothing
- its worktree, if it has one, is not locked and
  `git -C <path> status --porcelain --untracked-files=all` prints nothing

Everything else is **kept**. That includes anything a check failed on. Note why,
in a few words.

Done when every item is done or kept.

## 3. Ask once

Show every item with its state and reason. If nothing is done, say so and stop.
Otherwise ask one question: remove the done ones, or remove nothing.

Done when the user has answered.

## 4. Remove

For each done item: `git worktree remove <path>` if it has a worktree (never
`--force`), then `git branch -D <branch>`. If a step fails, report git's message
and skip the rest of that item.

Report what was removed and what was kept, with reasons.

Done when the report is in front of the user.
