---
description: "Take new behaviour from a rough idea to a pull request."
argument-hint: "<what you want to build> | build"
---

Behaviour that does not exist yet: $ARGUMENTS

Load each skill named below and follow it. Do not restate its method here.

With the argument `build`, skip to step 3 — the user has been through `/to-spec`
and `/to-tickets` and approved the tickets.

## 1. Grill

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
2. Review the spec until a round ends with no comments.
3. `/to-tickets`.
4. Come back with `/temper:feature build`.

## 3. Build

Work the tickets in blocker order, one at a time. For each, load
`mattpocock-skills:tdd` and follow its loop: one seam, one failing test, the
least code that passes it.

Do not widen a ticket. Work the spec asked for but no ticket covers is a finding
for the user, not extra code.

## 4. Finish

Load the `temper:finish` skill and follow it.
