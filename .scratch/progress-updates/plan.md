# Progress Updates Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Every long temper run posts one-line progress updates without being asked.

**Architecture:** A new `progress` skill holds the whole rule (when to post, the line's shape, what stays quiet). Each command that does long work loads it before its first step, so every skill it loads afterwards follows it in the same conversation. The two Superpowers parts are steered through temper's own text: the plan section `feature` pins, and `bug`'s root-cause step.

**Tech Stack:** Markdown skills and commands in a Claude Code plugin. The only gate is `claude plugin validate .`.

**Spec:** `.scratch/progress-updates/spec.md`

## Handing back to temper

This plan runs inside a temper run. When every task is complete and the final
whole-branch review is clean, end with your list of rulings and hand control back
to `/temper:feature`, which checks the branch and opens the pull request. temper's
finish takes the place of `superpowers:finishing-a-development-branch` here.

## Global Constraints

- Commits: subject line only, with no body and no trailer (not even Co-Authored-By); lowercase, at most 80 characters, saying what changed; one logical change per commit, and each commit passes its gates.
- Gate: `claude plugin validate .` passes after every commit.
- Line shape: `<phase>: <step> — <what's happening>`; phases are `check`, `build`, `debug`, `baseline`, `reshape`, `finish`.
- `check`, `finish`, `baseline`, `reshape`, `start`, `setup` and `cleanup` are not changed.
- No Superpowers or mattpocock skill is changed.
- Match the surrounding prose: short plain sentences, backticked skill names like `temper:progress`, no marketing words.

## Review Focus

- A multi-part command (`feature` parts A/B, `overhaul` parts A/B/C) is re-invoked per part: the load must sit where every part reads it, not only inside part A's first step.
- Reviewers sent together finish at different times: each one's line must be posted as it arrives, not batched at the verdict.
- A run that stops early (red gate, broken build, three failed fixes) must still post a closing line saying why.
- The pinned "Handing back to temper" section must keep its existing text intact; the progress sentence is added, not substituted.
- A slow gate must not produce repeated "still running" lines.

Each of these is pinned by a grep check in the task that owns the text.

---

### Task 1: The progress skill

**Files:**
- Create: `skills/progress/SKILL.md`
- Modify: `README.md` (the skills table row around line 21, and the file tree around line 676)
- Modify: `.claude-plugin/plugin.json` (version `0.6.1` → `0.7.0`)

**Interfaces:**
- Produces: the skill `temper:progress`, which Tasks 2 and 3 name.

- [ ] **Step 1: Confirm the skill doesn't exist yet**

Run: `test -e skills/progress/SKILL.md && echo exists || echo missing`
Expected: `missing`

- [ ] **Step 2: Write the skill**

Create `skills/progress/SKILL.md` with exactly:

````markdown
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

The phase is the part of the run doing the work: `check`, `build`, `debug`,
`baseline`, `reshape` or `finish`. A check reads like this:

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
````

- [ ] **Step 3: Add it to the README**

In `README.md`, change the skills table row

```
| Gates, refactor steps, review panel, proposing | temper | `start`, `baseline`, `reshape`, `check`, `finish`, and one agent: `comments-reviewer` |
```

to

```
| Gates, refactor steps, review panel, proposing | temper | `start`, `baseline`, `reshape`, `check`, `finish`, `progress`, and one agent: `comments-reviewer` |
```

and in the file tree, after the `finish/` line, add

```
│   └── progress/            one-line updates while a run works
```

changing the `finish/` line's `└──` to `├──`.

- [ ] **Step 4: Bump the version**

In `.claude-plugin/plugin.json`, change `"version": "0.6.1"` to `"version": "0.7.0"`.

- [ ] **Step 5: Verify**

Run: `claude plugin validate .`
Expected: passes.

Run: `grep -c "as it\s*$\|arrives, not all" skills/progress/SKILL.md; grep -n "Nothing repeats\|why" skills/progress/SKILL.md`
Expected: the arrival rule, the no-repeat rule and the stop-with-why rule are all present.

- [ ] **Step 6: Commit**

```bash
git add skills/progress/SKILL.md README.md .claude-plugin/plugin.json
git commit -m "add a progress skill that posts one-line updates while a run works"
```

---

### Task 2: Commands load the progress skill

**Files:**
- Modify: `commands/feature.md`, `commands/bug.md`, `commands/refactor.md`, `commands/overhaul.md`, `commands/review.md`

**Interfaces:**
- Consumes: the skill `temper:progress` from Task 1.

The load sits in each command's opening prose, before any part or step, so every
part of a multi-part command reads it on every invocation.

- [ ] **Step 1: Confirm none load it yet**

Run: `grep -l "temper:progress" commands/*.md`
Expected: no output.

- [ ] **Step 2: Add the sentence**

Add this paragraph to each file:

```markdown
Load `temper:progress` before the first step. It keeps the user posted for the
whole run.
```

Where it goes:

- `commands/feature.md` — after the paragraph ending "what's written here is only what temper adds." and before `## Part A — shape it`.
- `commands/overhaul.md` — after the paragraph ending "The slug and the default branch are as the `start` skill defines them." and before `## The plan`.
- `commands/bug.md` — after the paragraph ending "With no symptom given, ask for one first." and before `## 1. Start`.
- `commands/refactor.md` — after the paragraph ending "With no ask given, ask what should change shape first." and before `## 1. Start`.
- `commands/review.md` — after the paragraph ending "nothing is committed, pushed or deleted." and before `## 1. Where you are`.

- [ ] **Step 3: Verify**

Run: `grep -l "temper:progress" commands/*.md`
Expected: exactly `commands/bug.md`, `commands/feature.md`, `commands/overhaul.md`, `commands/refactor.md`, `commands/review.md`.

Run: `grep -n "temper:progress\|^## " commands/feature.md commands/overhaul.md | head -20`
Expected: in both files the `temper:progress` line comes before the first `## ` heading.

Run: `claude plugin validate .`
Expected: passes.

- [ ] **Step 4: Commit**

```bash
git add commands/feature.md commands/bug.md commands/refactor.md commands/overhaul.md commands/review.md
git commit -m "load the progress skill at the start of every long temper command"
```

---

### Task 3: The Superpowers parts report too

**Files:**
- Modify: `commands/feature.md` (step B3's pinned section)
- Modify: `commands/bug.md` (step 4)

**Interfaces:**
- Consumes: the line shape and phases from Task 1 (`build`, `debug`).

- [ ] **Step 1: Extend the pinned section**

In `commands/feature.md` step B3, the fenced "Handing back to temper" section keeps
its existing paragraph unchanged and gains a second paragraph inside the same fence:

```markdown
While it runs, post a progress line as each task starts, as its review comes back,
and as each fix starts, in the shape `build: task <n>/<total> — <what>`.
```

- [ ] **Step 2: Add the debugging sentence**

In `commands/bug.md` step 4, add a new paragraph directly after the list of three
places it ends in, and before "Done when the fix is committed":

```markdown
While it works, post a progress line for each cause tested and each fix attempted,
in the shape `debug: <cause or attempt> — <result>`.
```

- [ ] **Step 3: Verify**

Run: `grep -n "This plan runs inside a temper run\|task <n>/<total>" commands/feature.md`
Expected: both lines present, the original sentence first.

Run: `grep -n "debug: <cause or attempt>" commands/bug.md`
Expected: one match, inside step 4.

Run: `claude plugin validate .`
Expected: passes.

- [ ] **Step 4: Commit**

```bash
git add commands/feature.md commands/bug.md
git commit -m "tell the build loop and bug debugging to post progress lines"
```
