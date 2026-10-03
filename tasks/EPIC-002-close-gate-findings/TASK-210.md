---
id: TASK-210
parent: EPIC-002
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
findings: [VC-054]
pr: null
github-issue: null
jira-key: null
---

# Examples in skill text are invented, never lifted from a repo the skill is drilled on

## Context

Raised by the conventions pass at TASK-208's close (2026-10-03), as a register-on-introduce note: TASK-208's
plan applied a rule that is stated nowhere a future author would find it.

**The rule.** A skill's examples must use invented content, never a line copied from a real repo the skill
will be drilled against. A cold drill works by withholding the expected answer from the runner
(`skills/populate-tests/SKILL.md` § *The cold drill*). An example copied from the fixture puts the answer back:
the runner meets the same line in the fixture and copies the example's output instead of applying the rule,
so the drill passes whether the rule works or not, and nothing shows that it was compromised. TASK-208 wrote
its examples with invented content (a vendor contract, a staging host's TLS certificate, 2031 dates) for exactly
this reason, and its Symbio drill depended on it.

**What exists today.** § *The cold drill* → *Choosing a target* says a change justified by naming a repo
cannot be drilled on that repo. It says nothing about the skill **text** carrying that repo's data, which is the
same contamination arriving through the instructions instead of the fixture. AGENTS.md § Testing points at that
section and does not say it either.

**Existing mentions to triage** (found by the same pass; line numbers as of 2026-10-03, re-find them by name).
Real repo names appear as measured evidence in:

| File | Lines |
|---|---|
| `skills/new-project/LAYER.md` | 318, 328, 413, 422, 745 |
| `skills/specs/SKILL.md` | 76, 83 |
| `skills/specs/verbs/init.md` | 60 |
| `skills/roadmap/SKILL.md` | 106 |
| `skills/adopt-project/INFER.md` | 102, 110 |

Not every mention is a defect. A measured count cited as the reason for a rule ("all 31 areas carried
`shaped-by: []`") gives a runner no answer to copy. A line a runner could match against a fixture and copy the
output of does. Each mention needs that judgement.

## Acceptance criteria

- [ ] `skills/populate-tests/SKILL.md` § *The cold drill* states the rule, with its reason in one or two
      sentences: an example in skill text is invented, never copied from a repo the skill is drilled on, because
      it hands the runner the answer the drill withholds
- [ ] The section says what *is* allowed: a real repo cited as evidence for a rule (a count, a measured
      outcome) is not an example and stays
- [ ] Every mention in the table above is classified as **evidence** (stays) or **example a runner could copy**
      (rewritten with invented content), and the classification is recorded on this task, one line per mention
- [ ] AGENTS.md § Testing's pointer to § *The cold drill* is still accurate after the change (pointer, not a
      second copy of the rule)
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- A lint check for real repo names in skill text: a name list is a per-machine fact (the repos this team
  happens to have), and evidence mentions are legitimate. That is the measured-and-rejected shape § Framework /
  stack records for prose-shaped detection
- Rewriting evidence mentions that pass the classification

## Human test plan

N/A — the change is a rule and a classification, checked by reading; no behaviour runs. The rule's own
effectiveness is exercised whenever a later drill relies on it, and TASK-208 is the measured instance.

## Implementation plan

_Populated by `/tasks plan TASK-210` — leave empty until then._
