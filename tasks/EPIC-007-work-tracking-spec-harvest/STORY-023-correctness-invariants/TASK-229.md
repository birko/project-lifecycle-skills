---
id: TASK-229
parent: STORY-023
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: todo
# blocked: <reason> — add this line while the task is blocked, keeping its status; /tasks unblock removes it
priority: P2
assignee: unassigned
created: 2026-10-03
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [SH-25, SH-30]
pr: null
github-issue: null
jira-key: null
---

# `fix-next`'s ask-steps carry no question and no answer-less path, in a skill built to run unattended

## Context

Found by the defect-draining spec harvest (2026-10-03, EPIC-007, spec committed in b24eb8b). AGENTS.md § Output /
prose rules: an ask-step states the question actually put **and** what the run does when no answer comes. This
skill is the one most often run with nobody present (`--loop`, and unattended progress is its stated purpose).

- **SH-25 — three ask-steps lack both halves** in `skills/fix-next/SKILL.md`:
  - step 1, *Verification debt comes first*: "Offer to clear them first";
  - step 2: "Do stop and ask only if the top two are genuinely inseparable on every key above". Key 8's own text says
    this branch is routinely reachable, because `created` is a date and an intake files a whole pass on one day;
  - *Guardrails*: "a decision only the user can make … stop and ask with a concrete recommendation".
- **SH-30 — the verification-debt offer under `--loop` is undefined.** The loop continues "unless … a question is
  pending", and nothing says whether this offer is a pending question that halts the loop or is skipped.

## Acceptance criteria

- [ ] Each of the three ask-steps states its question verbatim and its unattended outcome, which is a **reported
      unresolved state**: never a value that reads as decided, never silence
- [ ] The inseparable-top-two path picks or stops deterministically when nobody answers, and says which key it ended on
- [ ] Step 9's `--loop` stop conditions say whether the verification-debt offer counts as a pending question
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- `/tasks pick`'s ask-steps — TASK-182
- `/fix-next`'s missing plan offer — TASK-135

## Human test plan

- [ ] Cold drill, no user present: an invented fixture whose top two candidates tie on every key, plus one `verify`
      task. Two runners record the same outcome at each ask, and neither invents an answer

## Implementation plan

_Populated by `/tasks plan TASK-229` — leave empty until then._
