---
name: progress
description: "Posts one-line progress updates while a temper run works, so the user never has to ask what's happening. Load when a temper command tells you to."
---

# Progress

A temper run keeps the user posted without being asked. The rule holds for the
whole run, across every skill the command loads.

## When to post

Post one line, on its own, at each of these moments:

- **A slow step starts** — the gates, the review panel, a build task, a fix round,
  the baseline, a reshape step, opening the pull request.
- **Anything comes back** — each gate's result with how long it took, each
  reviewer, each task's review, each fix.
- **The run stops or finishes** — and when it stops early, why.

Agents sent out together report one at a time: post each one's line as it
arrives, not all of them at the end.

Quick steps — reading config, checking the branch, naming things — post nothing.
Nothing repeats while a step runs: the line that said it started is the update
until something comes back.

## The shape

Every line has the same shape:

```
<phase>: <step> — <what's happening>
```

The phase is the part of the run doing the work, for example `check`, `build`,
`debug`, `baseline`, `reshape` or `finish`. Work outside those, such as a stop
in `start`, the grill, or overhaul part B, uses the command's name, like `bug`
or `overhaul`.

Time each gate. Note `date +%s` before the command and again after it, and
report the difference. If a duration wasn't measured, leave it out. Never
estimate one.

A check reads like this:

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
