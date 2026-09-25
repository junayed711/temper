#!/usr/bin/env bash
# Checks the fixture project after /temper:cleanup ran with the preselected
# choice. Usage: check.sh <fixture dir>
set -uo pipefail
T="${1:?usage: check.sh <fixture dir>}"
P="$T/proj"
fail=0

want="feat/dirty feat/locked fix/squashed main refactor/unpushed scratch/foo"
got=$(git -C "$P" branch --format='%(refname:short)' | sort | tr '\n' ' ' | sed 's/ $//')
[ "$got" = "$want" ] || { echo "FAIL branches: want [$want] got [$got]"; fail=1; }

want="dirty locked squashed unpushed"
got=$(git -C "$P" worktree list --porcelain | awk '/^worktree /{print $2}' \
  | grep '/.claude/worktrees/' | xargs -n1 basename | sort | tr '\n' ' ' | sed 's/ $//')
[ "$got" = "$want" ] || { echo "FAIL worktrees: want [$want] got [$got]"; fail=1; }

if git -C "$P" worktree list --porcelain | grep -q '^prunable'; then
  echo "FAIL a prunable worktree record is left"; fail=1
fi

[ -f "$P/.claude/worktrees/dirty/d" ] || { echo "FAIL the dirty worktree's file is gone"; fail=1; }

git -C "$T/origin.git" for-each-ref --format='%(refname) %(objectname)' \
  | diff -q - "$T/remote-before.txt" >/dev/null \
  || { echo "FAIL the remote changed"; fail=1; }

[ "$fail" = 0 ] && echo "PASS"
exit "$fail"
