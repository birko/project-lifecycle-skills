---
id: TASK-182
parent: STORY-011
feature: null
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: done
priority: P2
assignee: ai
picked-by: fix-next
created: 2026-09-24
depends-on: []
blocks: []
related: [TASK-127]
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [DRILL-174-1]
pr: null
github-issue: null
jira-key: null
---

# `/tasks pick` step 7's two questions carry no wording and no answer-less path

## Context

Found by TASK-174's drill on 2026-09-24. Three `claude -p` runners ran `skills/tasks/verbs/pick.md`
unattended on `pr-per-task` fixtures. All three reached step 7 and met two ask-steps. Neither is quoted
verbatim, and neither says what happens when nobody answers. Both break AGENTS.md § Output/prose rules:
*an ask-step carries the question it puts and the answer-less path, or it is not a step*. The two are:

- *"offer to cut `task/TASK-NNN` so the work is isolated"*. One runner cut the branch and reported *"that
  was my decision, not the verb's"*. With no rule, another runner is equally entitled to skip the cut
  and work on the default branch, which on a `pr-per-task` project is exactly what that model forbids.
- *"ask whether to fill `pr:` now"*. All three left it null, but by inference, not instruction.

This predates FEATURE-001 and is unrelated to its change. Step 6b, which that feature added, is
compliant and was not touched.

### Merged in 2026-09-26: TASK-134 — `/specs init` step 1's meta-root ask has no question text and no unattended path

_Merged because same defect shape (ask-step with no question text and no answer-less path) under one AGENTS.md rule. The original file stays, cancelled, at `tasks/EPIC-002-close-gate-findings/STORY-014-specs-gates/TASK-134.md`._

Found 2026-09-17 during [[TASK-127]]'s step-3 re-verification, and **deliberately not folded into it**.
It is the same defect shape as that task's four sites, but it resolves *project scope* rather than
blessing a map, so pulling it in would have widened TASK-127 rather than completed it.

`skills/specs/verbs/init.md` step 1:

> Polyrepo Shape A: if cwd is inside a subproject, init that subproject's `docs/specs/`; at the
> meta-root, **ask whether the user wants meta-level (cross-cutting) specs or a specific subproject**.

No wording, and no statement of what a run does when nobody answers. TASK-127 brought the other nine
ask-steps in `tasks` and `specs` up to the standard now recorded in `AGENTS.md` § Conventions
(*"An ask-step carries the question it puts and the answer-less path, or it is not a step"*); this one
was left, so the rule is nine-tenths applied in the two skills it was written from.

**Why it is P3 and not P2.** The branch needs a polyrepo meta-root to fire at all, where TASK-127's sites
sit on every first run of either front door. The consequence when it does fire is real though — a run that
guesses *meta-level* writes a `.map.yml` at the aggregator root whose globs reach every sibling, which is
the exact shape [[specs]] `regen` step 6 records as having reported "nothing unmapped" forever while
covering 97 sibling projects.

## Acceptance criteria

- [x] Both step-7 questions are quoted verbatim in `pick.md`.
- [x] Each has a stated answer-less path. For the branch offer, the path is read off `integration:`. Under `pr-per-task`, with nobody to ask, the branch is cut and the report says the cut was the documented default and nobody chose it. A run that works on the default branch under a policy forbidding it is the one outcome ruled out. For `pr:`, it stays null and `close` asks later.
- [x] A drill with two unattended runners gives the same outcome and the same report line from both. — passed 2026-11-04, see the Human test plan

*From TASK-134:*

- [x] Step 1's meta-root branch states **the question actually put**, in the form the other nine sites now use
- [x] It states what happens when **no answer comes**, and that outcome is a reported unresolved state —
      never a silently-chosen scope
- [x] The choice, once made, is **recorded** where a later run can read it rather than re-guess, or the
      task says explicitly why it is not worth recording
- [x] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- Step 6b — FEATURE-001 (TASK-174/175).

*From TASK-134:*

- The other nine ask-steps — built under [[TASK-127]].
- Whether Polyrepo Shape A is the right model at all; that is [[TASK-130]]'s territory, and undecided.

## Human test plan

- [x] Two cold runners each run `/tasks pick` unattended on a `pr-per-task` fixture with no `workspace:`. Expected: both cut `task/TASK-NNN`, leave `pr:` null, and print the same line saying the cut was the documented default. The brief withholds the expected outcome.
  - **Passed 2026-11-04:** both runners put the branch question and the `pr:` question verbatim, cut `task/TASK-001`, left `pr: null`, and printed the identical line `cut task/TASK-001 — the documented default for integration: pr-per-task; nobody chose it`.

*From TASK-134:*

AC3 resolved prose-only (the `.map.yml` a resolved run writes is the record), so per the line this replaces, this half is a reviewer check against the `AGENTS.md` ask-step rule: run as `/tasks close`'s standards pass on 2026-11-04 and recorded in § Outcome.

## Outcome

**What was fixed.** `/tasks pick` step 7 asked two questions in paraphrase, with no wording and no outcome for an unanswered run. The merged TASK-134 finding was the same defect in `/specs init` step 1's meta-root scope question. All three now quote their question and state what happens when nobody answers:

- **Branch offer (`pick`):** cut `task/TASK-NNN` and report `cut task/TASK-NNN — the documented default for integration: <value>; nobody chose it`. The default is read off `integration:`. An absent line applies the `pr-per-task` default the config template documents, and the report says the line is absent.
- **`pr:` offer (`pick`):** leave it null and say nothing, because `close` step 7 fills it. The question is now asked as "is there already a PR or commit?", the only case where filling it at pick makes sense.
- **Meta-root scope (`specs init`):** write nothing and report `scope not chosen: …` with how to rerun. Neither scope is guessed.

**Step-6 split: 0/0.** The change is prose only. `skills-lint.sh` passes (20 skills): a contract pin on link resolution, not evidence. Criterion 3 (two unattended runners agree) is the Human test plan's drill and stays unticked until it runs.

**Judgement calls.**
- **Cut the branch on no answer, rather than skip it.** The task's criteria required this. The reason is asymmetry: an unwanted cut costs one `git switch`, while work committed on the default branch under a policy that merges through task branches costs a rewrite. The report names it as a default nobody chose, so the run claims no decision.
- **An absent `integration:` applies `pr-per-task`.** This is not an inference. `skills/tasks/templates/config.yml` defines the absent line as undeclared and says consumers apply the `pr-per-task` default. I checked it against § *Read the declaration, never infer it* before keeping the clause.
- **TASK-134's criterion 3 (record the scope): no separate record.** The map the answer leads to is written where its scope lives, and step 2's re-discovery finds it from there. A second record would be a cache of a fact the filesystem already holds.

**Respec.** `work-tracking`, *Task branch per integration policy*: the answer-less cut and the `pr:` offer, plus one scenario. `specs-from-code`: one scenario for the meta-root with nobody present. The `shaped-by` fields were carried forward, not re-derived.

**Flagged, not fixed.** None.

## Implementation plan

_Not drafted: a /fix-next run, whose fix is recorded in § Outcome._

## Progress log

- step 2 — picked; ranked above TASK-321 because `/tasks pick` runs on every task started, so an unworded branch offer is the most reachable remaining ask-step gap (key 2), and a runner skipping the cut on pr-per-task silently works on the default branch the policy forbids (keys 1, 3); key 6 inert — both candidates are correctness-invariants
- step 3 — verified: held. pick.md step 7 carries the branch offer and the `pr:` ask as paraphrase with no answer-less path; specs init.md step 1 carries the meta-root scope ask the same way (the merged TASK-134 finding)
- step 4 — layer: local (skills/tasks/verbs/pick.md, skills/specs/verbs/init.md)
- step 5 — fix in skills/tasks/verbs/pick.md (step 7, both asks), skills/specs/verbs/init.md (step 1 meta-root); tests: skills-lint.sh (20 skills) green
- step 6 — reverted fix: 0/0 failed — prose only, nothing executable; fix-dependent = none; contract pins = skills-lint.sh link resolution; evidence = the Human test plan drill (criterion 3), not run
- step 7 — respecced work-tracking, specs-from-code; requirements changed: Task branch per integration policy (+1 scenario), Init discovers a capability map (+1 scenario); intended anyway — TASK-182's criteria, answered by /fix-next; shaped-by carried forward, not re-derived
- step 8 — handed to /tasks close --unattended; outcome in status:, commit in git log
- 2026-11-04 — **Human test plan — cold drill, passed.** Fixture: `repo/` on `main`, no remote, `tasks/.config.yml` `mode: local` + `integration: pr-per-task` and no `workspace:` line, one todo task (TASK-001) with a filled `## Implementation plan`; skill `tasks`. Built twice, one runner each. Runner: `claude -p --disable-slash-commands --permission-mode acceptEdits --allowedTools "Bash(git:*)" "Bash(cd:*)" "Bash(ls:*)" Read Glob Grep Edit Write < brief.txt`, cwd `%LOCALAPPDATA%\Temp\d182a`/`d182b`, which holds the committed fixture `repo/` and copies of the named skill folders under `skill/`. The brief said it was a drill, barred history and planning docs, said to write any question verbatim and continue unanswered, and asked for the output, the questions, what was left undecided, what was settled, what was inferred, what it read unsent, and its skill list. It stated no expected outcome. Task-specific ask: "Run /tasks pick TASK-001. Stop when the task is ready to be worked on; do not implement it. Give TASK-001's frontmatter as it stands at the end." **Coldness:** neither listed any skill. **Result:** both runners put the branch question and the `pr:` question verbatim, cut `task/TASK-001`, left `pr: null`, and printed the identical line `cut task/TASK-001 — the documented default for integration: pr-per-task; nobody chose it`. Also: both also read step 2b as possibly skipped on a bare-id pick, found no source for a plan's date in step 6, and printed "1 manual test steps" from 9b's offer → TASK-337. → `verify` → **done**.
