---
name: baseline
description: "Records a refactor's before: every gate run with caching off, its output saved to the run's scratch folder. Load when a temper command tells you to."
---

# Baseline

A refactor is proved by tests that passed before and still pass after, so the
before comes first. The slug is as the `start` skill defines it.

## 1. Run the gates

Run every command in the Gates field of the repo's `.claude/temper.md`, with
caching turned off wherever the command supports it — a replayed cache hit shows
the inputs didn't change, not that the tests ran. Write each command exactly as
run, with its full output, to `.scratch/<slug>/baseline.md`. Leave it uncommitted;
the `reshape` skill commits it.

A red gate ends the run: report the failing command and its output, and that the
worktree holds only the baseline.

Done when every gate is green and `baseline.md` holds each command with its output.
