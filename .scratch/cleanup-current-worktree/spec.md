# Clean the current worktree with `/temper:cleanup`

Labels: ready-for-agent

## Problem Statement

A temper run leaves the user inside the worktree it created. Once the work is
merged, the user wants to delete that worktree and its branch, but
`/temper:cleanup` stops at its first step when run from inside a worktree. The
user has to open a new session in the main checkout to clean up, and nothing
tells them that. From where a run ends, there is no command that removes the
worktree the user is standing in.

## Solution

`/temper:cleanup` works from inside a worktree. Run there, it looks only at the
worktree the session is in: it shows that item's details, refuses if the item
holds work, and otherwise says what will be deleted and asks for approval. On
approval it removes the worktree and its local branch. If the session can step
back to the main checkout it does so first; if it can't, it deletes anyway and
tells the user, in one line, to close the session and how.

Run from the main checkout, the command behaves as it does today, with one
addition: whenever it refuses an item, it prints the commands the user can run
to remove that item by hand.

## User Stories

1. As a temper user whose work is merged, I want to run `/temper:cleanup` from inside the worktree, so that I can remove it without opening another session first.
2. As a temper user, I want cleanup run from inside a worktree to look only at that worktree and its branch, so that the decision in front of me is the one I came to make.
3. As a temper user, I want to see the item's PR state, whether it is already in main, whether everything is pushed, and whether the worktree has uncommitted changes, so that I can decide with the facts in front of me.
4. As a temper user, I want to be told exactly what will be deleted — the worktree path and the branch name — before anything is deleted, so that nothing surprising is removed.
5. As a temper user, I want cleanup to delete nothing until I approve, so that a mistaken invocation costs nothing.
6. As a temper user, I want an answer that isn't a clear yes to delete nothing, so that an ambiguous reply is never taken as approval.
7. As a temper user, I want cleanup to refuse when the worktree has an open PR, so that work under review isn't removed.
8. As a temper user, I want cleanup to refuse when the branch has commits that were never pushed, so that work that exists only on my machine isn't lost.
9. As a temper user, I want cleanup to refuse when the worktree has uncommitted changes, so that edits in progress aren't lost.
10. As a temper user, I want cleanup to refuse when the worktree is locked or a detail couldn't be checked, so that it never deletes on incomplete information.
11. As a temper user, I want a refusal to say why, so that I know what to push, commit or close before trying again.
12. As a temper user, I want a refusal to print the exact commands that remove the item by hand, so that I can force it myself when I know the work is disposable.
13. As a temper user, I want cleanup never to run those force commands itself, so that discarding work is always something I did deliberately.
14. As a temper user, I want the same manual commands when cleanup refuses an item from the main checkout, so that a refusal gives the same help wherever I run it.
15. As a temper user in the session that created the worktree, I want cleanup to step the session back to the main checkout before deleting, so that I can keep working in the same session.
16. As a temper user who came back in a later session, I want cleanup to delete the worktree and branch anyway, so that one command does the job from where I am.
17. As a temper user whose session is left in a deleted folder, I want one plain line telling me to close the session, how to close it, and where to open the next one, so that I'm not left in a broken session wondering what happened.
18. As a temper user whose session stepped back to the main checkout, I want no "close this session" notice, so that I'm only told to do things that are needed.
19. As a temper user, I want cleanup's report to say what was deleted, so that I know the worktree and branch are gone.
20. As a temper user, I want a failed git step reported with git's own message and the rest of the item skipped, so that a half-finished delete is visible and not papered over.
21. As a user standing in a worktree that isn't a temper item, I want cleanup to delete nothing and say it is mine to remove by hand, so that temper only ever deletes what temper made.
22. As a user whose branch or worktree path has characters outside the safe set, I want cleanup to run no command with that name in it, so that an odd name can't change what a command does.
23. As a temper user, I want cleanup to stay local — no push, no prune, no PR closed — so that nothing on the remote changes when I clean up.
24. As a temper user in the main checkout, I want the numbered table and pick-by-number flow unchanged, so that cleaning up several leftover items works as it always has.
25. As a temper user reading the docs, I want the README to say cleanup runs from the main checkout or from inside a worktree, so that I know I can run it where a run ends.

## Implementation Decisions

- The change extends the existing cleanup command. There is no new command.
- The command's opening rule — stop unless the session is in the main checkout — is replaced by a branch on where the session is: the main checkout takes the existing path, a worktree takes the new current-worktree path.
- The current-worktree path identifies one item: the worktree the session is in, and the branch checked out there. It reuses the existing definition of a temper item, the existing detail checks, the existing definition of "holds work", and the existing rule for names with characters outside the safe set. These are stated once and used by both paths.
- When the current worktree is not a temper item — not under the temper worktrees folder, not on a temper-prefixed branch, detached, or oddly named — the command deletes nothing and says it is for the user to remove by hand.
- The current-worktree path shows the single item's details and does not show the numbered table or the other worktrees.
- An item that holds work is refused with the reason. The refusal rule is unchanged: the command never forces a removal.
- Every refusal, on either path, prints the manual commands for that item: a forced worktree removal and a branch delete, both run against the main checkout, with paths and names single-quoted. The command prints them and never runs them.
- Approval on the current-worktree path is a single yes-or-no question asked after stating what will be deleted. Anything other than yes deletes nothing.
- Deleting from inside a worktree has two cases, tried in this order:
  1. The session created the worktree. It leaves the worktree with the harness's exit-worktree tool, keeping the worktree on disk, then removes the worktree and branch from the main checkout with the same git steps the main-checkout path uses. The exit tool's own "remove" action is not used: it would bypass the command's safety checks, and it deletes the branch under the name the harness gave it, which temper renames.
  2. The exit tool reports no worktree session. The command runs the same git steps against the main checkout from where it is, as its last act, then tells the user in one line to close the session, how, and to start the next one in the main checkout.
- The "close this session" line appears only in the second case. It is short and direct, with a concrete example of how to close.
- If git won't remove a worktree while the shell is sitting in it, the second case falls back to refusing with the exact commands to run from the main checkout. This is to be verified during the build.
- The main checkout's path is derived from git's common directory, so the command never has to guess where it is.
- The command stays local only: no push, no pruning fetch, no PR state change. The non-pruning fetch it does today stays.
- The command's description and the README sections that say cleanup runs from the main checkout are updated to match.

## Testing Decisions

- A good test here checks what the user sees and what is left on disk — which worktrees and branches exist afterwards, what was reported — not the wording of the command file.
- The repo has no automated test suite. Its gate is plugin validation, which must pass on every commit.
- The command is a markdown prompt, so its behaviour is verified by walking scenarios in a throwaway git repository, with the results recorded in the pull request:
  - a clean, merged temper worktree, cleaned from inside it in the session that created it;
  - the same from a session that did not create it, confirming whether git allows the removal from inside the folder;
  - a worktree with uncommitted changes, one with unpushed commits, and one with an open PR — each refused, each with a reason and the manual commands;
  - a worktree that isn't a temper item — nothing deleted;
  - the main checkout path — the table and pick-by-number flow unchanged, and a refusal now carrying the manual commands.
- There is no prior art for automated tests in this repo. The prior art for verification is the scenario walk recorded on the pull requests that added and hardened cleanup.

## Out of Scope

- Deleting the remote branch, closing PRs, or pruning remote-tracking refs.
- An override that lets cleanup itself delete an item that holds work.
- Showing or picking other worktrees from inside a worktree.
- A separate command for cleaning the current worktree.
- Cleaning up automatically at the end of a run or when a PR merges.
- Removing a run's scratch folder separately from its worktree.

## Further Notes

- The later-session case is expected to be the common one: a merge usually lands after the session that built the work has ended.
- After the worktree is removed from under a session, that session has no working folder. The notice exists so the user isn't left to discover this from a failing command.
