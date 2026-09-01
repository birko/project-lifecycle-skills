---
id: TASK-094
parent: STORY-016
feature: null
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: todo
priority: P2
assignee: agent
created: 2026-09-01
depends-on: []
blocks: []
# findings: ids this task remediates, from a review/audit/spec-harvest pass (CR-* SEC-* SH-* VC-*)
findings: [DRILL-035-2, DRILL-035-3]
pr: null
github-issue: null
jira-key: null
---

# Two survey instructions whose literal reading diverges from their intent

## Context

**From the 2026-09-01 cold drill of `adopt-project` on `BardStudio`.** Grouped because both are the same
failure shape — an instruction a careful reader can obey *exactly* and get the wrong behaviour — and both
are one sentence a reader meets in step 1. Splitting them would put two one-line fixes in two tasks.

### DRILL-035-2 — "stop" means two things, and one of them loses every defect

`adopt-project/SKILL.md` § 1: **"Print the survey as a table and stop."**

The runner obeyed it, then noticed it had nearly ended the run:

> *"The word 'stop' means 'before writing', not 'end the run' … Worth naming because **a literal reading of
> 'stop' would have ended this run at the table with F1–F3 listed and unfiled, which is the exact
> untracked outcome § 3b exists to prevent.**"*

It recovered only by reading two *other* passages — the following sentence (*"before a single file is
written"*) and § 1's complete-table exit test. So the sentence is rescued by context rather than by its own
wording, and the failure it invites is precisely the one § 3b calls *"the failure this section exists to
stop"*: real defects reported in prose and given no id. This drill found three in the target repo — a
mandated `Result<T>` that does not exist, a duplicated type name against that repo's own naming rule, and
a possibly stale dashboard — so the loss is measured, not hypothetical.

### DRILL-035-3 — "covered" does not say *by what*

`LAYER.md`'s `.gitignore` row: **"Present → check that `.env` / `.env.*` are covered and that agent-tool
local state is (`.claude/settings.local.json` at minimum); offer the lines if not."**

`BardStudio` ignores `.claude/settings.local.json` — but by the **user's global** git ignore file, not by
the repo's own `.gitignore`. The runner:

> *"'Covered' is not defined as *covered by this file* or *covered at all*. I chose to report it as a gap
> … because **a global ignore protects this one machine and not a clone**, so the row's purpose is unmet."*

That reading is almost certainly the intended one, and the reasoning is better than the rule. The other
reading is available and silently correct-looking: `git check-ignore` says the file is ignored, so a runner
that stops at the observable answer reports no gap and the next clone commits the file. **The row's whole
purpose is the clone**, so the ambiguity inverts it.

## Acceptance criteria

- [ ] § 1's table instruction cannot be read as ending the run — the boundary it sets is stated as what it actually is (no writes before the user has seen the picture), without relying on a later sentence to rescue it
- [ ] Whatever wording lands stays consistent with § 1's complete-table exit and § 3b's filing requirement rather than contradicting either
- [ ] The `.gitignore` row states **by what** a path must be covered, and the answer accounts for a clone rather than the current machine
- [ ] A global-gitignore hit is explicitly not sufficient, with the reason recorded so it is not re-litigated
- [ ] Layer parity: the `.gitignore` change lands in `LAYER.md`, which both front doors read
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- The seed section list the same drill found unreachable — **TASK-093**.
- `present, elsewhere` on conditional rows, and guides split over several files — **TASK-091**.
- Whether adoption should offer `.gitignore` lines at all. It should; this is about what counts as already covered.
- **Step 3b's probe set was considered and deliberately not filed.** The `Birko.Framework` runner noted its empty defect list came from three probes it chose itself, so the defect section is not reproducible run to run. That is judged *correct by design*: adoption reads an unfamiliar codebase, the yield is the point, and an enumerated probe list would become a checklist that stops at its own end — the opposite of what § 3b is for. Recorded here so the decision is findable rather than rediscovered.

## Human test plan

- [ ] Hand the reworded table instruction to a cold reader with a repo carrying a real defect, and confirm the run reaches the filing step rather than ending at the table
- [ ] On a machine whose global git ignore covers `.claude/settings.local.json`, confirm the survey still reports the repo's own `.gitignore` as gapped

## Implementation plan

_Populated by `/tasks plan TASK-094` — leave empty until then._
