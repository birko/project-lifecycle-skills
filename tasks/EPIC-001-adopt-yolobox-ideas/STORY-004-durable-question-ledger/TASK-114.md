---
id: TASK-114
parent: STORY-004
feature: null
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: done
priority: P2
assignee: agent
created: 2026-09-08
depends-on: [TASK-115]
blocks: []
# findings: ids this task remediates, from a review/audit/harvest/drill pass. Prefixes: see /tasks intake
findings: []
pr: null
github-issue: null
jira-key: null
---

# `feature` reconciles an `idea.md` written before the question table existed

## Context

**Re-cut 2026-10-04 by TASK-195** under `skills/tasks/slicing.md`. This task used to be "The question table — the
shape every other task in this story reads", carrying the table *and* (merged 2026-09-26) TASK-119's reconcile.
The table alone fails H3 (a shape no verb writes or reads), so its shape criteria moved to TASK-115, which lands
the table with its writer and reader. This task keeps the reconcile half. Its priority moved with the
foundational work: TASK-115 is now P1, this one P2. **Edge:** TASK-115 defines the shape this task upgrades
older files to, so TASK-115 `blocks` it. TASK-115 also *recognises* a pre-table file and says so; this task
upgrades one.

### Merged in 2026-09-26: TASK-119 — `feature` reconciles an `idea.md` written before the question table existed

_Merged because the table and the reconcile of older idea.md files ship together; the table alone makes /feature pick report "no open questions" on every existing feature. The original file stays, cancelled, at `tasks/EPIC-001-adopt-yolobox-ideas/STORY-004-durable-question-ledger/TASK-119.md`._

**Derived from a convention, not from STORY-004's text** — recorded that way deliberately, so a reader
does not go looking for the sentence that asked for it.

`AGENTS.md` § *An owner verb reconciles; it does not assume*: a verb owning a file shape must answer
*"is this instance current?"*, not only *"does it exist?"* — because **existing is not current**. The
shape gains fields, and an instance written before one existed looks complete from outside.

TASK-115 gives `idea.md` a field it never had. Every `idea.md` already on disk therefore becomes an
older instance of a shape whose owner is `[[feature]]`. Without this task, such a feature stays on the
old shape forever: TASK-115 makes `/feature pick` say so rather than report *"no open questions"*, but
nothing brings the file up to date. **A caller still cannot get from "this file is old" to "this file is
current" except by hand.**

#### The population is real, not hypothetical

Consumer repos already carry the old shape at scale — one has 94 features, another 18, a third 6. This
is the same class of problem as TASK-059 (repos on an older layer), one level down: not a missing
artifact, a **stale shape inside a present one**.

#### Scope note

The layer inventory's `docs/features/` row is owned by `[[feature]]`, so this is **not** a
`new-project` / `adopt-project` parity change. Checked rather than assumed — the parity rule is about
rows in `LAYER.md`, and this changes a file's interior, not the inventory.

## Acceptance criteria

*From TASK-119:*

- [x] An older instance is reconciled **in place**: add what is missing, never re-decide what is there.
      Existing prose questions are carried into rows or left as fog **with the rule applied**, not
      silently dropped
- [x] The verb reports **already current** distinctly from **brought up to date** — the two must not
      print the same line
- [x] Reconciliation is offered, not imposed: a user who declines gets a recorded declination rather
      than a silent skip that repeats next run
- [x] Nothing restates TASK-115's shape or states
- [x] `bash .github/workflows/skills-lint.sh` passes

(TASK-119's first criterion, telling a pre-table `idea.md` from a current one, moved to TASK-115 at the re-cut,
because `pick` must not misread an older file the moment the table exists.)

## Out of scope

- **The table, `/feature new` writing it and `/feature pick` reading it** — TASK-115.
- **`claimed-by`** — TASK-257.
- **`grill-me` frontier rounds and the `research` type** — TASK-117.

*From TASK-119:*

- **Reconciling repos on an older universal layer** — TASK-059 owns that, one level up.
- Bulk-migrating a consumer's features unattended. Whether a 94-feature repo is done in one pass is a
  decision for whoever runs it, and if it needs machinery that is its own task.
- Changing `decisions.md`, which is unaffected by the table.

## Human test plan

*From TASK-119:*

- [x] Take a real `idea.md` written before this story — a consumer repo has many — and run the reconcile.
      Expected: existing prose questions survive, the report distinguishes *already current* from
      *brought up to date*, and a second run reports the first. Withhold all three expectations from any
      cold runner's brief.

## Implementation plan

_Populated by `/tasks plan TASK-114` — leave empty until then._

## Progress log

- 2026-10-05 — Picked. **Owner:** `skills/feature/questions.md` § *Bringing a pre-table section up to date*, because the owner of the shape owns its upgrade. The section is found by a heading **starting** `## Open questions` (real files reword it). Item → row mapping: names a decision → `resolved → Dn`; answer with no decision → `resolved — <answer as written>` (the `resolved` state was extended for this, so no decision is ever invented); precise and unanswered → `open`, with no invented edge; vague → Fog verbatim; template placeholders → left out and counted. The question wording and the heading stay as they are. Report lines: `brought up to date — <counts>` vs `current`, plus the pre-table and kept-by-choice lines in § *Current or pre-table*. **Declined** → a dated line under the heading stops the offer; **no answer** writes nothing and the offer comes back. **`pick`:** gate Q's pre-table branch offers it (question verbatim, three answer paths), and step 6's confirmation always names the open-questions state.
- 2026-10-05 — **A defect in my own first version, caught by the drill.** Converting FEATURE-004's items to rows dropped what the bullets carried beyond the decision id: an accepted limitation, a deferred D6, "this reverses the out-of-scope note". The rule now keeps the old list **verbatim in a collapsed `<details>` block** under the table, so the rows make the frontier computable and nothing is lost.
- 2026-10-05 — **Spec:** `feature-lifecycle`'s pick requirement and pre-table scenario are updated, and a new requirement (upgrade in place, on offer) gets two scenarios.
- 2026-10-05 — **Human test plan — passed**, on **copies** of WorkoutTracker's real `docs/features/` (7 features, written before the table; the consumer repo was untouched). Folder `%LOCALAPPDATA%\Temp\d114b`, outside every repo, with a copy of `skills/`; runners `claude -p --disable-slash-commands --permission-mode acceptEdits`, file edits only under the copied `docs/features`. Expected results were written down before the runs. **Coldness:** C, D and E listed no skills; A's skills line was not captured.
  - **A (FEATURE-006, upgrade accepted):** `brought up to date — 14 rows (9 resolved → D, 5 resolved with an answer, 0 open), 0 fog, 0 placeholder line(s) removed`. The questions were kept as written, the original 14 items were kept verbatim in the block, and `decisions.md` was untouched.
  - **C (FEATURE-003, declined):** the dated "kept by choice" line was written.
  - **D (FEATURE-006 again, fresh session):** `open questions: current`, no offer, no change.
  - **E (FEATURE-003 again, fresh session):** `pre-table, kept by choice on 2026-10-05`, no offer, no change.
  - A first round of runs was discarded: its brief said "answer Y to the *first* question", and on a `done` or `review` feature the first question is the sign-off confirmation or gate E. That was correct behaviour on the brief's error. One runner there noted that `pick` does not say what follows an `n` at gate E. That is outside this task; recorded, not filed, as a single observation.
- 2026-10-05 — Close review. Intent: all five criteria plus the test plan. Correctness: prose only, and lossless on real data. Comments: none. Conventions: the owner reconciles in place and reports "already current" distinctly from "brought up to date"; ask-steps carry their question and their answer-less path. → **done**.
