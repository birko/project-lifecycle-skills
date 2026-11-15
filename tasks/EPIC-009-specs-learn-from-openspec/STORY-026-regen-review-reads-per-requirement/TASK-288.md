---
id: TASK-288
parent: STORY-026
feature: FEATURE-004
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: done
# blocked: <reason> — add this line while the task is blocked, keeping its status; /tasks unblock removes it
priority: P2
assignee: unassigned
created: 2026-10-08
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: []
pr: null
github-issue: null
jira-key: null
---

# `/specs regen --all` writes each area as soon as its review is accepted

## Context

FEATURE-004 D5. `regen` step 3 harvests every area, then runs the reviews one after another, and nothing says when each area is written, so an interrupted `--all` run is all-or-nothing in practice. OpenSpec v1.14.1 writes each capability's spec as soon as it is drafted, so an interrupted run keeps them.

## Acceptance criteria

- [x] Under `--all`, each area is written (step 5) as soon as its own review is accepted, before the next review starts — `regen` step 3: an accepted area goes through step 5 before the next review
- [x] A re-run after an interruption can tell which areas are already current, and says so — step 3: fresh by verify's check and the same file list → `already current`, skipped; step 7 reports it
- [x] `bash .github/workflows/skills-lint.sh` passes — OK (20 skills)

## Out of scope

- Running the reviews in parallel: they stay one at a time, because each is a conversation with a person

## Human test plan

- [x] Drill: start `/specs regen --all` on a fixture with three areas, stop after the second review, and re-run. The first two areas are kept and reported as current
  - **Passed 2026-11-15**, two cold runners in sequence: `claude -p --disable-slash-commands --permission-mode
    acceptEdits` in `%LOCALAPPDATA%/Temp/d288`, the cwd holding only the two briefs, `skill/specs` at the fix and an
    invented repo with three stale areas (`math`, `text`, `dates`); both reports list no skills. Run 1 accepted two
    reviews and was cut off at the third: `math.md` and `text.md` written, `dates.md` not. Run 2 (`--all`, every
    review accepted) printed `already current — math written by an earlier run, its sources unchanged since`, the
    same for `text`, and regenerated `dates`. Single-runner readings recorded only: whether a skipped area must have
    been accepted earlier (it was written only on acceptance, by the rule); whether a run cut off still owes steps 6–7.

## Implementation plan

Not planned: one file (`regen` steps 3 and 7), three criteria, no unknowns.

## Outcome

**What was built:** `/specs regen --all` writes each area as soon as its review is accepted, so an interrupted run
keeps them; a re-run reports an area `already current` and skips it when its spec is fresh and its file list
unchanged (FEATURE-004 D5).

**Judgement call:** the skip needs both checks. Freshness alone misses a map whose globs changed while no source did,
which is why the resolved file list is compared with the spec's `sources:` as well.

**Close gate (inline; one skill file, one spec):** standards and intent met; correctness by d288; layer parity,
security, comments not applicable; local lint passes; specs-from-code gained the clause.

## Progress log

- picked 2026-11-15 in FEATURE-004's build, after TASK-286
- built in skills/specs/verbs/regen.md steps 3 and 7; drilled d288 (interrupt, then re-run); closed inline
