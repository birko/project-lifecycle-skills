---
id: TASK-359
parent: null
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: done
picked-by: fix-next
# blocked: <reason> — set by /tasks block, never by hand; status stays as it is; /tasks unblock removes it
priority: P3
# assignee — one of: agent (default), unassigned, human, or an installed agent type's name; ai is read as agent, never written
assignee: agent
created: 2026-11-13
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: []
pr: null
github-issue: null
jira-key: null
---

# Regenerate the `test-authoring` spec, two commits behind its sources

## Context

Found at TASK-354's close (2026-11-13). `docs/specs/test-authoring.md` is stamped `generated-at: 222c36d`
(2026-10-12). Since then two commits changed the files it covers (`skills/populate-tests/**`, `skills/tdd/**`)
without a regen:
- 812b262 TASK-271;
- 6873992 TASK-283.

TASK-354 made one surgical edit to it and left the stamp alone on purpose, because a new stamp would claim a
currency nobody checked. So the spec may describe behaviour those two commits changed.

**Loose on purpose.** This is tree maintenance, not a review finding. Filing it into an intake epic would make that
pool misreport how much of a review is left (`AGENTS.md` § Working rules, *A task outside a pool*).

## Acceptance criteria

- [x] `/specs regen test-authoring` has run, and its diff has been reviewed as "was this change intended?". Each
      requirement it changes is traced to TASK-271, TASK-283 or TASK-354, and anything else is spawned as a finding
- [x] The spec's `generated-at` names the commit it was regenerated at
- [x] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- Changing `populate-tests` or `tdd` themselves. A spec diff that shows a defect is spawned, not fixed here

## Human test plan

N/A — the regen's own diff review is the check, and it runs inside the task.

## Implementation plan

Inline: walk every source commit since the stamp, check whether the spec states what it changed, edit only what the code contradicts, restamp.

## Outcome

**Six source commits since the stamp, each traced (the stamp was older than the two this task named):**

| Commit | Spec |
|---|---|
| 6873992 TASK-283 (no harness: verify and ledger report no pass) | already specced in the same commit |
| 812b262 TASK-271 (citations replaced with inline reasons; `run` scoped to Claude Code) | no change: the spec states neither the citation nor which skill drives a browser |
| 1c489ef TASK-354 (`.gitignore` lines offered when chained from adoption) | already specced in the same commit |
| 12f9f91 TASK-072 (adopt's recipe by package manager) | already specced in the same commit |
| 2deb103 TASK-363 (the § Testing question names where tests are or will go) | **changed:** the § Testing requirement names it |
| eaefe24 TASK-210 (a skill's examples are invented) | **changed:** the drill-targets requirement states it, with a scenario |

Both changes are intended: each is the acceptance of the task that made it (TASK-363, TASK-210). Neither shows a
defect, so nothing is spawned. No source task carries `feature:`, so `shaped-by` is unchanged.

**Result.** Every spec area is fresh by `/specs verify`'s rule, for the first time this session.

## Progress log

- step 2 — picked as the named next pick, on the user's go-ahead; loose (tree maintenance), outside the ranked pool, recorded rather than ranked
- step 3 — verified: six source commits since 222c36d; three respecced in place, three not
- step 5 — regen: two requirements and one scenario changed, restamped at HEAD
- step 6 — check: no area stale under verify's anchor; lint passes
- step 8 — closed inline; commit in git log
