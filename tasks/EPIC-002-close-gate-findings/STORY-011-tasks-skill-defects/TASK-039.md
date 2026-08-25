---
id: TASK-039
parent: STORY-011
feature: null
# status: todo | in-progress | review (code done, sign-off pending) | blocked | done | cancelled
status: done
priority: P3
assignee: agent
created: 2026-08-20
depends-on: []
blocks: []
findings: []
pr: null
github-issue: null
jira-key: null
---

# The dashboard template has no slot for the todo-by-priority breakdown

## Context

Found by TASK-034's criterion 4 — *"brought back to a state a plain `triage` run reproduces exactly"*.
Making this repo's `tasks/README.md` template-faithful **removed a useful line**:
`` `todo` by priority: 15× P2 · 3× P3. ``

That line is not narrative and not a convention violation of the kind TASK-034 fixed: it is **fully
derivable** from task frontmatter, and the bare-`/tasks` stdout snapshot renders exactly it
(`SKILL.md` § *Status snapshot*, the `todo:` row with its `(<p0>× P0, …)` breakdown). The gap is that
`templates/README.md.tmpl` has no placeholder for it and `triage` step 7 does not list one, so the
persisted dashboard cannot show what the transient snapshot does.

So it was dropped rather than hand-added back — hand-adding it is what TASK-034 exists to stop. Filed
instead, which is the point of the rule.

**P3, deliberately:** the information is one `/tasks` away and nothing is wrong, only thinner than it
could be. Recording the reason so a re-reader does not mistake the low priority for low confidence.

## Acceptance criteria

- [x] `templates/README.md.tmpl` gains a placeholder for the breakdown, and `triage` step 7 lists it with the others
- [x] It follows the snapshot's own suppress-zeros rule — a priority with no tasks is omitted, not shown as `0×`
- [x] Absent when there are no `todo` tasks at all, rather than rendering an empty tail
- [x] This repo's dashboard reproduces byte-identically from a plain render **after** the change, so TASK-034's criterion is not quietly undone
- [x] `skills-lint` and `skills-lint-test` stay green

## Out of scope

- Any other difference between the stdout snapshot and the persisted dashboard. If there are more, they are their own finding — do not sweep them in here without measuring first.
- Changing what counts as `todo`, or the priority vocabulary.

## Human test plan

- [ ] Render the dashboard on this repo and confirm the breakdown matches what bare `/tasks` prints
- [ ] Cancel or close every `todo` task in a throwaway fixture and confirm the line disappears rather than rendering empty

## Outcome

**What was broken.** TASK-034 made this repo's dashboard template-faithful, and in doing so removed a line
that was **fully derivable** — `` `todo` by priority: 15× P2 · 3× P3. `` The stdout snapshot renders exactly
that breakdown; the persisted dashboard could not, because `templates/README.md.tmpl` had no placeholder and
`triage` step 7 listed none. So the line was dropped rather than hand-added back, which is what TASK-034
exists to enforce. Filed instead — the rule working.

**Fixed:** `{{TODO_BY_PRIORITY}}` in the template, listed in `triage` step 7 with its three rules —
suppress zeros, omit the whole line when nothing is `todo`, and match the snapshot's wording.

**A second defect with the same root cause, pulled in per *findings travel in packs*.** The Collection pass
specified the breakdown as `{P0, P1, P2}` — a **hard-coded set of three** — and the snapshot rendered
`(<p0>× P0, <p1>× P1, <p2>× P2)` to match. This repo has a **P3** `todo` task. So the breakdown as written
would have counted **21 of 22** and silently dropped it, and implementing TASK-039 by copying that list would
have shipped the bug into the persisted dashboard too.

Both now say **one bucket per priority actually present, ordered, never a fixed set** — the restated-growable-
list defect, in a spec rather than in prose. Left as a hard-coded three it would have gone wrong the first
time anyone used P4 or a project used its own scale.

**Step 6 — derived, not typed, which is the whole point of AC 4.**

| Check | Result | Role |
|---|---|---|
| the line renders from frontmatter alone | `` `todo` by priority: 4× P1 · 17× P2 · 1× P3. `` — computed by walking every task's frontmatter, not written by hand | **fix-dependent** — AC 4 is that a plain render reproduces it |
| the terms sum to the table | 4 + 17 + 1 = **22** = the `todo` count once this task closes | **fix-dependent** — a breakdown that does not sum is worse than none |
| the P3 term is present | it is, and a hard-coded `{P0,P1,P2}` render would have shown 21 | **fix-dependent** — this is the second defect's evidence |
| zero-suppression | P0 has no tasks and no `0× P0` term appears | contract pin — the snapshot's existing rule |
| lint | OK (18 skills) | contract pin |

**A note on the numbers, so a re-reader is not confused.** While this task was `in-progress` the counts table
read `todo 23` against a breakdown summing to 22 — correct, because the picked task had left `todo`. They
reconcile at close: 22 and 22.

**Step 7.** No usable spec map (`areas: []`) — no regen. Stated, not skipped.

**P3 was the right priority and the finding was still worth having.** Nothing was broken, only thinner than
it could be — and the P3 bucket defect it exposed would have been shipped by anyone implementing the P3 task
without checking the list first.

## Progress log

- step 2 — picked; the last tightly-scoped candidate, and one with direct evidence: this session hand-maintained that counts table through ten closes, so the missing derivable line was felt repeatedly. Key 6 (theme) **inert**: every EPIC-002 story declares `correctness-invariants`.
- step 3 — verified: **held, and a second defect found in the same lines.** The template has no placeholder and `triage` step 7 lists none — as filed. Additionally the Collection pass hard-codes `{P0, P1, P2}` while this repo has a P3 `todo` task, so the spec would drop it; same root cause, same edit, pulled in rather than spawned.
- step 4 — layer: **local.**
- step 5 — `templates/README.md.tmpl` (placeholder), `verbs/triage.md` step 7 (the three rules), `SKILL.md` Collection pass + snapshot (buckets derived, not listed).
- step 6 — line derived from frontmatter and rendered; terms sum to the count; P3 present; zeros suppressed; lint green.
- step 7 — no usable spec map (`areas: []`); regen skipped and stated.
- step 8 — 5d sweep: Out of scope bullets are boundaries. Nothing spawned. Gate: standards pass, intent pass, correctness pass; security not applicable.
