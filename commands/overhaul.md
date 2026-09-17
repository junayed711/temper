---
description: "Reshape code across the codebase without changing what it does: plan it as tickets you merge on main, then run each ticket as its own narrow refactor and pull request."
argument-hint: "<what should change shape> | publish | next <effort>"
---

# temper overhaul

$ARGUMENTS

A refactor too wide for one run, done as a sequence of narrow ones: add the new
shape beside the old, move the callers across in batches, delete the old. Each
step lands on its own with the tests green, in its own pull request.

- **An ask** — anything other than `publish` or `next` — runs part A, the plan.
- **`publish`** runs part B, in the worktree part A created.
- **`next <effort>`** runs part C: the next ticket of a plan already on the default
  branch.
- **Nothing** — ask what should change shape, then run part A.

Each step names the skill that does the work. Load it and follow it; what's
written here is only what temper adds. The slug and the default branch are as the
`start` skill defines them.

## The plan

A plan lives at `.scratch/<effort>/issues/<NN>-<name>.md`, one ticket per file,
numbered from `01` in dependency order. Each ticket has a **Blocked by** line and a
**Status** line. It's committed on the default branch while the work is under way,
so every step's worktree starts with it, and the pull request of the last step
deletes it.

- A ticket is **done** when its Status says `done`.
- A ticket is **open** when it isn't done.
- A ticket is **ready** when it's open and every ticket in its Blocked by line is
  done.

## Part A — plan it

### A1. Start

Load `temper:start` with the kind `refactor`, and keep the slug to 36 characters.
The slug it settles is the **effort**: it names the plan's folder, and each step
after it is `<effort>-<NN>`.

Done when the session is in `.claude/worktrees/<effort>` on the branch
`refactor/<effort>`.

### A2. The grill

Load `mattpocock-skills:grilling`, with `mattpocock-skills:codebase-design` as the
reference for its vocabulary — module, interface, seam, depth. Settle:

- the **target shape** — the modules and interfaces as they should be
- the **seams** the change happens at
- which **callers** move, grouped into batches that can each land alone
- what's **out** of scope

Behaviour stays exactly as it is; that's the requirement every ticket is judged
against. Where the grill finds code that moves with no test covering it, name it:
those tickets will stop at their pin until it's covered.

The grill can end the run:

- **Narrow enough for one run** — one seam, with callers you can count. Stop, and
  recommend `/temper:refactor`.
- **Not a refactor** — the cleanup turns up a bug or a missing feature. Stop, and
  recommend `/temper:bug` or `/temper:feature` first.

Each time, tell the user the worktree is still empty and that you'll remove it if
they ask.

Done when the user confirms you share an understanding, or the run has ended.

### A3. Hand over

Say this in the conversation, so `/to-tickets` works from it:

> The issue tracker for this plan is local markdown: one file per ticket under
> `.scratch/<effort>/issues/`. This is a wide refactor, so sequence it as
> expand–contract. Every ticket must land on its own with the gates green — no
> shared integration branch. Size each ticket for one narrow refactor run, and
> give each the acceptance criterion that behaviour is unchanged.

Use the real effort in the path. Then tell the user, and stop:

1. Type **`/to-tickets`**, and agree the breakdown with it.
2. Then type **`/temper:overhaul publish`**.

Done when the user has those two instructions.

## Part B — publish the plan

### B1. Pick up the run

Check you're in a worktree (`git rev-parse --git-dir` and
`git rev-parse --git-common-dir` differ) on the branch `refactor/<effort>`, with
the effort read from the worktree folder. If not, tell the user to go back to the
worktree part A created, and stop.

Find the tickets at `.scratch/<effort>/issues/`. If `/to-tickets` wrote them into
another folder under `.scratch/`, move them there. If there are none, tell the user
to run `/to-tickets` and stop.

Done when the tickets are in `.scratch/<effort>/issues/`.

### B2. Check the plan's shape

Every ticket needs a number, a Blocked by line and a Status line, and may only be
blocked by tickets numbered before it. A plan that relies on a shared integration
branch, or a ticket that can't land with the gates green on its own, isn't
something temper can run: stop, name the tickets, and suggest the user reshapes
them with `/to-tickets`.

Done when every ticket passes.

### B3. Open the plan's pull request

Commit the tickets following the Commits field of the repo's `.claude/temper.md`,
then:

1. `git push -u origin refactor/<effort>`.
2. `gh pr list --head refactor/<effort> --state open --json url`. If one is open,
   the push has updated it: report its URL.
3. Otherwise open it:
   `gh pr create --base <default branch> --head refactor/<effort> --title <title> --body-file <file>`.

The description follows the user's or the repo's pull request rules where there
are any. Otherwise: one plain sentence on what the refactor achieves, the tickets
in order with what blocks each, and a Heads up that the plan stays on the default
branch until the last ticket's pull request deletes it. No gates run: the change is
the plan alone.

Done when you've reported the pull request's URL.

### B4. What next

Tell the user:

1. Merge the plan's pull request, then remove this worktree.
2. From the main checkout, on the default branch, with the merge pulled, type
   **`/temper:overhaul next <effort>`** for each ticket in turn.

Done when the user has those instructions.

## Part C — the next ticket

### C1. Pick the ticket

Run `git fetch origin`, then read the plan from `origin/<default branch>` — every
step's worktree starts there. List the tickets with
`git ls-tree --name-only origin/<default branch> .scratch/<effort>/issues/` and read
each with `git show`.

- **No plan there** — stop. Either the plan's pull request isn't merged, or the
  effort is misspelt: list the folders under `.scratch/` that hold an `issues/`
  folder.
- **Every ticket done** — stop, and say the plan should already have been deleted.
- **A branch `refactor/<effort>-<NN>` already exists**, locally or on `origin`,
  for a ticket — that ticket is in progress. Leave it out.
- **Nothing ready** — stop. List each open ticket with what it's waiting on,
  and any in progress.

Otherwise take the ready ticket with the lowest number. Show the user its title
and body, and ask: *Run ticket `<NN>`?*

Done when the user says yes.

### C2. Start

Load `temper:start` with the kind `refactor`, and propose the slug
`<effort>-<NN>`.

Done when the session is in `.claude/worktrees/<slug>` on the branch
`refactor/<slug>`.

### C3. The baseline

Load `temper:baseline`.

Done when `.scratch/<slug>/baseline.md` holds every gate, green.

### C4. The spec

Write `.scratch/<slug>/spec.md`: the ticket's path, its title, its body, and the
requirement that behaviour stays exactly as it is.

If reading the code shows the ticket can't land with the gates green on its own,
stop. Say which ticket it depends on that the plan doesn't list, and that the plan
needs revising on a branch of its own. The worktree holds only the baseline and
spec.

Done when `spec.md` is written.

### C5. Reshape

Load `temper:reshape` with the spec, the baseline, and the scope `ticket`.

Done when every move the ticket names is committed green.

### C6. Update the plan

If this is the plan's last open ticket, delete the plan: `git rm -r
.scratch/<effort>`. Otherwise set this ticket's Status line to `done`. Commit,
following the Commits field.

The plan changes on this branch only, so the ticket counts as done once this pull
request merges, and not before.

Done when the change is committed and the tree is clean.

### C7. Check

Load `temper:check` with:

- mode `build`
- the default fixed point
- intent `.scratch/<slug>/spec.md`
- quality seat yes
- baseline `.scratch/<slug>/baseline.md`

Done when `check` has written its verdict.

### C8. Finish

Load `temper:finish` with the kind `refactor`, the verdict, the baseline result,
and every decision you noted after the start line — the first of them being which
ticket this was, and whether its pull request deletes the plan.

Done when `finish` has reported a pull request, or why there isn't one.
