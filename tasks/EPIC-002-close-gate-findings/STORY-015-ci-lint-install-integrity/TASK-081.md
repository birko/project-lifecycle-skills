---
id: TASK-081
parent: STORY-015
feature: null
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: todo
priority: P2
assignee: agent
created: 2026-08-31
depends-on: []
blocks: []
# findings: ids this task remediates, from a review/audit/spec-harvest pass (CR-* SEC-* SH-* VC-*)
findings: [CR-066-1, CR-066-2, CR-066-3, CR-066-4]
pr: null
github-issue: null
jira-key: null
---

# One number now names two different lint checks

## Context

**Spawned from TASK-066's close gate on 2026-08-31** (`/code-review`, which overran its scope onto the
18 unpushed commits and found this). Four findings, deliberately one task: they are the same renumbering
seen in four files, and splitting them buries the connection that makes them cheap to fix together.

Inserting **check 4 — cross-skill flags** pushed install-root drift from check 4 to check 5. The script
renumbered; the prose about it did not.

| Site | Says | Actually |
|---|---|---|
| `AGENTS.md:214` | *"today check 4, install-root drift"* | that is check **5** |
| `AGENTS.md:265` (§ Commands) | *"The lint's check 4 reports install-root drift"* | check **5** |
| `AGENTS.md:190` | *"check 4: every `/skill verb --flag` … must name a flag the receiving verb declares"* | correct — and this is what makes it a defect rather than a typo |
| `.github/workflows/skills-lint.sh:159` | comment: *"localize them so check 4 cannot clobber them. **It runs last today**"* | `check_root` **is** check 5; check 4 now runs *before* it, so the stated reasoning describes a relationship that no longer exists |
| `.github/workflows/skills-lint-test.sh:70` | *"passes trivially when check 4 is absent altogether"* with *"(check 5 here)"* bolted on | the guard asserts on `'== 5. install roots'`; prose and assertion disagree |

**Why this is worse than untidy.** `AGENTS.md` is the file `/verify-conventions` lints against, and it now
uses "check 4" for two different checks three sections apart. A reader following § Commands to debug an
advisory finding lands on the wrong part of the script. `skills-lint.sh:159`'s comment is the sharper half:
it justifies a `local` declaration with a run-order claim that is now false, so the next person hardening
that function localizes the wrong variables and the vacuous-pass bug this repo has already been bitten by
comes back.

**Separately, a heading is in the wrong place.** `skills-lint-test.sh:142-147` inserted the four new check-4
cases with a `printf 'Check 4 — cross-skill flags'` header *in the middle* of the check 1–3 case list, so the
five cases that follow (`skill folder with no SKILL.md`, `broken link in a companion doc`, `a whole skill tree
is missing`, …) now print under the check-4 heading. A failure in one of those sends the reader to the wrong
check — the same misdirection as the stale numbers, which is why it is grouped here.

## Acceptance criteria

- [ ] `AGENTS.md:214` and `:265` name the check that actually reports install-root drift
- [ ] No single check number in `AGENTS.md` refers to two different checks
- [ ] `skills-lint.sh:159`'s comment states a run-order relationship that is true, or stops relying on one
- [ ] `skills-lint-test.sh:70`'s prose and its `'== 5. install roots'` assertion agree
- [ ] The `Check 4 — cross-skill flags` header sits above the check-4 cases only; the check 1–3 cases print under a check 1–3 heading
- [ ] `bash .github/workflows/skills-lint.sh` and `skills-lint-test.sh` both pass

## Out of scope

- Check 4's **matching** being weaker than its stated contract — **TASK-082** owns that; this task only fixes what the prose *calls* each check.
- Renumbering the checks again, or making install-root drift fatal. `AGENTS.md` § Testing settles the second, and the first would re-create this defect.

## Human test plan

- [ ] Read `AGENTS.md` § Commands, follow its check number into `skills-lint.sh`, and confirm you land on the code that reports install-root drift
- [ ] Force one check 1–3 case to fail and confirm the heading printed above it names the check that failed

## Implementation plan

_Populated by `/tasks plan TASK-081` — leave empty until then._
