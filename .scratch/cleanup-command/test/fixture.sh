#!/usr/bin/env bash
# Builds a throwaway project with a bare local origin and one temper
# worktree or branch per cleanup state, plus a stub gh in <new dir>/bin for the
# run with PR checks on. Usage: fixture.sh <new dir>
set -euo pipefail
T="${1:?usage: fixture.sh <new dir>}"
HERE="$(cd "$(dirname "$0")" && pwd)"
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

# landed
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

git worktree add -q --detach "$W/detached"

# stray: a branch whose rename never happened, no worktree
git branch worktree-stray

# unusual: a valid git ref with shell metacharacters; must stay Live, untouched
git worktree add -q -b 'feat/x;echo${IFS}pwned' "$W/unusual"

# not temper's: must never be listed or touched
git switch -q -c scratch/foo
echo f > f
git add f
git commit -qm foo
git switch -q main

# closed: pushed, its PR closed without merging, then its folder deleted by hand
git worktree add -q -b feat/closed "$W/closed"
echo c > "$W/closed/c"
git -C "$W/closed" add c
git -C "$W/closed" commit -qm closed
git -C "$W/closed" push -q origin feat/closed
rm -rf "$W/closed"

# review: pushed, its PR still open
git worktree add -q -b feat/review "$W/review"
echo r > "$W/review/r"
git -C "$W/review" add r
git -C "$W/review" commit -qm review
git -C "$W/review" push -q origin feat/review

# autodeleted: squash-merged by PR, remote branch and its tracking ref long gone
git switch -q -c fix/autodeleted
echo x > x
git add x
git commit -qm autodeleted
git push -q origin fix/autodeleted
git switch -q main
git merge -q --squash fix/autodeleted
git commit -qm "squash fix/autodeleted"
git push -q origin main
git push -q origin --delete fix/autodeleted

# lostwork: detached, with a commit that exists nowhere else, folder deleted
git worktree add -q --detach "$W/lostwork"
echo l > "$W/lostwork/l"
git -C "$W/lostwork" add l
git -C "$W/lostwork" commit -qm lostwork
git -C "$W/lostwork" rev-parse HEAD > "$T/lostwork-sha.txt"
rm -rf "$W/lostwork"

# other: under .claude/worktrees/ but on a branch temper didn't make
git worktree add -q -b scratch/other "$W/other"

# elsewhere: a temper branch checked out in a worktree outside .claude/worktrees/
git worktree add -q -b feat/elsewhere "$T/elsewhere"

# GitHub deleted fix/squashed's branch after the merge; this clone prunes on fetch
git -C "$T/origin.git" update-ref -d refs/heads/fix/squashed
git config fetch.prune true
# the clone was of an empty origin, so set origin/HEAD now, as a fetch would
git remote set-head origin main

mkdir -p "$T/bin"
cp "$HERE/gh" "$T/bin/gh"
chmod +x "$T/bin/gh"
{
  echo "fix/squashed merged $(git rev-parse fix/squashed)"
  echo "fix/autodeleted merged $(git rev-parse fix/autodeleted)"
  # the parent, not the tip, so the headRefOid mismatch keeps this item Live despite the merged PR
  echo "refactor/unpushed merged $(git rev-parse refactor/unpushed^)"
  echo "feat/closed closed $(git rev-parse feat/closed)"
  echo "feat/review open $(git rev-parse feat/review)"
} > "$T/bin/prs.txt"

git -C "$T/origin.git" for-each-ref --format='%(refname) %(objectname)' > "$T/remote-before.txt"
git for-each-ref --format='%(refname) %(objectname)' refs/remotes > "$T/tracking-before.txt"
echo "fixture ready: $T/proj (for PR checks on, put $T/bin first on PATH)"
