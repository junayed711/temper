---
name: finish
description: "Proposes a temper run whose check came out clean: clears its scratch folder, gates again, opens the pull request. Load when a temper command tells you to."
---

# Finish

Turns a clean check into a pull request.

## What the caller gives you

- The **kind** — `feat`, `fix` or `refactor` — and the check's **verdict**.
- The **rulings**: every decision made on the user's behalf after the start line.
  For a feature, that includes the list from Superpowers' build loop's final
  message — the loop deletes its own ledger when it finishes, so that message is
  the only copy.
- For a bug: the **root cause** found. For a refactor: the **baseline** result.

The slug and the default branch are as the `start` skill defines them.

## When the verdict isn't clean

Open nothing and change nothing. Report the result, the blocking findings, and
where the work is: the worktree path, the branch, and `.scratch/<slug>/`. The user
picks it up from there.

Done when that's reported.

## 1. Write the description

Everything that has to outlive the run, taken now, because the next step deletes
`.scratch/`. If the user's or the repo's instructions say how to write a pull
request, follow them. Otherwise, write it for someone who doesn't work on the code:
the summary first, then the record.

```markdown
One sentence in plain words: what changes, and why it matters.

**What changes**

- Three to five short bullets, from the commits, in plain words.

**Heads up**

- A security pass that didn't run on a risky path, first.
- Every ruling that costs something if it was wrong, in a line each.

<details><summary>Details</summary>

**What was asked**: a few lines from `.scratch/<slug>/spec.md`.

**Rulings**: every decision made, why, and what it costs if it was wrong.

**Root cause** for a bug, or **baseline** proof for a refactor.

**How it was checked**: gates, each seat's outcome, verify.

**Not blocking**: each finding with its seat and rating.

</details>
```

Skip Heads up when there's nothing for it. The title is short, plain and names the
change. Write the file outside the repo: `mktemp`.

Done when the file holds every part that applies.

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
3. Otherwise open it:
   `gh pr create --base <default branch> --head <branch> --title <title> --body-file <file>`.

The pull request is the user's to review and merge; the worktree stays for their
feedback.

Done when you've reported the pull request's URL.
