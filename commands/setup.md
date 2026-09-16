---
description: "Prepare this repo for the temper commands. Run once."
---

Three passes, in order. Don't start one until the last is done.

## 1. Are the skills temper depends on installed?

temper sequences other people's skills; it does not carry copies of them. Check
your available skills for all five:

- `mattpocock-skills:grilling`
- `mattpocock-skills:tdd`
- `mattpocock-skills:code-review`
- `mattpocock-skills:diagnosing-bugs`
- `mattpocock-skills:codebase-design`

If any is missing, stop and tell the user to run these, then start again:

```
/plugin marketplace add mattpocock/skills
/plugin install mattpocock-skills@mattpocock
```

Say which ones were missing. A Claude Code plugin cannot declare a dependency on
another, so nothing installs these for you — and a temper command that loads a
skill which isn't there will improvise the method rather than fail, which is
worse than stopping here.

## 2. Matt's per-repo setup

`to-spec`, `to-tickets` and `code-review` all read `docs/agents/issue-tracker.md`.
If that file exists, say so and go to pass 3.

If it doesn't, tell the user to run `/setup-matt-pocock-skills` and stop. It is
theirs to run; you cannot run it for them.

## 3. What temper itself needs

Explore the repo, then propose a `## temper` section for its `CLAUDE.md` or
`AGENTS.md` — whichever it already uses. Lead with what you found so the user can
accept it in a word.

- **Gates** — the commands that must pass before work is proposed, in the order
  they should run. Read the package scripts and CI workflows rather than guessing.
- **Risky paths** — globs where a change earns a security review: auth, money,
  migrations, crypto, anything append-only. Name the skill or doc that says what
  each one protects, or `none` if the repo has none to protect.
- **Verify** — the command or skill that proves the app actually runs, or `none`.
- **Commits** — the repo's commit message rules, or `none`.

Write it only once the user has confirmed it.
