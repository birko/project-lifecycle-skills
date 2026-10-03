---
id: TASK-213
parent: STORY-022
feature: FEATURE-003
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: todo
# blocked: <reason> — add this line while the task is blocked, keeping its status; /tasks unblock removes it
priority: P2
assignee: unassigned
created: 2026-10-03
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [VI-001, VI-002, VC-057]
pr: null
github-issue: null
jira-key: null
---

# The old `review` and `blocked` wording still ships in writers, front doors and the `block` intro

## Context

Found by `/feature review FEATURE-003` (2026-10-03), Gate A's feature-level fidelity pass over
`git diff 6a67896..HEAD -- skills/`. FEATURE-003 D4 renamed the stored value `review` → `verify`, and D6 keeps
blocked tasks on offer. Both are built in the readers, but these sites still say the old thing. TASK-201's and
TASK-204's ticked criteria about leftover `review` mentions are not supported by the diff.

| Id | Site | Problem |
|---|---|---|
| VI-001 | `skills/tasks/SKILL.md` § Collection pass, `inReviewTasks[]` | Finds a worktree park only by a branch copy that "reads `review`"; `close` now writes `verify` there, so **every new worktree park is missing from verification debt**, the case the line exists for. `pick.md` already says "`review` (or `verify`)" |
| VI-001 | `skills/feature/verbs/review.md` step 5 | "Park any client tasks at `status: review` too" — a literal writer of the old value |
| VI-001 | `skills/tasks/verbs/close.md` `--unattended` table and step 5 | "Real unrun manual steps ⇒ `review`"; "To later move `review → done`" |
| VI-001 | `skills/fix-next/SKILL.md`, `skills/tasks/SKILL.md` lifecycle prose | "closing `review → done`"; lifecycles ending in `review` |
| VI-001 | `skills/feature/verbs/status.md`, `skills/feature/SKILL.md`, `skills/feature/verbs/decompose.md` | "Client tasks … carry `status: review`"; "mirrors the [[tasks]] skill's `review` task status"; "never straight into `review`/`done`" |
| VC-057 | `skills/new-project/templates/CONVENTIONS-universal.md` (spliced verbatim into every new consumer's rulebook) and `templates/CLAUDE.seed.md` | "dropped straight into `review`"; a deferred merge "ends at `blocked` … re-closes after `/tasks unblock`" (D3: it stays `in-progress` with a `blocked:` field); `/tasks … block` listed as setting `status:`; "its implementing task revert to `review`" |
| VI-002 | `skills/tasks/verbs/block.md` intro; `tasks/SKILL.md` router row and § Lifecycle | "`blocked` ≠ `todo`" and "excluded … from `/tasks pick` defaults" contradict D6, where a blocked task keeps its state and stays on offer in `pick` and `fix-next` |
| — | `skills/tasks/slicing.md` § Wide refactors | a deferred-merge batch "ends `blocked`" — ambiguous; should read "stays `in-progress` with a `blocked:` field" |

Where the **feature** phase or gate is meant (`/feature review`, phase `review`), `review` stays: it is a
separate vocabulary FEATURE-003 did not rename. Only the **task** status changes.

## Acceptance criteria

- [ ] `inReviewTasks[]` reads `verify` or `review` on a worktree branch copy
- [ ] No skill text writes, or describes writing, `status: review` for a task; prose describing the task
      lifecycle says `verify`. Checked by a grep recorded in the progress log, every remaining `review` hit
      classified (feature phase or gate, the reading table's old form, a skill name, a review pass)
- [ ] `CONVENTIONS-universal.md` and `CLAUDE.seed.md` say `verify` and describe a deferred merge as
      `in-progress` with a `blocked:` field; layer parity checked (`skills/new-project/LAYER.md` — both front
      doors consume these templates), and any copy of this prose in AGENTS.md updated to match
- [ ] `block.md`'s intro and `tasks/SKILL.md`'s router row and § Lifecycle describe a blocked task as keeping
      its state and staying on offer in `pick` and `fix-next`, out of the dashboard's "Next up" only
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- The feature's own `review` phase and gate, and the `review` skill — not renamed by FEATURE-003
- `close` refusing a blocked task — TASK-214

## Human test plan

- [ ] A cold run of `/new-project` scaffolding into an empty folder: the generated rulebook's lifecycle text
      says `verify` and describes a deferred merge as `in-progress` with a `blocked:` field

## Implementation plan

_Populated by `/tasks plan TASK-213` — leave empty until then._
