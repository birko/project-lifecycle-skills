---
id: TASK-035
parent: null
feature: null
# status: todo | in-progress | review (code done, sign-off pending) | blocked | done | cancelled
status: todo
priority: P2
assignee: agent
created: 2026-08-19
depends-on: []
blocks: []
findings: [CR-020-2, CR-020-3]
pr: null
github-issue: null
jira-key: null
---

# Nothing owns the `integration:` question — three rules each hand it to another

## Context

Two `/code-review` findings from TASK-020's close gate (2026-08-19), in files that task's diff did not
touch. **Filed as one task, not two:** they are the same declaration falling through the same three
steps, and splitting them buries the connection that makes them cheap to fix together.

`/tasks init` must be told `integration:` when a repo's config predates the field — inferring it from
`git log` is forbidden outright, and TASK-021/023 exist because it was inferred once. But no step owns
asking:

1. **Step 1 is forbidden to find out.** `SKILL.md` § 1 says *"From outside you cannot see a version …
   Where the artifact's row names a verb, step 3's delegation is what answers, so leave the version
   question to it rather than guessing here"*, and `LAYER.md:105` only permits `present, outdated`
   once the owner verb reports a delta. The `tasks/` row names a verb, so at step 1 the fact does not
   exist yet.
2. **Step 2 is told to ask it anyway.** `SKILL.md:96` requires asking about *"a declaration a present
   artifact lacks"*, with this exact case as its worked example — knowledge step 1 was just forbidden
   to gather. So adoption either asks blindly (pestering repos that already carry the field) or the
   question migrates into step 3, breaking the **one frontier round** rule at `SKILL.md:102`.
3. **The skip path drops it entirely.** `SKILL.md:81` lets the round be *"skipped entirely"* when the
   rulebook already answers, and `SKILL.md:102` puts the inferences **and** the choices (mode,
   `integration:`, guide kind, license) in that same round. `INFER.md:112` then forbids the obvious
   repair: *"Announcing 'skipping — your rulebook answers all five' and then opening a question round
   anyway is the contradiction this paragraph exists to prevent."* On a dense-rulebook repo whose
   config lacks `integration:` — Presenter's exact shape — obeying INFER strands the question and
   re-opens the guess-from-`git log` defect.

The likely shape of the fix: the skip is scoped to **proposals**, not to the round that also carries
**declarations**, and one step is named as the owner of probing a declaration a verb will need. Do not
treat that as decided — it is the reviewer's reading and mine, not a tested one.

## Acceptance criteria

- [ ] Exactly one step owns discovering that a present artifact lacks a declaration its owner verb needs, and the other steps point at it rather than each deferring
- [ ] A repo whose rulebook covers every inferable subsection **and** whose config lacks `integration:` still gets asked — once, in one round
- [ ] A repo that already carries the field is **not** asked, on a first run or a re-run
- [ ] The skip announcement and the question round can co-exist without contradicting `INFER.md` § *When the rulebook already answers it* — or that paragraph is amended in the same change
- [ ] The one-frontier-round rule still holds: no queue of single questions, and no question migrating into step 3
- [ ] Layer parity honoured if `LAYER.md` changes
- [ ] `skills-lint` and `skills-lint-test` stay green

## Out of scope

- TASK-028's separate defect in the same skip rule (counting five subsections when UI/UX is conditional). Adjacent line, different arithmetic — do them together if convenient, but its criteria are its own.
- Re-litigating the ban on inferring `integration:` from `git log`. The ban is right; this is about who asks instead.
- `/tasks init`'s own reconciliation, which TASK-023 already delivered.

## Human test plan

- [ ] Drill a repo with a dense rulebook and a config lacking `integration:`; confirm one round, one question, no `git log` inference
- [ ] Drill a repo whose config already has the field; confirm it is not asked, then re-run and confirm it is still not asked
- [ ] Confirm the skip announcement still names what covered the inferences (TASK-017's rule) in both cases
