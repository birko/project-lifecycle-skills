---
id: TASK-357
parent: STORY-016
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: todo
# blocked: <reason> — set by /tasks block, never by hand; status stays as it is; /tasks unblock removes it
priority: P2
# assignee — one of: agent (default), unassigned, human, or an installed agent type's name; ai is read as agent, never written
assignee: agent
created: 2026-11-13
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [DRILL-102-8, DRILL-102-9, DRILL-102-10, DRILL-102-11, DRILL-102-12, DRILL-102-13]
pr: null
github-issue: null
jira-key: null
---

# A full adoption's fills leave five readings that several cold runners each settled differently

## Context

Filed 2026-11-13 from the same cross-drill comparison as TASK-356, which lists the six drills. Each drill recorded its
one-runner readings on its own task as "not filed". Compared across drills, these five were raised by **two or more
runners independently**, the agreement bar FEATURE-002 D10 sets. They are a group because all are about what a full
adoption writes during its fill (step 3) and its regeneration (step 3c), and the owner verbs it chains.

| Id | Reading | Raised by |
|---|---|---|
| DRILL-102-8 | step 3c re-runs a generator unless the result would be "a pure no-op". Whether a re-render that differs only in its `_Generated …_` timestamp counts is unstated | d065b/full, d354, d102, d102b |
| DRILL-102-9 | `/tasks init` reconciles "every field the template declares and the file lacks". Whether the template's commented blocks (`external:`, `siblings:`) count as declared fields, and whether a present field gains its missing comment block, is unstated | d354, d102, d102b |
| DRILL-102-10 | LAYER.md's `docs/features/` row says "Create the folder + index if absent" and names no verb, while `/feature status` owns the index. Runners each picked a route | d354, d102b |
| DRILL-102-11 | rendering an empty generated section: an empty tree in `tasks/README.md`, a features index with no rows, and whether the template's hint comments stay. Runners wrote `_No tasks yet._`, `_None_`, or dropped the section | d065b/full, d102, d102b |
| DRILL-102-12 | "check for the negation wherever that row applies": whether the `.gitignore` offer includes `!.env.example` when the `.env.example` row is `not applicable`. One runner left it out, one put it in | d354, d102b |
| DRILL-102-13 | the CI row offers "a minimal install→build→test workflow" to a repo with no tests yet. Its first run fails (`pytest` exits 5 when it collects nothing), so the offer would land a red gate. Nothing says whether to offer it, say so, or offer it without the test step (added 2026-11-13) | d072/a, d356/s |

## Acceptance criteria

- [ ] DRILL-102-8 … 13 each have one stated answer, in the file that owns the rule (`adopt-project` step 3c,
      `tasks` `init` and `triage`, `feature` `status`, `LAYER.md`)
- [ ] A rendered empty section reads the same in every generator that has one, or each states its own form
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- Survey and report readings: TASK-356
- Pinning a test runner with no manifest: TASK-072
- Where offers are asked: TASK-102 (done)

## Human test plan

- [ ] Re-run the `d065b` full brief on a fresh copy of `d065/adopted` and of `skills/` with a cold runner. Expected:
      none of DRILL-102-8 … 13 in its "left undecided" section

## Implementation plan

_Populated by `/tasks plan TASK-357` — leave empty until then._
