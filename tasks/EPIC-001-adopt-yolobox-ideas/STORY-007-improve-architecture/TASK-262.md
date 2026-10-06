---
id: TASK-262
parent: STORY-007
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: done
# blocked: <reason> — add this line while the task is blocked, keeping its status; /tasks unblock removes it
priority: P2
assignee: agent
created: 2026-10-06
depends-on: []
blocks: [TASK-078]
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: []
pr: null
github-issue: null
jira-key: null
---

# `intake` states the shape of a "Findings dropped at intake" entry, because another skill now reads it

## Context

Found while planning **TASK-076**. The `improve-architecture` skill reads an earlier run's
`### Findings dropped at intake` list (written by `skills/tasks/verbs/intake.md` step 3) so that a candidate the
deletion test rejected is not raised again on the next run.

`intake.md` says what goes in that list ("drop it, with the reason recorded") but never what an entry looks like.
Today's entries in this repo's EPIC-007 are a three-column table (finding, claim, why dropped). That shape works for a
review pass, but it carries nothing a later run can re-check against: no path, no callers, no commit.

AGENTS.md § *Code structure & patterns*: **"A format one skill reads is a contract the writing skill must state
too."** If only the reader records the shape, the writer can change it without ever seeing the consequence, and the
reader then degrades silently.

The owner decided on 2026-10-06 to file this as its own task rather than fold it into TASK-078. TASK-078's own Out
of scope already routes any change to `intake` to a separate task.

## Acceptance criteria

- [x] `intake.md` step 3 states the shape of a dropped entry: what was dropped, why, and, where the finding names code, the path, the callers checked and the commit it was judged at
- [x] The existing table shape stays valid for passes whose findings name no code (review findings like EPIC-007's), so no filed epic becomes malformed
- [x] `intake.md` names the reader: a later pass reads this list so it does not re-raise what was dropped
- [x] The prefix table gains a row for the architecture pass, so its findings get ids of their own rather than a borrowed prefix (added 2026-10-06 from TASK-076's correctness review)
- [x] `{{SOURCE}}` is stated to name the pass that produced the epic, whatever else it carries (a report path, a PR, a date), because a later run finds its earlier runs by that name (TASK-076's conventions review, W2)
- [x] A pass whose findings include rejections is filed into an epic even when it has only one or two candidates, so the rejections have a home. Today the one-or-two-findings edge case files no epic at all (TASK-076's correctness review)
- [x] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- How `improve-architecture` reads the list (TASK-076) and how its handoff writes it (TASK-078)

## Human test plan

N/A: a wording change to one verb file. The reader side is drilled by TASK-076 and TASK-078, which consume this shape, so a human adds nothing here beyond reading the diff at the close gate.

## Implementation plan

Drafted 2026-10-06 by the `Plan` agent; facts checked against the files.

**Criterion 1, read with criterion 2:** the code-shaped entry applies where the rejection was **judged against a code path and its callers, at a commit**, so a later run can re-check it. Read literally, "names code" covers every finding, because intake step 2 already asks for `file:line` evidence, and that would invalidate EPIC-007's table. A clarification, not a change of target.

1. **"When this fires":** a pass with any dropped finding qualifies, not only one with more than a couple of findings.
2. **Step 2 prefix table:** a new `IA-*` row for [[improve-architecture]]. Initials, like `CR`, `VC`, `VI`. No `IA-` or `ARCH-` id exists anywhere; `ARCH-` would match inside `SEARCH-` on a loose grep. The ids number within the pass. The cross-run key is `<n>:<path>`, which TASK-078 writes.
3. **Step 3:** state that an entry's shape is a contract, name the reader, and choose the shape by what the rejection was judged against:
   - a code path, its callers and a commit → `- <path> — <reason> (callers: <paths>; at <commit>)`, with the `held by ADR` variant;
   - anything else → the existing `| Finding | Claim | Why dropped |` row.
4. **Step 5:** `{{SOURCE}}` **names the pass**, whatever else it carries. That is the Source column's skill, or the row's own name where no skill ran. All three existing intake epics already comply: EPIC-002 (`/verify-conventions`, `/code-review`), EPIC-003 (`field use`) and EPIC-007 (`specs regen`).
5. **Edge cases:** "one or two findings" narrows to "one or two findings, **none dropped**". A pass that dropped anything gets its epic, even when every finding was dropped and no task is filed. **Added beyond the plan, owned by criterion 6:** such an epic is a record, not a backlog, so it is written `done` at once. Otherwise it reads `planned` forever, a parent-versus-children contradiction `audit` would flag.
6. **`new.md` line 95** restated `{{SOURCE}}`'s meaning; it becomes a pointer to intake step 5 (AGENTS § *Defer to a shared inventory*).
7. **This file's Context** said four-column; the table has three columns.
8. Lint.

No change is needed in `fix-next` (it reads `kind:` and `findings:`, and points at the prefix table), in `tasks/SKILL.md`, in `templates/TASK.md` or in `roadmap`. The shape is now stated on both sides, intake and `improve-architecture` Step 5, which is the contract rule's intent; TASK-078 drills the pair.

## Progress log

- 2026-10-06 — Picked; plan drafted by the `Plan` agent and checked against the files. `intake.md` and `new.md` changed per the plan; lint OK.
- 2026-10-06 — **Close gate (step 5b), each axis reported separately:**
  - **Standards** ([[verify-conventions]]): no blockers. Two warnings, both fixed. `callers: none` is now stated on the reader side too. The record epic's `done` now goes through `new.md`'s `{{STATUS}}`, never a hand edit. Two notes fixed as well: "field use" is now worded as the source's own words, and AGENTS.md's contract rule names this instance (register-on-introduce).
  - **Fidelity** ([[verify-intent]]): all 7 criteria built, and the reader side agrees. Five additions beyond the plan, each traceable to the close-gate reviews:
    1. `improve-architecture` Step 5: the `callers:` slot carries implementations for an item 4 verdict, and `none`. One side of this contract, kept in step with the other.
    2. A later pass filing tasks into a `done` record epic re-opens it.
    3. Step 8's "Drain it" line is omitted when no task was filed.
    4. `new.md` `{{STATUS}}` gains its `done` case, and the template's `source:` comment is reworded.
    5. The AGENTS.md clause.
  - **Correctness** (code-review pass): 6 findings, all fixed:
    1. the `done` record epic could not be reached through the verbs (now `{{STATUS}}`);
    2. the template comment and the `--source` argument still suggested a bare path;
    3. a re-run into a `done` epic left children under a `done` parent;
    4. "omit `callers:`" covered verdicts the reader cannot re-check (the slot now holds the paths the verdict turned on, and only `held by ADR` omits it);
    5. step 8 told an all-dropped pass to drain;
    6. the escaped pipes could be copied literally.
  - **Security:** not applicable, because the diff is prose with no security surface. **Comments:** not applicable, because there are no code comments in range.
  - **Out of scope (5d):** 1 boundary (TASK-076, TASK-078), 0 spawned, 0 declined.
