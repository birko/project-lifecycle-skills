---
id: TASK-225
parent: STORY-024
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: done
# blocked: <reason> — add this line while the task is blocked, keeping its status; /tasks unblock removes it
priority: P2
assignee: unassigned
created: 2026-10-03
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [SH-2, SH-13]
pr: null
github-issue: null
jira-key: null
picked-by: fix-next
---

# Two sentences still describe the task states before FEATURE-003

## Context

Found by the work-tracking spec harvest (2026-10-03, EPIC-007). FEATURE-003 made `blocked` a flag and renamed the
task status `review` to `verify`; these two sentences were missed by its sweeps (TASK-213, TASK-219).

- **SH-2 — `tasks/SKILL.md` § Conventions, "The merge is part of done":** the alternative to merging is "a captured
  deferral reason in `## Out of scope`". `close` steps 5c and 6 now record a deferred merge as `in-progress` with a
  `blocked:` field.
- **SH-13 — `triage.md` step 3b:** "Omit the whole section when no task is in `review`", and the
  template placeholder is still named `{{TK_REVIEW}}` — the task status is `verify` (the old form still reads the
  same).

## Acceptance criteria

- [x] § Conventions describes a deferred merge as `close` records it
- [x] Step 3b's omission rule speaks of tasks awaiting verification; the placeholder's name follows if it is renamed
      in both `triage.md` and `templates/README.md.tmpl` together
- [x] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- The feature's own `review` phase and gate

## Human test plan

N/A — wording, checked by reading against `close` and the reading table.

## Implementation plan

Drafted 2026-11-12 by `/fix-next` (no grill: nobody to answer one). Trigger: three acceptance criteria.

1. **SH-2** — `tasks/SKILL.md` § Conventions: describe a deferral as `close` records it (`in-progress` plus a
   `blocked: 'merge deferred: …'` field, steps 5c and 6), not as prose in `## Out of scope`.
2. **SH-13** — `triage.md`: step 3b omits the section when no task awaits verification (`verify` or the older
   `review`), and step 7 calls the row `verify`. **Keep `{{TK_REVIEW}}`**: it names the Collection pass's `review`
   bucket, which counts both forms, so a rename would split one bucket across two names. The criterion makes a rename
   optional.

## Outcome

**The fix.** Two sentences still described task states from before FEATURE-003:
- **Deferred merge:** `tasks/SKILL.md` said the alternative to merging is a deferral reason written in `## Out of
  scope`. `close` records a deferral as `in-progress` plus a `blocked: 'merge deferred: …'` field, and an agent
  following the old sentence would write a note nothing reads. It now describes the field.
- **Dashboard:** `triage.md` keyed its "Awaiting verification" section and its counts row on `review`. Both now speak
  of verification (`verify`, or the older `review`).

**Step 6 split.** 3 of 3 assertions failed on HEAD's copies and pass on the fix. All are fix-dependent: the deferral is
described as `close` records it, step 3b is keyed on verification, and step 7 names the `verify` row. Contract pin,
**not evidence**: skills-lint passes on both.

**Judgement calls.**
- **The placeholder stays `{{TK_REVIEW}}`.** It fills from the Collection pass's `review` bucket, which counts `verify`
  and the old `review` together (`SKILL.md` § Collection pass). Renaming the placeholder alone would make the template
  and the bucket disagree. Renaming both is a vocabulary change across the collection engine that this finding does
  not need. Step 7 now says outright which row it fills.
- **No spec change.** `work-tracking` already describes the deferred merge as a `blocked:` field and the dashboard in
  verification terms. The prose was behind the spec here, not the other way round.
- **Close gate ran inline** on a 3-line prose diff.
  - Standards, intent and correctness: no finding.
  - Security: not applicable.
  - Comments: not applicable.

**Flagged, not fixed.** Nothing.

## Progress log

- step 2 — picked; ranked above TASK-224 because both are stale rules in `tasks` prose (key 1 wrong results), but SH-2 tells an agent to record a deferred merge as prose in `## Out of scope`, a write `close` no longer reads, so the deferral vanishes from every view silently (key 3), while TASK-224's drifted verb lists make a reader unsure whether a verb refuses a flag, a doubt that shows. Last run's runner-up. Key 6 did not separate them: both `contract-drift`
- step 3 — verified: held, both. SKILL.md § Conventions "a captured deferral reason in `## Out of scope`"; triage step 3b "no task is in `review`" and step 7 "the `review` row"
- step 3b — planned: drafted inline as `/tasks plan --no-grill` would (trigger: three acceptance criteria)
- step 4 — layer: local
- step 5 — fix in skills/tasks/SKILL.md, skills/tasks/verbs/triage.md
- step 6 — reverted fix (HEAD's copies): 3/3 assertions failed; fix-dependent = all three; contract pins = skills-lint (passes on both)
- step 7 — work-tracking: already describes both in current terms; unchanged
- step 8 — handed to /tasks close --unattended; outcome in status:, commit in git log
