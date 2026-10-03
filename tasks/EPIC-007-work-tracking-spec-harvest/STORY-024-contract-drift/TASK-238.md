---
id: TASK-238
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
findings: [SH-31, SH-32, SH-33, SH-34, SH-35, SH-36, SH-40]
pr: null
github-issue: null
jira-key: null
---

# `/specs verify` and `show` restate the router's and `regen`'s rules, and the copies have drifted

## Context

Found by the specs-from-code spec harvest (2026-10-03, EPIC-007, spec committed in b24eb8b). All seven are in
`skills/specs/verbs/verify.md` and `show.md`, and would be fixed in one pass over the two files. Each verb file must
be readable standalone (AGENTS.md § Output / prose rules), so where a verb restates a rule it must restate it right.

**The no-map case:**
- **SH-31.** The router (`SKILL.md`) prints `No usable spec map — run /specs init to bootstrap.` for a missing map **or**
  an empty `areas:` list. `verify` step 1 prints `No docs/specs/.map.yml — run /specs init to bootstrap.` and checks
  only a missing file, so an empty map read through `verify` alone is processed as zero areas.
- **SH-40.** `show` step 1 loads `.map.yml` and has no step for a missing or empty map.

**The unmapped check:**
- **SH-32.** `verify` step 3 globs "project sources". `regen` step 6 derives its search roots from the map's own
  `sources:` globs, because globbing the project root finds nothing in a polyrepo aggregator. That blind spot is fixed
  in `regen` and still open in `verify`. `SKILL.md` also says the scan covers every tracked file, which neither verb's
  wording states.

**The baseline:**
- **SH-33.** `show`'s stale footer names `<generated-at short sha>`, while `verify` anchors on the later of
  `generated-at` and the spec's own last commit. The footer can name a sha the check did not use.
- **SH-34.** `verify` diffs `<anchor>..HEAD`, so source edits left uncommitted after a regen are never reported stale.
  Whether that is intended is not stated (the *Known bias* paragraph covers a different case).
- **SH-36.** Step 3 defines **stale (unknown baseline)** for an in-repo anchor that resolves to nothing. The render's
  `unknown baseline` line describes only a missing `source-commits` entry for an external repo.
- **SH-35 (cosmetic).** The non-git sentence appears twice on consecutive lines at the end of *The stamp predates its
  own spec*.

## Acceptance criteria

- [ ] `verify` and `show` handle a missing **and** an empty map the way the router does, with the same message
- [ ] `verify`'s unmapped check uses the same search roots as `regen` step 6, stated once and pointed at from the other
- [ ] `show`'s footer names the anchor `verify` actually used
- [ ] `verify` says whether uncommitted source edits count, with the reason
- [ ] The render has a line for an in-repo unknown baseline, or step 3 reports it under an existing line
- [ ] The non-git sentence appears once
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- `regen`/template disagreements — TASK-239
- `regen`'s ask-steps — TASK-230

## Human test plan

- [ ] On an invented git fixture with an empty map, then a populated map whose spec was regenerated and committed, run
      `/specs verify` and `/specs show <area>`. Both print the router's message for the empty map, and the footer's sha
      matches the anchor `verify` reports

## Implementation plan

_Populated by `/tasks plan TASK-238` — leave empty until then._
