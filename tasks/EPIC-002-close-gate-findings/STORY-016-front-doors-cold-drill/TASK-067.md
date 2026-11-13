---
id: TASK-067
parent: STORY-016
feature: null
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: done
priority: P2
assignee: agent
created: 2026-08-22
depends-on: [TASK-032]
blocks: []
# findings: ids this task remediates, from a review/audit/spec-harvest pass (CR-* SEC-* SH-* VC-*)
findings: [DRILL-053-10]
pr: null
github-issue: null
jira-key: null
picked-by: fix-next
---

# Nobody says what the empty case looks like, so every agent invents one

## Context

**From the 2026-08-22 cold drill** (STORY-016 § Provenance). Two unstated defaults the drill had to
invent, grouped because the fix is one pass: *what does the degenerate case render as?*

### (a) `## Conventions` when the stack is "none"

`new-project/SKILL.md:75` says to *"seed the stack's idiomatic defaults"* and gives examples for
TS / Python / .NET / Go. `:79` says every subsection *"either carries a real rule or is removed — never
a dangling token."* With stack `none yet / docs-only` there are no idioms, so the two rules leave no
legal output.

The drill wrote real markdown-repo rules (kebab-case files, resolving relative links, id formats) and a
Testing line stating plainly that there is no runner **and** that wiring one is part of the change that
picks a stack. It rejected deleting the subsections wholesale on the grounds that it would leave
`/verify-conventions` nothing to lint — which is `:79`'s own stated rationale, so the reasoning is sound
and it should not have had to derive it.

### (b) No documented empty render for a generated file

Neither `/feature status` step 7 nor `tasks triage` step 7 says what a **zero-item** render looks like.
Triage covers the omit-when-empty sections, but not the tree with no epics or the index with no features.
The drill invented placeholder prose for both.

**This is why this repo's own features index carries a hand-written line.** `docs/features/README.md` has
`_No features yet._ See EPIC-001 in tasks/ — the current work is deliberately task-only.` — not derivable
from the template's three tokens, and forbidden by `AGENTS.md`'s *"nothing goes in a generated file that
its verb cannot derive."* It exists because there was no defined empty render, so somebody wrote one.

**Two independent passes reached that line from opposite directions** at TASK-053's gate: the cold drill
flagged the line itself, and `/code-review` caught the same line being used as *justification* for
suppressing the dashboard's DV5 drift callout. That is the cost of an undefined degenerate case — it does
not stay a formatting question, it becomes evidence somebody reasons from.

### Why one task

Both halves are "the generator was specified for the populated case only". One pass through
`new-project` step 3, the `feature status` template and `triage` fixes both, and splitting them invites
two different answers to the same question.

### Ordering — TASK-032 lands first

Criterion 3 below names two outlets for the hand-written line, and **TASK-032 is likely to supply a
third and better one**: it builds a hand-editable record for a divergence that has been *accepted*,
which is precisely what that line is being used as. Landing this task first means choosing a home for
the stance before TASK-032 has decided what such a record looks like — the "two different answers to
the same question" that § *Why one task* above exists to prevent, one level up.

The edge is `depends-on`, **not a `blocked` status**: half (a) is wholly independent of TASK-032, so
`/tasks pick` should warn about the open dependency and still let the task through.

## Acceptance criteria

- [x] `## Conventions` has a defined shape for a project with no stack — real rules, no dangling token, and something for `/verify-conventions` to lint
- [x] `/feature status` and `tasks triage` each document their **zero-item** render, so it is derivable rather than invented
- [x] This repo's `docs/features/README.md` no longer carries the hand-written line: either the empty render covers it, or the content moves to the EPIC body's `§ State as of` where non-derivable commentary belongs
- [x] Regenerating both files on this repo produces exactly what is on disk — the test that the render is now derivable
- [x] The chosen empty renders say something useful; a blank section that reads as a bug is not a fix
- [x] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- The BRIEF conditionality and the missing purpose question — **TASK-064**. Same drill, same file, but those are about intake and conditionality rather than what a generator emits.
- The record-routing table in the seed guide — **TASK-056**.
- `tasks/README.md`'s dashboard template gaining a priority breakdown — **TASK-039**.
- The other drill findings — separate tasks under STORY-016.

## Human test plan

- [x] Scaffold a docs-only project with no stack and read its `CLAUDE.md § Conventions`: every subsection carries a real rule or is gone, and `/verify-conventions` has something to check
- [x] Run `/feature status` on this repo (zero features) and `git diff` — must be empty, proving the render is derivable
- [x] Run `/tasks triage` on a scratch tree with no epics and confirm the output reads as deliberate rather than broken

**All three passed 2026-11-13.**
- **Steps 1 and 3**, cold drill `%LOCALAPPDATA%/Temp/d067`: `/new-project` for "a docs-only knowledge base called
  fieldnotes … no stack yet", then `/feature status` twice, then `/tasks triage`.
  - **Coldness:** no skills listed and no Skill tool.
  - **`## Conventions`:** Framework/stack, Code structure, Naming and Testing each carried the new document-repo rule.
    UI/UX was removed, and the universal block matched its template exactly.
  - **The features index** rendered a `_None_` row, and the second render was identical.
  - **`tasks/README.md`'s tree** read `_None_` under `## Tree`, deliberate rather than broken.
- **Step 2, on this repo, which now has four features, not zero:** two cold runners ran `/feature status` (all
  features) on a clone (`%LOCALAPPDATA%/Temp/d067r`). The second run, over the first's output, changed **only the
  five timestamp lines**. The regenerated files were then copied in, with `{{PROJECT_NAME}}` set to this repo's
  folder name, as the verb derives it.
- **Two points from the d067 runner came from this task's own text**, fixed at the close:
  - the Testing line contradicted the universal "every capability gets tests" beneath it;
  - UI/UX was unstated for a docs-only repo.

## Implementation plan

_Populated by `/tasks plan TASK-067` — leave empty until then._

## Outcome

**The fix.**
- **(a) A project with no stack gets real `## Conventions` rules** (`new-project` step 3):
  - no stack yet, and adding one is a recorded decision;
  - one topic per file, with resolving relative links;
  - `kebab-case` names and the layer's id forms;
  - no test runner until a stack is picked, the universal test line reading as a rule waiting for code;
  - UI/UX removed.
  So `/verify-conventions` has something to lint.
- **(b) Both zero-item renders were already stated** by TASK-357: a `_None_` dashboard tree, and a `_None_`
  features-index row. This task's drill confirms them.
- **Criterion 3** was met before this task started: the hand-written "deliberately task-only" line left
  `docs/features/README.md` when FEATURE-001 to 004 arrived.
- **Criterion 4**, on the user's decision: this repo's features index and its four `status.md` rollups, last generated
  2026-10-04, were regenerated by `/feature status`, and a second run reproduced them except for timestamps.

**Step-6 split.** Behavioural, by the drills under Human test plan. No revert split: (a) is a new case, and (b) was
already in place.

**Judgement calls.**
- **Regenerating through cold runners, not by hand.** A generated file assembled by hand is the defect § *Generated
  files are owned by their verbs* forbids, and a runner executing the verb is the honest way to show it is
  derivable.
- **The regenerated drift note is kept as derived, though 8 of its 13 DV7 entries are false.** They are false because
  [[roadmap]]'s DV7 measures from `generated-at` alone where `/specs verify` takes the spec's own commit, so a spec
  respecced in the same commit as its source reads stale. Hand-trimming the note would be the defect again; the rule
  is filed as TASK-371. The other 5 are genuinely behind: TASK-372 and TASK-359.
- **Picking this task exposed a false record of mine:** TASK-032's "task-only on purpose" acceptance reason.
  Corrected in ae020d1 on the user's decision (EPIC-001 kept with a true reason, EPIC-010's removed), before this
  task's work.

**Close gate (inline):**
- **Standards:** the no-stack rules sit in `new-project`, the owner of the seeding, and every generated file came from
  its verb.
- **Intent:** all six criteria met.
- **Correctness:** two drill points were fixed.
- **Security, comments:** not applicable.
- **CI:** `ci: main green — 1 workflow read`.

**Flagged.**
- **TASK-370**, filed: seed hint comments above their tokens, and `.gitignore`'s create/check asymmetry. Two runners
  each.
- **TASK-371**, filed: DV7's baseline.
- **TASK-372**, filed: four specs to respec.

## Progress log

- step 2 — picked; P2 correctness-invariants, unblocked by TASK-032 (done 2026-11-13). This repo's features index carries a hand-written line its verb cannot derive (key 1), the line TASK-053's review saw used as justification for suppressing a callout
- step 3 — verified: half (a) held. Half (b) and criterion 3 were already met by later work: TASK-357 (2026-11-13) stated both zero-item renders (`_None_` tree; a `_None_` index row), and this repo's hand-written "deliberately task-only" line left `docs/features/README.md` when FEATURE-001 to 004 arrived (2026-09 and 2026-10). Picking this task exposed that TASK-032's acceptance reason was false; corrected in ae020d1 on the user's decision
- step 3b — not planned: one bullet in one file
- step 4 — layer: local
- step 5 — fix in skills/new-project/SKILL.md (the `## Conventions` shape for stack "none yet / docs-only")
- step 7 — respecced project-baseline (seeding requirement), restamped
- step <guardrail> — decision put to the user (2026-11-13): criterion 4's premise (zero features) no longer holds and the on-disk index is stale since 2026-10-04; the user chose to regenerate it now with /feature status (all features), so the criterion is met on this repo
- step 6 — behavioural: d067 (docs-only scaffold, empty renders), d067r (this repo's index and rollups regenerated, second run identical but for timestamps)
- step 8 — handed to /tasks close --unattended; outcome in status:, commit in git log
