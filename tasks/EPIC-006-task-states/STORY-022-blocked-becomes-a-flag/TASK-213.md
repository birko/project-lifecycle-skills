---
id: TASK-213
parent: STORY-022
feature: FEATURE-003
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: done
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

- [x] `inReviewTasks[]` reads `verify` or `review` on a worktree branch copy
- [x] No skill text writes, or describes writing, `status: review` for a task; prose describing the task
      lifecycle says `verify`. Checked by a grep recorded in the progress log, every remaining `review` hit
      classified (feature phase or gate, the reading table's old form, a skill name, a review pass)
- [x] `CONVENTIONS-universal.md` and `CLAUDE.seed.md` say `verify` and describe a deferred merge as
      `in-progress` with a `blocked:` field; layer parity checked (`skills/new-project/LAYER.md` — both front
      doors consume these templates), and any copy of this prose in AGENTS.md updated to match
- [x] `block.md`'s intro and `tasks/SKILL.md`'s router row and § Lifecycle describe a blocked task as keeping
      its state and staying on offer in `pick` and `fix-next`, out of the dashboard's "Next up" only
- [x] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- The feature's own `review` phase and gate, and the `review` skill — not renamed by FEATURE-003
- `close` refusing a blocked task — TASK-214
- Deferred to TASK-217 — `migrate` selects tasks by a status set that has no `verify` and still lists `blocked`, so it never exports a task awaiting verification

## Human test plan

- [x] A cold run of `/new-project` scaffolding into an empty folder: the generated rulebook's lifecycle text
      says `verify` and describes a deferred merge as `in-progress` with a `blocked:` field

## Implementation plan

_Populated by `/tasks plan TASK-213` — leave empty until then._

## Progress log

- 2026-10-03 — Picked (in place; single-branch). One-theme sweep, plan written in Context's table, grill skipped. Inventory by grep over `skills/` and `skills-pi/` for every task-status `review` and every stale `blocked` description.
- 2026-10-03 — Changed: `tasks/SKILL.md` (`inReviewTasks[]` reads `verify` or `review` on a worktree branch copy — the VI-001 bug; a worktree park writes `verify`; two lifecycle lines; the router row and § Lifecycle's blocked sentence per D6), `close.md` (unattended row, `verify → done`, the deferral line), `fix-next` (`verify → done`), `feature` SKILL, `pick`, `status`, `decompose`, `review` (client tasks park at `verify`), `slicing.md` (a deferred batch stays `in-progress` with a `blocked:` field), `block.md`'s intro (blocked is a flag; on offer in `pick` and `fix-next`, out of "Next up" only), `init.md` (one "ready pool" phrase), `new-project/templates/CONVENTIONS-universal.md` (three sites) and `CLAUDE.seed.md` (one). Lint OK.
- 2026-10-03 — Remaining `review` hits classified (grep `'`review`|status: review|review → |→ review'` over `skills/` and `skills-pi/`, 82 hits): the feature's own vocabulary (its `status: review` marker, phase, gate, verb — FEATURE-003 renamed only the task status); the internal `review` count bucket `verify` counts in (`tasks` and `feature` Collection passes); readers accepting the old form (the reading table, `audit`'s `old-form` row, `init` 3b's migration, `pick` 2b and `inReviewTasks[]`); skill names and review passes (`review`, `/feature review`, `security-review`, "the review passes"). None writes or describes writing a task's `status: review`.
- 2026-10-03 — Layer parity: the change is wording inside `CONVENTIONS-universal.md` and `CLAUDE.seed.md`, not an inventory row, so `LAYER.md` is untouched; `new-project` splices the template verbatim and `adopt-project` reconciles the layer's shape, not its prose — both doors carry the new text through the same file. AGENTS.md holds none of these sentences. Drill: one cold runner of `new-project` into an empty folder (one runner: the splice is verbatim, so the check is mechanical), oracle `%TEMP%\d213-oracle.txt` written first.
- 2026-10-03 — Drill: **two cold runners** of `new-project` (the second one started first, as a plain `&` I could not confirm was alive, so a clean one was run beside it; both finished, both cold — no skills listed). Both generated `CLAUDE.md`s match the oracle on all four points — "dropped straight into `verify`"; a deferred merge "stays `in-progress` with a `blocked:` field … re-closes after `/tasks unblock`"; `/tasks block/unblock` add or remove the field; the feature reverts to `review` and its task to `verify` — with no `status: review` anywhere, and the comment-rule block byte-identical. Reports and both guides at `%TEMP%\d213reports`.
- 2026-10-03 — Close review, one reviewer, two verdicts. **Standards:** pass — the comment-rule block untouched (lint check 5 agrees), no `LAYER.md` or `adopt-project` change needed (wording inside a template, no new row or bullet), AGENTS.md holds none of the sentences. **Correctness:** no defect introduced; three sites the sweep missed, all inside this task's criteria, fixed: `pick`'s no-match edge case suggested `--status todo,blocked`; `decide.md` reverted the *feature* `done → verify` (now `done → review`, its tasks `done → verify`); `close`'s rejected-alternative note said "ending at `blocked`". A nit in my own `close` edit fixed (a deferred merge is `in-progress`, so it shows as blocked under "In progress", never in "Next up"). Spawned: TASK-217 — `migrate` never exports a `verify` task (CR-142). **Intent** (inline): all 5 criteria met. **Security / comments:** not applicable. Out-of-scope sweep: 3 boundaries (feature vocabulary, TASK-214, TASK-217). Closed `done`.
