---
id: TASK-136
parent: STORY-012
feature: null
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: todo
priority: P2
assignee: agent
created: 2026-09-17
depends-on: []
blocks: []
related: [TASK-110]
# findings: ids this task remediates, from a review/audit/harvest/drill pass. Prefixes: see /tasks intake
findings: [CR-110-5]
pr: null
github-issue: null
jira-key: null
---

# Three files state the `.env.example` condition as *reads*, two as *requires* — and the two answer differently

## Context

**From the [[code-review]] pass at TASK-110's close gate, 2026-09-17.** Spawned rather than folded in:
TASK-110 fixed how the condition is *decided* (artifact question, not project kind); this is a defect in
**what the condition says**, and the two are independent — the wording split was there before that task
and survives it untouched.

`LAYER.md:206` settles the calibration explicitly:

> **The condition means *requires*, not merely *reads* — the row's own definition says so and the
> question did not.** … **Ask: would a new contributor be unable to run this without being told a value?**

Two sites match it (`LAYER.md:32`'s row, and `new-project/SKILL.md`'s bullet as of TASK-110). **Three do
not**, and still say *reads*:

| Site | Says |
|---|---|
| `AGENTS.md:291` | *"does anything here **read** runtime config from the environment? and any component answering yes settles it"* |
| `skills/adopt-project/SKILL.md:77` | *"is deployed, **reads** env config, or ships as a package"* |
| `LAYER.md` § *Conditional rows*, the "Ask the artifact's own question" paragraph | *"does anything here **require** an environment variable to run?"* — correct, but it is the paragraph the other two were copied from before `:206` narrowed it |

### Why it matters

The two readings **disagree on a measured, real repo.** `LAYER.md:206` records a web app that reads three
runtime environment variables and boots correctly with **none** of them set, because every value lives in
committed `appsettings*.json`. Read as *reads*, the row fires and reports a missing template for variables
nobody must supply. Read as *requires*, it is correctly `not applicable`.

So an adopter following `SKILL.md:77` produces a false gap on exactly the repo shape `:206` was written
from — and `AGENTS.md:291`, the convention pointer, tells a reader the looser rule is the rule.

**TASK-110 widened the split rather than causing it**: it brought `new-project` onto *requires*, taking
the count from 2-vs-1 to 3-vs-2. That is a reason to fix it, not a reason to have left `new-project` wrong.

## Acceptance criteria

- [ ] All five sites state the same condition, and it is the one `LAYER.md:206` settles (*requires*)
- [ ] `AGENTS.md:291`'s pointer matches, since § Conventions is what `/verify-conventions` lints against
- [ ] `adopt-project/SKILL.md:77`'s detection list matches — it is the line a survey actually executes
- [ ] The *"any component answering yes settles it"* clause survives: the fix narrows **which** question is
      asked, not the rule that one component is enough
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- The `Dockerfile` row's condition — *deployed as a running service* has no reads/requires ambiguity.
- Re-deciding the calibration itself. `LAYER.md:206` settled it with a measured instance; this task
  propagates that decision, it does not reopen it.

## Human test plan

- [ ] Grep the five sites and confirm one wording. Then re-walk `LAYER.md:206`'s measured repo shape (a web
      app whose three env vars all have committed defaults) against the adopter's detection list and
      confirm it now reaches `not applicable` rather than reporting a missing template.
