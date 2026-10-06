---
id: TASK-258
parent: STORY-023
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: todo
# blocked: <reason> — add this line while the task is blocked, keeping its status; /tasks unblock removes it
priority: P2
assignee: unassigned
created: 2026-10-06
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [SH-83, SH-84]
pr: null
github-issue: null
jira-key: null
---

# A question the grill drops or defers during `/feature new` has nowhere to land in the table

## Context

Found by the `idea-interrogation` spec harvest (2026-10-06, TASK-080, EPIC-007 fourth pass) at `07de657`, and
checked against the files before intake.

`grill-me` produces four outcomes for a question. `/feature new` step 4, which writes the open-question table from
the grill, maps only two of them:

| Grill outcome (`skills/grill-me/SKILL.md`) | `/feature new` step 4 writes |
|---|---|
| answered | `resolved → Dn` |
| not reached | `open`, with its edges |
| **made moot by another answer** — "dropped, and says why" (§ *Ask in rounds*, last bullet) | nothing defined |
| **explicitly deferred** — "every open question has an answer or an explicit 'defer'" (§ *When the grill is done*), emitted as `<topic> → deferred: <unblock condition>` | nothing defined |

- **SH-83 — dropped.** `skills/feature/questions.md` § *States* does have `dropped — <reason>`, but its *Set by*
  column names only `/feature pick`'s resume branch, "when the user rules it moot". `grill-me` drops a question on
  its own judgement, when an answer made it moot, and does so inside `/feature new` too. So the same outcome is
  user-ruled in one place and grill-ruled in another. During `/feature new` it either gets written as `open`, which
  is wrong and leaves it blocking its dependants, or it is omitted, which loses the question and its edges.
- **SH-84 — deferred.** The question table has no deferred state. Step 5 turns every grill line into a `proposed`
  decision ("one row per branch the grill surfaced"), so a deferred branch probably becomes a decision row, but
  step 4 does not say whether its question reads `resolved → Dn` or `open`. Those two make opposite frontier claims.

Both sit in the same two places (`feature/verbs/new.md` step 4 and `questions.md` § *States*), so one edit fixes both.

## Acceptance criteria

- [ ] `/feature new` step 4 says what it writes for a question the grill dropped as moot, and for one the user deferred
- [ ] `questions.md` § *States* names every step that sets `dropped`, and says who may rule a question moot. It must be consistent with `grill-me`, or `grill-me` changes to match
- [ ] A deferred question's table state and its `decisions.md` row agree about whether it is still on the frontier
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- The grill's behaviour when nobody answers (TASK-259)
- Adding a new question state, unless the fix shows `dropped`/`open`/`resolved` genuinely cannot express "deferred". That would be a vocabulary change to decide first, not to make here

## Human test plan

- [ ] Run `/feature new` on a throwaway idea where one answer makes a second question moot and another question is explicitly deferred; confirm the written `idea.md` table shows both with the states the fixed step names, and that `/feature pick` then computes the frontier without either of them blocking anything wrongly

## Implementation plan

_Populated by `/tasks plan TASK-258` — leave empty until then._
