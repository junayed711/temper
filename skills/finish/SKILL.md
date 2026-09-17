---
name: finish
description: "Proposes a temper run whose check came out clean: clears its scratch folder, gates again, opens the pull request. Load when a temper command tells you to."
---

# Finish

Turns a clean check into a pull request.

## What the caller gives you

- The **kind** — `feat`, `fix` or `refactor` — and the check's **verdict**.
- For a feature: the list of **rulings** Superpowers' build loop made on the user's
  behalf, from its final message. The loop deletes its own ledger when it finishes,
  so that message is the only copy.
- For a bug: the **root cause** found. For a refactor: the **baseline** result.

The slug and the default branch are as the `start` skill defines them.

## When the verdict isn't clean

Open nothing and change nothing. Report the result, the blocking findings, and
where the work is: the worktree path, the branch, and `.scratch/<slug>/`. The user
picks it up from there.

Done when that's reported.

## 1. Gather the description

Everything that has to outlive the run, taken now — the next step deletes
`.scratch/`:

1. **Not checked**, first — a security pass that didn't run on a risky path leads.
2. **What was asked**, in a few lines from `.scratch/<slug>/spec.md`.
3. **What changed**: each commit's subject, in order.
4. By kind: the **root cause**, or the **baseline** proof, or every **ruling** —
   what was decided, why, and what it costs if it was wrong.
5. **How it was checked**: gates, each seat's outcome, verify.
6. **Not blocking**: each finding with its seat and rating.

Write it to a file outside the repo: `mktemp`.

Done when the file holds every section that applies.

## 2. Clear the scratch folder

`git rm -r .scratch/<slug>` and commit, following the Commits field. The pull
request carries what mattered; a spec left in the tree gets trusted long after it
stops being true.

Done when `.scratch/<slug>/` is gone from `HEAD` and the tree is clean.

## 3. Gates, once more

That deletion is a new commit, so run every gate command again. If one fails, open
nothing and report it.

Done when every gate passes against `HEAD`.

## 4. Open the pull request

1. `git push -u origin <branch>`.
2. `gh pr list --head <branch> --state open --json url`. If one is open, the push
   has updated it: report its URL.
3. Otherwise `gh pr create --base <default branch> --head <branch> --title <title>
   --body-file <file>`, with a title that follows the Commits field.

The pull request is the user's to review and merge; the worktree stays for their
feedback.

Done when you've reported the pull request's URL.
