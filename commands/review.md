---
description: "Review work that already exists, with the gates and a verification run around it."
argument-hint: "[fixed point — a commit, branch or tag; default: the merge-base with the default branch]"
---

Work that already exists. Nothing is built here: $ARGUMENTS

The review itself is `mattpocock-skills:code-review`. This command exists to put
the repo's gates and its verification run either side of it, and to stop rather
than propose.

## 1. Fixed point

Whatever the user passed. With no argument, the merge-base with the default
branch. Confirm it resolves and the diff isn't empty before going further.

## 2. Follow `finish`

Load the `temper:finish` skill and follow steps 1 to 4, then its review-only
ending. Tell it the fixed point.

Do not commit, and do not open a pull request. The work is the user's; this says
what state it is in.
