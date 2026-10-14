---
id: TASK-254
parent: STORY-011
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: done
# blocked: <reason> — add this line while the task is blocked, keeping its status; /tasks unblock removes it
priority: P3
assignee: unassigned
picked-by: fix-next
created: 2026-10-04
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [DRILL-193-1]
pr: null
github-issue: null
jira-key: null
---

# `pick`'s in-place fallback with an upstream never says where the status flip is committed

## Context

Found by TASK-193's cold drill (2026-10-04). The runner answered the question it was set correctly, then noted
in passing: *"The spec doesn't say exactly where an in-place upstream flip is committed, but 'nothing is
committed on the local default branch' settles that it must be the task branch."*

`skills/tasks/verbs/pick.md` step 6b: **"A fallback with an upstream** follows the in-place pick in step 7
(status flip, branch cut) and then runs `git push -u <remote> task/TASK-NNN`". Step 7 flips the status with an
edit and cuts the branch, and commits nothing. So the flip is an **uncommitted** edit carried onto the task branch,
and it first lands in a commit at `close`. That works, because the pushed branch, not the status line, is the taken
signal (FEATURE-001 D25). But a reader has to derive it, and the no-upstream path commits its pick explicitly
(`TASK-NNN: pick`), so the asymmetry reads like an omission.

Not linked to FEATURE-001: it changes no decided behaviour (D23, D25), only says what the text already implies.
If the fix changes behaviour (for example, committing the pick on the task branch before the push), it becomes a
`changed` decision on FEATURE-001 and the link is added then.

## Acceptance criteria

- [x] Step 6b's upstream fallback says where the status flip lives after the push: an uncommitted edit until `close`, or a `TASK-NNN: pick` commit on the task branch, whichever is chosen
- [x] If the choice changes behaviour, FEATURE-001's ledger records it — not applicable: the uncommitted-edit option was chosen, which changes no behaviour
- [x] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- The worktree path, which commits its pick explicitly
- Naming (TASK-193)

## Human test plan

N/A — wording. If behaviour changes, a drill of the fallback (a `-p` runner always takes it; see the cold-runner notes) replaces this line.

## Implementation plan

Written by `/fix-next` after step 3 (it runs no `/tasks plan`): state in `pick.md` step 6b that the upstream fallback's flip stays uncommitted until `close`, and why the push needs none; respec `work-tracking`.

## Outcome

- **The fix.** `pick`'s worktree fallback with an upstream pushed the task branch but never said where the status flip lived. A reader had to work out that it stays an uncommitted edit until `close`, and the explicit pick commit on the no-upstream path made the silence read like an omission. Step 6b now says so, and says why no commit is needed: the pushed branch, not the file, is the taken signal (FEATURE-001 D25). `fix-next`'s note on where its log lines ride now covers this path too. Files: `skills/tasks/verbs/pick.md` step 6b, `skills/fix-next/SKILL.md` step 2, and the `work-tracking` spec.
- **Step-6 split:** none. The change states what the text already implied, and the finding's own drill (TASK-193) showed a cold reader deriving this exact answer. The Human test plan is `N/A — wording`. Contract pin: lint OK.
- **Judgement calls.** Of the two options the criteria allow, the uncommitted edit was chosen. Rejected, as the larger change: committing `TASK-NNN: pick` on the task branch before the push. It would be a behaviour change (a `changed` decision on FEATURE-001) for no gain, because the taken signal is the branch's existence, and `close` already commits the flip with the work.
- **Specs.** `work-tracking` respecced by `/fix-next` step 7: the worktree-with-upstream requirement gains the fallback sentence. *Intended anyway — TASK-254's criteria, answered by /fix-next.*
- **Review gate.** Standards: pass, no findings. Fidelity: criterion 1 built, criterion 2 not applicable, criterion 3 verified here (lint OK). Correctness: the claim holds. Two low wording gaps were fixed: a self-contradicting sentence about pick commits, and `fix-next`'s log-line note. One medium gap predates this change and is outside its criteria: the *other* 6b fallback (the proof mismatch, which a `-p` runner always takes) never pushes the branch with an upstream, so other clones would see the task as free. Filed as TASK-328 (P2). Security and review-comments: not applicable.
- **Flagged, not fixed.** TASK-328.

## Progress log

- step 2 — picked at the user's request ("ok continue 254"), following the previous run's named next pick; ranked above TASK-327 on key 7 (P3 tie on keys 1–6 is not claimed: the user chose it)
- step 3 — verified: held. `pick.md` step 6b: "A fallback with an upstream follows the in-place pick in step 7 (status flip, branch cut) and then runs `git push -u <remote> task/TASK-NNN`". Step 7 commits nothing, so the flip is an uncommitted edit, and nothing says so
- step 4 — layer: local
- step 5 — fix in skills/tasks/verbs/pick.md step 6b: states the flip stays uncommitted on the task branch's checkout until `close`, and why the push needs no commit (D25). Chose the option that changes no behaviour, so FEATURE-001's ledger is untouched; test = lint OK
- step 6 — no revert-and-split: the change states what the text already implies, and the finding's own drill (TASK-193) showed a cold reader deriving exactly this answer. The task's Human test plan is `N/A — wording`, and a drill would only confirm the derivation. Contract pin: lint OK
- step 7 — respecced work-tracking; requirement changed: the worktree-with-upstream requirement gains the in-place fallback (push, flip uncommitted until close)
- step 7 (amended after review) — wording fixed in pick.md and fix-next step 2; the proof-mismatch fallback's missing push filed as TASK-328
- step 8 — handed to /tasks close --unattended; outcome in status:, commit in git log
