---
description: "Reshape existing code without changing what it does: baseline first, a grill about the seam, a small move with the tests green throughout, then a pull request."
argument-hint: "<what should change shape>"
---

# temper refactor

The same behaviour in a different shape: $ARGUMENTS

Narrow refactors only — one seam, with callers you can count. Each step names the
skill that does the work; what's written here is only what temper adds. With no
ask given, ask what should change shape first.

## 1. Start

Load `temper:start` with the kind `refactor`.

Done when the session is in `.claude/worktrees/<slug>` on the branch
`refactor/<slug>`.

## 2. The baseline

Load `temper:baseline`.

Done when `.scratch/<slug>/baseline.md` holds every gate, green.

## 3. The grill

Load `mattpocock-skills:grilling`, with `mattpocock-skills:codebase-design` as the
reference for its vocabulary — module, interface, seam, depth. Settle:

- the **target shape** — the modules and interfaces as they should be
- the **seam** the change happens at
- which **callers** move, and in what order
- what's **out** of scope

Behaviour stays exactly as it is; that's the requirement the whole run is judged
against.

Where a question turns on what a library actually does, settle it with
`temper:docs` before the next round, not from memory.

The grill can end the run:

- **Too wide** — a change fanning out across the codebase, where no single run can
  land it with the tests green. Stop, and recommend `/temper:overhaul`, which plans
  it as a sequence of narrow refactors, one pull request each.
- **Not a refactor** — the cleanup turns up a bug or a missing feature. Stop, and
  recommend `/temper:bug` or `/temper:feature` first, so the refactor lands
  against behaviour that's settled.

Each time, tell the user the worktree holds only the baseline, and that you'll
remove it if they ask.

Write the four answers, with the requirement that behaviour is unchanged, to
`.scratch/<slug>/spec.md`.

Done when the user confirms the answers and `spec.md` is written.

## 4. Reshape

Load `temper:reshape` with the spec, the baseline, and the scope `whole`.

Done when the old shape is gone and every step is committed green.

## 5. Check

Load `temper:check` with:

- mode `build`
- the default fixed point
- intent `.scratch/<slug>/spec.md`
- quality seat yes
- baseline `.scratch/<slug>/baseline.md`

Done when `check` has written its verdict.

## 6. Finish

Load `temper:finish` with the kind `refactor`, the verdict, the baseline result,
and every ruling: each decision you made after the start line, and whatever
`.scratch/<slug>/rulings.md` holds.

Done when `finish` has reported a pull request, or why there isn't one.
