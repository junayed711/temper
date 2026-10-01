# Verification: cleanup from inside a worktree

Walked by following `commands/cleanup.md` step by step in throwaway repositories
(local bare origin, a stand-in `gh`, a project path with a space in it).
`ExitWorktree` can't be called in a throwaway repo; scenarios 1–2 took its
"no worktree session" branch and scenario 3 its "moved to the main checkout" branch.

git version: git version 2.50.1 (Apple Git-155)

| # | Scenario | Result | Notes |
|---|---|---|---|
| 1 | merged worktree, session can't leave | pass | Git dirs differed, so a current-worktree run. Details: PR merged, already in main (exit 0), all pushed (0), no changes. Both `git -C '<main checkout>'` commands succeeded; worktree and `feat/merged` gone; the run ends with the close-the-session line naming the project folder. The second command was run from a folder that no longer existed: the `in.sh` helper's `cd` failed there, so it was run from `/` instead. A real session's shell would simply have a missing working directory, and `git -C <absolute path>` doesn't need it. |
| 2 | same, from a subfolder | pass | From `.claude/worktrees/merged/sub/dir`, `git rev-parse --show-toplevel` gave the worktree root, so the item was found. Same details and same result as 1, including the helper's `cd` failure on the second command. |
| 3 | merged worktree, session steps back | pass | `git worktree remove` then `git branch -D feat/merged` run from the project folder without `-C`; both worked. Worktree and branch gone; no close-the-session line. |
| 4 | holds work: uncommitted, unpushed, open PR | pass | `dirty`: no PR, in main, all pushed, uncommitted changes (`?? new.txt`). `unpushed`: no PR, not in main (exit 1), 1 commit only here. `openpr`: PR open. Each held work, so each was refused without a question and the manual commands were printed single-quoted, never run. All three worktrees and branches still existed afterwards. Then, acting as the user, the printed commands for `dirty` (`worktree remove --force`, `branch -D`) removed its worktree and branch. |
| 5 | `gh` errors and fetch fails | pass | With `origin` pointing at a missing path, `git fetch --no-prune origin` failed (exit 128), reported, walk carried on. `gh` exited 4, so PR read "couldn't check", which holds work: refused, manual commands to be printed, nothing deleted (all seven worktrees and six branches intact). See the note below on stale remote refs. |
| 6 | not a temper item: other branch, detached | pass | From `other` (branch `spike`) and from `detached`, the show-toplevel worktree matched no temper item. Each: "for the user to remove by hand", nothing deleted, no question asked. |
| 7 | approval isn't a clear yes | pass | Details read merged, in main, all pushed, no changes, so the question was asked; "ok maybe" is not a clear yes: nothing deleted, said so, stopped. All worktrees and branches intact. |
| 8 | full run from the main checkout | pass | Git dirs matched, so a full run. Four numbered items (`merged`, `dirty`, `unpushed`, `openpr`); `other`, `detached` and the main checkout unnumbered. `merged` deleted with `git worktree remove` then `git branch -D`. `dirty` refused (uncommitted changes) with the manual commands. Every command worked despite the space in the project path. |

Two readings I had to make, neither enough to fail a scenario:
- Step 1 says a branch is not a temper item if its name "or path inside the repo" has a character outside `A-Za-z0-9._/-`. I read "path inside the repo" as the path relative to the main checkout (`.claude/worktrees/merged`), not the absolute path with the space.
- "The default branch as the `start` skill defines it" resolved to `main` here because the stand-in `gh` doesn't answer the default-branch call.

Observation, scenario 5: after a failed fetch the `main` and `pushed` checks still ran against the old `origin/*` refs and read normally. Here the failed `gh` call alone made the item hold work. With working `gh` and a failed fetch, those two details could be out of date and nothing would flag it. The command's wording ("say so and carry on") matches this, so nothing was changed.

## Changes made to the command

None.

## Not verified

- A live `ExitWorktree` call. Its two outcomes were stood in for, not exercised.
- Locked, prunable ("folder missing") and checked-out-elsewhere worktrees, and branch or path names with characters outside `A-Za-z0-9._/-`: no scenario covers them.
