---
status: ready-for-agent
---

# `/temper:cleanup` — remove dangling temper worktrees and branches

## Problem Statement

Every temper run leaves a worktree under `.claude/worktrees/<slug>` and a local
`feat/`, `fix/` or `refactor/` branch behind it. `finish` keeps them on purpose so
the pull request can take feedback, and runs that stop in the grill or partway
through a build leave theirs too. Nothing ever removes them. The README tells the
user to run `git worktree remove` and delete the branch by hand, one run at a
time, after working out for themselves which ones have landed. Over time the
project fills with worktrees and branches whose work merged long ago, runs that
were abandoned, and git records of worktree folders that no longer exist. The user
can't tell at a glance which are safe to delete, and deleting the wrong one loses
work that was never pushed.

## Solution

A new command, `/temper:cleanup`, run from the main checkout of the project the
user is working in. It finds every temper worktree and branch in that project,
works out the state of each, and shows them all in one table. Items that are
safe to remove are preselected. Items that still hold work (an open pull request,
uncommitted changes, unpushed commits, a locked worktree, or anything it couldn't
check) are shown but can't be selected. The user confirms once, and the command
removes what they picked, locally only, then reports what it removed and what it
left and why. It never touches the remote.

## User Stories

1. As a temper user, I want one command that cleans up after finished runs, so that I don't remove worktrees and branches by hand one at a time.
2. As a temper user, I want the command to act only on the project I'm working in, so that it never reaches into another repo or into temper's own.
3. As a temper user, I want it to consider only temper's own worktrees and branches, so that branches I or other tools made are never listed or touched.
4. As a temper user, I want worktrees under `.claude/worktrees/` included, so that every run's workspace is covered.
5. As a temper user, I want local `feat/`, `fix/` and `refactor/` branches included, so that runs whose worktree is already gone are still found.
6. As a temper user, I want leftover `worktree-*` branches included, so that a run whose branch rename never happened is still found.
7. As a temper user, I want overhaul step branches (`refactor/<effort>-NN`) covered by the same rules, so that a finished overhaul can be cleaned up too.
8. As a temper user, I want each item marked **Landed** when its pull request was merged, so that squash-merged work is recognised even though git's own ancestry check misses it.
9. As a temper user, I want an item marked **Landed** when its branch is already an ancestor of `origin/<default branch>`, so that work merged without a pull request is recognised too.
10. As a temper user, I want each item marked **Abandoned** when its pull request was closed without merging, so that I can decide whether to drop it.
11. As a temper user, I want each item marked **Empty** when it has no pull request and no commits of its own beyond the default branch, so that runs that ended in the grill are easy to clear.
12. As a temper user, I want each item marked **Orphaned** when git still tracks a worktree whose folder is gone, or a branch has no worktree, so that stale records get cleared.
13. As a temper user, I want an item marked **Live** when it has an open pull request, so that work in review is never removed.
14. As a temper user, I want an item marked **Live** when its worktree has uncommitted changes, so that edits I haven't committed are never lost.
15. As a temper user, I want an item marked **Live** when its branch has commits that exist nowhere else, even if its pull request merged, so that commits added after a merge are never lost.
16. As a temper user, I want a locked worktree marked **Live (locked)** and skipped, so that a worktree another session may be using is left alone.
17. As a temper user, I want every Live item to show why it's Live, so that I know what to do about it myself.
18. As a temper user, I want the command to fetch `origin` before judging anything, so that "landed" is measured against the default branch as it is now.
19. As a temper user, I want that fetch to be a plain `git fetch origin` with no pruning, so that nothing about the remote or its tracking refs changes as a side effect.
20. As a temper user, I want the command to carry on when the fetch fails, and say so, so that it still works offline, judged against the last fetched state.
21. As a temper user without `gh` signed in, or with no GitHub remote, I want the command to still run on git alone, so that I can clean up anyway.
22. As that user, I want anything that would need pull request state treated as Live, and the report to say pull request checks didn't run, so that a missing check never leads to a deletion.
23. As a temper user, I want to see every item in one table, with its worktree path, branch, state and reason, before anything is removed, so that I can review the whole picture at once.
24. As a temper user, I want Landed, Empty and Orphaned items preselected, so that the common case is one confirmation.
25. As a temper user, I want Abandoned items offered but not preselected, so that dropping closed work is a deliberate choice.
26. As a temper user, I want Live items impossible to select, so that I can't remove work by mistake.
27. As a temper user, I want to be asked only once, so that cleanup is quick.
28. As a temper user, I want picking nothing to remove nothing, so that running the command doubles as a dry run with no flag to remember.
29. As a temper user, I want worktrees removed with `git worktree remove` and never with `--force`, so that git's own safety check on dirty worktrees always applies.
30. As a temper user, I want the chosen branches deleted with `git branch -D`, so that squash-merged branches, which `git branch -d` refuses, are removed once the state checks have passed.
31. As a temper user, I want `git worktree prune` run so that git's records of missing worktree folders are cleared.
32. As a temper user, I want the command never to delete, push to, or otherwise change anything on the remote, so that remote branches, which can still reopen a closed pull request, are always mine to manage.
33. As a temper user, I want a final report listing what was removed and what was left, and why, so that I know the project's state afterwards.
34. As a temper user, I want a removal that fails to be reported along with git's message and not retried with force, so that nothing is lost to a retry.
35. As a temper user who runs the command from inside a worktree, I want it to stop and tell me to run it from the main checkout, so that it never tries to remove the worktree I'm standing in.
36. As a temper user, I want the command to run from the main checkout on any branch, with or without a clean tree and with or without `.claude/temper.md`, so that nothing blocks housekeeping, since it never commits.
37. As a temper user with nothing to clean up, I want it to say so and stop, so that I don't get an empty table and a pointless question.
38. As a temper user reading the README, I want the manual cleanup steps replaced by a pointer to the command, so that the docs match what temper does.
39. As a temper user reading the README's command table, I want `/temper:cleanup` listed with the other commands, so that I can find it.

## Implementation Decisions

- **One new command, no new skill.** The command lives alongside `bug`, `feature`, `refactor`, `overhaul`, `review` and `setup`, written in the same style: numbered steps, each ending in a "Done when" line. Nothing else would reuse a cleanup skill, so none is added.
- **Scope is the working project's own git repo.** The command reads `git worktree list --porcelain` and `git branch --list` in the repo it's run in, and nothing else.
- **What's a candidate.** Any worktree whose path is under `.claude/worktrees/`, and any local branch named `feat/*`, `fix/*`, `refactor/*` or `worktree-*`. A worktree and its branch are one item. A branch with no worktree is its own item, and so is a worktree record whose folder is gone. The main checkout and the default branch are never candidates.
- **Where it runs.** From the main checkout: `git rev-parse --git-dir` and `git rev-parse --git-common-dir` resolve to the same path. Otherwise it stops. There are no other preconditions: any branch, dirty or clean tree, `.claude/temper.md` optional. The default branch is as the `start` skill defines it.
- **States, checked in this order; the first match wins.**
  1. **Live**: the worktree is locked; it has uncommitted or untracked changes; the branch has commits not reachable from any remote-tracking ref or the default branch; it has an open pull request; or a check needed to decide its state couldn't run. The reason is recorded.
  2. **Landed**: a merged pull request exists for the branch (`gh pr list --head <branch> --state merged`), or the branch tip is an ancestor of `origin/<default branch>`.
  3. **Abandoned**: a closed, unmerged pull request exists for the branch, and no open one.
  4. **Empty**: no pull request, and no commits beyond the merge-base with `origin/<default branch>`.
  5. **Orphaned**: git tracks the worktree but its folder is missing, or the branch has no worktree and matches none of the states above.
- **Unpushed commits beat a merged pull request.** A branch counts as holding unpushed work when it has commits not contained in any `refs/remotes/origin/*` ref or `origin/<default branch>`. That catches commits added after a merge.
- **Without `gh`.** When `gh auth status` fails or the remote isn't on GitHub, pull request lookups are skipped. Landed is decided by ancestry alone. Empty and Orphaned still apply to items with no commits of its own, since those have nothing to lose. Anything else with commits of its own is Live, because its pull request state can't be confirmed. The report says pull request checks didn't run.
- **Fetch.** `git fetch origin` once at the start, with no `--prune`. If it fails, say so and continue against the last fetched state.
- **One question.** A table of every candidate (worktree path, branch, state, reason), then a single multi-select question. Landed, Empty and Orphaned are preselected, Abandoned is offered unselected, and Live items are listed in the table but aren't options. If there are no selectable items, show the table (if any) and stop without asking.
- **Removal, local only.** For each selected item, in this order: `git worktree remove <path>` (never `--force`) when it has a worktree, then `git branch -D <branch>`, then one `git worktree prune` at the end. A failed step is reported with git's message and that item's remaining steps are skipped. Nothing ever runs `git push`, `git push --delete`, `gh pr close` or any other command that changes the remote.
- **Report.** Removed items, then items left with their state and reason, then anything that failed or couldn't be checked.
- **README.** Add `/temper:cleanup` to the command table and the layout tree; point "After the pull request" and the uninstall section's "Runs that didn't finish" to it in place of the manual `git worktree remove` steps; describe it in the same voice as the other commands.
- **Plugin version.** Bump the plugin's minor version for a new command, following how earlier commands were added.

## Testing Decisions

- The repo has no automated tests; its only gate is `claude plugin validate .`. That gate must pass.
- **The seam is the command itself, run end to end against a throwaway git repo.** Build a scratch repo with a bare "origin", then create one fixture per state: a landed branch (merged by fast-forward), a squash-merged branch (landed only by pull request state, so Live without `gh`), an empty worktree, a worktree with uncommitted changes, a branch with unpushed commits, a locked worktree, a worktree whose folder was deleted by hand, and a non-temper branch (`scratch/foo`) that must never appear. Run the command's steps there and check that the table sorts each fixture correctly, that only the selected items are removed, that the non-temper branch and the remote are untouched, and that the command stops when run inside a worktree.
- A good check looks only at what the user sees and what git reports afterwards (`git worktree list`, `git branch --list`, `git ls-remote origin`), not at how the command reached its answer.
- Prior art: none in this repo; the other commands were checked by running them.

## Out of Scope

- Anything on the remote: deleting remote branches, closing pull requests, pruning remote-tracking refs.
- Branches and worktrees temper didn't create, meaning anything outside `.claude/worktrees/` and the four branch prefixes.
- Other repos, and temper's own repo unless it is the project being worked in.
- `.superpowers/` workspaces and `.scratch/` folders on the default branch (the uninstall section keeps its own steps for those).
- Flags such as `--dry-run`, `--all` or `--force`; picking nothing is the dry run.
- Removing the worktree the session is in.

## Further Notes

- `finish` still keeps the worktree after opening a pull request, for feedback. This command is where it goes once the work lands.
- A squash merge is the common case on GitHub, which is why pull request state, not `git branch --merged`, decides Landed.
