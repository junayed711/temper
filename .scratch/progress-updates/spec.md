---
status: ready-for-agent
---

# Progress updates across a temper run

## Problem Statement

While a temper run works, the user can't tell what it is doing. The quality gates
run with no sign that they have started, the review panel's reviewers report into
the conversation but nothing is said until the final verdict, and the Superpowers
build loop works through a plan's tasks in silence. The user ends up asking for
updates again and again to find out whether anything is happening, how far along
the run is, and what came back.

## Solution

Every temper run that does long work posts short, one-line progress updates as it
goes, without being asked. A single shared progress rule says when a line is posted
and what it looks like; the commands switch it on at their first step, and every
skill they load afterwards follows it because it runs in the same conversation. The
Superpowers parts of a run — the build loop in `/temper:feature` and root-cause
debugging in `/temper:bug` — are told to report in the same way, through the places
temper already uses to steer them.

A check run, for example, reads:

```
check: gates — running claude plugin validate .
check: gates — pass (4s)
check: panel — 3 reviewers out (security not run: no risky paths)
check: panel — comments reported: 1 blocking
check: panel — standards + spec reported: clean
check: fixes — round 1, fixing 1 finding
check: gates — pass (3s)
check: verdict — clean
```

## User Stories

1. As a temper user, I want a line when the gates start running, so that I know the run hasn't stalled.
2. As a temper user, I want each gate's result posted with how long it took, so that I can see pass or fail without waiting for the verdict.
3. As a temper user, I want a line when the review panel goes out, naming how many reviewers were sent, so that I know the review has begun.
4. As a temper user, I want to be told when the security seat is not run and why, so that its absence isn't a surprise at the verdict.
5. As a temper user, I want a line as each reviewer reports, with whether it found anything blocking, so that I can follow the panel as it happens.
6. As a temper user, I want a line when a fix round starts, saying how many findings it is fixing, so that I understand why the run is still going.
7. As a temper user, I want a line when the verdict is reached, so that I know the check has ended and how.
8. As a temper user running `/temper:feature build`, I want a line as each plan task starts, so that I know which part is being built.
9. As a temper user running `/temper:feature build`, I want a line when each task's review comes back, so that I can see whether it passed.
10. As a temper user running `/temper:feature build`, I want a line when a task is being fixed after review, so that I know why it hasn't moved on.
11. As a temper user running `/temper:feature build`, I want task lines to carry their position (task 2/5), so that I can tell how far through the build is.
12. As a temper user running `/temper:bug`, I want a line for each cause tested during debugging, so that I can follow the investigation.
13. As a temper user running `/temper:bug`, I want a line for each fix attempted, so that I know how many attempts have been made.
14. As a temper user running `/temper:refactor` or an `/temper:overhaul` ticket, I want lines as the baseline gates run and as each reshape step goes green, so that a long refactor is visible.
15. As a temper user running `/temper:review`, I want the same check lines, so that a review-only run is as visible as a build.
16. As a temper user, I want a line when the pull request is being opened and when it is up, so that I know the run has finished.
17. As a temper user, I want a line when a run stops early, saying why, so that I don't mistake a stop for a stall.
18. As a temper user, I want quick steps — reading config, checking the branch name — to post nothing, so that the updates stay short.
19. As a temper user, I want no repeated "still running" lines while something slow runs, so that the conversation isn't filled with noise.
20. As a temper user, I want every line to share one shape, `<phase>: <step> — <what>`, so that I can scan them at a glance.
21. As a temper maintainer, I want the progress rule written once, so that changing its format is a single edit.
22. As a temper maintainer, I want new steps in existing skills to report without extra wording, so that a new step can't forget to.
23. As a temper maintainer, I want the build loop's reporting instruction to live in the plan's pinned section, so that it survives a session compacting.

## Implementation Decisions

- A new `progress` skill holds the whole rule: the line shape, the three moments a line is posted, and what gets no line. It is a skill so a command can load it by name like any other.
- The three moments: a slow step starts (gates, the panel, a build task, a fix round, a baseline, a reshape step, opening the pull request); anything comes back (each gate result with its duration, each reviewer, each task, each fix); the run stops or finishes. Quick steps post nothing, and nothing repeats while waiting.
- Line shape: `<phase>: <step> — <what's happening>`, where phase is the skill or command part doing the work (`check`, `build`, `debug`, `baseline`, `reshape`, `finish`).
- `feature`, `bug`, `refactor`, `overhaul` and `review` load the `progress` skill in their first step. `check`, `finish`, `baseline` and `reshape` are not changed: they are loaded later in the same conversation and follow the rule from there.
- `setup` and `cleanup` do not load it; they are short and interactive.
- `feature`'s pinned "Handing back to temper" plan section gains one sentence telling the build loop to post a line as each task starts, as its review comes back, and as it is fixed, in the rule's shape. The pinned section is the place a recovering session is pointed to, so the instruction survives compaction.
- `bug`'s root-cause step gains one sentence telling it to post a line for each cause tested and each fix attempted. Debugging runs in the main conversation, so this needs no plan file.
- This replaces no existing behaviour: no temper skill reports progress today.

## Testing Decisions

- A good test checks what the user sees — progress lines appearing during a run — not the wording inside a skill file.
- The repo has no test suite. The gate `claude plugin validate .` must pass, which confirms the plugin, including the new `progress` skill, still loads.
- Acceptance is a real temper run after merge: `/temper:review` on any branch is the cheapest. It passes when the check posts its gate, panel and verdict lines without the user asking. The pull request lists this as an acceptance step.
- No prior art: this is the first behaviour in the repo checked by a run rather than by the gate alone.

## Out of Scope

- Running gates in separate agents, one agent per gate type, or in parallel.
- Writing gate output to log files.
- Periodic "still running" updates while a slow step runs.
- Changing any Superpowers or mattpocock skill; temper only steers them through its own files.
- Progress lines in `setup` and `cleanup`.

## Further Notes

Running gates in agents, typed gates and gate log files were considered and set
aside on 2026-09-30; this work addresses the visibility problem the user actually
reported without them.
