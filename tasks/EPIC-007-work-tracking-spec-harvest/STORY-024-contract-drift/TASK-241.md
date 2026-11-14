---
id: TASK-241
parent: STORY-024
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: done
# blocked: <reason> — add this line while the task is blocked, keeping its status; /tasks unblock removes it
priority: P3
assignee: unassigned
picked-by: fix-next
created: 2026-10-03
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [SH-48, SH-49, SH-50]
pr: null
github-issue: null
jira-key: null
---

# Three stale words in `feature`: a count, a citation and a list of forms

## Context

Found by the feature-lifecycle spec harvest (2026-10-03, EPIC-007, spec committed in b24eb8b). Each is a phrase that
no longer matches what it describes.

- **SH-48.** `skills/feature/SKILL.md` § *The feature list is a living artifact* says "Two standing obligations" and
  lists three (Completeness, Currency, Keep the companion docs in sync).
- **SH-49.** `verbs/pick.md`, edge case *Feature is `done`*, cites "per SKILL.md" for the rule that a change to a
  human-verifiable surface sends the implementing task back to `verify`. That rule lives in `verbs/decide.md`
  § *Changing a closed feature*, and `SKILL.md` does not carry it.
- **SH-50.** `verbs/help.md`'s `prototype` line lists "HTML / wireframe / spike". It is missing the fourth form, the
  state-model playground, which TASK-124 (at `verify`) added to `prototype.md` without updating the help table.

## Acceptance criteria

- [x] The count matches the list
- [x] `pick.md` cites `decide.md` § *Changing a closed feature*
- [x] `help.md` names all four prototype forms
- [x] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- Other content of TASK-124

## Human test plan

N/A — three wording fixes, checked by following each to its target.

## Implementation plan

Inline: two one-word fixes; the third was already made.

## Outcome

- **SH-48:** `SKILL.md` now says "Three standing obligations", matching its three numbered items.
- **SH-49:** already fixed before this pick. `pick.md`'s *Feature is `done`* case cites `decide.md` § *Changing a closed
  feature*, which exists and carries the rule.
- **SH-50:** `help.md`'s `prototype` line names all four forms, the state-model playground included.

**Human test plan:** N/A as filed. Each fix was followed to its target: three numbered items; the decide.md heading
exists; four forms in `prototype.md`'s table.

**Close gate (inline; two skill files):**
- **Standards, intent:** all criteria met.
- **Correctness:** by reading.
- **Security, comments:** not applicable.
- **CI:** local lint passes; main is unpushed.
- **Specs:** none quotes the changed words, so there is no respec.

## Progress log

- step 2 — picked; ranked above TASK-264 because stale words mislead every reader of the skill now, where TASK-264 is a capability-detection rewording on one verb's publish path; STORY-024 already in-progress
- step 3 — re-verified: SH-48 and SH-50 hold at HEAD; SH-49 already fixed (pick.md cites decide.md § *Changing a closed feature*)
- step 5 — fixed SH-48 and SH-50
- step 6 — by reading (plan N/A); lint passes
- step 7 — no spec quotes the changed words
- step 8 — closed inline; commit in git log
