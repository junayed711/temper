# Skill routing in temper runs — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Every temper run that writes code loads the skills that fit it, when writing and when reviewing, with everything settled before the start line and nothing about skills stopping a run after it.

**Architecture:** One new shared skill, `temper:skill-routing`, holds every rule once: the Skills field, the installed check, the skill list shown at the start line, the writer's instruction, the reviewer's instruction, and what to record. Every command and skill that needs one of those rules loads it and names the section — the same pattern as `temper:progress`. Nothing existing is removed; each change adds a line or a step beside what's there.

**Tech Stack:** Claude Code plugin — markdown commands (`commands/*.md`) and skills (`skills/*/SKILL.md`) with YAML frontmatter. No code, no test suite.

**Spec:** `.scratch/build-code-quality/spec.md`

## Global Constraints

- The only gate is `claude plugin validate .`; it must pass after every commit.
- Commits: subject line only, with no body and no trailer (not even Co-Authored-By); lowercase, at most 80 characters, saying what changed; one logical change per commit.
- Purely additive: every existing step, gate, stop and rule keeps working as it does today. Don't delete or reword existing instructions except where a task says to.
- Write like the surrounding files: short plain sentences, numbered `## N.` steps, each step ending in a `Done when …` line; second person; no "comprehensive", "robust", "seamless".
- The new skill is named exactly `skill-routing` (loaded as `temper:skill-routing`), at `skills/skill-routing/SKILL.md`.
- The Skills field's exact shape: `- Skills: <glob> (<skill>); <glob> (<skill>)`, or `- Skills: none`. A `.claude/temper.md` with no Skills line is treated as `Skills: none`.
- The only point a run may stop for a skill is a declared skill not installed, found before the start line. After the start line nothing about skills stops a run.
- Version goes from `0.8.2` to `0.9.0`.

## Review Focus

1. A repo set up before this change — `.claude/temper.md` has no Skills line — must pass `start`'s readiness check and run exactly as before (Task 2).
2. `Skills: none` — no installed check fails, the skill list still shows the skills the session picks itself (Tasks 1, 2).
3. A declared skill uninstalled after the start line — writers and `check` carry on and record it; nothing stops (Tasks 1, 5).
4. A Standards finding that comes from a skill rule and survives two fix rounds doesn't end the check; any other finding that survives two rounds still does (Task 5).
5. `/temper:review` with a declared skill missing reports it under "Not checked" and still gives a verdict (Tasks 1, 5).

---

## Handing back to temper

This plan runs inside a temper run. When every task is complete and the final
whole-branch review is clean, end with your list of rulings and hand control back
to `/temper:feature`, which checks the branch and opens the pull request. temper's
finish takes the place of `superpowers:finishing-a-development-branch` here.

While it runs, post a progress line as each task starts, as its review comes back,
and as each fix starts, in the shape `build: task <n>/<total> — <what>`.

---

### Task 1: The shared `skill-routing` skill

**Files:**
- Create: `skills/skill-routing/SKILL.md`

**Interfaces:**
- Produces: the skill `temper:skill-routing`, with these `##` sections that later tasks name exactly: `The Skills field`, `Installed`, `The skill list`, `Writing`, `Reviewing`, `What to record`.

- [ ] **Step 1: Write the check that fails**

Run: `grep -c '^## ' skills/skill-routing/SKILL.md`
Expected: fails — no such file.

- [ ] **Step 2: Write `skills/skill-routing/SKILL.md`**

Frontmatter: `name: skill-routing`, and `description: "Chooses the skills a temper run writes and reviews code with: the repo's declared skills, plus those that fit the language, packages and change. Load when a temper command or skill tells you to."`

Opening: one short paragraph — the skills that fit the work are loaded when code is written and when it's reviewed; the caller names the section it needs.

Sections, each a few lines in the house style:

- `## The Skills field` — the line in `.claude/temper.md`, shape `- Skills: <glob> (<skill>); …` or `none`; no line at all reads as `none`. A declared skill **applies** to a file its glob matches.
- `## Installed` — "installed" means the skill is in the session's list of available skills. Check every skill the field names. Return each missing one, with its fix: install it, or edit the field. This section never decides whether to stop; the caller does.
- `## The skill list` — given the spec (and, for a feature, the plan's tasks): for each task (or the whole run, outside a feature), the declared skills whose globs match the files it names, plus installed skills that fit its language, packages, context and kind of change, picked from the spec and task. Show it as one line per task: `Task N: <skill>, <skill> (declared: <skill>)`. Mark any declared skill that isn't installed as `missing`.
- `## Writing` — before writing code or tests: load every skill on the agreed list for this work, every declared skill whose glob matches a file you touch, and any further installed skill that fits what you find as you go. Write the code and its tests following them. A skill that turns out not to be available is skipped: carry on as you would without it, and note it — never stop for a skill. Report every skill you loaded and every one you skipped.
- `## Reviewing` — choose skills from the diff yourself; don't take the writer's list. Add every declared skill whose glob matches a changed file. Judge the code and its tests against each. A finding from a skill names the skill and the rule. A declared skill not installed is reported under "Not checked", never a stop.
- `## What to record` — for the pull request: the skills writers loaded, the skills reviewers loaded, the ones reviewers loaded that writers didn't (the gap), skills skipped as unavailable, and unresolved skill findings.

- [ ] **Step 3: Run the checks**

Run: `grep '^## ' skills/skill-routing/SKILL.md`
Expected: exactly the six section headings above, in that order.

Run: `claude plugin validate .`
Expected: passes.

- [ ] **Step 4: Commit**

```bash
git add skills/skill-routing/SKILL.md
git commit -m "add skill-routing skill for choosing skills to write and review with"
```

---

### Task 2: Declare skills in setup, check them in start

**Files:**
- Modify: `commands/setup.md` (section `## 3. .claude/temper.md`)
- Modify: `skills/start/SKILL.md` (section `## 1. Check the repo is ready`)

**Interfaces:**
- Consumes: `temper:skill-routing` sections `The Skills field` and `Installed` (Task 1).

- [ ] **Step 1: Write the check that fails**

Run: `grep -n 'Skills' commands/setup.md skills/start/SKILL.md`
Expected: no match for a Skills field.

- [ ] **Step 2: Setup proposes the field**

In `commands/setup.md` step 3, add a **Skills** bullet to the list of fields worked out from the repo: the languages and file types the repo uses, matched against the skills installed in this session; only skills that are installed; `none` when nothing fits. Add `- Skills: <glob> (<skill>); <glob> (<skill>)` as the last line of the proposed file's shape block. The existing "show the differences field by field" rule covers re-runs; leave it.

- [ ] **Step 3: Start checks the declared skills**

In `skills/start/SKILL.md` step 1, change "Check all four" to "Check all five", and add a fifth bullet:

- **Declared skills installed** — load `temper:skill-routing` and follow `Installed`. A `.claude/temper.md` with no Skills line passes. Fix: install each missing skill, or edit the Skills line.

Update the Done line to "all five pass".

- [ ] **Step 4: Run the checks**

Run: `grep -n 'Skills' commands/setup.md skills/start/SKILL.md`
Expected: the new field in setup's list and shape block; the fifth check in start.

Run: `grep -n 'all five' skills/start/SKILL.md`
Expected: two matches (the instruction and the Done line).

Run: `claude plugin validate .`
Expected: passes.

- [ ] **Step 5: Commit**

```bash
git add commands/setup.md skills/start/SKILL.md
git commit -m "propose a skills field in setup and check declared skills in start"
```

---

### Task 3: Skills in the feature build

**Files:**
- Modify: `commands/feature.md` (sections `### B1`, `### B3`, `### B4`)

**Interfaces:**
- Consumes: `temper:skill-routing` sections `Installed`, `The skill list`, `Writing`, `Reviewing`, `What to record` (Task 1).

- [ ] **Step 1: Write the check that fails**

Run: `grep -c 'skill-routing' commands/feature.md`
Expected: `0`.

- [ ] **Step 2: B1 checks again**

In B1, after the spec is found and before it's committed, add: load `temper:skill-routing` and follow `Installed`. If a declared skill is missing, name it and its fix, and stop — no plan has been written and no code changed.

- [ ] **Step 3: B3 pins the skills rule**

Append to the `## Handing back to temper` block that B3 pins (inside the same fenced markdown), a paragraph:

> Every implementer dispatch tells the implementer to load `temper:skill-routing` and follow `Writing`, with its task's line from the skill list below. Every task-reviewer dispatch tells the reviewer to load `temper:skill-routing` and follow `Reviewing`. Neither may stop the build over a skill. Your final list of rulings includes, per task, the skills the implementer loaded and skipped and the skills its reviewer loaded.

and below it a `### Skills` heading holding the agreed skill list (filled in at B4).

Keep the existing paragraph explaining why the rule lives in the plan.

- [ ] **Step 4: B4 shows the skill list**

In B4, before asking the start-line question: load `temper:skill-routing` and follow `The skill list`, against the spec and the plan's tasks. Show it below the tasks. If a declared skill is `missing`, say so: the user installs it or edits the Skills line, and the list is worked out again — this is the last point a run stops for a skill. Changes the user asks for go into the list too. Once they say go, write the agreed list under the plan's `### Skills` heading and commit the plan, following the Commits field.

- [ ] **Step 5: Run the checks**

Run: `grep -n 'skill-routing' commands/feature.md`
Expected: matches in B1, the B3 pinned block, and B4.

Run: `claude plugin validate .`
Expected: passes.

- [ ] **Step 6: Commit**

```bash
git add commands/feature.md
git commit -m "route skills through the feature build and show them at the start line"
```

---

### Task 4: Skills in bug, refactor and overhaul

**Files:**
- Modify: `commands/bug.md` (sections `## 3. The start line`, `## 4. Root cause, then the fix`)
- Modify: `skills/reshape/SKILL.md` (sections `## 2. The start line`, `## 3. Move it in steps`)

**Interfaces:**
- Consumes: `temper:skill-routing` sections `The skill list`, `Writing`, `What to record` (Task 1).

- [ ] **Step 1: Write the check that fails**

Run: `grep -c 'skill-routing' commands/bug.md skills/reshape/SKILL.md`
Expected: `0` for each.

- [ ] **Step 2: Bug**

In bug step 3, before the start-line sentence: load `temper:skill-routing`, follow `The skill list` against the spec, and show the list. A `missing` declared skill is settled here (install it or edit the Skills line), the last point the run stops for a skill. Then the start line.

In bug step 4, before systematic debugging is loaded: follow `Writing` from `temper:skill-routing` with the agreed list, for the failing test and the fix. Keep the skills loaded and skipped with the root cause, for the pull request.

- [ ] **Step 3: Refactor and overhaul, through reshape**

Both refactor and overhaul reach their start line inside `temper:reshape` step 2, so the change goes there once. In `skills/reshape/SKILL.md` step 2, before the start-line sentence: load `temper:skill-routing`, follow `The skill list` against the spec, and show the list; a `missing` declared skill is settled here, the last point the run stops for a skill.

In reshape step 3, before the first move: follow `Writing` with the agreed list for every step, including tests the step adds. Note the skills loaded and skipped with the decisions for the pull request.

`commands/refactor.md` and `commands/overhaul.md` need no change: they load `temper:reshape`. Leave them as they are.

- [ ] **Step 4: Run the checks**

Run: `grep -n 'skill-routing' commands/bug.md skills/reshape/SKILL.md`
Expected: two matches in each (the list at the start line, and `Writing`).

Run: `claude plugin validate .`
Expected: passes.

- [ ] **Step 5: Commit**

```bash
git add commands/bug.md skills/reshape/SKILL.md
git commit -m "route skills through bug fixes and reshape steps"
```

---

### Task 5: Skills in check and finish

**Files:**
- Modify: `skills/check/SKILL.md` (sections `## 2. The review panel`, `## 3. Fixes`, `## 5. The verdict`)
- Modify: `skills/finish/SKILL.md` (sections `## What the caller gives you`, `## 1. Write the description`)

**Interfaces:**
- Consumes: `temper:skill-routing` sections `Reviewing`, `What to record` (Task 1).

- [ ] **Step 1: Write the check that fails**

Run: `grep -c 'skill-routing' skills/check/SKILL.md skills/finish/SKILL.md`
Expected: `0` for each.

- [ ] **Step 2: The Standards seat**

In check step 2, below the seat table, add: before `code-review` runs, load `temper:skill-routing` and follow `Reviewing` against the diff; give `code-review` each chosen skill's file as an extra standards source. A rule of one of those skills, broken, is a documented rule broken — blocking, with the skill named. A declared skill that isn't installed is noted under "Not checked", in both modes; the check carries on. Leave the table's rows as they are.

- [ ] **Step 3: The two-round rule**

In check step 3, after "When the same finding survives two rounds, the check ends **not clean**…", add: the exception is a Standards finding from a skill's rule. When one survives two rounds, it stops blocking: record it as an **unresolved skill finding**, and the check carries on. Every other finding keeps the two-round rule.

- [ ] **Step 4: The verdict**

In check step 5's verdict block, add two lines after `- Standards: <outcome>`:

```
- Skills: <skills the Standards seat used> | none
- Unresolved skill findings: <finding — skill, location> … | none
```

Add one sentence after the "Clean only when…" list: unresolved skill findings don't stop a verdict being clean; they're reported first after Security not run.

- [ ] **Step 5: Finish**

In finish's `What the caller gives you`, add a bullet: the **skills** the writers loaded and skipped (for a feature, from the build loop's rulings; otherwise the caller's notes).

In the description template's Details, after **Rulings**, add: `**Skills**: what the writers loaded, what the reviewers loaded, the gap between them, and any skipped as unavailable — as `temper:skill-routing`'s `What to record` lists.`

In the Heads up paragraph, after "A security pass that didn't run on a risky path comes first.", add: "Then each unresolved skill finding from the verdict."

- [ ] **Step 6: Run the checks**

Run: `grep -n 'skill-routing\|unresolved skill finding' skills/check/SKILL.md skills/finish/SKILL.md`
Expected: matches in check steps 2, 3 and 5, and finish's inputs, Details and Heads up.

Run: `claude plugin validate .`
Expected: passes.

- [ ] **Step 7: Commit**

```bash
git add skills/check/SKILL.md skills/finish/SKILL.md
git commit -m "review against routed skills in check and record them in the pull request"
```

---

### Task 6: README and version

**Files:**
- Modify: `README.md`
- Modify: `.claude-plugin/plugin.json`

**Interfaces:**
- Consumes: the behaviour from Tasks 1–5.

- [ ] **Step 1: Write the check that fails**

Run: `grep -c 'Skills:' README.md; grep '"version"' .claude-plugin/plugin.json`
Expected: `0`; `"version": "0.8.2"`.

- [ ] **Step 2: README**

- `## How it's put together`: add `skill-routing` to the temper row's skills.
- `## Set up a repo`: add a `- Skills: …` line to the example `temper.md` block, and one sentence on what it does and that setup only proposes installed skills.
- `### The start line` (under How to use it): one sentence that the start line also shows the skills the run will use, and a declared skill not installed is settled there.
- `### When a run stops`: one bullet — a declared skill isn't installed, found before the start line; nothing about skills stops a run after it.
- `### check` under The shared ending: one sentence in step 2 on the Standards seat reviewing against routed skills; one in step 3 on unresolved skill findings not stopping the run.
- `### finish`: mention the Skills part of Details.
- `## Design decisions`: one bullet — **The writer picks its skills, and so does the reviewer, separately**, so a reviewer can catch a skill the writer missed; skills never stop a run after the start line.
- `## Not yet proven`: one item — Superpowers' controller passes the skills instruction to every implementer and task reviewer from the plan.
- `## Files`: add `skill-routing/` under `skills/`.

- [ ] **Step 3: Version**

In `.claude-plugin/plugin.json`, set `"version": "0.9.0"`.

- [ ] **Step 4: Run the checks**

Run: `grep -n 'skill-routing\|Skills:' README.md; grep '"version"' .claude-plugin/plugin.json`
Expected: README matches in each section listed; `"version": "0.9.0"`.

Run: `claude plugin validate .`
Expected: passes.

- [ ] **Step 5: Commit**

```bash
git add README.md .claude-plugin/plugin.json
git commit -m "document skill routing and bump version to 0.9.0"
```
