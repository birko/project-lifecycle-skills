---
id: TASK-237
parent: STORY-024
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: done
# blocked: <reason> — add this line while the task is blocked, keeping its status; /tasks unblock removes it
priority: P2
assignee: unassigned
picked-by: fix-next
created: 2026-10-03
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [SH-28]
pr: null
github-issue: null
jira-key: null
---

# Three skills still advise a project-local skill that shadows them, which does not work

## Context

Found by the defect-draining spec harvest (2026-10-03, EPIC-007, spec committed in b24eb8b).

- **SH-28.** `skills/fix-next/SKILL.md` § Conventions: "A project needing more than that should ship a project-local
  skill that shadows this one." Name-shadowing does not work. `skills/verify-conventions/SKILL.md` § Scope layering
  records the measurement (2026-09-07, Claude Code): a name present at both user and project level resolves user-level
  first, so the project copy never runs. That skill's fix is a **distinct** name (`verify-<project>-conventions`) that
  the generic skill discovers in its step 0 and hands off to.
- **Same advice, same root cause, outside this harvest's area:** `skills/roll-changelog/SKILL.md` (intro: "A repo may
  ship its own project-local `roll-changelog` that shadows this one") and `skills/new-project/SKILL.md` (§ Related
  skills: "a project-local variant may shadow it"). Fixed in the same edit, because leaving two of the three copies
  keeps the advice alive.
- **Rescoped at step 3 (2026-10-12), before any edit.** `roll-changelog` reads no project guide at all, so the
  second option below was not true of it. The third option is added for that case: a separately named skill the
  project invokes by its own name, which `verify-conventions` § Scope layering already names as "a second door".
  The `docs/specs/changelog-maintenance.md` requirement that repeats the shadowing advice is respecced at step 7.

## Acceptance criteria

- [x] None of the three skills advises shadowing by name
- [x] Each says what a project does instead: either the distinct-name hand-off `verify-conventions` uses (which the
      skill must then actually perform), or that project specifics go in the project's own guide, which the skill
      already reads, or, for a skill that reads no guide, a separately named skill the project invokes by its own
      name, which the generic skill does not claim to discover
- [x] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- Adding a step-0 discovery to `fix-next` or `roll-changelog`. If the chosen wording needs one, that is a spawned task

## Human test plan

N/A — wording, checked against `verify-conventions` § Scope layering.

## Implementation plan

_Populated by `/tasks plan TASK-237` — leave empty until then._

## Outcome

**What changed.** Three skills told projects to override them with a same-named project-local copy, which never
runs, because the user-level copy resolves first. Each now says what to do instead:
- `fix-next` § Conventions: record the project's needs in its guide, which the skill already reads; do not ship a
  local `fix-next`.
- `roll-changelog` intro: a same-named local copy never runs, so a project that needs its own changelog process
  ships it under a distinct name and invokes it by that name. This skill does not look for one.
- `new-project` § Related skills: a project-local variant needs a distinct name.
All three point at [[verify-conventions]] § Scope layering for the measurement instead of restating it.
`docs/specs/changelog-maintenance.md` § *Code changelog, not the decision ledger* was respecced to match. No other
spec mentions the shadowing advice.

**Step-6 split.** There is no automated guard: this is prose, and a lint for "advises shadowing" would be a
prose-shaped detector of the kind § Framework / stack measured and rejected. The check is a grep for
`shadows this one|may shadow it` across `skills/`: **3 hits with the fix reverted (`git stash -- skills`), 0 with
it**. Fix-dependent: that grep. Contract pin, not evidence: `skills-lint.sh` (OK, 20 skills), which passes either
way.

**Judgement calls.**
- `roll-changelog` got the third option added at step 3, not the `verify-conventions`-style discovery hand-off.
  The stricter option, a step-0 glob for a distinctly named variant, was rejected because it is out of scope by
  this task's own line, and nothing shows a project has needed it.
- `fix-next` got the guide option because it already reads `CLAUDE.md` § Conventions / § Testing.

**Flagged, not fixed.** Nothing.

**Merge gate (close step 5b, run inline, each verdict on its own):**
- *Standards* ([[verify-conventions]]): pass. The three sites point at § Scope layering rather than restating the
  measurement, so no list is copied, and no new cross-cutting pattern is introduced.
- *Fidelity* ([[verify-intent]]): pass. Criterion 1: the advice grep returns 0. Criterion 2: `fix-next` takes the
  guide option, `roll-changelog` and `new-project` the distinct-name option added at step 3. Criterion 3: lint OK.
- *Correctness* ([[code-review]]): one finding, fixed before commit. The new sentences stated "user-level resolves
  first" for every runtime, while the measurement was taken on Claude Code only. All three, and the spec, now say
  "on Claude Code".
- *Security*: not applicable, because the diff touches no security surface.
- *Comments* ([[review-comments]]): not applicable, because the diff carries no code comment.

## Progress log

- step 2 — picked; ranked above TASK-298 because both are silent wrong-result defects reachable from ordinary use, but TASK-237 is self-contained wording with its mechanism already measured (key 4, key 5), while TASK-298 carries an open design question about where the record goes and its stopgap already reports and stops (key 3). key 6 not reached: the pool separated on keys 3–5, although contract-drift would sort after correctness-invariants there
- step 3 — verified: rescoped: all three quotes hold, and verify-conventions § Scope layering carries the measurement; roll-changelog reads no project guide, so acceptance gained a third option (a separately named skill invoked by its own name) and the changelog spec's repeat of the advice is named for step 7
- step 4 — layer: local
- step 5 — fix in skills/fix-next/SKILL.md, skills/roll-changelog/SKILL.md, skills/new-project/SKILL.md; no test file (prose); lint OK, 20 skills
- step 6 — reverted fix: grep for the advice 3/3 hits reverted, 0 with fix; fix-dependent = that grep; contract pins = skills-lint.sh
- step 7 — respecced changelog-maintenance; requirements changed: Code changelog, not the decision ledger (body only, title unchanged)
- step 8 — handed to /tasks close --unattended; outcome in status:, commit in git log
