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

Load `temper:progress` before the first step. It keeps the user posted for the
whole run.

## Part A — shape it

### A1. Start

Load `temper:start` with the kind `feat`.

Done when the session is in `.claude/worktrees/<slug>` on the branch `feat/<slug>`.

### A2. The grill

Load `mattpocock-skills:grilling` and grill until the user confirms you share an
understanding. The grill takes the place of `superpowers:brainstorming` in a temper
run; don't load it.

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

1. Type **`/to-spec`**. In a temper run the issue tracker is local markdown, so
   it writes the spec to `.scratch/<slug>/spec.md` and nowhere else — give the
   real slug and path, so it lands where part B looks.
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

Load `temper:skill-routing` and follow `Installed`. If a declared skill is
missing, name it and its fix, and carry on to the plan: B4 settles it.

If the tree has uncommitted changes that aren't the spec or research notes, a
previous build stopped partway through. Ask whether to keep them — committed,
following the Commits field — or discard them.

Commit the spec and research notes following the Commits field of the repo's
`.claude/temper.md`.

If `.scratch/<slug>/plan.md` already exists, this is a resumed build. If the plan
has no `### Skills` heading, or its "Handing back to temper" section has no
paragraph about `temper:skill-routing`, put B3's section in place of that section
and commit the plan following the Commits field. Then go to B4.

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

While it runs, post a progress line as each task starts, as its review comes back,
and as each fix starts, in the shape `build: task <n>/<total> — <what>`.

When you dispatch an implementer, put in its prompt: load `temper:skill-routing`,
follow `Writing`, with this task's line from `### Skills` below. When you dispatch
a task reviewer, put in its prompt: load `temper:skill-routing` and follow
`Reviewing`. Neither may stop the build over a skill. After each task review, add
a ledger line
`Task N: skills — writer loaded …, skipped …; reviewer loaded …`, from the
implementer's reply and the first line of the reviewer's report. Copy those lines
into your final message alongside the rulings.

### Skills

(The agreed skill list goes here at the start line.)
```

When a long session compacts, instructions in the conversation get summarised,
but the build loop's ledger names this plan file as the one it's running. Putting
the rule in the plan keeps it where a recovering session is pointed.

Done when the section is in `plan.md` and the plan is committed.

### B4. The start line

Show the user the plan's tasks — the `### Task N:` headings, one line each.

Before asking the start-line question, load `temper:skill-routing` and follow
`The skill list`, against the spec and the plan's tasks. Show the list below the
tasks. If a declared skill is `missing`, say so, and settle it by following
`Settling a missing skill`. Run again in a new session, `/temper:feature build`
resumes here.

Then ask: *Start the build? Nothing is asked from here until the pull request.*
Change the plan as they ask, and show the tasks again. Changes to the skill list
go through the same loop.

Once they say go, set the agreed list under the plan's `### Skills` heading
(replacing the placeholder, or the earlier list on a resumed build). Then write
each task's skills into the task itself, as the first line under its
`### Task N:` heading:

```markdown
**Skills:** load `temper:skill-routing` and follow `Writing` with <skill>, <skill>; reviewers follow `Reviewing`.
```

The build loop hands each implementer and task reviewer its task's full text, so
the skills reach them even if the dispatch prompt leaves them out. On a resumed
build, replace any earlier `**Skills:**` line rather than adding a second. Commit
the plan following the Commits field. This is a second commit of the plan.

From here on, a question you'd have asked is a decision you make: take the choice
the spec supports best, note it for the pull request, and carry on.

Done when the user says go and the plan with the agreed skill list is committed.

### B5. Build

Load `superpowers:subagent-driven-development` on `.scratch/<slug>/plan.md`. The
worktree already exists; it works in this one. When its final review is clean it
hands back here, as the plan's "Handing back to temper" section says, and doesn't
load `superpowers:finishing-a-development-branch`.

Keep its final message's list of **rulings** and its `Task N: skills` lines — its
ledger is deleted when it finishes, so that message is the only copy.

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

Load `temper:finish` with the kind `feat`, the verdict, every ruling — the build
loop's list and each decision you noted after the start line — and the skills
loaded and skipped, from the build loop's `Task N: skills` lines.

Done when `finish` has reported a pull request, or why there isn't one.
