---
id: TASK-194
parent: STORY-021
feature: FEATURE-001
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: done
priority: P3
assignee: unassigned
created: 2026-09-29
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [DRILL-186-2, DRILL-186-3]
pr: null
github-issue: null
jira-key: null
---

# `pick` step 3 leaves open whether this machine's tasks also appear as `taken`, and step 9 calls `gh` in local mode

## Context

Found by the TASK-186/188 drill (2026-09-29). The runner's output was correct on both points, but it
had to resolve each by choosing one of two readings. This task groups the two findings, because both
are unclear wording in `skills/tasks/verbs/pick.md` that the same drill found.

- **DRILL-186-2.** Step 3 hides every task whose branch exists and prints it under `taken (hidden)`. It then
  prints a worktree-held `in-progress` branch "apart", and says a `review` branch copy "belongs to 2b's
  verification debt, not to this line". Neither says whether the task is **also** dropped from
  `taken (hidden)`. The runner reported: *"It's just as plausible that 'this line' means only the 'in progress on this
  machine' line, which would mean TASK-012 is listed a second time as taken."* Listed twice, the session's own
  task reads as someone else's, which is the defect CR-F001-5 fixed.
- **DRILL-186-3.** Step 9 runs `gh issue view <num> --comments` whenever `github-issue:` is set, whatever the
  `mode:`. A repo that went from `hybrid` back to `local` keeps its `github-issue:` values, so a pick calls
  GitHub in a repo that declared it does not sync. The fixture reached this state by construction: its
  config was switched to `mode: local`. A real repo reaches it by switching back.

## Acceptance criteria

- [x] Step 3 says outright that a task reported on the "in progress on this machine" line or as verification debt is **not** also listed under `taken (hidden)`, or that it is, whichever is intended.
- [x] Step 9 fetches GitHub comments only under `mode: hybrid` with `provider: github`, or states why `github-issue:` alone is enough.
- [x] `bash .github/workflows/skills-lint.sh` passes.

## Out of scope

- The tie-break for equal priority and date in the pick list. That is TASK-139.

## Human test plan

- [x] Re-run the TASK-186 fixture's bare `/tasks pick` brief (recorded on TASK-186). The runner reports no ambiguity on either point, and `taken (hidden)` does not list TASK-011 or TASK-012.

## Implementation plan

Planned inline at pick: two wording fixes in `skills/tasks/verbs/pick.md`, one per finding, then the
`work-tracking` spec (pick.md is a source), then the drill.

## Progress log

- 2026-10-04 — Picked. **DRILL-186-2:** step 3 now says that neither a task on the "in progress on this machine" line nor a task step 2b reports as verification debt is also listed under `taken (hidden)`, and why (this machine's own work would read as another clone's). **DRILL-186-3:** step 9 fetches `gh issue view` comments only when `.config.yml` declares `mode: hybrid` with `external.provider: github` (the template's field). Under any other mode a `github-issue:` value is a leftover: nothing is fetched, and `github-issue: #<num> not fetched — mode: <mode>` is printed. `jira-key:`'s line was considered and left alone: it only *suggests* a skill to the user, and makes no external call.
- 2026-10-04 — **Spec:** `work-tracking`'s "Picking a task" requirement gains both rules plus a scenario (leftover issue link in a local tracker). The diff is 8 added and 2 removed, and every other requirement is word for word. Re-stamped at `57fedb5`. `shaped-by-unresolved` 7 → 6, because TASK-193's commit now leads its subject and resolves.
- 2026-10-04 — **Human test plan — drill, passed on the second runner.** The TASK-186 fixture (an Affiliate bundle in `%TEMP%/d186`) no longer exists, and that task recorded its brief only as "one read-only brief per verb". So a **synthetic fixture of the same shape** was built in `%LOCALAPPDATA%\Temp\d194`. `repo/` has `main` tracking a bare `remote.git`; `mode: local`, `workspace: worktree`, `worktree-root: ../wt`. TASK-011 is in progress in a worktree, pushed. TASK-012 is parked at `verify` in its worktree, pushed. TASK-014's branch is on the remote only. TASK-013 is free, with `github-issue: 42`. `skill/` holds copies of `tasks/SKILL.md` and `verbs/pick.md`. The brief, recorded here so it can be re-run: render bare `/tasks pick` with each placement justified by quoted text, describe step 9's hand-off when TASK-013 is picked, list every place read two ways, and list available skills. Read-only, no fetch. Runner: `claude -p --disable-slash-commands --allowedTools "Bash(git:*)" Read Glob Grep < brief.txt`, cwd `d194`. **Coldness:** both runners listed no skills.
  - **Runner 1** got every placement right: `taken (hidden): TASK-014 (remote/origin)` only, TASK-011 on its own line, TASK-012 as debt, and no `gh` call. But it **flagged point 1 as a two-way reading**: "Each such task" literally covered only the in-progress line, and it reasoned its way to excluding TASK-012. That is a failure of this task's own wording, so it was fixed ("**Neither is also listed under `taken (hidden)`** — not a task on the in-progress line, and not a task 2b reports as debt").
  - **Runner 2**, fresh, on the reworded text: the same correct placements, and it quoted the new sentence for TASK-012. It printed `github-issue: #42 not fetched — mode: local` with no command. Neither point appears in its two-way list. **Passed.**
- 2026-10-04 — Both runners independently raised the same five *other* rendering questions in `pick.md`: the one-task debt line, `remote/<name>`, where the in-progress line goes, the multiple-in-progress warning, and one report line or two. Outside this task's two points, so they were filed as **TASK-255** (DRILL-194-1 … 5, P3).
- 2026-10-04 — Close review. Intent: both criteria and the test plan met. Correctness: wording plus one gated external call; the drill shows both. Comments: none touched. Conventions: the `gh` gate reads the declared `mode:` and provider, never inferring sync from the field's presence. → **done**.
