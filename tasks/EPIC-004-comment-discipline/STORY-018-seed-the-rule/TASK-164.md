---
id: TASK-164
parent: STORY-018
feature: FEATURE-002
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: todo
priority: P3
assignee: unassigned
created: 2026-09-24
depends-on: []
blocks: []
findings: [DRILL-163-1]
pr: null
github-issue: null
jira-key: null
---

# Two single-reader comment findings from TASK-163's drill — borderline, grouped

## Context

Found while doing **TASK-163**, by its human test plan: two cold `claude -p --disable-slash-commands`
readers (E, F), whole guide minus the measurement table, all six scripts. Each item below was raised by
**one** reader of two, and is borderline on the rule's own terms — which is why they are grouped rather
than filed apart, and why dismissing either with a reason is a legitimate outcome. Verified against the
tree 2026-09-24.

| Site | Finding | Reader | The case for leaving it |
|---|---|---|---|
| `skills-lint.sh:112-114` ↔ `skills-lint-test.sh:111-112` | the same content twice — the receiver is read whole because `tasks/verbs/import.md` declares flags in a table, and keying on bullets reported its real flags missing | E | the rule allows a test comment naming the finding it pins; the lint's copy is the design at the point it bites. One side becoming a pointer at the other is the likely fix |
| `skills-lint-test.sh:346` | `# link now dangles; source gone` restates the `rm -rf` beside it | F | it states *intent* — the `rm` after `mk_link` is the fixture, not cleanup — which `r_stale`'s name only half-carries |

**Dismissed in TASK-163, not here:** F's report that the `install.*` headers restate § Commands — TASK-148
decided those headers keep their one-line mechanism.

## Acceptance criteria

- [ ] Each row is acted on or dismissed with a reason recorded.
- [ ] If `:112-114` / `:111-112` changes, exactly one side keeps the content and the other points at it — never both cut.
- [ ] `bash .github/workflows/skills-lint.sh` and `skills-lint-test.sh` both pass, case count unchanged.
- [ ] `AGENTS.md` § Comments table re-measured if either script's counts move.

## Out of scope

- The EVIDENCE/PIN lines both readers called borderline QA logs — accepted as by-design on **TASK-153**.
- `skills-lint.sh:218-219` check number — **TASK-081**; the `ARG_RE` block and `pi-install` headers — **TASK-141**.

## Human test plan

- [ ] Two cold readers, same fixture shape as TASK-163's. Expected: neither row reported, or reported and the recorded reason explains why it stands.

## Implementation plan

_Populated by `/tasks plan TASK-164` — leave empty until then._
