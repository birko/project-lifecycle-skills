---
id: TASK-314
parent: EPIC-003
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: done
# blocked: <reason> — add this line while the task is blocked, keeping its status; /tasks unblock removes it
priority: P3
assignee: agent
picked-by: fix-next
created: 2026-10-13
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [SH-WT-2]
pr: null
github-issue: null
jira-key: null
---

# SKILL.md re-checks the epic only above a reopened story, while new.md checks it either way

## Context

Raised by the spec harvest of work-tracking (2026-10-13). `skills/tasks/SKILL.md` § *Roll status up to parents* re-evaluates the epic "above a reopened STORY". `skills/tasks/verbs/new.md` step 10 (TASK-308) checks it "whether or not the story was reopened", because a `planned` story can sit under a `done` epic. The verb is the superset; the router's rule is narrower, so a verb that follows only the router misses that case.

## Acceptance criteria

- [x] SKILL.md § *Roll status up to parents* states the epic check the way new.md step 10 does, or new.md points at a router rule that covers it
- [x] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- Other roll-up wording

## Human test plan

N/A — a one-sentence alignment between two files; the lint covers the link, and TASK-308's drill already exercises the path.

## Outcome

**What was fixed.** The router's roll-up rule (`skills/tasks/SKILL.md` § *Roll status up to parents*) re-evaluated the epic only above a story that had just been reopened. `new.md` step 10 checks it whether or not the story was reopened, because a `planned` or `in-progress` story can sit under a `done` epic, left by `close --epic --force`, and an open child makes that epic's `done` false too. A verb that followed only the router would leave the epic `done` over open work. The router now states the wider check, with that reason inline.

**Step-6 split: 0/0.** The change is one sentence of prose. `skills-lint.sh` passes (20 skills): a contract pin, not evidence. TASK-308's drill already exercises the path, as the `N/A` test plan says.

**Judgement calls.**
- **Widen the router, not narrow the verb.** The task allowed either direction. The router is the owner every verb defers to, and `close` step 5's park and the router's own unlanded-record bullet already use "the EPIC above a STORY parent", so the narrow sentence was the outlier.

**Respec.** `work-tracking` unchanged: its requirement already says "re-evaluate the parent story and then its epic" with no reopen condition, so the code no longer contradicts it.

**Flagged, not fixed.** None.

## Implementation plan

_Not drafted: a /fix-next run, whose fix is recorded in § Outcome._

## Progress log

- step 2 — picked; ranked above TASK-315 because a verb following only the router leaves a `done` epic over open work (a contradiction in the tree, key 1 wrong results), while TASK-315 is an unstated reopen the verb already performs; key 6 inert — both sit under EPIC-003 with no theme
- step 3 — verified: held. SKILL.md § Roll status up re-evaluates the epic only above a reopened STORY; new.md step 10 checks it whether or not; close.md 5 and the router's own unlanded-record bullet already use "the EPIC above a STORY parent"
- step 4 — layer: local (skills/tasks/SKILL.md)
- step 5 — fix in skills/tasks/SKILL.md (§ Roll status up to parents); tests: skills-lint.sh (20 skills) green
- step 6 — reverted fix: 0/0 failed — one sentence of prose; fix-dependent = none; contract pins = skills-lint.sh
- step 7 — respecced work-tracking: unchanged — the requirement already states the epic check without a reopen condition
- step 8 — handed to /tasks close --unattended; outcome in status:, commit in git log
