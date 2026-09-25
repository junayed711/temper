#!/usr/bin/env bash
# Builds a throwaway project with a bare local origin and one temper
# worktree or branch per cleanup state. Usage: fixture.sh <new dir>
set -euo pipefail
T="${1:?usage: fixture.sh <new dir>}"
mkdir -p "$T"
cd "$T"
git init -q --bare -b main origin.git
git clone -q origin.git proj 2>/dev/null
cd proj
git config user.email fixture@example.com
git config user.name fixture
printf '.claude/worktrees/\n' > .gitignore
echo base > README
git add .
git commit -qm base
git push -q origin main
W=.claude/worktrees

# landed: fast-forward merged into main and pushed
git worktree add -q -b feat/landed "$W/landed"
echo a > "$W/landed/a"
git -C "$W/landed" add a
git -C "$W/landed" commit -qm landed
git merge -q --ff-only feat/landed
git push -q origin main

# squashed: branch pushed, squash-merged into main; only a PR proves it landed
git worktree add -q -b fix/squashed "$W/squashed"
echo s > "$W/squashed/s"
git -C "$W/squashed" add s
git -C "$W/squashed" commit -qm squashed
git -C "$W/squashed" push -q origin fix/squashed
git merge -q --squash fix/squashed
git commit -qm "squash fix/squashed"
git push -q origin main

# empty: a run that ended in the grill
git worktree add -q -b feat/empty "$W/empty"

# dirty: an uncommitted file
git worktree add -q -b feat/dirty "$W/dirty"
echo d > "$W/dirty/d"

# unpushed: a commit that exists nowhere else
git worktree add -q -b refactor/unpushed "$W/unpushed"
echo u > "$W/unpushed/u"
git -C "$W/unpushed" add u
git -C "$W/unpushed" commit -qm unpushed

# locked: maybe in use by another session
git worktree add -q -b feat/locked "$W/locked"
git worktree lock "$W/locked"

# gone: folder deleted by hand, git still tracks it
git worktree add -q -b feat/gone "$W/gone"
rm -rf "$W/gone"

# detached: a worktree with no branch, at main
git worktree add -q --detach "$W/detached"

# stray: a branch whose rename never happened, no worktree
git branch worktree-stray

# not temper's: must never be listed or touched
git switch -q -c scratch/foo
echo f > f
git add f
git commit -qm foo
git switch -q main

git -C "$T/origin.git" for-each-ref --format='%(refname) %(objectname)' > "$T/remote-before.txt"
echo "fixture ready: $T/proj"
