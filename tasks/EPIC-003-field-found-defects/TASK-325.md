---
id: TASK-325
parent: EPIC-003
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: verify
# blocked: <reason> — add this line while the task is blocked, keeping its status; /tasks unblock removes it
priority: P3
assignee: agent
picked-by: fix-next
created: 2026-10-14
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [CR-317-4, CR-317-5]
pr: null
github-issue: null
jira-key: null
---

# Batch verbs that run `/tasks new` drop its reopen and record lines, and repeat them per item

## Context

Found by TASK-317's close review (2026-10-14). This is a group: both findings sit on the same output, for batch creators. TASK-317 made `new.md` step 13 report every container step 10 reopened and every unlanded `record/<ID>` line, and made `spawn.md` step 8 relay them. Three other verbs chain `new` and print their own summary in its place, without those lines:

- `skills/tasks/verbs/intake.md` step 8
- `skills/tasks/verbs/import.md` step 7
- `skills/feature/verbs/decompose.md`

Two smaller defects on the same output:

- **Duplicates.** Nothing says to print each line once. A multi-id `move`, a `decide` that reverts two tasks under one story, or a batch `new` prints the same `record/<ID>` or `not checked` line once per child.
- **A flood of `not checked` lines.** `new.md` step 10 runs `git ls-remote` for every item a batch creates. That includes items under containers created in the same run, which cannot have a record branch. With the remote unreachable, every one of them prints a `not checked` line.

## Acceptance criteria

- [x] `intake`, `import` and `decompose` relay every reopened container and every `record/<ID>` line their `new` runs produced
- [x] Each distinct `record/<ID>` line is printed once per run, whatever the number of children behind it
- [x] A container created in the same run is not checked, and one unreachable remote yields one `not checked` line, not one per item
- [x] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- `close`'s re-close park (TASK-324)

## Human test plan

- [ ] On an upstream fixture with `record/STORY-001` pushed and unlanded, `/tasks intake` a pass that files three findings under STORY-001. Expected: one record line in intake's report.

## Outcome

**What was fixed.** Three verbs that create tasks in bulk (`/tasks intake`, `/tasks import`, `/feature decompose`) print their own summary instead of `/tasks new`'s confirmation, and none of them passed on the lines `new` produces when a parent gets reopened or when an unlanded `record/<ID>` branch would close a parent over the new work. Those lines now appear in all three summaries. The check behind the record lines also now runs once per run instead of once per child. It skips containers created in the same run, and it stops asking a remote that has already failed, so a batch prints each record line once and prints one `not checked` line, not one per item.

- `skills/tasks/SKILL.md` § *Roll status up to parents* has two new sub-bullets: the once-per-run rule (dedupe, skip a container created this run, one line for an unreachable remote) and the relay duty for any verb that replaces `new`'s confirmation. The rule lives in the owner, so `move`, `decide` and the batch callers all inherit it rather than restating it.
- `skills/tasks/verbs/intake.md` step 8, `import.md` (file mode step 7, `--github` step 4, `--jira` step 7) and `skills/feature/verbs/decompose.md` step 5 relay the lines and point at that rule.

**Step-6 split: 0/0.** No executable code changed, so revert-and-split has nothing to fail. `skills-lint.sh` passes before and after. It pins that the new `[[tasks]]` and relative links resolve: a **contract pin, not evidence**. The only real evidence is the Human test plan drill, which has not been run.

**Judgement calls.**
- I put the dedupe and unreachable-remote rule once in SKILL.md instead of in each caller, because the rule's owner is the roll-up section. Five copies would be the restated list § *Defer to a shared inventory* forbids.
- The unreachable-remote line keeps the existing `record/<ID> not checked: <reason>` prefix (`record/<ID>, record/<ID> not checked: <reason>`), so every reader that already relays that wording still matches it. I rejected a new line shape because it would have meant updating `move`, `decide`, `spawn` and `close` too.
- `import --github` had no confirm step at all. I extended its create step to print `new`'s confirmation rather than adding a step, which keeps the change small.

**Respec.** Step 7 changed `work-tracking` (the roll-up requirement plus two scenarios) and `feature-lifecycle` (the decompose requirement). These were scoped edits under the stable-wording rule. `shaped-by`, `shaped-by-derived` and `shaped-by-unresolved` were carried forward unchanged, not re-derived. TASK-325 has `feature: null`, so it adds no provenance, but other tasks' counts were not recomputed.

**Flagged, not fixed.** None.

## Implementation plan

_Not drafted: a /fix-next run, whose fix is recorded in § Outcome._

## Progress log

- step 2 — picked; ranked above TASK-100 because an unannounced unlanded record/<ID> branch is a gate record silently never landed (key 1), whereas TASK-100's stale dashboard is regenerable and its runner already surfaced it; TASK-323 lost on key 4 (open design question); key 6 inert — TASK-325 sits under its EPIC with no theme
- step 3 — verified: held. intake.md step 8, import.md steps 7 (file and --jira; --github mode has no confirm step at all) and decompose.md step 5 print their own summary in place of new.md step 13, relaying no reopen or record line; SKILL.md § Roll status up states no once-per-run or created-this-run rule, so duplicates and the not-checked flood follow
- step 4 — layer: local (skills/tasks and skills/feature in this repo)
- step 5 — fix in skills/tasks/SKILL.md, skills/tasks/verbs/intake.md, skills/tasks/verbs/import.md, skills/feature/verbs/decompose.md; tests: skills-lint.sh (20 skills) green
- step 6 — reverted fix: 0/0 failed — prose only, nothing executable; fix-dependent = none; contract pins = skills-lint.sh link resolution; evidence = the Human test plan drill, not run
- step 7 — respecced work-tracking, feature-lifecycle; requirements changed: Parents rolled up after child changes (+2 scenarios), Decompose turns approved and changed decisions into tasks; intended anyway — TASK-325's criteria, answered by /fix-next; shaped-by carried forward, not re-derived
- step 8 — handed to /tasks close --unattended; outcome in status:, commit in git log
