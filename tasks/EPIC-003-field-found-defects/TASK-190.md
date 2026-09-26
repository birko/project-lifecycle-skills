---
id: TASK-190
parent: EPIC-003
feature: null
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: done
priority: P1
assignee: unassigned
created: 2026-09-26
depends-on: []
blocks: []
findings: [FIELD-004]
pr: null
github-issue: null
jira-key: null
---

# pi refuses six skills: descriptions that are invalid YAML or over 1024 characters

## Context

Reported from real use on 2026-09-26: pi's loader prints `[Skill conflicts]` for six skills.

| Skill | pi's error | Cause |
|---|---|---|
| `adopt-project`, `fix-next`, `verify-intent` | `Nested mappings are not allowed in compact mappings` | unquoted `description:` contains `: ` — a plain YAML scalar cannot |
| `new-project` (1105), `review-comments` (1209), `verify-conventions` (1534) | `description exceeds 1024 characters` | the Agent Skills limit on `description` |

Also found while measuring: `skills-pi/review`'s description contains ` #N`, which YAML reads as the
start of a comment — the description is silently truncated there. No error, so pi did not report it.

The lint never parsed the frontmatter as YAML; check 1 only greps for `^description:`. So all
seven passed CI.

## Acceptance criteria

- [x] Check 1 fails on an unquoted single-line `description:` containing `: ` or ` #`, and on a description over 1024 characters.
- [x] Check 1 also enforces pi's name rules (≤64 chars, `a-z0-9-`, no leading/trailing/doubled hyphen) and rejects a skill name present in both trees.
- [x] `AGENTS.md` § Framework / stack states every frontmatter rule pi enforces, what pi does when each is broken, and a budget for descriptions.
- [x] Test cases in `skills-lint-test.sh` fail without the new checks.
- [x] All seven descriptions fixed; trigger phrases kept (the long three trimmed, not stripped of triggers).
- [x] `bash .github/workflows/skills-lint.sh` and the test suite pass.

## Out of scope

- The § Comments measurement table in `AGENTS.md`, whose rows for the two lint scripts this change made stale: TASK-191.
- Block-scalar descriptions (`description: >` or `|`) skip the `: `, ` #` and length checks, because the lint reads one line. Decided not to extend it: no skill uses one, and `AGENTS.md` now says to keep the description on one line.
- The descriptions of the skills pi did not report were not trimmed. The longest is 983 bytes, under the limit.

## Human test plan

- [x] Start pi (`pi --provider finstat --model finstat`) and confirm `[Skill conflicts]` no longer lists any of the six skills.

## Progress log

- 2026-09-26 — Edited before `/tasks pick`: the task was filed first and then worked without the pick, so it moved `todo → done` at close with no recorded `in-progress`. Recorded here rather than backfilled.
- 2026-09-26 — Lint check 1 extended (description YAML shape and length, name shape, unique names across trees); seven descriptions fixed; `AGENTS.md` § Framework / stack gained pi's frontmatter rules. Suite 63/63; with the new checks removed, all six new failing cases fail.
- 2026-09-26 — Human test run by the user: pi's `[Skill conflicts]` is empty.
- 2026-09-26 — Close review. Standards: pass after two lint comments that restated the new AGENTS.md table were reduced to a pointer. Intent: pass, all criteria met. Correctness: pass. `${#desc}` counts bytes under a C locale, which is stricter than pi's character count and never looser; noted in the lint. The duplicate-name error now prints under the check 1 header. Security: not applicable, no security surface. Comments: pass after the reduction.
- 2026-09-26 — A scripted edit read `skills-lint.sh` in universal-newline mode. That turned the literal CR inside check 5's awk bracket into a line break and converted the file to LF, and check 5 then silently found no blocks. The suite caught it (6 check-5 cases failed). The file was restored to HEAD's bytes, and the edits were reapplied line by line, keeping each line's ending: a 14-line diff, suite 63/63.
