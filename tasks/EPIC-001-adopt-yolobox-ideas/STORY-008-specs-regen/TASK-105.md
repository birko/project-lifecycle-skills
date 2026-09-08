---
id: TASK-105
parent: STORY-008
feature: null
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: todo
priority: P2
assignee: agent
created: 2026-09-08
depends-on: [TASK-106]
blocks: []
# findings: ids this task remediates, from a review/audit/harvest/drill pass. Prefixes: see /tasks intake
findings: [DRILL-079-2]
pr: null
github-issue: null
jira-key: null
---

# `change-review` and `work-tracking` describe the same gate in near-identical words

## Context

**Found 2026-09-08 while running TASK-079's outstanding human-test item** — the third cold read of
`docs/specs/.map.yml`'s area list. The reader was given the 14 names and titles and nothing else.

Two titles claim the same object:

| Area | Title |
|---|---|
| `work-tracking` | The developer-facing backlog — epics, stories and tasks, **with a gate before done** |
| `change-review` | **The gate on a change** — your own rules, the task's criteria, correctness, and security |

> *"Those are the same sentence twice. I cannot tell whether the gate is invoked from work-tracking,
> described in it, or a different gate."*

It also second-guessed routing item 16 (*"does my change do what the ticket asked"*) toward
`work-tracking` before settling on `change-review`.

**This is a conclusive negative, and that is why it survives a contaminated drill.** The reader was
**not** cold — see TASK-106 — so it held the product's own vocabulary and still could not
discriminate. `populate-tests` § *The cold drill* names this asymmetry directly: *"A contaminated
drill can still produce a conclusive negative… if the runner still reports having to decide, the fix
failed, whatever it guessed about the answer."* The pass-direction results from the same run are
weak evidence and are not relied on here.

### Why this is new rather than a re-run of TASK-103

TASK-104 merged three diff-review areas into `change-review` on usage evidence, and that merge is
sound — it dissolved the four-way naming problem TASK-103 recorded. It also created this collision:
the merged area's title now names *"the gate on a change"*, while `work-tracking` already claimed
*"a gate before done"*. They are the same gate — `tasks/verbs/close.md` step 5b **is** it, and that
file is in `work-tracking`'s sources while the axes it fires are in `change-review`'s.

### Two further unrecoverable pairs, filed here because the root cause is shared

Both are titles that name a capability without naming its **scope**:

- **`feature-lifecycle` ↔ `glossary-and-adrs`** — both promise to record why something was decided;
  neither states scope (a per-feature ledger vs a repo-wide record). Routing item 18 landed on
  `feature-lifecycle` only because the question happened to contain the word "feature", which the
  reader flagged itself.
- **`defect-draining` ↔ `work-tracking`** — *"Working a **filed** review backlog down"*: filed by
  what, into where. No area on the list names an intake step, so the backlog's origin is invisible.

## Acceptance criteria

- [ ] A reader holding only the titles can tell which area to open to **run** the gate and which
      describes the backlog the gate sits in — the two no longer both claim "a gate" unqualified
- [ ] `feature-lifecycle` and `glossary-and-adrs` state their scope, so a decision-recording need
      routes to exactly one of them
- [ ] Where a filed defect backlog comes from is recoverable from the list — a title says it, or the
      intake step gets an area
- [ ] Verified by a **routing test, not the author's own reading**: items 1, 16 and 18 from the
      TASK-079 brief, plus a new "where do my defects come from" item, each route to one area with
      no `UNSURE` and no pair reported "not recoverable"
- [ ] `coverage: verified` still holds — no `sources:` glob moved, or the 63/63 recount is redone
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- **The `glossary-and-adrs` name itself.** The same reader called it *"a filing label, not a want…
  the `and` is the confession"* — but one skill owns both halves, so the map has no split available.
  That is `domain`'s scope, already recorded in the map's own comment and in TASK-103.
- **`installation` and `skill-authoring-rules`.** The reader's judgement on these two is discounted:
  they describe the product-as-product, which is precisely what a contaminated runner already knows.
  (It returned `yes` on `installation`, contradicting an earlier reader — unusable either way.)
- **Making a genuinely cold reader available — TASK-106.** This task's own human test cannot run
  until that lands, which is why `depends-on` names it.
- **Generating spec bodies — TASK-080.**

## Human test plan

- [ ] Re-run the routing test with a runner acquired by TASK-106's documented method, briefed with
      the area list alone. Expected: items 1 and 16 both to `change-review`, item 18 to exactly one
      area, the defects-origin item to exactly one area, and no `UNSURE` or "not recoverable" on any
      pair involving the four areas above.

## Implementation plan

_Populated by `/tasks plan TASK-105` — leave empty until then._
