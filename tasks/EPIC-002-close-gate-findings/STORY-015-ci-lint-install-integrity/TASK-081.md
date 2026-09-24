---
id: TASK-081
parent: STORY-015
feature: null
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: done
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

- **Confirmed by a [[code-review]] pass 2026-09-08 (CR-2), which found the contradiction still live and named both sites:** `AGENTS.md:267` (the normative advisory rule) and `AGENTS.md:319` (the Commands block) still say *"check 4, install-root drift"*, while `:158` says check 5 for drift and `:216` says check 4 for flags. The consequence is sharper than a stale number: a reader following `:267` concludes the **flag** check must never fail the build.

**Confirmed again 2026-09-20 by two more independent readers** (TASK-160's verification), neither
holding this task in context. Reader Q states the direction explicitly: *"the hazard runs the other
way: `check_root` assigns both in its own loops, so without `local` it is the function that clobbers
the outer ones."* Reader P adds the sharpest evidence for the fix's shape: **this is now the only
numbered cross-reference left in the file, and it is the only wrong one** — every other has been
converted to a name (`:156` *"unlike the advisory install-roots check below"*, `:195` *"ADVISORY —
never touches `fail`"*). Four readers total have now reached this independently.

## Acceptance criteria

> **Repointed 2026-09-20 from TASK-151.** TASK-146 inserted a new check 5 and pushed install-root
> drift to **check 6**, so every line number and ordinal below was one renumbering behind. They are
> restated against the working tree at that date. Criterion 4 is the only one TASK-146 happened to
> clear; the other four are still open, so this task is **not** closable as already-resolved.

- [x] The § *A repo-level check* bullet names the check that actually reports install-root drift — it says **check 5**, which is the universal-conventions copies check. (The § Commands block, `# The lint's check 6 reports install-root drift`, is already correct.) **Cited by section and quoted text, not by line number**: the first repoint said `:182`/`:477` and `:477` went stale inside the same commit, because that commit also rewrote § Comments five lines further up. A task about stale citations must not ship one.
- [x] No single check number in `AGENTS.md` refers to two different checks — today **`check 5`** names install-root drift in § *A repo-level check is answered by what the repo tracks* and the conventions-copy check in § *Where the same prose must exist in two files*
- [x] `skills-lint.sh:222-223`'s comment states a relationship that is true, or stops relying on one. **Amended 2026-09-20 — the premise here was wrong, not merely stale.** It says *"localize them so check 4 cannot clobber them. It runs last today"*. **Check 4 never touches `tree` or `d` at all** — it uses `src`/`inv`/`skill`/`verb`/`recv`/`flag`; the two variables are set by the loops at `:51` and `:60`, and the exposure runs the **other way**: an unlocalised `check_root` would clobber *them*. So the fix is not renumbering 4 → 6; it is naming the right loops and the right direction. Found independently by two cold readers running TASK-141's test plan, neither of which had this task in context.
- [x] `skills-lint-test.sh:70`'s prose and its install-roots assertion agree — both now read check 6 (`'== 6. install roots'`); cleared incidentally by TASK-146
- [x] The `Check 4 — cross-skill flags` header at `skills-lint-test.sh:237` sits above the check-4 cases only; `:250-252` (`skill folder with no SKILL.md`, `broken link in a companion doc`, `a whole skill tree is missing`) are check 1–3 cases still printing under it
- [x] `bash .github/workflows/skills-lint.sh` and `skills-lint-test.sh` both pass

## Out of scope

- Check 4's **matching** being weaker than its stated contract — **TASK-082** owns that; this task only fixes what the prose *calls* each check.
- Renumbering the checks again, or making install-root drift fatal. `AGENTS.md` § Testing settles the second, and the first would re-create this defect.

## Human test plan

- [x] Read `AGENTS.md` § Commands, follow its check number into `skills-lint.sh`, and confirm you land on the code that reports install-root drift
- [x] Force one check 1–3 case to fail and confirm the heading printed above it names the check that failed

## Implementation plan

Sites as of `1d5662c`. The fix shape follows reader P's evidence on this task: every other cross-reference
in these files has become a **name**, and the numbered ones are the ones that went wrong — so where prose
refers to a check, name it; keep a number only where the number *is* the subject (§ Commands, the lint's
own banners).

| Criterion | Site | Fix |
|---|---|---|
| 1, 2 | `AGENTS.md` § *A repo-level check is answered by what the repo tracks* — *"`skills-lint.sh` check 5 *does* read machine state (install-root drift)"* | → *"`skills-lint.sh`'s install-roots check"*. After it, "check 5" in `AGENTS.md` names only the conventions-copy check (§ *Where the same prose must exist in two files*); the other install-root mentions already say 6 |
| 3 | `skills-lint.sh` `check_root`, the comment above its `local` | name the loops that actually own `tree` and `d` (the tree-existence loop and check 1) and state the real direction: `local` stops **this** function clobbering **them**; nothing reads them after it today, which is position, not safety |
| 5 | `skills-lint-test.sh` — `skill folder with no SKILL.md`, `broken link in a companion doc`, `a whole skill tree is missing` printing under `Check 4 — cross-skill flags` | move the three `case_is` lines up into the *Broken input must fail* group they belong to. Order only; the case count is unchanged |

Then both suites, `AGENTS.md` § Comments table if the counts move (the lint loses no lines; the test file
none), and the two human-test steps run literally.

**Outcome (2026-09-24).** All five open criteria met.
- `AGENTS.md` § *A repo-level check is answered by what the repo tracks* now says *"`skills-lint.sh`'s
  install-roots check"* — a name, not a number. "check 5" in `AGENTS.md` now means only the
  conventions-copy check (§ *Where the same prose must exist in two files*).
- `check_root`'s comment names the loops that own `tree` and `d` (the tree-existence loop and check 1)
  and states the direction the four readers found: `local` stops this function clobbering them.
- The three check 1-3 cases moved into *Broken input must fail*; order only, 56 cases before and after.

**Human test plan, run literally:** (1) § Commands' *"check 6 reports install-root drift"* → `== 6.
install roots` → `check_root`. (2) A throwaway copy of the suite with `skill folder with no SKILL.md`'s
expectation flipped printed `FAIL  skill folder with no SKILL.md` under **Broken input must fail**, and
`Check 4 — cross-skill flags` only after it. Copy deleted.

**Gate, inline** — one prose line, two comment lines, three moved lines: standards ✅ (a named reference
instead of an ordinal is what reader P's evidence recommends; no new pattern) · fidelity ✅ criteria 1-3, 5,
6 · correctness ✅ the only executable change is case order, 56/56, lint exit 0 · comments ✅ the rewritten
comment states a true relationship. Security: not applicable. `AGENTS.md` § Comments table re-measured
(test file 392 → 393, a blank line between groups; `skills-lint.sh`'s TASK-081 finding removed).
