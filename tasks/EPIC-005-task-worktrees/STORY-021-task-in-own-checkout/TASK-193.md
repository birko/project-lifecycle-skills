---
id: TASK-193
parent: STORY-021
feature: FEATURE-001
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: todo
priority: P2
assignee: unassigned
created: 2026-09-29
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [DRILL-186-1]
pr: null
github-issue: null
jira-key: null
---

# "Local mode" names two unrelated settings, and a cold runner read one as the other

## Context

Found by the TASK-186 drill (2026-09-29, remote-mode fixture of Affiliate). The `/fix-next` runner
reported: *"the config says `mode: local`, but the pick commit is only on the task branch … the skill
doesn't say which wins."*

Two different facts share the words:

| Words | Meaning | Where |
|---|---|---|
| `mode: local` / "local mode (files only)" | the **tracker**: files only, no GitHub/Jira sync (vs `hybrid`) | `tasks/.config.yml`, `tasks/SKILL.md` description and § Mode |
| "local mode" / "remote mode" | the **worktree workspace**: whether the default branch tracks a remote (`<default>@{upstream}`) | `pick.md` steps 3, 6b; `close.md` steps 4b, 8; `fix-next/SKILL.md` step 2 |

A repo with `mode: local` and an upstream, which is the common case, is "local mode" by one and
"remote mode" by the other. The runner reached the right answer only because step 0's branch lookup
runs regardless. A skill step that branches on "in local mode" (fix-next step 2, `pick.md` 6b) can be
read against the wrong setting.

## Acceptance criteria

- [ ] The worktree sense gets a name that cannot be read as `mode:`. For example "upstream-tracked" / "no upstream", or keep "remote mode" and rename its counterpart. Chosen and recorded in `docs/glossary.md`.
- [ ] Every worktree-sense "local mode" in `skills/` (the sites in the table, found by `grep -rn "local mode" skills`) uses the new name.
- [ ] FEATURE-001's decision ledger records the rename as a `changed` decision, since it rewords shipped behaviour.
- [ ] `bash .github/workflows/skills-lint.sh` passes.

## Out of scope

- Renaming `mode: local | hybrid` itself. It is a declared field that consumer repos already carry, and changing it would need an `init` reconcile path.

## Human test plan

- [ ] Cold drill: a runner in a repo with `mode: local` and an upstream-tracked default branch, briefed to explain which workspace path `pick` 6b takes and why, without being told about the collision. It must name the upstream check, not `mode:`.
