---
name: skill-routing
description: "Chooses the skills a temper run writes and reviews code with: the repo's declared skills, plus those that fit the language, packages and change. Load when a temper command or skill tells you to."
---

# Skill routing

The skills that fit the work are loaded when code is written and again when it is
reviewed. The command or skill that loaded you names the section it needs; read
that one.

## The Skills field

`.claude/temper.md` declares skills on one line:

```
- Skills: <glob> (<skill>); <glob> (<skill>)
```

or `- Skills: none`. A `.claude/temper.md` with no Skills line reads as `none`.

A declared skill **applies** to a file its glob matches.

## Installed

A skill is **installed** when it is in the session's list of available skills.
Check every skill the field names. Return each one that is missing, with its fix:
install it, or edit the field.

This section never decides whether to stop. The caller does.

## The skill list

You are given the spec and, for a feature, the plan's tasks. For each task, or for
the whole run outside a feature, list:

- the declared skills whose globs match the files it names, and
- the installed skills that fit its language, packages, context and kind of
  change, picked from the spec and the task.

Show one line per task:

```
Task N: <skill>, <skill> (declared: <skill>)
```

Mark any declared skill that isn't installed as `missing`.

## Writing

Before writing code or tests, load:

- every skill on the agreed list for this work,
- every declared skill whose glob matches a file you touch, and
- any further installed skill that fits what you find as you go.

Write the code and its tests following them.

A skill that turns out not to be available is skipped: carry on as you would
without it, and note it. Never stop for a skill.

Report every skill you loaded and every one you skipped.

## Reviewing

Choose skills from the diff yourself; don't take the writer's list. Add every
declared skill whose glob matches a changed file.

Judge the code and its tests against each. A finding from a skill names the skill
and the rule.

A declared skill that isn't installed is reported under "Not checked". It never
stops the review.

## What to record

For the pull request, record:

- the skills writers loaded,
- the skills reviewers loaded,
- the ones reviewers loaded that writers didn't (the gap),
- skills skipped as unavailable, and
- unresolved skill findings.
