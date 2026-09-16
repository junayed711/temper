# grill-to-pr

An agent pipeline that takes a rough idea to a reviewed pull request.

It does not reimplement the thinking. The stages are Matt Pocock's engineering
skills; this plugin exists to sequence them, run the project's gates between
them, and decide whether the result is good enough to propose.

## Requires

- [`mattpocock-skills`](https://github.com/mattpocock/skills) installed.
- `/setup-matt-pocock-skills` run once in the target repo. It writes
  `docs/agents/issue-tracker.md`, which `to-spec`, `to-tickets` and `code-review`
  all read. Without it those three stop and ask for it.

## The workflow today

Run by hand, in order. Only `grilling`, `tdd`, `code-review` and
`diagnosing-bugs` can be invoked by an agent; the rest you type.

| # | Stage | Skill | Who runs it |
|---|-------|-------|-------------|
| 1 | Sharpen the idea | `grilling` | agent or you |
| 2 | Write the spec | `/to-spec` | you |
| 3 | Break it into tickets | `/to-tickets` | you |
| 4 | Build it test-first | `/implement` → `/tdd` | you |
| 5 | Review it | `/code-review` | you |
| 6 | Diagnose a failure | `diagnosing-bugs` | agent or you |

Stage 4 calls `/tdd` for the red-green loop, then `/code-review`, then commits —
so stages 4 and 5 are one command in practice.

`/code-review` runs two sub-agents in parallel and reports them separately:
**Spec** (does the diff do what the spec asked, and only that) and **Standards**
(does it follow the repo's documented rules, plus a baseline of twelve Fowler
smells). Neither axis is allowed to mask the other.

## What this plugin adds

Nothing yet. This is the blank slate.

## What it will add

The gaps in the chain above, in rough order of value:

1. **Orchestration.** Every stage but `grilling` is typed by hand, so there is no
   unattended run. This is the whole point of the plugin.
2. **Gates.** `/implement` advises running typecheck and tests. Nothing refuses to
   continue when they are red.
3. **Parallel builds.** `/implement` works tickets in order, in one session. No
   worktrees.
4. **A pull request.** Nothing decides whether the work is clean enough to propose,
   and nothing opens one.
5. **Verification.** Nothing checks the change actually runs, only that it compiles
   and its tests pass.
6. **A comments pass.** The Standards axis catches smells, not comments that restate
   the code beneath them.
7. **Security review.** Nothing looks at a diff adversarially.
8. **Cleanup.** Nothing closes or removes what a run created.

## Install

```
/plugin marketplace add /Users/junayed/Developer/Personal/superlayzer/grill-to-pr
/plugin install grill-to-pr@grill-to-pr
```
