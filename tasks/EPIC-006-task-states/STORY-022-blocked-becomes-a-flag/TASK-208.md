---
id: TASK-208
parent: STORY-022
feature: FEATURE-003
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: todo
# blocked: <reason> — add this line while the task is blocked, keeping its status; /tasks unblock removes it
priority: P2
assignee: unassigned
created: 2026-10-02
depends-on: []
blocks: [TASK-205]
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [FIELD-007]
pr: null
github-issue: null
jira-key: null
---

# The migration writes "reason unknown" over a block reason the file already states

## Context

Found while running TASK-205's human test plan (2026-10-02) against Symbio's migration branch,
`tasks/status-migration` at `888af6dc` (PR BirkoWorks/Symbio#1, open, not merged). Of the 12 tasks the
migration rewrote, 4 got `blocked: reason unknown` although the old file stated why it was blocked.

The reason ladder is `skills/tasks/verbs/init.md` step 3b, the **Reason** bullet. It tries, in order:
a `> Blocked <date> — <reason>` note (read through emphasis), then unmet `depends-on`, then
`reason unknown`. The four files hold their reason in shapes the ladder does not try:

| Symbio task | Where the reason is on `main` | Why the ladder missed it |
|---|---|---|
| TASK-358 | the `status: blocked  # ⚠ …` comment, and `> **BLOCKED 2026-08-08 — awaiting a commercial decision, deliberately.**` in the body | the note is upper-case `BLOCKED`; the status-line comment is dropped by the anchored read (the leon fix in TASK-205) |
| TASK-068 | `status: blocked  # ⏸ DEFERRED 2026-09-19 by the user until Booking is real work …`, continued over several `#` lines | the status-line comment is never a reason source |
| TASK-305 | body line `🚫 **Blocked — no PostgreSQL, MSSQL, MySQL or ElasticSearch instance exists on this machine** …` | not a `>` note and carries no date |
| TASK-273 | body heading `## DEFERRED 2026-07-28 — there is no environment to rotate yet` | a heading, and the word is `DEFERRED` |

The anchored read of `status:` is right for the **value** and must stay; the defect is that the
comment it discards was, in two of these files, the only place the reason was written. DraCode (24
blocked, all reasons from `depends-on`) is unaffected, which is why one repo of the two checked passed.

## Acceptance criteria

- [ ] Step 3b's reason ladder finds a reason stated in each of the four shapes above: a comment on the
      `status: blocked` line (including its `#`-continuation lines), an upper-case `BLOCKED` note, a bold
      `Blocked —` line that is not a `>` note, and a `## DEFERRED <date> — <reason>` / `## BLOCKED …` heading
- [ ] The order of the ladder is stated, and `block`'s own `> Blocked <date> —` note still wins when present
- [ ] A long reason is cut to one line in the `blocked:` field, and the field says where the full text is,
      rather than copying a paragraph into frontmatter
- [ ] `reason unknown` is still written when a file states no reason in any shape — the fix must not
      promote unrelated prose (a "blocks:" line, a mention of another task being blocked) into a reason
- [ ] Symbio's migration branch is re-run with the fixed step and the four tasks carry their real reason;
      the other 8 are unchanged
- [ ] Regression check: a case the lint or its tests can pin, if the reason ladder is checkable there; if it
      is prose-only, the four Symbio files are recorded as the drill fixture, with the expected reason for each

## Out of scope

- Re-migrating the other repos — DraCode, WorkoutTracker and Birko.Framework reasons were checked or
  came from `depends-on`; only re-run one if a check shows the same defect there
- Presenter, still skipped for the reason recorded on TASK-205

## Human test plan

- [ ] On Symbio's `tasks/status-migration` branch after the re-run, `/tasks show` TASK-358, TASK-068,
      TASK-305 and TASK-273: each `blocked:` reason says what the old file said, in one line
- [ ] This is TASK-205's check too: once it passes, the owner's `/tasks` check in DraCode and Symbio can
      be signed off there

## Implementation plan

_Populated by `/tasks plan TASK-208` — leave empty until then._
