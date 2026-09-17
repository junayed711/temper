---
name: start
description: "Opens a temper run: checks the repo is ready, names the work, creates its worktree and branch. Load when a temper command tells you to."
---

# Start

The command that loaded you gives you the **kind** — `feat`, `fix` or `refactor` —
and the user's ask.

## The slug

The **slug** names one piece of work everywhere: the worktree folder
`.claude/worktrees/<slug>`, the branch `<kind>/<slug>`, and the folder
`.scratch/<slug>/`. Inside a run, read it from the worktree folder with
`basename "$(git rev-parse --show-toplevel)"`. The folder name is fixed for the
life of the run; the branch name is not.

## The default branch

`gh repo view --json defaultBranchRef -q .defaultBranchRef.name`, or `main` if
that fails. Every step below that says "default branch" means this.

## 1. Check the repo is ready

Check all four. Report every one that fails, each with its fix, then stop.

- **Main checkout** — `git rev-parse --git-dir` and
  `git rev-parse --git-common-dir` resolve to the same path. Fix: start again
  from the repo's main checkout.
- **On the default branch** — `git branch --show-current` prints it. Fix: switch
  to it.
- **Clean tree** — `git status --porcelain` prints nothing. Fix: commit or stash.
- **Configured** — the root `CLAUDE.md` or `AGENTS.md` has a `## temper` section.
  Fix: `/temper:setup`.

Done when all four pass.

## 2. Name the work

Propose a slug: lowercase words joined by dashes, at most 40 characters, naming
the change itself (`csv-audit-export`). Confirm nothing already uses it — no
branch `<kind>/<slug>` in `git branch --list` or `git ls-remote --heads origin`,
and no folder `.claude/worktrees/<slug>`. If something does, propose another.

Ask once, leading with the proposal: *Working in `<kind>/<slug>`. Change it?*
This comes before the start line, so asking here is part of the job.

Done when the user has accepted a slug nothing else uses.

## 3. Create the worktree

1. `git fetch origin`, so the worktree starts from the default branch as it is on
   the remote now. If the fetch fails, say so and continue.
2. Call `EnterWorktree` with `name` set to the slug. It creates
   `.claude/worktrees/<slug>` and moves the session into it. If the tool is
   unavailable or refuses, report its message and stop.
3. Rename the branch it created: `git branch -m <kind>/<slug>`. Claude Code names
   worktree branches `worktree-<name>`; the pull request should carry a name that
   says what the work is.

Done when `git branch --show-current` prints `<kind>/<slug>`, the slug read from
the worktree folder matches, and `git merge-base --is-ancestor HEAD
origin/<default branch>` succeeds — the worktree starts from the remote default
branch, not from something else.

## 4. Report

One line: the worktree path, the branch, and that it starts from
`origin/<default branch>` — so commits on the local default branch that were never
pushed are not in it.
