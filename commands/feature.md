---
description: "Build something new: grill it, you write the spec with /to-spec, Superpowers plans and builds it, temper checks it and opens a pull request."
argument-hint: "<what you want to build> | build"
---

# temper feature

$ARGUMENTS

This command runs in two halves, split by `/to-spec`, which only a person can run.

- **An ask** — anything other than `build` — runs part A.
- **`build`** runs part B, in the worktree part A created.
- **Nothing** — ask what to build, then run part A.

Each step names the skill that does the work. Load it and follow it; what's
written here is only what temper adds.

## Part A — shape it

### A1. Start

Load `temper:start` with the kind `feat`.

Done when the session is in `.claude/worktrees/<slug>` on the branch `feat/<slug>`.

### A2. The grill

Load `mattpocock-skills:grilling` and grill until the user confirms you share an
understanding.

When a question turns on a fact nobody in the conversation has — what a library
actually does, what an API really returns — load `mattpocock-skills:research` to
settle it, and save its notes under `.scratch/<slug>/research/`.

Settle what existing behaviour this replaces. Where it replaces some, the old
behaviour's tests go when the new ones arrive.

The grill can end the run. When the work isn't worth doing, say so and stop. When
it's really a bug, stop and recommend `/temper:bug`. When it's two pieces of work,
name the seam between them and stop. Each time, tell the user the worktree is
still empty and that you'll remove it if they ask.

Done when the user confirms you share an understanding, or the run has ended.

### A3. Hand over

Tell the user, then stop:

1. Type **`/to-spec`**. It writes the spec to `.scratch/<slug>/spec.md` — give
   the real slug and path, so it lands where part B looks.
2. Then type **`/temper:feature build`**.

Done when the user has those two instructions.

## Part B — build it

### B1. Pick up the run

Check you're in a worktree (`git rev-parse --git-dir` and
`git rev-parse --git-common-dir` differ) on the branch `feat/<slug>`, with the slug
as the `start` skill defines it. If not, tell the user to go back to the worktree
part A created, and stop.

Find the spec at `.scratch/<slug>/spec.md`. If `/to-spec` wrote it into another
folder under `.scratch/`, move it there. If there's no spec, tell the user to run
`/to-spec` and stop.

If the tree has uncommitted changes that aren't the spec or research notes, a
previous build stopped partway through. Ask whether to keep them — committed,
following the Commits field — or discard them.

Commit the spec and research notes following the Commits field of the repo's
`## temper` section.

If `.scratch/<slug>/plan.md` already exists, this is a resumed build: go to B4.

Done when the spec is committed on `feat/<slug>` and the tree is clean.

### B2. Write the plan

Load `superpowers:writing-plans`, working from `.scratch/<slug>/spec.md` and
saving the plan to `.scratch/<slug>/plan.md`. When it offers a choice of how to
execute, the choice is **Subagent-Driven**, starting after step B4.

Done when `plan.md` is saved with its tasks.

### B3. Pin temper's rule into the plan

Add this section directly after the plan's header, then commit the plan following
the Commits field:

```markdown
## Handing back to temper

This plan runs inside a temper run. When every task is complete and the final
whole-branch review is clean, end with your list of rulings and hand control back
to `/temper:feature`, which checks the branch and opens the pull request. temper's
finish takes the place of `superpowers:finishing-a-development-branch` here.
```

When a long session compacts, instructions in the conversation get summarised,
but the build loop's ledger names this plan file as the one it's running. Putting
the rule in the plan keeps it where a recovering session is pointed.

Done when the section is in `plan.md` and the plan is committed.

### B4. The start line

Show the user the plan's tasks — the `### Task N:` headings, one line each — and
ask: *Start the build? Nothing is asked from here until the pull request.* Change
the plan as they ask, and show the tasks again.

From here on, a question you'd have asked is a decision you make: take the choice
the spec supports best, note it for the pull request, and carry on.

Done when the user says go.

### B5. Build

Load `superpowers:subagent-driven-development` on `.scratch/<slug>/plan.md`. The
worktree already exists; it works in this one.

Keep its final message's list of **rulings** — its ledger is deleted when it
finishes, so that message is the only copy.

When it stops for one of its own reasons — something irreversible,
security-sensitive or outside this worktree, or a plan broken beyond a ruling —
this run stops with it. Report why, which tasks are complete, and that running
`/temper:feature build` again picks up from the first unfinished task.

Done when every task is complete and its final review is clean, or the run has
stopped with its report.

### B6. Check

Load `temper:check` with:

- mode `build`
- the default fixed point
- intent `.scratch/<slug>/spec.md`
- quality seat **no** — the build loop's final review already covered it
- no baseline

Done when `check` has written its verdict.

### B7. Finish

Load `temper:finish` with the kind `feat`, the verdict, and every ruling: the build
loop's list and each decision you noted after the start line.

Done when `finish` has reported a pull request, or why there isn't one.
