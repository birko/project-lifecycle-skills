---
id: TASK-150
parent: STORY-012
feature: null
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: todo
priority: P2
assignee: unassigned
created: 2026-09-19
depends-on: []
blocks: []
findings: [DRILL-149-1]
pr: null
github-issue: null
jira-key: null
---

# The `docs/architecture.md` row names a state but no fill action, and the two doors disagree

## Context

Raised by the cold runner during TASK-149's verification drill, 2026-09-19 — unprompted, and about the
skill's own instructions rather than the repo it was adopting. Its words: *"two readings exist and the
row doesn't settle which… This isn't a rule-ran-out `unknown` — the row's state is plainly `missing`;
the gap is in its prescribed action."*

`skills/new-project/LAYER.md:23` reads:

```
| `docs/architecture.md` | — | Leave it; report if absent. |
```

**"Leave it; report if absent" names no fill action**, while [[new-project]] creates the file as part of
scaffolding. So for an adopted repo the row is silent on the question that matters: does the adopter
*offer* to create it, or only report it missing?

**This is not hypothetical — the two drill runs took opposite readings.** The 2026-09-19 failing run
(DRILL-138-1) *generated* a `docs/architecture.md`; the passing re-run *reported it missing* and created
nothing. Same skill, same fixture, same brief.

**And the first reading is how a wrong verdict became durable.** That generated file asserted *"Nothing
here is deployed as a running service. Two CLIs and a library, distributed as packages and invoked on
demand"* — a run-mode claim about a component whose run mode could not be determined. A wrong line in a
report is read once; a wrong line in a committed architecture document is read by everyone afterwards
and is exactly the sort of thing `/adopt-project` is not supposed to author. TASK-149 fixed the
*classification* that produced that sentence. It did not settle whether the adopter should be writing
the file at all.

**Note the row also has an empty middle column** where its siblings carry a detection signal, which may
be part of why it reads as under-specified. Check whether that is deliberate before filling it.

## Acceptance criteria

- [ ] The row states what the adopter does when `docs/architecture.md` is absent: report only, offer, or create — one of the three, not a sentence that admits two.
- [ ] Whichever is chosen, `new-project`'s behaviour and the adopter's are consistent with each other, or the row says plainly why they differ.
- [ ] If the adopter may create or offer it, the row says what the file may and may not assert — a run mode or a deployment claim must not be written where the underlying question reached `unknown` (TASK-149's states).
- [ ] The empty middle column is filled or its emptiness is explained.
- [ ] `bash .github/workflows/skills-lint.sh` passes.

## Out of scope

- The classification rule that produced the bad content — TASK-149, done.
- The adopter's per-state reporting list — TASK-112.

## Human test plan

- [ ] Re-run the adopter on the `drill-138` fixture (resettable with `git reset --hard && git clean -fd`). Expected: it takes the row's single reading, and if it creates or offers the file, the content asserts nothing about `feedsync`'s run mode, which is `unknown`.
- [ ] Run it twice and compare. Expected: the same decision both times. The defect this task exists to fix is precisely two runs differing, so one run proves nothing.
