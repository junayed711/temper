---
description: "Take new behaviour from a rough idea to a pull request."
argument-hint: "<what you want to build> | build"
---

Behaviour that does not exist yet: $ARGUMENTS

Load each skill named below and follow it. Do not restate its method here.

With the argument `build`, skip to step 3 — the user has been through `/to-spec`
and `/to-tickets` and approved the tickets.

## 1. Grill

Before the first question, read the part of the codebase the ask touches —
load `pstack:how`. `grilling` dispatches sub-agents for facts a question needs,
but it can only do that once the question exists; this is what makes the first
round concrete instead of generic.

Load `mattpocock-skills:grilling` and grill until the user confirms you share an
understanding.

If the grill stalls on a fact nobody in the room has — what a library actually
does, what an API really returns — load `mattpocock-skills:research` and settle
it before going on. Don't guess, and don't research what the grill hasn't asked
for.

Ask what existing behaviour this replaces. If it replaces any, the old
behaviour's tests must go when the new ones arrive — say so now, while there is
still someone to say it to.

## 2. Hand over

`to-spec` and `to-tickets` are the user's to run; you cannot run them. Tell them,
in this order, then stop:

1. `/to-spec`.
2. `/to-tickets`.
3. Come back with `/temper:feature build`.

That return is the **start line**. From it until the pull request, ask nothing —
no checkpoint, no clarification, no confirmation. A question that surfaces after
it is one the grill missed, and it stops the run rather than interrupting the
user.

## 3. Build

Work the tickets in blocker order, one at a time. For each, load
`mattpocock-skills:tdd` and follow its loop: one seam, one failing test, the
least code that passes it.

Do not widen a ticket. Work the spec asked for but no ticket covers is a finding
for the user, not extra code.

**If a ticket fails, stop and say where you got to**: which ticket failed, the
command and its verbatim output, which tickets are committed, and which are
untouched. A run that halts without that leaves the user reconstructing it by
hand.

## 4. Finish

Load the `temper:finish` skill and follow it.
