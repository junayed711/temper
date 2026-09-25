#!/usr/bin/env bash
# Checks the fixture project after /temper:cleanup ran and the user picked
# "Remove the N ticked". Usage: check.sh <fixture dir> <off|on>
# off: PR checks were off (no stub gh). on: the stub gh was first on PATH.
set -uo pipefail
T="${1:?usage: check.sh <fixture dir> <off|on>}"
MODE="${2:?usage: check.sh <fixture dir> <off|on>}"
P="$T/proj"
fail=0

case "$MODE" in
  off)
    want_branches="feat/closed feat/dirty feat/elsewhere feat/locked feat/review fix/autodeleted fix/squashed main refactor/unpushed scratch/foo scratch/other"
    want_worktrees="closed dirty locked lostwork other review squashed unpushed" ;;
  on)
    want_branches="feat/closed feat/dirty feat/elsewhere feat/locked feat/review main refactor/unpushed scratch/foo scratch/other"
    want_worktrees="closed dirty locked lostwork other review unpushed" ;;
  *) echo "usage: check.sh <fixture dir> <off|on>"; exit 2 ;;
esac

got=$(git -C "$P" branch --format='%(refname:short)' | sort | tr '\n' ' ' | sed 's/ $//')
[ "$got" = "$want_branches" ] || { echo "FAIL branches: want [$want_branches] got [$got]"; fail=1; }

got=$(git -C "$P" worktree list --porcelain | awk '/^worktree /{print $2}' \
  | grep '/.claude/worktrees/' | xargs -n1 basename | sort | tr '\n' ' ' | sed 's/ $//')
[ "$got" = "$want_worktrees" ] || { echo "FAIL worktrees: want [$want_worktrees] got [$got]"; fail=1; }

# Only the two folder-gone worktrees that still hold work keep their records.
got=$(git -C "$P" worktree list --porcelain | awk '/^worktree /{w=$2} /^prunable/{print w}' \
  | xargs -n1 basename | sort | tr '\n' ' ' | sed 's/ $//')
[ "$got" = "closed lostwork" ] || { echo "FAIL prunable records: want [closed lostwork] got [$got]"; fail=1; }

# lostwork's commit exists nowhere else; its worktree record must still hold it.
lost=$(cat "$T/lostwork-sha.txt")
git -C "$P" worktree list --porcelain | grep -qx "HEAD $lost" \
  || { echo "FAIL lostwork's commit is no longer held by a worktree"; fail=1; }

[ -f "$P/.claude/worktrees/dirty/d" ] || { echo "FAIL the dirty worktree's file is gone"; fail=1; }
[ -d "$T/elsewhere" ] || { echo "FAIL the worktree outside .claude/worktrees/ is gone"; fail=1; }

git -C "$T/origin.git" for-each-ref --format='%(refname) %(objectname)' \
  | diff -q - "$T/remote-before.txt" >/dev/null \
  || { echo "FAIL the remote changed"; fail=1; }

git -C "$P" for-each-ref --format='%(refname) %(objectname)' refs/remotes \
  | diff -q - "$T/tracking-before.txt" >/dev/null \
  || { echo "FAIL the remote-tracking refs changed (pruned?)"; fail=1; }

[ "$fail" = 0 ] && echo "PASS"
exit "$fail"
