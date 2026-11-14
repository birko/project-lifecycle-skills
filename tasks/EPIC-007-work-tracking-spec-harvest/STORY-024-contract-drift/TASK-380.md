---
id: TASK-380
parent: STORY-024
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: todo
# blocked: <reason> — set by /tasks block, never by hand; status stays as it is; /tasks unblock removes it
priority: P3
# assignee — one of: agent (default), unassigned, human, or an installed agent type's name; ai is read as agent, never written
assignee: agent
created: 2026-11-14
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [DRILL-349-1]
pr: null
github-issue: null
jira-key: null
---

# `/specs show`'s one-line header: field names or values

## Context

Filed 2026-11-14 by comparing two cold runs of TASK-238's brief: `%LOCALAPPDATA%/Temp/d238` (§ 3, "How much of the spec
to print") and `d349` (§ 3, point 3). Both raised it, so it meets FEATURE-002 D10's two-runner bar.

- **DRILL-349-1.** `skills/specs/verbs/show.md` step 3 says to "keep the frontmatter as a one-line header: `area ·
  generated-on · shaped-by`". Neither runner could tell whether the header prints the field names, the values, or the
  values with a `shaped-by:` label. d349 printed values, labelling only `shaped-by` because the never-derived form
  (TASK-349) carries one; d238 printed the body as it stood.

## Acceptance criteria

- [ ] `show.md` states the header line's exact form, with a worked example, consistent with TASK-349's never-derived
      form `shaped-by: (never derived — /specs regen <area> fills it)`
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- d349's single-runner readings, among them `verify` step 4's `<glob>` (the map's globs or the spec's resolved
  `sources:`): file it when a second runner raises it
- Everything TASK-238 and TASK-349 settled

## Human test plan

- [ ] Re-run TASK-238's brief (`%LOCALAPPDATA%/Temp/d349/brief.txt`, fresh copies of its `empty/` and `mapped/` repos and
      of `skills/` at the fix) with a cold runner. Expected: the header form is not in its "left undecided" section

## Implementation plan

_Populated by `/tasks plan TASK-380` — leave empty until then._
