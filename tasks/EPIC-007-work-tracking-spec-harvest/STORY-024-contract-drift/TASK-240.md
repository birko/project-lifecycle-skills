---
id: TASK-240
parent: STORY-024
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: todo
# blocked: <reason> — add this line while the task is blocked, keeping its status; /tasks unblock removes it
priority: P2
assignee: unassigned
created: 2026-10-03
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [SH-45, SH-46, SH-47, SH-51]
pr: null
github-issue: null
jira-key: null
---

# Three `feature` records name no writer, or several: the prototype line, `superseded`, and the index row

## Context

Found by the feature-lifecycle spec harvest (2026-10-03, EPIC-007, spec committed in b24eb8b). One root cause: a
value the skill reads has no single verb that writes it.

- **SH-46 — nobody writes `Skipped — <reason>`.** `skills/feature/verbs/prototype.md` 4b says the skipped form "is set
  at `/feature new`/`decide` time, not here". `new.md` step 6 writes only the pending form, and `decide.md` never
  mentions the prototype line. The skill calls an absent or unrecorded choice "the bug", and no verb records it.
- **SH-47 — two formats for one line.** `new.md` step 6 writes `Built — <…>`. `prototype.md` 4b writes
  `**Built** — <…>`. [[roadmap]] step 2 reads the line, so the format is a contract.
- **SH-51 — `superseded` has no owner.** `SKILL.md`'s status table says `superseded` is set "when a feature is re-homed
  into another" and gives no verb. `pick` and `status` read it, and *Never silently displace planned scope* requires
  re-homing, but no verb performs the transition or writes `superseded-by:`.
- **SH-45 — the index row has several writers, and one sets a derived value by hand.** `templates/README.md.tmpl`
  says "Do not hand-edit — re-run the verb" and `status` owns the index (AGENTS.md lists it under generated files).
  `new` 6b appends a row, `prototype` 4c edits one, and `SKILL.md` says `decide`/`review`/re-home update rows.
  `prototype` 4c sets the Phase column to `prototyping` by hand, though phase is derived only by `status`, and by
  `status`'s own rule a feature with approved decisions is not `prototyping`.

## Acceptance criteria

- [ ] One verb is named as the writer of `Skipped — <reason>`, and that verb's file says when it writes it
- [ ] The prototype line has one format, used by every writer and matched by [[roadmap]]'s reader
- [ ] One verb owns setting `superseded` and `superseded-by:`, and `SKILL.md`'s table names it
- [ ] Every index-row write either goes through `/feature status` or is listed by `status.md` as an allowed exception,
      and no verb writes a phase that `status` would compute differently
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- The phase rules themselves — TASK-234

## Human test plan

- [ ] On an invented feature, run `/feature new`, skip the prototype, then `/feature decide`. The `## Prototype` line
      reads `Skipped — <reason>` and the index row's phase matches what `/feature status` then computes

## Implementation plan

_Populated by `/tasks plan TASK-240` — leave empty until then._
