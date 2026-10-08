# Cleanup refuses the worktree its own session locked

## Symptom

`/temper:cleanup`, run from inside the worktree that `/temper:start` created,
always refuses to delete it. `EnterWorktree` locks the worktree for the session
(`locked claude session <slug> (pid <n> start <date>)`). Cleanup counts any
locked worktree as holding work, so it refuses in step 3, before it reaches the
step that leaves the worktree.

## Expected

- A lock is **this session's own** only when its reason starts with
  `claude session` and its pid equals `$CLAUDE_PID`. Any other shape, or an
  unset `$CLAUDE_PID`, counts as held work, as now.
- An own lock does not count as held work. The details show "locked by this
  session", and the `git status` check still runs, so uncommitted changes still
  refuse the delete. The other checks (open PR, commits only here, checked out
  elsewhere) apply as before.
- When the session can't leave the worktree (`ExitWorktree` fails or is
  missing), the own lock is still there. Cleanup runs `git worktree unlock` on
  it, only after every check has passed and the user has said yes, in the same
  joined command as the remove and the branch delete, and never with `--force`.

## Reach

1. In the main checkout, run `/temper:start` (or any temper command); it calls
   `EnterWorktree` with the slug.
2. In the same session, with nothing uncommitted and nothing unpushed, run
   `/temper:cleanup`.
3. Cleanup reports the worktree as locked and refuses.

## Out of scope

- Locks left by dead sessions (the pid is no longer running) still hold work.
- The full run from the main checkout is unchanged: every lock it sees holds
  work.
- `temper:start` keeps using `EnterWorktree` as it does.

## Facts checked before the fix

- The lock's pid equals `$CLAUDE_PID` and the shell's `$PPID` (58949 in the
  session that checked; 40675 in the user's own check).
- `ExitWorktree` with `keep` releases the lock.
- `EnterWorktree` with `path`, into an existing worktree, takes no lock.

## Hypotheses for the debugging step

- The refusal comes from step 2 of `commands/cleanup.md`: "locked" both replaces
  the `git status` check and is listed under "holds work", with no exception for
  the session's own lock.
- A fresh session opened inside an existing worktree has no lock. Not verified.
