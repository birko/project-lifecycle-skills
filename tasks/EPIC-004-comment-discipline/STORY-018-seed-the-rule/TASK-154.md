---
id: TASK-154
parent: STORY-018
feature: FEATURE-002
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: todo
priority: P3
assignee: unassigned
created: 2026-09-20
depends-on: []
blocks: []
findings: [DRILL-151-2]
pr: null
github-issue: null
jira-key: null
---

# Two check headers in `skills-lint.sh` argue a case the rulebook already settled

## Context

Found by `/review-comments --all` run as **TASK-151**'s human test plan, on the working tree after
that task's fixes had landed. Both sites are judgement calls (⚠), neither is one of TASK-151's four
named findings, and filing them rather than absorbing them is what kept that task inside its
acceptance list.

**They are one task, not two, because a half-fix is worse than either.** The two comments sit above
adjacent checks and answer the same question — *is this check a gate, and why?* Fixing one leaves the
two headers disagreeing about how much a check explains itself, which is the inconsistency that
invites the next person to "restore" the deleted half.

### Site 1 — `skills-lint.sh:199-205`, destination *a decision record*

> `# ADVISORY — this check never touches `fail` and can never change the exit code. Two reasons, and`
> `# the first is the real one: a missing junction is fixed by re-running an installer, which lives`
> `# OUTSIDE this repo, so no diff can clear the finding and a repo gate must not block on it. Second,`
> `# the roots do not exist on the CI runner, so a fatal check here would make this gate's meaning`
> `# depend on which machine ran it.`

`AGENTS.md:355-358` carries **both reasons, in the same order, in near-identical words**:

> *"A check whose remedy lives **outside the repo** … cannot be a blocker: no diff can clear it, and
> the roots do not exist on the CI runner, so making it fatal would leave the gate meaning different
> things on different machines."*

This is the closest thing to a verbatim duplicate in the repository.

### Site 2 — `skills-lint.sh:159-162`, destination *a decision record*

> `# … Neither can point at the other — a consumer install cannot see this repo — so the only thing`
> `# keeping them from drifting is this check. Fatal, not advisory: the remedy is a diff here, unlike`
> `# check 6's installer re-run.`

That is FEATURE-002 **D13** restated — *"No pointer between them is possible — a consumer install
cannot see this repo"* — and `AGENTS.md` § *Where the same prose must exist in two files* carries the
same reasoning again.

**The counter-argument, recorded so it is answered rather than ignored.** A reader editing a gate
arguably needs to know why it is fatal or advisory without leaving the file — and if they do not, the
next "helpful" change makes check 6 fatal and breaks CI on a machine with no install roots. That is
real, and it is exactly what the rule's *"delete it, **or leave one line pointing at the record**"*
clause is for. The pointer is the fix, not deletion.

**One clause at site 2 is not a duplicate and must survive:** *"unlike check 6's installer re-run"*
is a contrast between two checks in one file, which no record carries and which is the thing a script
editor actually needs.

## Acceptance criteria

- [ ] Both sites either point at their record — `AGENTS.md` § Testing for site 1, FEATURE-002 D13 for site 2 — or keep the prose with a recorded reason. "Left as is" alone does not close this.
- [ ] Each check's *verdict* still reads off the script: a reader must be able to see that check 6 is advisory and check 5 is fatal without opening another file. It is the **argument** that relocates, never the fact.
- [ ] Site 2's `"unlike check 6's installer re-run"` contrast survives — it lives nowhere else.
- [ ] The two headers end up consistent with each other about how much a check explains itself.
- [ ] `bash .github/workflows/skills-lint.sh` and `bash .github/workflows/skills-lint-test.sh` both pass.

## Out of scope

- Making check 6 fatal, or check 5 advisory — `AGENTS.md` § Testing settles both, and this task only moves prose.
- The four survivors TASK-151 named (`:124-133`, `:256-259`, `:43-44`, `:14-16`) — measured as living nowhere else, twice.
- The 8-of-39 copy in `skills-lint-test.sh` — **TASK-153**; the installer why-clause — **TASK-148**.

## Human test plan

- [ ] Run `/review-comments --all` and confirm both sites are gone, or reported with the recorded reason standing.
- [ ] Hand someone the script alone and ask which checks can fail the build. Expected: they answer correctly from the script. If the relocation took the fact out along with the argument, this is where it shows.

## Implementation plan

_Populated by `/tasks plan TASK-154` — leave empty until then._
