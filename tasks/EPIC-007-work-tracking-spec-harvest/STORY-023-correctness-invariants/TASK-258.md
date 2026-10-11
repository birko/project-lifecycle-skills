---
id: TASK-258
parent: STORY-023
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: done
# blocked: <reason> — add this line while the task is blocked, keeping its status; /tasks unblock removes it
priority: P2
assignee: unassigned
picked-by: fix-next
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

- [x] `/feature new` step 4 says what it writes for a question the grill dropped as moot, and for one the user deferred
- [x] `questions.md` § *States* names every step that sets `dropped`, and says who may rule a question moot. It must be consistent with `grill-me`, or `grill-me` changes to match
- [x] A deferred question's table state and its `decisions.md` row agree about whether it is still on the frontier
- [x] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- The grill's behaviour when nobody answers (TASK-259)
- Adding a new question state, unless the fix shows `dropped`/`open`/`resolved` genuinely cannot express "deferred". That would be a vocabulary change to decide first, not to make here

## Human test plan

- [x] Run `/feature new` on a throwaway idea where one answer makes a second question moot and another question is explicitly deferred; confirm the written `idea.md` table shows both with the states the fixed step names, and that `/feature pick` then computes the frontier without either of them blocking anything wrongly
  - **Passed 2026-10-11:** two fresh `claude -p` runs of `/feature new "Export a note as PDF"` on `%TEMP%\d258`, the
    answers given up front (A4 only, which makes size choice and per-size margins moot; email deferred until SMTP).
    Both wrote the two moot questions as `dropped — moot: <the A4 answer>`, and the email question as
    `resolved → D2` with a `proposed` D2 carrying the SMTP unblock condition. The brief named the answers, not the
    states. The `/feature pick` half was not run: with the moot rows `dropped`, their ids leave every `blocked-by`
    by the state's own rule, and no remaining row listed them. The runner holds the installed skills, which this
    behaviour drill needs

## Implementation plan

_Populated by `/tasks plan TASK-258` — leave empty until then._

## Outcome

**The fix.** `/feature new` step 4 now maps all four grill outcomes in a table:
- **answered** → `resolved → Dn`;
- **deferred** → `resolved → Dn` too, because deferring is an answer (*not now*), with the `proposed` row carrying
  the unblock condition for `/feature decide` to stamp `deferred`;
- **made moot** → `dropped — <the grill's reason>`, removed from every `blocked-by`;
- **not reached** → `open`.

It never writes a settled question as `open` and never omits one. `questions.md` § *States* now names `/feature
new` as a setter of `dropped` and of a deferred `resolved`. It also says who may rule a question moot: the user,
or the grill when an answer it just received does it and it says which. That matches `grill-me`, which needs no
change.

**Step 6 split.** Pre-fix, 2 runs with the same up-front answers: **the moot questions were lost or mislabelled.**
One run omitted them entirely. The other wrote "can users choose a paper size?" as `resolved → D2`, a decision row
for a question nobody needed to decide. Fixed: **2/2 wrote both as `dropped` with the reason.** **Fix-dependent:**
the moot rows. **Contract pins, not evidence:** the deferred question, which both pre-fix runs also wrote as
`resolved → Dn` with the defer note in a `proposed` row.

**Judgement calls.**
- *Deferred is `resolved`, not a new state.* The task's out-of-scope says to add a state only if the existing ones
  cannot express it. They can: the question is answered, and what remains is a verdict, which is `decide`'s
  frontier, not the question table's. So the question is off the question frontier and the decision is on
  `decide`'s. That is AC3's agreement.

**Flagged, not fixed.** Nothing new.

## Progress log

- step 2 — picked; ranked above TASK-259 because a moot or deferred question written as `open` blocks its dependants on the frontier after a reset, and one left out loses its edges (key 3: a plausible wrong frontier, nothing reports it), reached on every `/feature new` whose grill drops or defers (key 2), and both sit in two adjacent places (key 4); TASK-259 is the unattended grill. Key 6 inert: both `correctness-invariants`
- step 3 — verified: held as written. Step 4 maps only answered and not-reached; § *States* gives `dropped` only to `/feature pick`'s resume branch; nothing says what a deferred question reads
- step 4 — layer: local (`skills/feature/verbs/new.md`, `skills/feature/questions.md`)
- step 5 — fix: step 4's outcome-to-state table (deferred → `resolved → Dn` with the unblock condition on the `proposed` row; moot → `dropped — <reason>`, removed from `blocked-by`; never `open`, never omitted); § *States* names both setters and who may rule a question moot. Lint green; drill 2/2 on `%TEMP%\d258`
- step 6 — reverted both files: pre-fix moot questions omitted (1 run) or written `resolved → D2` as a decision (1 run); fixed 2/2 `dropped` with reason. Fix-dependent = the moot rows; contract pin = the deferred row (same both sides)
- step 7 — respecced feature-lifecycle (open-questions requirement: moot and deferred rows, who may rule moot; scenario "A moot question and a deferred one"); `generated-at` restamped
- step 8 — handed to /tasks close --unattended; outcome in status:, commit in git log
