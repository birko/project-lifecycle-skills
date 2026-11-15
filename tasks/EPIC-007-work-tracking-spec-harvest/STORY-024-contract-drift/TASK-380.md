---
id: TASK-380
parent: STORY-024
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: done
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
picked-by: fix-next
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

- [x] `show.md` states the header line's exact form, with a worked example, consistent with TASK-349's never-derived
      form `shaped-by: (never derived — /specs regen <area> fills it)` — `<area> · generated <generated-on> · shaped-by: <ids>`, with an example and the empty-derived `none`
- [x] `bash .github/workflows/skills-lint.sh` passes — OK (20 skills)

## Out of scope

- d349's single-runner readings, among them `verify` step 4's `<glob>` (the map's globs or the spec's resolved
  `sources:`): file it when a second runner raises it
- Everything TASK-238 and TASK-349 settled

## Human test plan

- [x] Re-run TASK-238's brief (`%LOCALAPPDATA%/Temp/d349/brief.txt`, fresh copies of its `empty/` and `mapped/` repos and
      of `skills/` at the fix) with a cold runner. Expected: the header form is not in its "left undecided" section
  - **Passed 2026-11-15**, cold runner: `claude -p --disable-slash-commands --permission-mode acceptEdits` in
    `%LOCALAPPDATA%/Temp/d380`, the cwd holding only `brief.txt`, fresh copies of d349's `empty/` and `mapped/`, and
    `skill/specs` at the fix; its report says no skills were available. It printed
    `core · generated 2026-11-10 · shaped-by: (never derived — /specs regen core fills it)`, and the header form is
    not among its eight undecided points. One of them came from this fix's own first wording (*the body, from its
    first line after the frontmatter*: is the blank line printed), loosened in the same change.

## Implementation plan

Not planned (step 3b): one file, two criteria.

## Outcome

**What was fixed:** `/specs show` said to print the spec's frontmatter "as a one-line header: `area · generated-on ·
shaped-by`", which two cold runners read two ways (field names, or values). `show.md` step 3 now gives the form,
`<area> · generated <generated-on> · shaped-by: <ids>`, with an example, and says an empty derived list prints `none`.

**Step 6, as a split:** the old text was raised as undecided by 2 of 2 runners (d238, d349); the fixed text by 0 of 1
(d380). There is no automated test: the product is prose, so the cold drill is the instrument (AGENTS.md § Testing).

**Judgement calls:**
- Only `shaped-by` keeps its label: the never-derived form TASK-349 settled is a sentence, so it needs one; labelling
  every field would lengthen the line for no reader gain. The stricter option, all three labelled, was rejected for
  that reason.
- An empty derived list prints `none`, kept distinct from the never-derived sentence: one means "looked, found
  nothing", the other "never looked".

**Flagged, not fixed:** d380's other undecided points are single-runner readings or already recorded as out of scope
here (verify's `<glob>`), so none is filed.

**Close gate (inline; one skill file, one spec):** standards and intent met; correctness by d380; layer parity,
security and comments not applicable; local lint passes; specs-from-code respecced (the header form and a scenario).

## Progress log

- step 2 — picked; ranked above TASK-381 because keys 1–3 tie (an ambiguous instruction, reachable on every run, silent) and key 4 separates: one reading in one file against four across two verbs
- step 3 — verified: held — show.md step 3 named the header's fields, not its form
- step 3b — not planned: one file, 2 criteria, no feature:, no unknowns
- step 4 — layer: local
- step 5 — fix in skills/specs/verbs/show.md step 3; no test file (prose; the drill is the test)
- step 6 — old text 2/2 runners undecided (d238, d349); fixed text 0/1 (d380); one wording reading from the fix itself, loosened
- step 7 — respecced specs-from-code; requirements changed: Show prints one spec (header form), scenario added
- step 8 — closed inline; outcome in status:, commit in git log
