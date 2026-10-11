---
id: TASK-234
parent: STORY-023
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: done
# blocked: <reason> — add this line while the task is blocked, keeping its status; /tasks unblock removes it
priority: P2
assignee: unassigned
picked-by: fix-next
created: 2026-10-03
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [SH-43, SH-44]
pr: null
github-issue: null
jira-key: null
---

# `/feature status` re-collects what it was told to consume, and its phase rules leave ledgers with no phase

## Context

Found by the feature-lifecycle spec harvest (2026-10-03, EPIC-007, spec committed in b24eb8b). Both findings are in
`skills/feature/verbs/status.md`, steps 1–3, and would be fixed in one pass over the derivation.

- **SH-43 — two collections.** Step 1 says to run [[roadmap]]'s Cross-tree pass and consume its output model, "don't
  re-enumerate", and buckets the tasks from the model. Step 3 then greps `tasks/` for `feature: FEATURE-NNN` itself and
  buckets again. Two collections of one fact can disagree, for example on a task that is taken on a branch.
- **SH-44 — the phase rules do not cover every ledger.** Step 2's rules:
  - `idea` needs no decisions stamped and no prototype; `prototyping` needs a prototype artifact; `deciding` needs the
    prototype done; `building` needs an `approved`/`changed` decision.
  - A ledger with no prototype and some rows stamped `deferred`/`removed` but none approved matches none of them. Nor
    does a ledger with only `deferred`/`removed` rows that is not `dropped`.
  - Whether a recorded `Skipped — <reason>` counts as "prototype done" is not said.
  - Where both `prototyping` and `deciding` hold, no precedence is given.

## Acceptance criteria

- [x] Step 3 reads the tasks from step 1's model and does not grep again, or step 1 stops claiming it
- [x] Step 2's rules assign exactly one phase to every combination of prototype line (Built / Skipped / Pending / N/A)
      and decision counts, with an evaluation order stated
- [x] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- DV1 reading the phase when `status.md` is absent — TASK-207
- Who writes the prototype line — TASK-240

## Human test plan

- [x] On an invented `docs/features/` with three ledgers (no prototype + one `deferred` row; only `deferred` rows;
      `Skipped` + mostly `proposed`), run `/feature status`. Each gets one phase, and a second run agrees
  - **Passed 2026-10-11:** two fresh `claude -p` runs of `/feature status` on `%TEMP%\d234`, with the three
    ledgers plus a fourth (a standing Built prototype, rows mostly `proposed` and one `deferred`). Both runs gave
    FEATURE-001 `deciding`, FEATURE-002 `deciding`, FEATURE-003 `deciding` and FEATURE-004 `prototyping`, in
    `status.md` and the index alike. The brief was the bare command. The runner holds the installed skills, which
    this behaviour drill needs

## Implementation plan

_Populated by `/tasks plan TASK-234` — leave empty until then._

## Outcome

**The fix.** `/feature status` worked out a feature's phase from six rules that overlapped in some cases and
left gaps in others. A feature whose decisions were all deferred matched no rule, so each run made up a phase.
The rules are now a table read top to bottom, where the first match wins. That gives exactly one phase for every
combination of the prototype line (Built, Built then deleted, Skipped, nothing recorded) and decision counts. A
recorded Skip counts as the prototype step being over. Only a prototype that is still standing holds a feature
at `prototyping`. A ledger with nothing but deferred or removed rows reads `deciding`, with a next step of reopening a row
or dropping the feature. Step 3 now takes the feature's tasks from step 1's collection instead of searching
`tasks/` a second time, and reads task files only for their test plans, which that collection does not carry.

**Step 6 split.** Pre-fix text, 2 runs on the same fixture: **FEATURE-002 (every row deferred) split** between
`deciding (on hold)` and `idea`, and both runners said no rule covered it. **FEATURE-004 (a standing prototype)
read `deciding` in both**, where the fixed text gives `prototyping`. Fixed text: 2/2 runs agreed on all four.
**Fix-dependent:** FEATURE-002's agreement and FEATURE-004's phase. **Contract pins, not evidence:**
FEATURE-001 and FEATURE-003 read `deciding` in all four runs. Step 3's single collection is not observable on a
fixture with no tasks, so it rests on the text.

**Judgement calls.**
- *A standing prototype outranks deciding.* While the artifact exists, the stakeholder is still reacting to it.
  Once it is deleted or was skipped, the remaining work is verdicts.
- *All-deferred is `deciding`, not a new phase and not `idea`.* `idea` means nothing stamped, and these rows were
  stamped. A ninth phase would need every reader of the phase (`pick`, the index, the roadmap) to learn it.
- *Rule 2 ignores cancelled tasks.* Without that, a feature with one cancelled task could never reach `review`
  and read `building` forever. That is the same every-combination gap, so it is folded in. Whether `done/total`
  counts cancelled tasks is left as it was.

**Flagged, not fixed.** Nothing new.

## Progress log

- step 2 — picked; ranked above TASK-223 because a ledger with no prototype and only `deferred`/`removed` rows gets no phase, so the stakeholder rollup shows an invented or blank phase with nothing reporting it (keys 1, 3: a plausible wrong page), reached by every feature whose first verdicts are deferrals (key 2); TASK-223's miscount is a dashboard total. Keys 6 inert: both `correctness-invariants`
- step 3 — verified: held as written. Step 1 consumes [[roadmap]]'s model and step 3 greps `tasks/` again; step 2's six rules overlap (`prototyping` and `deciding` both hold on a built prototype with mostly `proposed` rows) and leave gaps (no prototype and only `deferred`/`removed` rows; `Skipped` unclassified). Also found in the same derivation: `review`'s "all tasks `done` or `verify`" can never hold for a feature with a `cancelled` task, so such a feature reads `building` forever. Folded in, since AC2 asks for every combination
- step 4 — layer: local (`skills/feature/verbs/status.md`)
- step 5 — fix in `skills/feature/verbs/status.md`: step 2 is an ordered six-rule table (stored marker; all non-cancelled tasks done/verify → `review`; approved/changed → `building`; standing Built prototype → `prototyping`; any deferred/removed, or Skipped / Built-then-deleted → `deciding`; else `idea`), with notes on the mirrors, the all-deferred next step and Skipped; step 3 reads tasks from step 1's model and only the files for test plans. Lint green; drill 2/2 on `%TEMP%\d234`
- step 6 — reverted: pre-fix 2 runs split on FEATURE-002 (`deciding (on hold)` / `idea`, both reporting no matching rule) and gave FEATURE-004 `deciding` twice; fixed 2/2 agree (`deciding` ×3, `prototyping`). Fix-dependent = FEATURE-002 agreement, FEATURE-004 phase; contract pins = FEATURE-001, FEATURE-003
- step 7 — respecced feature-lifecycle ("Coarse status is stored, phase is derived": the six ordered rules, prototype read from its line, all-deferred `deciding`; scenarios "Every decision deferred" and "A standing prototype outranks deciding"; "Status regenerates the rollup…": tasks read from the shared collection); `generated-at` restamped
- step 8 — handed to /tasks close --unattended; outcome in status:, commit in git log
