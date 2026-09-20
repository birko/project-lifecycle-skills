---
id: TASK-162
parent: STORY-018
feature: FEATURE-002
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: todo
priority: P2
assignee: unassigned
created: 2026-09-20
depends-on: []
blocks: [TASK-141]
findings: [DRILL-141-2]
pr: null
github-issue: null
jira-key: null
---

# `skills-lint-test.sh` was never swept, and it holds nine findings

## Context

Found by re-running **TASK-141**'s test plan on 2026-09-20, after its four blockers closed. Two cold
readers, a fixture carrying the whole guide **minus the measurement table only**, and — the change
that mattered — **all six scripts** rather than one.

**Six readers had already swept these scripts and missed all of this**, because every earlier sweep
was scoped to `skills-lint.sh`. TASK-141's measurement claimed six scripts examined; only one ever
was by anyone but me. **That is the finding behind the findings**, and it is why this task exists
rather than a tidy-up.

Everything below was verified against the tree before filing.

### The QA log, and it has already rotted

`skills-lint-test.sh:6` — *"A review of the first version found eight defects; every one has a case
here."*

| Claim | Reality |
|---|---|
| *"the first version"* | `:271` heads **"Regressions from the second review pass"** |
| *"eight defects … every one has a case here"* | the suite runs **56** cases |

Both readers reported it. T caught the rot. A note about a past review that no longer describes the
file it sits in — the QA-log row, decayed exactly as the rule predicts.

### One sentence, four copies — all four verified

*"A negative assertion passes for free if the thing it checks is deleted."*

| Where | Text |
|---|---|
| `skills-lint-test.sh:70` | *"A bare 'must not contain' passes trivially when check 4 is absent"* |
| `skills-lint-test.sh:321-322` | *"Asserting the exit code alone would also pass if the whole check were deleted"* |
| `skills-lint-test.sh:387` | *"passes trivially when the section is deleted"* |
| `AGENTS.md:359-360` | *"a 'must not appear' check passes trivially when the section is deleted"* |

The helper's contract line earns its place; the two call sites should keep only their case-specific
half.

### Three more restatements

| Site | Restates |
|---|---|
| `:4-5` | § Testing — *"It is the repo's only gate, so a silent regression in it disables checking entirely with no signal."* `skills-lint.sh:2` already does this right, as a pointer |
| `:41-42` | a § Testing bullet near-verbatim — **and drops the maintenance rule that bullet carries** (*"Keep the POSIX path first…"*), so the copy is also lossy |
| `:284-286` | what `skills-lint.sh:159-160` already states in pointer form |
| `:50-52` | borderline — *"Check 6 is advisory and never touches the exit code"* is § Testing; the `rc -eq 0` justification beside it earns its place |

### Two comments that name things which do not exist

- `skills-lint-test.sh:322` says **`check_silent`**; the helper is `case_silent` (`:66`).
- `skills-lint-test.sh:70` says **"check 4"**; `case_silent` greps `== 6. install roots`, as `:76`'s
  own failure message says.

Not comment-placement defects — accuracy defects in comments. Filed here because they were found in
the same sweep and fixing them separately means reading the same lines twice.

## Acceptance criteria

- [ ] Each of the nine is acted on or dismissed **with a reason recorded**; "left as is" alone does not close this.
- [ ] The QA log at `:6` goes. The two sentences before it — why a silent regression here disables the gate, and what each case does — are the file's actual contract and stay.
- [ ] Of the four copies of the negative-assertion rationale, **the helper keeps its contract line** and the call sites keep only what is specific to their case. Do not delete all four: the rule itself is in `AGENTS.md` and the helper is where it is operative.
- [ ] `:41-42`'s fix restores the dropped maintenance rule or points at it. A lossy copy replaced by a lossy pointer is not a fix.
- [ ] `check_silent` → `case_silent`, and `:70`'s "check 4" → the check it actually greps.
- [ ] Every deletion names the destination that holds the content, **verified by reading it**.
- [ ] `bash .github/workflows/skills-lint.sh` and `skills-lint-test.sh` both pass, and the case count is unchanged — a comment fix that changes what runs is a different task.

## Out of scope

- `skills-lint.sh:219`'s wrong check number — **TASK-081**, now confirmed by a sixth independent reader.
- `AGENTS.md`'s own drift (§ *A repo-level check* saying "check 5", § Testing saying 47 cases against 56) — **TASK-081** and **TASK-029** respectively; T flagged both as evidence the numbers rot, not as script defects.
- The `pi-install` header both readers reported — handled directly on **TASK-141**, since it reverses a TASK-148 criterion rather than adding new scope.
- The `ARG_RE` block — **TASK-141** records the evidence that settles it; acting on it belongs with whoever takes that.

## Human test plan

- [ ] Two cold readers on the same six-script fixture. Expected: these nine gone, and `skills-lint.sh`'s existing pointers still cleared rather than newly reported.
- [ ] Expected failure to watch for: the fix deletes the negative-assertion rationale from **all four** places, leaving the helper with no statement of its own contract. The rule lives in the guide; the helper is where it bites, and those are different jobs.

## Implementation plan

_Populated by `/tasks plan TASK-162` — leave empty until then._
