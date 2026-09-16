---
id: TASK-127
parent: EPIC-002
feature: null
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: todo
priority: P2
assignee: agent
created: 2026-09-16
depends-on: []
blocks: []
# findings: ids this task remediates, from a review/audit/harvest/drill pass. Prefixes: see /tasks intake
findings: [DRILL-109-1, DRILL-109-2]
pr: null
github-issue: null
jira-key: null
---

# Four steps say "ask the user" and none of them says what to ask, or what happens when nobody answers

## Context

**From the cold drill run for TASK-109 on 2026-09-16** — two runners, `--disable-slash-commands` in a
guide-free scratch root, both confirmed cold. Each was told: *"if the instructions have you ask the user
something, write that question out VERBATIM and continue as if it went unanswered."* Neither could, and
both said so unprompted. Filed at epic level because the fix spans two skills and neither owns it alone.

### DRILL-109-1 — three ask-steps in `tasks`, no question text

The B1 runner, on `/tasks init` against a folder with no git and no user:

> *"No question text is supplied, so there is nothing to quote to you verbatim as **my** question — the
> instruction **is** the prompt."*

| Where | What it says |
|---|---|
| `skills/tasks/verbs/new.md` § Mode detection flow, step 2 | *"**Ask user** via AskUserQuestion with three options: local / hybrid (github) / hybrid (jira). Pre-select the suggested one."* |
| `skills/tasks/verbs/init.md` step 3 | *"A field whose value is a **real choice** (`integration:`) is **asked**, never defaulted"* |
| `skills/tasks/SKILL.md` § Shape detection, step 4 | *"Ambiguous → ask the user once and write `.config.yml` so the choice sticks."* |

The third fired in the drill and nothing records it: `project/` had no `*.sln`, no `.git` and no existing
config, so steps 1-3 all fell through — the ambiguous case exactly — and the runner picked a location by
inference from the brief rather than from the skill.

### DRILL-109-2 — `/specs init`'s blessing has no wording *and* no mechanism

The B2 runner:

> *"The init header says the run is to 'scan the codebase, propose a capability map, **let the user bless
> it**, write `.map.yml`.' Step 4 says present the table; step 6 says write 'the blessed areas'. **Nothing
> between them says how blessing is obtained or what to do when it is not forthcoming.**"*

It proceeded as if blessed, and wrote the question itself because the skill supplies none.

### Why one task, and why this is not cosmetic

Both are the same defect: **a step names an interaction without specifying either half of it** — the
question to put, or the path when no answer comes. The two halves fail differently and both matter. No
wording means every run invents its own, so two runs of the same verb ask materially different questions
and neither is reproducible. No unattended path means the run either stalls or, as happened twice here,
silently promotes a *suggestion* into a *decision* — which is the exact defect class TASK-109 just fixed
one layer down, arriving through the interaction instead of through a template.

**This repo already has the shape of the answer**, which is why this is a gap and not an open design
question: `/tasks close` has `--unattended`, and `AGENTS.md` § Conventions requires that such a flag
*"define behaviour at every point that needs it"*. These four points have no such definition.

## Acceptance criteria

- [ ] Each of the four ask-steps above states **the question actually put** — not a description of the
      question — so two runs ask the same thing
- [ ] Each states what happens **when no answer comes**, and the unattended outcome is a *reported
      unresolved state*, never a silently-promoted suggestion
- [ ] The `/specs init` blessing has a stated mechanism, not just a named one — what constitutes blessing,
      and what an unblessed-but-proceeding run writes and reports
- [ ] The rule is stated once and referenced, not restated per site — where it belongs is part of this
      task's judgement, and `AGENTS.md`'s existing `--unattended` convention is the obvious anchor
- [ ] `SKILL.md` § Shape detection's ambiguous branch is reachable in a drill and produces a recorded
      question rather than an inferred location
- [ ] A cold drill re-run of both verbs quotes the questions verbatim rather than reporting it cannot
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- **Changing what any of the four questions decides.** `mode:`, `integration:`, task-root placement and
  the area map keep their current semantics; this is about the asking, not the answer.
- Adding an `--unattended` flag to `init` — decide whether that is the mechanism, but building it out
  across every verb is its own task if it turns out to be the answer.
- The other drill findings from the same run — TASK-128, TASK-129.

## Human test plan

- [ ] Re-run the TASK-109 cold-drill recipe against both verbs with no user available, and confirm each
      report can quote the questions verbatim and names each unresolved field
- [ ] Confirm an unattended run writes no value that a user did not supply, for every one of the four

## Implementation plan

_Populated by `/tasks plan TASK-127` — leave empty until then._
