---
id: TASK-155
parent: STORY-019
feature: FEATURE-002
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: done
priority: P3
assignee: unassigned
created: 2026-09-20
depends-on: []
blocks: []
findings: [DRILL-152-1]
pr: null
github-issue: null
jira-key: null
---

# One reader in six renders ⚠ where the severity table says 🛑

## Context

Measured by TASK-152's drill — six cold `claude -p` runners over three rounds, on independent copies
of a fixture, each given a brief that withheld every verdict. **Every one of the six resolved the
scope identically.** They did not agree on severity.

**The case.** A rationale comment whose reasoning is already in `docs/adr/0003-single-writer.md`:

```
// Concurrent writers interleaved under load and corrupted the running total, so we
// accepted one writer with an enqueue in front of it and the throughput bound that implies.
```

| Runner | Severity |
|---|---|
| 1, 2, 3, 5, 6 | 🛑 |
| 4 | ⚠ |

**The outlier is not a misread, which is what makes it worth a task.** Runner 4 wrote: *"The rule also
names a rationale above a declaration as always a violation, but the deletion is safe here only because
the record exists."* It quoted the correct rule and still rendered the lower severity — so the failure
is not that it missed the always-violation list; it is that **two rules in the skill both claim this
case and point at different severities**, and nothing says which wins:

| Rule | Says |
|---|---|
| `SKILL.md` § Step 4 severity table | 🛑 — *"an instance the project's own rule text names as **always** a violation"* |
| the same table, next row | ⚠ — *"the content appears to live at one of the table's destinations; a human should confirm"* |

A rationale sitting above a declaration whose reasoning is in an ADR satisfies **both** rows at once:
it is a named always-violation *and* its content is at a destination. Five readers took the first row,
one took the second, and the skill does not say the first outranks the second.

**Why this matters more than one notch of severity.** `/tasks close` step 5b reports this skill as its
own axis, and a 🛑 is what a reader scans for. The same comment rendering 🛑 for one reviewer and ⚠ for
another makes the axis unreproducible in exactly the way the destination test was designed to prevent —
the whole premise being *"a check two reviewers answer identically"*.

## Acceptance criteria

- [x] § Step 4's severity table says what happens when a finding satisfies more than one row — the always-violation row outranks the destination row, or it does not, stated once.
- [x] The rule is written so a reader who has already found the destination cannot conclude the severity drops because the content was safely relocatable. Runner 4's sentence is the shape to defeat.
- [x] Re-run at least two cold runners on TASK-152's fixture (`scratchpad/drill-152`, rebuildable from this task's sibling record). Expected: both render the ADR case at the same severity.
- [x] `bash .github/workflows/skills-lint.sh` passes.

## Out of scope

- The three scopes and their resolution — TASK-152, measured 6 of 6 and not in question here.
- The destination table itself — that lives in the project's guide (FEATURE-002 D1/D2), never in this skill.
- The `universal:` ⚠ cap (D14) — a different severity rule, already unambiguous.

## Human test plan

- [x] Two cold runners on the rebuilt fixture, brief withholding the expected severity. Expected: same severity for the ADR case from both.
- [x] Expected failure to watch for: the fix makes *everything* 🛑. A table where one severity swallows the others is not more reproducible, it is less informative — the ⚠ row exists because most findings genuinely do need a human to confirm.

## Implementation plan

One precedence sentence under § Step 4's severity table, worded against runner 4's reasoning rather than
restating the rows: an always-violation stays 🛑 when its content also has a destination, because the
destination answers *is the fix safe*, not *how plainly the rule condemns it*. **held** is explicitly left
to § *The only copy* — the only other row that could compete, and outside this task.

### Drill record — 2026-09-24

**Fixture** `scratchpad/drill-155` (copies `-155a`, `-155b`), rebuilt from TASK-152's round-1 record: a
TypeScript repo with the rule spliced verbatim from `templates/CONVENTIONS-universal.md` at rung 0, an open
`TASK-007`, `docs/adr/0003-single-writer.md`, and `src/ledger.ts` carrying the three blocks — the
ADR-backed rationale above a declaration (the case), the ticket-backed defect note, and a
destination-*nowhere* block — all committed, so the diff is empty.
**Runner:** `echo <brief> | claude -p --permission-mode acceptEdits --add-dir ~/.claude/skills
C:/Source/project-lifecycle-skills`, two processes on independent copies, concurrently — TASK-152's
acquisition. **Brief, verbatim:** *"Use the review-comments skill on `src/ledger.ts` in this repo and give
me its report."* It withholds every severity. The runners hold the installed skill — the thing under test —
and nothing about this task.

| | Runner a | Runner b |
|---|---|---|
| ADR-backed rationale (the case) | **🛑**, ADR 0003 named | **🛑**, ADR 0003 named |
| ticket-backed defect note | ⚠, TASK-007 | ⚠, TASK-007 |
| destination-*nowhere* block | kept, not reported for length | kept, same |
| files edited | none | none |

**Same severity from both — criterion 3 met.** Runner b restated the new sentence's reasoning unprompted:
*"Having the decision record makes the fix safe; it doesn't make the finding less severe"* — the inverse of
runner 4's. **The watched failure did not occur:** the ticket-backed note stayed ⚠ in both, so the rule did
not collapse the table into 🛑. Two runners is weaker evidence than TASK-152's six; it is what the criterion
asked for, and the reasoning is quoted rather than inferred.

**Gate, inline** — one paragraph of skill prose: standards ✅ imperative, rationale inline, no restated
list · fidelity ✅ criteria 1-4 · correctness ✅ lint exit 0 · comments: not applicable, no code comment in
range. Security: not applicable.
