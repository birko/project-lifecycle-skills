---
id: TASK-328
parent: EPIC-003
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: done
# blocked: <reason> — add this line while the task is blocked, keeping its status; /tasks unblock removes it
priority: P2
assignee: agent
picked-by: fix-next
created: 2026-10-14
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [CR-254-1]
pr: null
github-issue: null
jira-key: null
---

# `pick`'s proof-mismatch fallback never pushes the task branch with an upstream, so other clones see the task as free

## Context

Found by TASK-254's close review (2026-10-14). `skills/tasks/verbs/pick.md` step 6b has two ways to fall back to an in-place pick:

- **`git worktree add` fails.** Since TASK-254 this path says it pushes `task/TASK-NNN` when the default branch has an upstream, and that the status flip stays uncommitted until `close`.
- **The enter-then-prove check mismatches.** This happens whenever the session cannot enter the worktree, and a `claude -p` runner always takes it. This path says only "continue at step 7". Nothing says it pushes with an upstream.

With an upstream, nothing is committed on the local default branch, so the pushed branch is the only taken signal (FEATURE-001 D25). Scenario: a session picks with an upstream, the proof mismatches, it falls back in place, and it never pushes. Every other clone's Collection pass sees no `task/TASK-NNN` on the remote and offers the task as free, so two people work it at once. `docs/specs/work-tracking.md`'s worktree-with-upstream requirement carries the same narrowing ("when the worktree cannot be created").

## Acceptance criteria

- [x] Every 6b fallback that ends in an in-place pick with an upstream pushes `task/TASK-NNN`, or prints the **not-pushed** line, and says where the flip lives
- [x] The spec requirement covers both fallbacks
- [x] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- The worktree-add fallback, which TASK-254 already describes

## Human test plan

- [x] On an upstream fixture with `workspace: worktree`, run `/tasks pick` from a `claude -p` runner, which cannot enter a worktree. Expected: the run falls back in place and `git ls-remote --heads origin task/TASK-NNN` shows the branch.
  - Passed 2026-10-14 as a cold drill (`skills/populate-tests/SKILL.md` § *The cold drill*). Runner: `claude -p --disable-slash-commands --permission-mode acceptEdits --allowedTools "Bash(git:*)" "Bash(cd:*)"`, brief on stdin. The cwd was a scratchpad clone, `d328-fixed/repo`, whose `main` tracks a local bare remote (`workspace: worktree`, `worktree-root: ../wt`), holding copies of `SKILL.md` and `pick.md`. Coldness: the runner reported no skills. Result: it created the worktree, failed the proof, removed the worktree, cut `task/TASK-001` in place and pushed it. `git ls-remote --heads origin` lists `refs/heads/task/TASK-001`. The drill ran on the first version of the fix; the review rework added the upstream checks ahead of the push, and was drilled separately (`e328-fixed`, step 6).

## Implementation plan

Written by `/fix-next` after step 3 (it runs no `/tasks plan`): make *Create*'s fallback push name every 6b fallback; point the mismatch bullet at it; report a fallback that cut no branch; respec `work-tracking`; drill with a `-p` runner, which always falls back.

## Outcome

- **The fix.** With an upstream, `pick` step 6b has five ways to fall back to working in place, and only one of them said to push the task branch. That push is the only thing telling other clones the task is taken. Now every fallback is covered:
  - every fallback pushes;
  - the three that leave 6b before its upstream checks run them first: the main-copy check, the fetch, the local-ahead check, the taken-elsewhere check and the fast-forward;
  - the branch is cut from the upstream's tip;
  - a fallback that cuts no branch says so on its own `no branch` line.

  Files: `skills/tasks/verbs/pick.md` step 6b (the *Create* paragraph, the mismatch bullet, the report lines) and the `work-tracking` spec.
- **Step-6 split.** Two drills, both 0 of 1:
  - **Proof mismatch.** On an upstream fixture both runners pushed the branch. The original runner read "A fallback with an upstream" as general.
  - **Undeclared root, after the review rework.** The task was already taken on the remote. Both runners stopped with the taken-elsewhere line. The original runner said it got there by inference outside its path: *"Nothing in the text I actually followed said to stop … I applied that rule outside the path."*

  Contract pins: the fallback, the push, the uncommitted flip, the taken-elsewhere stop. Nothing proves the fix on these fixtures. As with TASK-317 and TASK-324, it turns a careful reader's inference into a written rule. Here that rule guards against two clones working one task.
- **Judgement calls.**
  - The first version just said "every fallback pushes". The correctness review showed that was worse than the gap it closed: three fallbacks leave before the upstream checks, so the push could go out over a task another clone holds. The guard now runs the skipped checks first instead of moving the fallbacks, which would reorder a section FEATURE-001 shaped.
  - The no-branch case gets its own report line instead of reusing **not-pushed**, since a fixed line per outcome is the rule this section states.
- **Specs.** `work-tracking` respecced by `/fix-next` step 7: targeted edit, `generated-at` restamped, `shaped-by` carried (`feature: null`). *Intended anyway — TASK-328's criteria, answered by /fix-next*, plus the review rework.
- **Review gate.** Standards: two warnings, both fixed (reused report line; `refusal`, not `fell-back`, for the refused root). Fidelity: criterion 1 was only partly covered (the undeclared-root fallback never evaluated "with an upstream"), now fixed; criterion 2 met; the ordering note was kept. Correctness: high, three fallbacks pushing before the upstream checks, fixed by running them first; medium, the stale base, fixed by cutting from `<upstream>`; low, the unclean main copy carries its unrelated files onto the in-place branch, accepted, because a fallback in place means the checkout is the work. Security and review-comments: not applicable.
- **Flagged, not fixed.** The drill found that a pick by bare id skips step 3's taken filter, so an ordinary in-place pick can take a task another clone holds. Filed as TASK-329 (P2).

## Progress log

- step 2 — picked; ranked above TASK-327 because keys 1 and 3: two clones can work one task at once with no signal (silent, wrong results on the tree), while TASK-327 is a misleading empty-pool message; TASK-328 is also P2 over P3
- step 3 — verified: rescoped: wider than filed. With an upstream, five 6b fallbacks end at step 7's in-place pick (`worktree-root` undeclared, the root refused as inside the repo, the main copy not clean, `git worktree add` failing, the proof mismatch); only the add failure pushes. Each other one leaves the default branch reading `todo` and no remote branch, so every other clone sees the task as free. Criterion 1 already says "every 6b fallback", so the acceptance list stands
- step 4 — layer: local
- step 5 — fix in skills/tasks/verbs/pick.md step 6b: the *Create* paragraph's push now names every fallback, with a `no task branch was cut` report for the one that cuts nothing, and states that the `upstream` line follows `fell-back`; the mismatch bullet points at it; test = lint OK + cold drill (step 6)
- step 6 — reverted fix (cold `claude -p` runners, original vs fixed `SKILL.md`/`pick.md`, upstream fixture: bare local remote, `workspace: worktree`, `worktree-root: ../wt`): 0/1 outcomes flip. Both runners created the worktree, failed the proof (a `-p` runner cannot enter it), removed it, cut `task/TASK-001` in place and pushed it; `git ls-remote` shows the branch on both remotes. The original runner applied "A fallback with an upstream" to the mismatch by reading it as general ("The fallback cuts the branch in place without offering, then runs `push -u`"). fix-dependent = none proven; contract pins = the fallback, the push, the uncommitted flip, no dashboard. Like TASK-317 and TASK-324, the fix makes explicit a scope that a careful reader already infers. Both runners raised one gap: whether the `upstream` line prints after `fell-back` (both printed both; now stated)
- step 7 — respecced work-tracking; requirement changed: the worktree-with-upstream requirement now names every in-place fallback as pushing, or reporting that it could not or that no branch was cut
- step 6 (re-drill after review) — undeclared root, task already on the remote: both runners stopped at taken-elsewhere; the original runner listed the stop as an inference outside its path, the fixed runner as the rule. The fixed runner raised two gaps in the new text (main-copy check, the fell-back line before a stop), both fixed, and the bare-id gap, spawned TASK-329
- step 8 — handed to /tasks close --unattended; outcome in status:, commit in git log
