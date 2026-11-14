---
id: TASK-372
parent: null
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: done
picked-by: fix-next
# blocked: <reason> — set by /tasks block, never by hand; status stays as it is; /tasks unblock removes it
priority: P3
# assignee — one of: agent (default), unassigned, human, or an installed agent type's name; ai is read as agent, never written
assignee: agent
created: 2026-11-13
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: []
pr: null
github-issue: null
jira-key: null
---

# Respec four spec areas whose sources changed without a respec

## Context

Found 2026-11-13 at TASK-067's close, by counting, for each spec area, the source commits since its `generated-at`
that did **not** also change the spec:

| Area | Unspecced source commit |
|---|---|
| `feature-lifecycle` | af904eb (TASK-366: `/feature status` takes `triage`'s timestamp form) |
| `specs-from-code` | eaefe24 (TASK-210: `verify` and `regen` examples renamed to invented paths) |
| `idea-interrogation` | 1648d29 (TASK-260: `grill-me`'s description) |
| `glossary-and-adrs` | be3e932 (TASK-275: `domain`'s scope pointer and record history) |

`test-authoring` is the fifth, and is TASK-359's.

**Added 2026-11-13: FEATURE-005's DV8.** FEATURE-005 (UX baseline) was created as a backfill for TASK-293, and no spec
lists it in `shaped-by`, because TASK-293's commits predate the `feature:` link. `/specs regen --feature FEATURE-005`
is DV8's own fix path, and recomputes the provenance of the areas TASK-293 changed (`change-review` for
`verify-conventions`, `feature-lifecycle` for `feature prototype`).

Some of these changes are wording the spec may not state at all, so the regen may produce no diff. That is a valid
outcome, and it moves the stamp honestly.

**Loose on purpose:** tree maintenance, not a review finding (`AGENTS.md` § Working rules, *A task outside a pool*).

## Acceptance criteria

- [x] `/specs regen` has run for each of the four areas, and `--feature FEATURE-005` so DV8 no longer fires for it, each diff reviewed as "was this change intended?", and each
      stamp names the commit it was regenerated at
- [x] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- `test-authoring`: TASK-359
- DV7's baseline disagreement: TASK-371

## Human test plan

N/A — the regen's own diff review is the check.

## Implementation plan

Inline: read each unspecced commit, check whether its spec states the changed text, regenerate scoped, then `--feature FEATURE-005`'s provenance and expected-change check.

## Outcome

**The regen, area by area (each diff reviewed as "was this change intended?"):**
- **`feature-lifecycle`, `specs-from-code`, `idea-interrogation`, `glossary-and-adrs`:** no body change. None of them
  states the text their unspecced commits changed (a timestamp form, example paths, a skill description, a record
  history and a pointer), so the stamp moves and the requirements stay verbatim, per the stable-wording rule.
- **`--feature FEATURE-005`:**
  - **`change-review` had an expected change missing.** D2 (approved) puts the UX baseline into `/verify-conventions`, and
    the smell-baseline requirement still described one inventory. It now names both inventories and what each applies
    to, with a scenario for a confirmation guarding a reversible action. **Matches an approved decision** (D2), so clean.
  - **`feature-lifecycle`** already specs D3 (the prototype check), so only provenance changed.
  - **`shaped-by` gains FEATURE-005 on both areas**, from TASK-293's two subject-led commits (c9f705a, b2729b1), which
    touched `skills/verify-conventions/**` and `skills/feature/**`. Both resolved, so `shaped-by-unresolved` is unchanged.
- **Stamps:** all five name the commit they were regenerated at.

**Result.** By `/specs verify`'s rule, the only stale area left is `test-authoring` (TASK-359), and FEATURE-005's DV8
no longer fires.

## Progress log

- step 2 — picked by the user's go-ahead on the named next pick; loose (tree maintenance), so outside the ranked pool, recorded rather than ranked
- step 3 — verified: the four areas each had exactly one unspecced source commit; FEATURE-005 in no `shaped-by`
- step 5 — scoped regen of five spec areas: one requirement and one scenario in change-review, FEATURE-005 provenance on two areas, five restamps
- step 6 — check: staleness under verify's anchor leaves only test-authoring; lint passes
- step 8 — closed inline; commit in git log
