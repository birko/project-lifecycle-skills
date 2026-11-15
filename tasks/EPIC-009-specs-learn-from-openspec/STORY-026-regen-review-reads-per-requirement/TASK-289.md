---
id: TASK-289
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

# `/specs regen` keeps a spec file's existing line endings

## Context

FEATURE-004 D6. On Windows a rewrite can turn an LF spec into CRLF, or the reverse, and the review then shows a whole-file diff. This repo already keeps a watch item about CRLF drift. OpenSpec v1.13.2 keeps a file's existing line endings when it rewrites a spec.

## Acceptance criteria

- [x] `regen` step 5 writes with the line endings the existing file has, and writes a new file with the endings the repo declares in `.gitattributes`, where it declares any — step 5d: an existing spec keeps the endings its first line has; a new one takes `git check-attr eol`, else LF
- [x] `bash .github/workflows/skills-lint.sh` passes — OK (20 skills)

## Out of scope

- Normalising files already committed with mixed line endings

## Human test plan

- [x] Drill: regenerate an area whose spec is checked out with CRLF endings. The diff shows only the changed requirement
  - **Passed 2026-11-15**, cold runner: `claude -p --disable-slash-commands --permission-mode acceptEdits` in
    `%LOCALAPPDATA%/Temp/d289`, the cwd holding only `brief.txt`, `skill/specs` at the fix and a clone of d349's
    `mapped/` with `core.md` converted to CRLF, `eol=crlf` declared and a `neg` function added; its report says no
    skills were loaded. `/specs regen core`, accepted: `core.md` came back 47 CRLF lines and no bare LF, and the diff
    held only the new content (28 added, 2 removed). Line endings are not among its seven undecided points; the
    others concern existing regen behaviour (no explicit accept question, template headings against stable wording)
    and are recorded here only.

## Implementation plan

Not planned: one file (`regen` step 5d), two criteria, no unknowns.

## Outcome

**What was built:** `/specs regen` step 5d keeps a spec's line endings. An existing spec is rewritten with the endings
its first line has; a new one takes what the repo declares for its path, else LF. FEATURE-004 D6.

**Judgement call:** the existing file's first line decides, not a majority count over the file: one rule every run
applies the same way, and a mixed file is out of scope (normalising it is its own job).

**Close gate (inline; one skill file, one spec):** standards and intent met; correctness by d289; layer parity,
security, comments not applicable; local lint passes; specs-from-code gained the line-endings clause.

## Progress log

- picked 2026-11-15 by `/feature` work on FEATURE-004 (user's order: 289 and 287 first); STORY-026 and EPIC-009 rolled up to in-progress
- built in skills/specs/verbs/regen.md step 5d; drilled d289; closed inline
