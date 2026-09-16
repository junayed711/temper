# temper

An agent pipeline that takes a rough idea to a reviewed pull request.

Tempering is the step that turns hard-but-brittle metal into something tough.
Rough work goes under heat, gets shaped, and has to prove it won't shatter before
it gets out.

temper does not reimplement the thinking. The stages are Matt Pocock's
engineering skills; this plugin sequences them, runs the project's gates between
them, and decides whether the result is good enough to propose.

## Requires

- [`mattpocock-skills`](https://github.com/mattpocock/skills) and
  [`pstack`](https://github.com/michael-denyer/pstack-claude) installed. A Claude
  Code plugin can't declare a dependency on another, so this is on you — but
  `/temper:setup` checks for both and refuses to go further if either is missing.
- `/setup-matt-pocock-skills` run once in the target repo. It writes
  `docs/agents/issue-tracker.md`, which `to-spec`, `to-tickets` and `code-review`
  all read. Without it those three stop and ask for it.

## The stages

Only `research`, `grilling`, `tdd`, `code-review`, `codebase-design` and
`diagnosing-bugs` can be invoked by an agent. The rest are yours to type, which is why `/feature`
has to stop in the middle rather than run straight through.

| # | Stage | Skill | Who runs it |
|---|-------|-------|-------------|
| 0 | Settle a fact the grill stalls on | `research` | agent |
| 1 | Sharpen the idea | `grilling` | agent or you |
| 2 | Write the spec | `/to-spec` | you |
| 3 | Break it into tickets | `/to-tickets` | you |
| 4 | Build it test-first | `tdd` | agent |
| 5 | Review it | `code-review` | agent or you |
| 6 | Diagnose a failure | `diagnosing-bugs` | agent or you |

Matt's `/implement` does stages 4 and 5 in one go, but it's typed-only, so temper
loads `tdd` directly and calls `code-review` from `finish` instead.

`/code-review` runs two sub-agents in parallel and reports them separately:
**Spec** (does the diff do what the spec asked, and only that) and **Standards**
(does it follow the repo's documented rules, plus a baseline of twelve Fowler
smells). Neither axis is allowed to mask the other.

## Commands

| Command | For |
|---------|-----|
| `/temper:setup` | Once per repo, before anything else |
| `/temper:feature` | Behaviour that doesn't exist yet |
| `/temper:bug` | Behaviour that exists and is wrong |
| `/temper:refactor` | The same behaviour in a different shape |
| `/temper:review` | Work that already exists |

The review itself is Matt's `code-review`; `/review` only wraps it in the gates
and a verification run, and stops instead of proposing.

Every command above ends by loading the `finish` skill: gates, review on two axes
with a security pass when the paths earn it, a comments pass, verification, then
either a pull request or an explanation of why there isn't one. Any fix made
along the way sends it back to the gates before anything else counts.

`/feature` stops once and hands you `/to-spec` and `/to-tickets`, because only
you can run those. `/refactor` does the same when the blast radius is wide enough
to need them. `/bug` never stops.

## What this plugin adds

Four thin commands and one skill. The thinking is Matt's; the sequencing, the
gates and the pull request are this plugin's.

## What it will add

The gaps in the chain above, in rough order of value:

1. **Parallel builds.** Tickets are worked one at a time, in one session. No
   worktrees.
2. **Resuming.** A run that stops has to be restarted by hand — the stop report
   says where it got to, but you drive it from there.

## Install

```
/plugin marketplace add /Users/junayed/Developer/Personal/superlayzer/temper
/plugin install temper@temper
```
