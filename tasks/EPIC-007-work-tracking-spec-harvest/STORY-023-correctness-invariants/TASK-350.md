---
id: TASK-350
parent: STORY-023
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: todo
# blocked: <reason> — set by /tasks block, never by hand; status stays as it is; /tasks unblock removes it
priority: P2
# assignee — one of: agent (default), unassigned, human, or an installed agent type's name; ai is read as agent, never written
assignee: agent
created: 2026-11-12
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [DRILL-240-1, DRILL-240-2, DRILL-240-3]
pr: null
github-issue: null
jira-key: null
---

# `/feature decide`'s verdict question has no answer-less path, and nobody commits what `prototype` writes

## Context

Spawned 2026-11-12 from TASK-240's Human test plan drill: one cold run of `/feature prototype FEATURE-001 --skip …` then
`/feature decide FEATURE-001` on an invented fixture (`%LOCALAPPDATA%/Temp/d240`, report kept there as `report.md`).
Raised by one runner. These three are checked against the files, not taken on its word: each is a plain reading of the
text quoted below.

- **DRILL-240-1 — `decide` step 2 asks with no answer-less path.** "For each, drive a verdict via `AskUserQuestion`"
  gives neither the question's words nor what happens when nobody answers, against AGENTS.md's ask-step rule. The
  runner wrote its own question and, with no answer, treated the row as skipped by inference from step 6.
- **DRILL-240-2 — `decide` step 6 contradicts itself when step 5 ran.** Step 6 lists "`status.md` and
  `docs/features/README.md` from step 5" among the files this run wrote, and also says "A run where every verdict was
  skipped wrote nothing and commits nothing". Step 5 chains `/feature status` on every run, so an all-skipped run did
  write those two files.
- **DRILL-240-3 — `prototype` has no commit step.** Every form, and now `--skip`, writes `idea.md`, the ledger and,
  through the status chain, `status.md` and the index. Nothing commits them, and `decide` step 6 refuses files it did
  not write, so they sit dirty with no owner. That is the case AGENTS.md § *With an upstream, a gate's record goes on
  a `record/<ID>` branch* describes for the other feature verbs.

## Acceptance criteria

- [ ] `decide` step 2 states its verdict question and what an unanswered row becomes, recorded so it does not read as decided
- [ ] `decide` step 6 says what an all-skipped run commits when step 5 rewrote the rollup and the index
- [ ] `prototype` commits what it wrote, in the shape the other feature verbs use (`chore: …` subject, a record branch with an upstream), or states why it does not and who does
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- The `--skip` path and the prototype line's writers — TASK-240

## Human test plan

- [ ] Re-run TASK-240's brief on a fresh copy of its fixture (recipe on TASK-240) with a cold runner. Expected: `decide`'s question is the stated one, the run reports D1 as unanswered, and `git status` is clean or names each file left with the reason

## Implementation plan

_Populated by `/tasks plan TASK-350` — leave empty until then._
