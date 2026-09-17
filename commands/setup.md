---
description: "Check a repo is ready for temper and write its ## temper section. Run once per repo."
---

# temper setup

Run from the repo's main checkout. Three passes, in order. Each one ends in a
pass, or a stop that names what to fix.

## 1. Plugins and tools

Check your available skills for every one of these:

| Plugin | Skills temper loads |
|---|---|
| `mattpocock-skills` | `grilling`, `research`, `code-review`, `codebase-design` |
| `superpowers` | `writing-plans`, `subagent-driven-development`, `systematic-debugging`, `requesting-code-review`, `test-driven-development`, `verification-before-completion` |

`/to-spec` is absent from that list by design — only a person can run it — and it
ships in the same plugin as `grilling`, so finding `grilling` covers it.

If any skill is missing, stop. Name each missing one and give the install lines:

```
/plugin install mattpocock-skills@claude-plugins-official
/plugin install superpowers@claude-plugins-official
```

Then tell the user to start a new session before running setup again. temper
declares both plugins as dependencies, so a missing skill means a dependency didn't
install or was turned off — temper came from a marketplace that doesn't allow
dependencies from other marketplaces, or someone disabled one. A temper command
whose skill is missing improvises the method in its place; stopping here is what
prevents that.

Four more checks:

- **`gh auth status`** fails → stop. temper opens pull requests with `gh`.
- **`security-review`** is missing from your skills → warn, and continue. Security
  passes will be recorded as not run.
- **`claude plugin list`** shows `mattpocock-skills` installed from two
  marketplaces → warn, and continue. Recommend uninstalling the copy from
  `mattpocock`, so the same skills aren't loaded twice.
- **Any `pstack:` skill** is present → warn, and continue. pstack's session hook
  names `poteto-mode` as the entry point for all engineering work, and it competes
  with a temper run; recommend disabling pstack in repos that use temper.

Done when every skill in the table is present and `gh` is signed in.

## 2. The issue tracker

temper keeps each run's spec and plan in `.scratch/<slug>/`, committed on the
branch and deleted before the pull request. That needs Matt's local markdown
tracker, and a `.scratch/` git can see.

- **`docs/agents/issue-tracker.md`** missing → stop. The user runs
  `/setup-matt-pocock-skills` and chooses **Local markdown**.
- **The tracker it describes** keeps issues somewhere other than
  `.scratch/<feature-slug>/` → stop. Explain why temper needs local markdown, and
  that switching means running `/setup-matt-pocock-skills` again.
- **`git check-ignore -v .scratch/probe`** prints a rule → stop. Show the rule and
  the file it's in; `.scratch/` has to be committable.

Done when all three pass.

## 3. The `## temper` section

Use the root `CLAUDE.md` if it exists, otherwise `AGENTS.md`. If neither exists,
propose creating `CLAUDE.md`.

Work out each field from the repo itself:

- **Gates** — the commands the repo's CI runs to accept a change, in the order it
  runs them. Read the CI workflow files and the package scripts, `Makefile` or
  build config they call.
- **Risky paths** — globs for code where a mistake is a security or integrity
  problem: authentication, money, migrations, cryptography, anything append-only.
  For each, name the project skill under `.claude/skills/` or the doc that explains
  what it protects, or `none`.
- **Verify** — the command or project skill that proves the running application
  works end to end, beyond its tests.
- **Commits** — the repo's documented commit message rules, or the convention
  `git log` shows consistently.

Propose the whole section in exactly this shape, and for each value say where it
came from, so the user can accept it in a word:

```markdown
## temper

- Worktrees: all work happens in a worktree created from <default branch>.
- Superpowers: in temper runs, grilling and /to-spec replace brainstorming, and temper's finish replaces finishing-a-development-branch.
- Gates: <command>; <command>
- Risky paths: <glob> (<skill or doc>); <glob> (none)
- Verify: <command or skill>
- Commits: <rules>
```

Every field carries a value: a field with nothing to put in it says `none`. The
Worktrees and Superpowers lines are fixed wording; they make temper's rules
project instructions, which Claude Code and Superpowers both rank above their own
defaults.

If the section already exists, show the differences field by field and change only
what the user confirms.

Write the section once the user confirms it. Leave it uncommitted, and tell the
user to commit it through their usual process: temper commands start only from a
clean tree.

Done when the section is written and every field has a value.
