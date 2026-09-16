---
description: "Fix a bug test-first, from symptom to pull request."
argument-hint: "<the symptom>"
---

Behaviour that exists and is wrong: $ARGUMENTS

Load each skill named below and follow it. Do not restate its method here.

## 1. Grill, briefly

Load `mattpocock-skills:grilling`. A bug needs four answers and no more: the
symptom, what should happen instead, how to reach it, and what is out of scope.

A cause the user suspects is their hypothesis, not a finding. Record it as such.

## 2. Diagnose, only if you need to

If the cause isn't obvious from the grill, load `mattpocock-skills:diagnosing-bugs`.
If it is obvious, skip this.

## 3. Fix it test-first

Load `mattpocock-skills:tdd`. The failing test is the reproduction: write it
first, watch it fail for the right reason, then make it pass.

If the fix needs a contract change or a new module, stop. That is a feature
wearing a bug's clothes, and it needs `/temper:feature`.

## 4. Finish

Load the `temper:finish` skill and follow it.
