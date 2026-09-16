---
description: "Reshape existing code without changing what it does."
argument-hint: "<what should change shape>"
---

The same behaviour in a different shape: $ARGUMENTS

Load each skill named below and follow it. Do not restate its method here.

## 1. Baseline, before anything else

Run the repo's **Gates** in full, caching off, and keep the verbatim output. A
refactor is proved by a suite that passed before and passes after, so a red
baseline ends this here — say which commands failed and stop.

This runs before the grill. It is read-only, and it costs the user nothing to
learn early that the work cannot be proved.

## 2. Grill

Load `mattpocock-skills:grilling`. Settle the seam and the order callers move in.
For the vocabulary — module, interface, depth, seam — load
`mattpocock-skills:codebase-design` as a reference.

If the grill stalls on a fact nobody in the room has — what a library actually
does, what an API really returns — load `mattpocock-skills:research` and settle
it before going on. Don't guess, and don't research what the grill hasn't asked
for.

## 3. Size the blast radius

Ask how far the change reaches.

- **Narrow** — one seam, callers countable. Go to step 4.
- **Wide** — a mechanical change fanning across the codebase, where no single
  slice lands green. Hand over: tell the user to run `/to-tickets`, which
  sequences a wide refactor as expand, migrate in batches, contract. Then stop
  and wait for `/temper:feature build`.

## 4. Move it

Add the new form beside the old, migrate callers, then delete the old form.
Gates stay green at every step, not only at the end.

New tests are for behaviour the move exposed that nothing covered. The proof
that behaviour is unchanged is the baseline, not a new assertion.

## 5. Finish

Load the `temper:finish` skill and follow it. Give it the baseline output:
every test that passed then must pass now.
