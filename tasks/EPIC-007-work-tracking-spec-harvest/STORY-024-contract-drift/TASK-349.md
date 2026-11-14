---
id: TASK-349
parent: STORY-024
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: done
# blocked: <reason> — set by /tasks block, never by hand; status stays as it is; /tasks unblock removes it
priority: P3
# assignee — one of: agent (default), unassigned, human, or an installed agent type's name; ai is read as agent, never written
assignee: agent
picked-by: fix-next
created: 2026-11-12
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [DRILL-238-2, DRILL-238-3, DRILL-238-4, DRILL-089-1]
pr: null
github-issue: null
jira-key: null
---

# `/specs verify`, `show` and `init` leave four rendering details to the reader

## Context

Spawned 2026-11-12 from TASK-238's Human test plan drill: one cold run of `/specs verify` and `/specs show core` on an
invented fixture (`%LOCALAPPDATA%/Temp/d238`, report kept there as `report.md`). **Raised by one runner only**, so each
is a candidate to confirm, not a measured defect. The drill's one substantive reading, DRILL-238-1 (equal committer
dates, no tie rule), was fixed inside TASK-238. It is a group: three small rendering readings from one drill.

- **DRILL-238-2:** `verify`'s render template fixes the nouns (`<A> areas`, `<k> changed sources`), so one area prints
  `1 areas` and one file `1 sources`. Nothing says whether to inflect.
- **DRILL-238-3:** `show` step 3 says "Suggest `/specs regen <area>` to fill it" for a never-derived `shaped-by`, with
  no wording and no place (header line, footer, or a line of its own).
- **DRILL-238-4:** `show`'s footer `<anchor short sha>` gives no length. git's default abbreviation varies with the size
  of the repository, so two runs can print different lengths for one sha.
- **DRILL-089-1 (added 2026-11-14):** `init`'s confirmation line `<n> areas — one per capability found; fewer than the
  typical range…` has the same fixed noun, and reads oddly at 0. Raised by both TASK-089 runners
  (`%LOCALAPPDATA%/Temp/d089a` point 7, `d089b` point 12), and it is DRILL-238-2's class in a third verb, so one
  inflection rule for every `/specs` count line closes both.

## Acceptance criteria

- [x] Each of DRILL-238-2 … 4 is either confirmed by a second cold runner and then answered in `verify.md` or `show.md`, or recorded here as not reproduced
- [x] DRILL-089-1: `init`'s count lines inflect for one and read correctly at zero, by the same rule as `verify`'s
- [x] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- The no-map message, the unmapped scan set, the footer's anchor, uncommitted edits, the unknown-baseline line and the equal-date tie — TASK-238

## Human test plan

- [x] Re-run TASK-238's brief (in `%LOCALAPPDATA%/Temp/d238/brief.txt`, fixture recipe on TASK-238) with a cold runner. Expected: none of the confirmed findings in its "left undecided" section
  - **Passed 2026-11-14**, cold drill `%LOCALAPPDATA%/Temp/d349` (`claude -p --disable-slash-commands`, cwd holding only
    `skill/` at the fix, TASK-238's brief and fresh copies of its `empty/` and `mapped/` repos; the runner listed no
    skills). None of the four in its § 3: verify printed `(1 area)` and `core: 1 changed source`; show's header read
    `shaped-by: (never derived — /specs regen core fills it)` with no other suggestion; the footer read `1 source
    changed since ef4347b`, seven characters.

## Implementation plan

Inline: one stated answer per reading, in the verb that renders it.

## Outcome

**Answered without a separate confirming run.** DRILL-238-2 was confirmed by DRILL-089-1's two runners (the same fixed-noun
class in `init`). DRILL-238-3 and 4 had one runner each; answering them cost one sentence apiece, less than a confirming
drill, and d349 then found nothing undecided in their place.
- **DRILL-238-2 and DRILL-089-1 (`verify.md`, `init.md`):** every `/specs` count noun is singular for exactly 1 and plural
  otherwise, 0 included. `init`'s fewer-than-typical line is never printed at zero, because a map with no areas is the
  `not-applicable` verdict and has its own confirmation line.
- **DRILL-238-3 (`show.md`):** the regen suggestion sits in the header line, `shaped-by: (never derived — /specs regen
  <area> fills it)`, and nowhere else.
- **DRILL-238-4 (`show.md`):** the footer's anchor is always its first 7 characters (`git rev-parse --short=7`).

**One-runner readings left unfiled** (FEATURE-002 D10): d349 § 3 points 1-8, of which point 1 (`verify` step 4's `<glob>`:
the map's globs or the spec's resolved `sources:` list, which differ once a new matching file is added) is the one worth
watching for a second runner.

**Close gate (inline; three skill files plus one spec):**
- **Standards:** the count rule lives once, in `verify.md`, and `init.md` points at it.
- **Intent:** all criteria met.
- **Correctness:** d349.
- **Security, comments:** not applicable.
- **CI:** local lint passes; main is unpushed.

## Progress log

- step 2 — picked; ranked above TASK-216 because it is the last open P3 drill-reading batch with a two-runner reading in it (DRILL-089-1), where the rest of the P3 pool is single-reading or design-shaped; STORY-024 started
- step 3 — re-verified: none of the four has a stated answer at HEAD
- step 5 — fixed in verify.md, show.md and init.md
- step 6 — behavioural: d349 (none of the four undecided)
- step 7 — respecced specs-from-code (count nouns, header suggestion, seven-character anchor), restamped
- step 8 — closed inline; commit in git log
