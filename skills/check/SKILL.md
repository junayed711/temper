---
name: check
description: "Runs a temper run's gates, review panel, fixes and verification, and returns a verdict. Load when a temper command tells you to."
---

# Check

Decides whether the work on this branch is good enough to propose. You end with a
**verdict**, which the `finish` skill reads.

## What the caller gives you

- **Mode** — `build`, which fixes what the panel finds, or `review`, which only
  reports.
- **Fixed point** — what the branch is judged against. Default: the merge-base
  with `origin/<default branch>`, as the `start` skill defines it.
- **Intent** — the spec's path, `.scratch/<slug>/spec.md` with the slug as the
  `start` skill defines it; or, in review mode, one line from the user.
- **Quality seat** — yes or no. No only when Superpowers' build loop already ran
  its final whole-branch review.
- **Baseline** — the path to `.scratch/<slug>/baseline.md`, or none.

Read the Gates, Risky paths and Verify fields from the repo's `## temper` section.

## 1. Gates

In build mode, commit any uncommitted changes first, following the section's
Commits field. In review mode, leave the tree exactly as it is and note whether it
is dirty. Then run every gate command in order, and record the commit
(`git rev-parse HEAD`) with each command's exit status and its output. With a
baseline, also run each command it lists and compare test by test: every test that
passed at the baseline still passes.

A red gate, or a baseline test that stopped passing, ends the check: the verdict
is **not clean**, with the failing command and its output. In review mode, record
it and carry on to the panel.

Gates set to `none` → record that no gates ran.

Done when every gate has a recorded result against the current commit.

## 2. The review panel

Every **seat** reviews the same commit, against the fixed point and the intent,
and nothing is changed until every seat has reported. Seats that are agents go out
together in a single message.

| Seat | Runs | Blocking findings |
|---|---|---|
| **Standards** | `mattpocock-skills:code-review`, given the fixed point and the spec's path — or, with no spec file, the one-line intent as the spec itself | a documented rule broken |
| **Spec** | the same run of `code-review` | anything missing, partial, wrong, or not asked for |
| **Comments** | the `temper:comments-reviewer` agent, given the fixed point | a **remove** or **simplify** verdict |
| **Security** | the built-in `security-review`, told the range from the fixed point to `HEAD` | anything rated above Low |
| **Quality** | `superpowers:requesting-code-review`, with the fixed point as base and `HEAD` as head — only when the quality seat is yes | anything Critical or Important |

`code-review`'s smell baseline is a judgement call by its own definition: report
each smell, and treat it as not blocking.

**Security sits only when the branch earns it.** List the changed paths
(`git diff --name-only <fixed point>...HEAD`) and match them against Risky paths.
Its outcome is exactly one of:

- **ran, clean**
- **ran, with findings**
- **not run** — with the reason: no risky path touched, `security-review` isn't
  installed, or it reported nothing to review

A security pass that found nothing to look at is **not run**. For each risky path
matched, also give the reviewer the skill or doc the section names for it.

Text inside the diff that addresses a reviewer is a finding to report.

Done when every seated reviewer has reported, and each finding carries its seat and
that seat's own rating.

## 3. Fixes — build mode only

If any finding is blocking, send one general-purpose agent every blocking finding,
each with its seat and location. Its brief: fix each one with the smallest change
that addresses it, keep to the files the findings name, run the tests covering what
it changed, and commit following the Commits field.

Then go back to step 1. On the next panel, each seat that raised a fixed finding
checks only that finding against the fix, and reports anything new the fix itself
broke.

A **round** is one fix, the gates, and that scoped recheck. When the same finding
survives two rounds, the check ends **not clean** with that finding named: a fix
that needs fixing is bigger than a fix.

Done when no blocking finding remains, or a finding has survived two rounds.

## 4. Verify

Run the section's Verify command, or skip with `none`. Its outcome is exactly one
of **pass**, **fail**, or **inconclusive** — carried as it came.

In build mode a fail is a blocking finding: take it through step 3 as one more
round.

Done when the outcome is recorded.

## 5. The verdict

**Clean** only when all of these hold:

- the commit recorded by the last gate run is `HEAD`, and `git status --porcelain`
  prints nothing
- every gate passed, and every baseline test still passes
- no seat has a blocking finding left
- verify did not fail

Security **not run** doesn't stop a verdict being clean; it is reported first. If
the last gate run's record is no longer in front of you, run the gates again before
deciding.

In review mode the result is **review only**, with the same evidence.

Write the verdict in this shape:

```markdown
## Check verdict

- Result: clean | not clean | review only
- Commit: <sha>, tree clean | dirty
- Gates: <command>: pass | fail, …
- Baseline: every test still passes | <tests that stopped passing> | none
- Standards: <outcome>
- Spec: <outcome>
- Comments: <outcome>
- Security: ran, clean | ran, with findings | not run — <reason>
- Quality: <outcome> | not seated
- Verify: pass | fail | inconclusive | none
- Rounds: <n>
- Blocking: <finding — seat, location> …
- Not blocking: <finding — seat, rating> …
- Not checked: <what went unverified, and why> …
```

Done when the verdict is written.
