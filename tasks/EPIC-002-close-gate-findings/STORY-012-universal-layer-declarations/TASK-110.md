---
id: TASK-110
parent: STORY-012
feature: null
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: todo
priority: P2
assignee: agent
created: 2026-09-08
depends-on: []
blocks: []
# findings: ids this task remediates, from a review/audit/harvest/drill pass. Prefixes: see /tasks intake
findings: [CR-4]
pr: null
github-issue: null
jira-key: null
---

# The scaffolder still gates two conditional rows on a kind list the inventory replaced with a question

## Context

**From a [[code-review]] pass on 2026-09-08.**

`AGENTS.md` § Conventions requires that **"a row's condition and its creator must agree"** — the same
change that adds a conditional row fixes the scaffolder line that contradicts it. `LAYER.md:32-33`
states both conditions as questions **about the artifact**, explicitly not as project kinds:

> *"does anything here require an environment variable to run?"* · *"is anything here deployed as a
> running service?"*

`skills/new-project/SKILL.md:93` and `:141` (and the layout tree at `:23`) still gate both on a **kind
list** — `service / API / web / worker`. Line 93's parenthetical even claims *"the row in LAYER.md is
the one both now match"*, which is false as written.

### The concrete divergence

A repo of kind `other` — or the **desktop app** kind `LAYER.md` itself notes the intake enum does not
offer — that reads runtime config from the environment gets **no `.env.example` from `new-project`**,
while [[adopt-project]] walking the same row reports it `missing`. The two front doors disagree about
the same repo, which is the exact failure layer parity exists to prevent.

**This is the rule catching its own author:** the convention was written in this epic, and the
scaffolder line it names was never brought into line.

## Acceptance criteria

- [ ] `new-project` decides both rows by the artifact question `LAYER.md` states, not by a kind list
- [ ] Kind remains usable as **evidence** toward the answer, never as the answer — matching
      `LAYER.md` § *Conditional rows* and the precedence rule that a declared kind outranks an inferred one
- [ ] The false parenthetical at `:93` is corrected or removed, not left asserting agreement that does
      not exist
- [ ] The layout tree at `:23` agrees with whatever the rows now say
- [ ] Both front doors produce the same verdict for the same repo — demonstrated on a kind the enum
      does not offer, since that is the case that exposed it
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- **Adding a `desktop app` kind to the intake enum.** `LAYER.md` deliberately decides rows by artifact
  question precisely so the enum does not have to be exhaustive; extending it is a separate argument.
- Any conditional row other than `.env.example` and `Dockerfile`.
- The `(lazy)` rows — a different marker with different rules.

## Human test plan

- [ ] Run `new-project` for a repo that reads runtime config from the environment but is not any of
      `service / API / web / worker`, then run `adopt-project` over the result. Expected: both agree.
      Today the scaffolder creates nothing and the adopter reports `missing`.
