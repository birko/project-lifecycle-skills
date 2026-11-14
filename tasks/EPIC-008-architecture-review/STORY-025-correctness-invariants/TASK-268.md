---
id: TASK-268
parent: STORY-025
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: done
# blocked: <reason> — add this line while the task is blocked, keeping its status; /tasks unblock removes it
priority: P2
picked-by: fix-next
assignee: agent
created: 2026-10-06
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [IA-1]
pr: null
github-issue: null
jira-key: null
---

# A change to a cross-skill contract ripples through up to 21 files in six skill folders

## Context

Filed by `/improve-architecture` (EPIC-008, author run at `30f9716`).

Candidate key: 4:skills/feature/SKILL.md — IA-1

- **Files:** a co-change set of 26 files across 7 skill folders, main file `skills/feature/SKILL.md`: the `feature` router and six of its verbs; `fix-next`; `populate-tests`; `roadmap`; `specs` (router, `init`, `regen`, `map.yml` template); `tasks` (router, `block`, `close`, `init`, `intake`, `new`, `pick`, `spawn`, `triage`, the `TASK.md` and `config.yml` templates); and `new-project`'s `CLAUDE.seed.md`.
- **Problem:** class 4, leaky seam, `4, co-change`.
  - The files form one transitive group of co-change pairs (strongest: `tasks/SKILL.md` ↔ `close.md` 18 commits, `tasks/SKILL.md` ↔ `pick.md` 14, `feature/SKILL.md` ↔ `tasks/SKILL.md` 11, `fix-next` ↔ `tasks/SKILL.md` 10).
  - The files name each other (`[[tasks]]`, `[[feature]]`, `[[specs]]`, `[[roadmap]]`, `[[fix-next]]` links, and verb paths). In 67 commits a change touched two or more of them: a median of 3 files in 2 folders, at most 21 files in 6 folders.
- **Solution:** move the logic to where the data lives, or ask the owning module for what is wanted (Step 4's class 4 move). Here: where several skills restate one contract (the status vocabulary, the review-axis list, the `blocked:` field, the dropped-entry shape), make the owning skill the only full statement, and have readers point at it instead of restating it.

  `Gate: not a shallowness claim — 4, co-change`. **Tension to weigh first:** AGENTS.md § *A format one skill reads is a contract the writing skill must state too* deliberately makes both sides of a contract state it, so some of this co-change is the rule working. The finding is the share of it that is restatement rather than contract.
- **Benefits:**
  - Leverage: not measured, because which of the 26 files restate a contract rather than point at one is a reading, not a count.
  - Locality: a median of 3 files in 2 folders per change today, at most 21 in 6. After: not measured until the restating files are identified.
- **Before/after:** before, 26 files in 7 folder frames, linked by co-change edges, most of them through `tasks/SKILL.md` and `close.md`. After, each shared contract is stated in one owning file, with pointer edges from the readers, and the co-change edges collapse onto the owners.
- **Strength:** `strong`, because fix landings in its own files corroborate a candidate raised on co-change: `close.md` 10, `specs/SKILL.md` 9, `tasks/SKILL.md` 8, `roadmap` 7, `fix-next` 6.

## Acceptance criteria

- [x] Each contract restated in two or more of these skills is listed in this task with its owning file, and every restatement is classified as contract (both sides must state it, per AGENTS.md § *A format one skill reads is a contract*) or copy
- [x] Every restatement classified as a copy is replaced by a pointer to its owning file, so a grep for the contract's defining sentence finds it in the owner only
- [x] `bash .github/workflows/skills-lint.sh` passes

> Criteria rewritten 2026-10-06, before work started: a cold reader found the original "a later run shows fewer folders per change" uncheckable at merge time (TASK-078's test plan).

## Out of scope

- Changing the AGENTS.md contract rule itself. That would be a decision, not this task

## Human test plan

N/A: a prose restructuring verified by the lint and by a later `/improve-architecture` run's co-change figures, not by a person.

## Implementation plan

Inline: for each contract the finding names, find its owner and every statement of it in `skills/` and the rulebook, classify each, and point every copy at the owner.

## Outcome

**The four contracts the finding names, their owners, and every statement of them outside the owner.**

| Contract | Owner (the only full statement) | Statements elsewhere | Class | Done |
|---|---|---|---|---|
| **Task status vocabulary**, two forms read everywhere (`verify` / older `review`; `blocked:` field / old `status: blocked`) | `skills/tasks/SKILL.md` § *Lifecycle* → *Reading a task's status* | `feature` SKILL.md, `review`, `status`; `roadmap`; `fix-next` (two places); `tasks` `close`, `init`, `migrate`, `pick`, `triage` | **contract**: each reader must accept both forms, so each names them, and all but one already pointed at the owner | `fix-next`'s *Verification debt comes first* named the older form with no pointer; it now points |
| **The review passes a close runs** | `skills/tasks/verbs/close.md` step 5b (which passes, which are conditional) | `AGENTS.md` § Working rules; `new-project/templates/CONVENTIONS-universal.md`; `review-comments` SKILL.md | **copy**: each listed the passes ("adherence, fidelity and correctness always…", "beside standards, fidelity and correctness"), which go stale when an axis is added, the case AGENTS.md § *Independent review axes* already warns about | all three now name `close` step 5b and list nothing |
| **The `blocked:` field and how it is written** | `skills/tasks/SKILL.md` § *Lifecycle* → *Writing a `blocked:` value* | `tasks` `block`, `cancel`, `close`, `audit`, `export`, `import`, `init`, `pick`, `show`, `spawn`, `triage`; `fix-next`; `roadmap`; `slicing.md`; the `TASK.md` template; `CONVENTIONS-universal.md` | **contract**: writers (`block`, `close`, `import`, `init`) and readers each act on the field and point at the owner for how to write it; the template's comment is the field's documentation, per § *A template ships nothing a render cannot make true* | none needed |
| **The dropped-finding entry** (`### Findings dropped at intake`) | the writer, `skills/tasks/verbs/intake.md` steps 3 and 5 | `improve-architecture` SKILL.md (the reader); `AGENTS.md` | **contract**: AGENTS.md § *A format one skill reads is a contract the writing skill must state too* requires both sides to state it, by name | none |

**Criterion 2, checked by grep:** each contract's defining sentence is found in its owner only. *Two forms, both read
everywhere* and *one rule for every writer* are in `tasks/SKILL.md` alone. The pass list (*fidelity and correctness
run unconditionally*) is in `close.md` alone. No other file in `skills/` or `AGENTS.md` lists the passes.

**What this does not measure:** the finding's co-change figures. Those come from a later `/improve-architecture` run,
as the plan says; nothing here claims the median of 3 files per change has moved. Most of the co-change the finding
saw is the contract rule working, the tension its context named.

**Human test plan:** N/A as filed.

**Close gate (inline; four files plus three restamps):**
- **Standards:** § *Defer to a shared inventory* and § *Independent review axes*.
- **Intent:** all criteria met.
- **Correctness:** by grep and by reading; the consumer template's changed line sits outside its byte-checked
  `comment-rule` block, and the lint passes.
- **Security, comments:** not applicable.
- **CI:** local lint passes; main is unpushed.
- **Specs:** change-review, defect-draining and project-baseline restamped with no content change. Work-tracking's
  close requirement, which names the passes, describes the owner and is right where it is.

## Progress log

- step 2 — picked; the last task in the pool not waiting on a person or a decision; STORY-025 already in-progress
- step 3 — re-verified: the pass list copied in three places; one status-form mention without a pointer
- step 5 — four statements pointed at their owners
- step 6 — by grep (each defining sentence in its owner only) and the lint; plan N/A
- step 7 — change-review, defect-draining, project-baseline restamped, no content change
- step 8 — closed inline; commit in git log
