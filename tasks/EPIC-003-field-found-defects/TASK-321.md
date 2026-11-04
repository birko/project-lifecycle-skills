---
id: TASK-321
parent: EPIC-003
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: done
# blocked: <reason> — add this line while the task is blocked, keeping its status; /tasks unblock removes it
priority: P3
assignee: agent
picked-by: fix-next
created: 2026-10-14
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [FIELD-017]
pr: null
github-issue: null
jira-key: null
---

# `/feature pick`'s decompose offer has no answer-less path

## Context

Found by TASK-319's post-fix drill (2026-10-14). `skills/feature/verbs/pick.md` gate D puts "N approved decision(s) have no tasks. Decompose now? [Y/n]" and its step 4 defines only `Y` and `n`. With nobody to answer, the runner stopped and said the instructions give no path for silence, while gate Q in the same file says "Silence is not a no." AGENTS.md § Output/prose rules requires every ask-step to state its answer-less path.

## Acceptance criteria

> Rescoped 2026-11-04 by /fix-next step 3, before any edit: gates A, B and C in the same table carry the same defect — A's offer has no question text, B's `[Y/n]` and C's `[y/N]` define no answer-less path. Same root cause, same verb, so they are in scope; the first criterion is the original.

- [x] Gate D's offer (and step 4) states what the run does when nobody answers, and what it reports
- [x] Gates A, B and C each state the question they put and their answer-less path
- [x] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- Gate D's condition

## Human test plan

- [x] A cold runner reaches gate D with nobody to answer. Expected: it takes the stated answer-less path and reports it, without saying the instructions left it undefined.
  - **Passed 2026-11-04:** gates Q, A, B and C passed; at gate D it put the question, then printed `not decomposed: D1, D2 have no tasks — nobody answered` and the task-first gate and stopped at step 6, quoting step 4's no-answer rule; it did not call the path undefined.

## Outcome

**What was fixed.** `/feature pick` walks readiness gates and offers the verb that clears each one. Gate D's offer to decompose defined only `Y` and `n`, so a runner with nobody present stopped with no rule to follow, even though gate Q in the same file says "Silence is not a no". Gates A, B and C had the same gap: A had no question text, and B and C had no answer-less path. All four now quote their question and state what silence does:

- **A, re-grill:** change nothing, report `not grilled`, and stop. Nothing past A can run without decisions.
- **B, decide:** change nothing, report the still-proposed ids, and stop.
- **C, prototype:** do not prototype, report `prototype: suggested, nobody answered`, and continue. C never blocks, so silence passes it the way `N` does.
- **D, decompose:** do not decompose and do not hand off. Report `not decomposed: <ids> … nobody answered`, print the task-first gate, and stop at step 6. Nothing is recorded as a refusal, so the offer comes back next run.

**Step-6 split: 0/0.** The change is prose only. `skills-lint.sh` passes (20 skills): a contract pin on link resolution, not evidence. The cold drill in the Human test plan is the evidence and has not been run.

**Judgement calls.**
- **D's `[Y/n]` default does not apply to silence.** Decompose files tasks and asks where to place them, so running it with nobody present makes placements and a split nobody chose. The capital `Y` is a default for a person pressing enter, not for an absent one. Silence isn't treated as `n` either: `n` is a refusal and prints as one, while silence records nothing.
- **C continues; A, B and D stop.** C is the only soft gate, and its `[y/N]` already means "skippable". The others guard something every later gate reads.

**Respec.** `feature-lifecycle`, requirement *pick*: states the answer-less outcome of A, B, C and D, plus one scenario for D with nobody present. The `shaped-by` fields were carried forward, not re-derived.

**Flagged, not fixed.** None.

## Implementation plan

_Not drafted: a /fix-next run, whose fix is recorded in § Outcome._

## Progress log

- step 2 — picked; ranked above TASK-316 because `/feature pick` is the front door to every feature, so its unworded offers are reached on every run (key 2), while fix-next's tie question is reached only when keys 1–8 are exhausted; key 6 inert — both sit under EPIC-003 with no theme
- step 3 — verified: rescoped: gate D holds as written (step 4 defines `Y` and `n` only, while gate Q in the same file says "Silence is not a no"); gates A (no question text), B and C (no answer-less path) carry the same defect — criteria extended before any edit
- step 4 — layer: local (skills/feature/verbs/pick.md)
- step 5 — fix in skills/feature/verbs/pick.md (gates A–C question table, step 4 answer-less path); tests: skills-lint.sh (20 skills) green
- step 6 — reverted fix: 0/0 failed — prose only, nothing executable; fix-dependent = none; contract pins = skills-lint.sh link resolution; evidence = the Human test plan cold drill, not run
- step 7 — respecced feature-lifecycle; requirements changed: the /feature pick requirement (+1 scenario); intended anyway — TASK-321's criteria, answered by /fix-next; shaped-by carried forward, not re-derived
- step 8 — handed to /tasks close --unattended; outcome in status:, commit in git log
- 2026-11-04 — **Human test plan — cold drill, passed.** Fixture: `docs/features/FEATURE-001-export/` with `idea.md` (`status: idea`, Prototype `Skipped — CLI command …`), `decisions.md` with D1 and D2 `approved` and empty `→ Tasks`, a `status.md`; `tasks/` with one epic and no tasks; skills `feature`, `tasks`, `roadmap`. Runner: `claude -p --disable-slash-commands --permission-mode acceptEdits --allowedTools "Bash(git:*)" "Bash(cd:*)" "Bash(ls:*)" Read Glob Grep Edit Write < brief.txt`, cwd `%LOCALAPPDATA%\Temp\d321`, which holds the committed fixture `repo/` and copies of the named skill folders under `skill/`. The brief said it was a drill, barred history and planning docs, said to write any question verbatim and continue unanswered, and asked for the output, the questions, what was left undecided, what was settled, what was inferred, what it read unsent, and its skill list. It stated no expected outcome. Task-specific ask: "Run /feature pick FEATURE-001. Stop where the instructions hand off to another verb; do not run it." **Coldness:** it listed no skills. **Result:** gates Q, A, B and C passed; at gate D it put the question, then printed `not decomposed: D1, D2 have no tasks — nobody answered` and the task-first gate and stopped at step 6, quoting step 4's no-answer rule; it did not call the path undefined. Also: it also found that `questions.md` covers no `idea.md` without an open-questions section, and that gate D's question has two wordings (the gate table's and step 4's) → TASK-336. → `verify` → **done**.
