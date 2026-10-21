# Skill routing in temper runs

## Problem Statement

When a temper run has an agent write code, the code is often not good: more of it
than the change needs, out of step with the codebase's own helpers and conventions,
poorly structured, tested against mocks rather than behaviour, and noisy with
comments. The agents that write and review it work from generic instructions. They
never reach for the skills that hold the know-how for the language, the packages or
the kind of change in front of them, even when those skills are installed, and a
repo has no way to say "these standards always apply to these files".

## Solution

Every temper run that writes code uses the skills that fit it, both when the code is
written and when it is reviewed.

- The agent writing code works out for itself which installed skills fit the
  language, packages, context and kind of change, loads them before it writes, and
  says which it loaded.
- A repo can declare skills that always apply to certain files, in a new **Skills**
  field of `.claude/temper.md`. `/temper:setup` proposes it.
- Reviewers pick their own skills from the diff, independently of the writer, plus
  the declared ones, and judge the code against them. A broken skill rule blocks the
  pull request like a broken documented rule does.
- Everything is in place before the build starts. At the start line, alongside the
  task list, the user sees the skills the run will use. Every declared skill must be
  installed by then; if one isn't, the run stops there and says which, before any
  code is written.
- After the start line, skills never stop a run. A skill that turns out to be
  unavailable is worked without, as temper works today, and noted. A skill finding
  that survives two fix rounds doesn't stop the pull request; it heads the PR's
  Heads up instead.
- The pull request shows which skills the writers and the reviewers loaded, so a gap
  between them is visible.

This is an addition to how temper writes, tests and reviews code, not a change to
what it does. Every existing step, gate and stop stays as it is.

This covers every workflow that writes code: `/temper:feature`, `/temper:bug`,
`/temper:refactor` and `/temper:overhaul`. `/temper:review` uses the same reviewer
side.

## User Stories

1. As a temper user, I want the agent writing code to load the skills that fit the language it is writing, so that the code follows that language's idioms.
2. As a temper user, I want the agent writing code to load the skills that fit the packages and frameworks it touches, so that it uses them the way they are meant to be used.
3. As a temper user, I want the agent writing code to load skills that fit the kind of change (a migration, a UI change, an API change), so that change-specific practice is followed even where no file pattern would catch it.
4. As a temper user, I want the writing agent to decide which skills apply from the code and context in front of it, so that I don't have to list every skill up front.
5. As a temper user, I want the writing agent to list the skills it loaded in its report, so that I can see what guided the code.
6. As a repo owner, I want to declare in `.claude/temper.md` which skills always apply to which files, so that my repo's standards are applied every run, whatever the agent picks.
7. As a repo owner, I want the Skills field to use the same `<glob> (<name>)` shape as Risky paths, so that the file stays easy to read and edit.
8. As a repo owner who wants no always-on skills, I want to write `Skills: none`, so that the file says so rather than leaving the field empty.
9. As a repo owner, I want `/temper:setup` to propose the Skills field from the repo's languages and the skills installed, so that I can accept it in a word.
10. As a repo owner, I want `/temper:setup` never to propose a skill that isn't installed, so that the field starts out correct.
11. As a repo owner re-running `/temper:setup`, I want changes to the Skills field shown as a difference like the other fields, so that nothing is overwritten without my say.
12. As a temper user, I want a run to stop before any code is written when a declared skill isn't installed, and tell me which, so that no run quietly builds without the standards my repo declares.
13. As a temper user, I want that check in the readiness check every command runs before it creates a worktree, so that I find out before any work starts.
14. As a temper user running `/temper:feature build` in a later session, I want the check run again before planning, so that a skill uninstalled between shaping and building is still caught.
15. As a temper user running `/temper:review`, I want a missing declared skill reported as not checked rather than stopping the review, so that a review still gives me a verdict.
16. As a temper user building a feature, I want every implementer the build loop sends out to receive the skills instruction, so that no task is written without it.
17. As a temper user building a feature, I want every per-task reviewer the build loop sends out to pick its own skills from that task's diff, so that it can catch a skill the implementer missed.
18. As a temper user building a feature, I want the instruction pinned in the plan file, so that it survives a long session compacting.
19. As a temper user fixing a bug, I want the agent writing the fix to choose and load fitting skills before it writes the failing test and the fix, so that bug fixes meet the same bar as features.
20. As a temper user running a refactor or an overhaul ticket, I want the agent moving the code to choose and load fitting skills before each step, so that the new shape follows the same standards.
21. As a temper user, I want the Standards seat of `check` to choose skills from the diff on its own, add the declared ones, and judge the code against each, so that the final review applies the same know-how.
22. As a temper user, I want a broken rule from one of those skills to be a blocking finding, so that skill guidance is enforced rather than advisory.
23. As a temper user, I want blocking skill findings to go through `check`'s existing fix rounds, so that they are fixed the same way as any other blocking finding.
24. As a pull request reviewer, I want the PR's Details to list the skills the writing agents loaded, so that I know what guided the code.
25. As a pull request reviewer, I want the PR's Details to list the skills the reviewers loaded, so that I know what the code was judged against.
26. As a pull request reviewer, I want any skill the reviewers loaded that the writers didn't load to be called out, so that I can see where the writing missed a standard.
27. As a pull request reviewer, I want a missing declared skill in a review run listed under what wasn't checked, so that I don't assume it was applied.
28. As a temper maintainer, I want the README to describe the Skills field and the skill routing, so that users know what the field does and why a run might stop.
29. As a temper maintainer, I want the plugin version bumped for this change, so that installed copies pick it up on update.
30. As a temper user, I want to see at the start line, next to the task list, the skills the run will use for each task, so that I can spot a missing one before the build starts.
31. As a temper user, I want to add or remove skills at the start line, or install a missing one before saying go, so that everything is in place before any code is written.
32. As a temper user, I want the skill list I agreed at the start line fixed in the plan, so that the build uses what I saw.
33. As a temper user running a bug fix, refactor or overhaul ticket, I want the same skill list shown at its start line, so that every workflow settles skills before it writes.
34. As a temper user, I want a run never to stop because of a skill once the build has started, so that I come back to a pull request rather than a halted run.
35. As a temper user, I want a writer that finds a skill unavailable mid-build to carry on without it, as temper works today, and note it, so that a missing skill costs only that skill's guidance.
36. As a temper user, I want a skill finding that survives two fix rounds to open the pull request anyway, listed first under Heads up, so that I still get the work along with what it fell short of.
37. As a temper user, I want the skills applied to the tests the writer adds as well as the code, so that testing improves along with the code.

## Implementation Decisions

- **The skills instruction.** One fixed instruction, worded once and used everywhere
  code is written: before writing, look at the installed skills and load every one
  that fits the language, packages, context and kind of change; also load every
  declared skill whose glob matches a file being touched; list what was loaded. The
  reviewer's version: choose skills from the diff independently, add the declared
  ones that match the diff, and judge the code against them.
- **Where the instruction reaches writers.**
  - Feature: the plan section temper pins in B3 ("Handing back to temper") tells
    Superpowers' build-loop controller to add the writer's instruction to every
    implementer dispatch and the reviewer's instruction to every per-task reviewer
    dispatch. The build loop gives subagents only the task's own text and the
    plan's Global Constraints, and keeps open-ended directives out of the latter, so
    the controller has to be told explicitly. The implementer's report and the
    reviewer's findings carry the skills each loaded; the build loop's final message
    of rulings carries them back to temper.
  - Bug: the bug command tells the session that runs systematic debugging to follow
    the writer's instruction before the failing test is written.
  - Refactor and overhaul: the reshape skill tells the session to follow the
    writer's instruction before the first move.
- **The Skills field.** A new line in `.claude/temper.md`:
  `- Skills: <glob> (<skill>); <glob> (<skill>)`, or `none`. It is never empty, like
  the other fields. Setup works it out from the repo's languages and file types
  matched against the skills installed in the session, says where each entry came
  from, and only ever proposes installed skills.
- **The installed check.** "Installed" means present in the session's list of
  available skills.
  - The start skill's readiness check gains a fifth check: every skill the Skills
    field names is installed. A missing one fails readiness, naming each missing
    skill and how to fix it (install it, or edit the field). A repo whose
    `.claude/temper.md` has no Skills line at all is treated as `Skills: none`, so
    repos set up before this change keep working.
  - The feature command's build half (B1) runs the same check before the spec is
    committed or the plan written, and stops the same way.
  - Review mode does not stop: the check skill records a missing declared skill
    under "Not checked".
- **The skill list at the start line.** Before each workflow's start line, temper
  works out the skills the run will use: for a feature, per task, the declared
  skills matching the files the task names plus those it picks from the spec and
  the task; for a bug, refactor or overhaul ticket, the same from its spec. The
  start-line question shows this list with the tasks. The user can change it or
  install a missing skill before saying go; a missing declared skill is the last
  point a run can stop for a skill. For a feature, the agreed list goes into the
  plan, beside the "Handing back to temper" section, so the controller passes each
  task's skills to its implementer.
- **Nothing about skills stops a run after the start line.**
  - A writer may load further installed skills it finds relevant as it works.
  - A skill on the agreed list that turns out to be unavailable is skipped: the
    writer works as temper does today and notes it, and the PR's Details list it.
  - In `check`, a blocking skill finding goes through the fix rounds like any other.
    If it survives two rounds, it does not end the check: it is recorded as an
    unresolved skill finding, which doesn't stop the verdict being clean, and
    `finish` lists it first under Heads up. Every other blocking finding keeps
    today's two-round rule.
- **Tests too.** The writer's instruction covers the tests it writes as well as the
  code, and the reviewer's covers the tests in the diff.
- **The Standards seat.** The check skill's Standards seat chooses skills from the
  diff, adds the declared ones that match it, and gives Matt's code-review each
  chosen skill's file as an extra standards source. A skill's rule broken counts as
  "a documented rule broken", so it is blocking, and goes through the existing fix
  rounds. The Spec seat, which shares that code-review run, is unchanged.
- **The verdict.** The check verdict gains a line for the skills the Standards seat
  used, and missing declared skills go under "Not checked".
- **The pull request.** The finish skill's Details gain a **Skills** part: the skills
  the writers loaded, the skills the reviewers loaded, and the difference between
  them. It is taken from the build loop's rulings (feature), the session's own notes
  (bug, refactor, overhaul), and the verdict.
- **README.** Documents the Skills field alongside the other fields, the skill
  routing, and the new reason a run can stop.
- **Version.** The plugin version goes from 0.8.2 to 0.9.0: a new config field and
  new behaviour.
- **Additive.** No existing behaviour is replaced; nothing is removed. Every existing
  step, gate and stop works as before; the skills sit on top of them.

## Testing Decisions

- temper is markdown instructions with no test suite. Its one gate, `claude plugin
  validate .`, proves the plugin still loads and every file's frontmatter is valid.
  It must pass after every commit.
- The rest is checked by reading: the build's reviewers read each changed
  instruction against these user stories. In particular, they trace the skills
  instruction from where it is written to the writer and the reviewer in each of
  the feature, bug and refactor/overhaul workflows, and confirm the installed check
  stops a run before any code is written in each.
- A live temper run using the new behaviour can't happen inside this build: it would
  itself be a temper run in another worktree. It is listed in the pull request as
  not checked, for the user to try after merging.
- Prior art: the earlier feature branches in this repo (cleanup, PR description
  cap) were checked the same way — the validate gate plus review.

## Out of Scope

- The wider review panel: the eleven review dimensions (correctness, design, fit
  with the codebase, simplicity, tests, readability, error handling, performance,
  comments, security, and everything beyond the code), running the full panel on
  every check, and turning the quality seat back on for features. That is a
  separate run.
- Changing Superpowers' or Matt's skills. temper only changes what it hands them and
  what it adds around them.
- Writing or bundling any language- or framework-specific skills. temper routes to
  skills the user has installed.
- Installing missing skills on the user's behalf.

## Further Notes

- Decisions from the grill: the writer chooses its own skills (Q4); declared plus
  discovered (Q5); reviewers choose independently (Q9); a broken skill rule blocks
  (Q13); a missing declared skill stops the run before any code is written (Q12);
  the check runs in start, in feature build B1, and reports in review (Q16); bump
  the version in this branch (Q17); the skill list is settled and shown at the start
  line (Q18); nothing about skills stops a run after the start line — an
  unavailable skill falls back to today's behaviour, and an unresolved skill finding
  goes to Heads up (Q19).
- The user's framing: this is an addition that improves how temper writes, tests
  and reviews code. It doesn't change what temper does.
- `.claude-plugin/**` is a risky path in this repo, so the version bump seats the
  security reviewer.
