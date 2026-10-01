# Verification: cleanup from inside a worktree

`commands/cleanup.md` is a prompt, so it was verified by running the git and `gh`
commands it names, in the order it names them, in throwaway repositories: a local
bare origin, a stand-in `gh`, and a project path with a space in it. Each
scenario used a fresh repository. Commands were run through helper scripts from
the folder the session would be in.

What this does and doesn't show:

- The git and `gh` results are observed. What the command then says to the user
  (the question, a refusal, the close-the-session line) is the file's wording
  applied to those results; no live `/temper:cleanup` run produced it.
- `ExitWorktree` can't be called in a throwaway repo. Scenarios 1–2 took its
  "no worktree session" outcome and scenario 3 its "moved to the main checkout"
  outcome.
- The default branch was taken as `main`, not looked up. The stand-in `gh` has
  no repository to report, so the `gh repo view` lookup was not exercised.
- Scenarios 1, 2, 3, 6, 7 and 8 ran every command steps 1 and 2 name. Scenarios 4
  and 5 are from the first walk, which ran the detail checks for the item in
  hand but did not record the output of step 1's two listing commands.

git version: git version 2.50.1 (Apple Git-155)

| # | Scenario | Result | Observed |
|---|---|---|---|
| 1 | merged worktree, session can't leave | pass | The two git dirs differed, so a current-worktree run. `--show-toplevel` gave the `merged` worktree, on `feat/merged`, a temper branch. PR merged; `merge-base --is-ancestor` exit 0; 0 commits only here; status empty. The single command `git -C '<main checkout>' worktree remove '<path>' && git -C '<main checkout>' branch -D 'feat/merged'`, started from inside the worktree, exited 0. Afterwards the worktree folder, its record and `feat/merged` were gone; the other five worktrees and four branches were untouched. |
| 2 | same, from a subfolder | pass | From `merged/sub/dir`, `--show-toplevel` still gave the worktree root. Same details and same result as 1, with the single command started from the subfolder. |
| 3 | merged worktree, session steps back | pass | Same details as 1. From the main checkout, `git worktree remove '<path>'` exit 0, then `git branch -D feat/merged` exit 0. Worktree and branch gone, the rest untouched. No close-the-session line applies. |
| 4 | holds work: uncommitted, unpushed, open PR | pass | `dirty`: no PR, in main, 0 commits only here, status `?? new.txt`. `unpushed`: no PR, `merge-base` exit 1, 1 commit only here. `openpr`: PR open. Each holds work, so no question and no delete; all three worktrees and branches existed afterwards. The manual commands, filled in and single-quoted, were then run for `dirty` as the user would: both worked and removed its worktree and branch. |
| 5 | `gh` errors and fetch fails | pass | With `origin` pointing at a missing path, `git fetch --no-prune origin` exited 128; the walk carried on. `gh` exited 4, so PR is "couldn't check", which holds work: no question, no delete. All seven worktrees and six branches were intact. |
| 6 | not a temper item: other branch, detached | pass | From `other`, `--show-toplevel` gave a worktree whose porcelain record is `branch refs/heads/spike`; from `detached`, one whose record is `detached`. The temper branch list was `feat/dirty`, `feat/merged`, `fix/unpushed`, `refactor/openpr`, so neither worktree is a temper item. No detail check, no question, no delete; all seven worktrees and six branches intact. |
| 7 | approval isn't a clear yes | pass | PR merged; `merge-base` exit 0; 0 commits only here; status empty — so the item doesn't hold work and the question is asked. With the answer "ok maybe" no delete command was run; all seven worktrees and six branches intact. |
| 8 | full run from the main checkout | pass | The two git dirs matched, so a full run. Four temper branches, each with a worktree under `.claude/worktrees/`; `other`, `detached` and the main checkout are not items. Details: `merged` clean and merged; `dirty` `?? new.txt`; `unpushed` exit 1 and 1 commit; `openpr` PR open. For `merged`, `git worktree remove` and `git branch -D` both exit 0. `dirty` not deleted. Afterwards only `merged` and `feat/merged` were gone. Every command worked with the space in the project path. |

## Changes made to the command

- **Step 1, the character rule.** It said a branch isn't a temper item if its
  name "or path inside the repo" has a character outside `A-Za-z0-9._/-`. Read as
  the absolute path, the space in the project path would have excluded every
  item (scenarios 1 and 8). It now says "worktree path relative to the main
  checkout".
- **Step 4, when the session can't leave.** The worktree removal and the branch
  delete were two commands. In the first walk of scenarios 1 and 2 the helper
  could not start the second one: its folder had just been deleted. A shell
  started from the deleted folder in the re-walk also printed
  `shell-init: error retrieving current directory`. They are now one `&&`
  command, and the report gives the branch delete to run by hand if the worktree
  went but the branch didn't.

## Observation

Scenario 5: after a failed fetch, the "main" and "pushed" checks still read the
existing `origin/*` refs and looked normal; only the failed `gh` call made the
item hold work. With a working `gh` and a failed fetch, those two details could
be out of date. The command says to report the failed fetch and carry on, which
is how it behaved before this change, so it was left as it is.

## Not verified

- A live `/temper:cleanup` run, and so the exact words the command prints.
- A live `ExitWorktree` call. Its two outcomes were stood in for.
- How a real Claude Code session behaves after its folder is deleted.
- The `gh repo view` default-branch lookup.
- The branch-delete-failed path of the single command.
- Locked, prunable ("folder missing") and checked-out-elsewhere worktrees, and
  branch or path names with characters outside `A-Za-z0-9._/-`.
