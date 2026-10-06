---
id: TASK-268
parent: STORY-025
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: todo
# blocked: <reason> — add this line while the task is blocked, keeping its status; /tasks unblock removes it
priority: P2
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

- [ ] Each contract restated in two or more of these skills is listed in this task with its owning file, and every restatement is classified as contract (both sides must state it, per AGENTS.md § *A format one skill reads is a contract*) or copy
- [ ] Every restatement classified as a copy is replaced by a pointer to its owning file, so a grep for the contract's defining sentence finds it in the owner only
- [ ] `bash .github/workflows/skills-lint.sh` passes

> Criteria rewritten 2026-10-06, before work started: a cold reader found the original "a later run shows fewer folders per change" uncheckable at merge time (TASK-078's test plan).

## Out of scope

- Changing the AGENTS.md contract rule itself. That would be a decision, not this task

## Human test plan

N/A: a prose restructuring verified by the lint and by a later `/improve-architecture` run's co-change figures, not by a person.

## Implementation plan

_Populated by `/tasks plan TASK-268` — leave empty until then._
