---
id: TASK-202
parent: STORY-022
feature: FEATURE-003
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: done
priority: P3
assignee: unassigned
created: 2026-09-30
depends-on: [TASK-196]
blocks: [TASK-204]
findings: []
pr: null
github-issue: null
jira-key: null
---

# Migrate: tracker sync maps the blocked flag to a GitHub label and Jira's Flagged field

## Context

A migrate batch of FEATURE-003 (owner group: the hybrid-mode verbs `export`, `import`, `migrate` and the
remote step of `close`/`cancel`). D8: the flag maps to the GitHub label `blocked` or Jira's "Flagged" field,
the reason travels as a comment, and the issue's open/closed state does not change, because a blocked
task is still open.

## Acceptance criteria

- [x] Exporting a flagged task adds the tracker's marker and a comment carrying the reason; removing the flag removes the marker
- [x] Importing an issue carrying the marker writes the `blocked:` field with the comment's reason, or `reason unknown` when there is none
- [x] No verb changes a remote issue's open/closed state because of the flag
- [x] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- Jira transitions or custom workflows beyond the Flagged field

## Human test plan

- [x] On a throwaway GitHub repo: export a flagged task, check that the label and comment appear, unflag it, and check the label is removed.
  - **Run 2026-10-01 on `birko/BardStudio`, chosen by the owner, passed on the second run.** Fixture: `%TEMP%/d202`, a hybrid-mode tree (`external.repo: birko/BardStudio`) with one loose task: old-form `status: blocked` plus a `> Blocked` note. Runner: `claude -p --permission-mode acceptEdits --allowedTools "Bash(git:*)" "Bash(gh:*)" "Bash(grep:*)" "Bash(ls:*)" Read Grep Glob Edit Write Skill --add-dir ~/.claude/skills C:/Source/project-lifecycle-skills < brief.txt`. The brief said: export, then unblock, and touch nothing but the one issue and the labels the skill names.
    - **Run 1 failed before creating anything.** `gh issue create` refused the issue on `priority/P3`, a label the repo did not have, and nothing in `export` creates labels. That defect is older than FEATURE-003: export failed on any repo lacking the skill's labels. Fixed in place (below).
    - **Run 2:** export created the missing `priority/P3` and `blocked` labels and named them. It created issue #1 with both labels and commented `Blocked: waiting on the drill to finish`, the reason taken from the note. Unblock removed `blocked` and commented `Unblocked: drill finished`. **Independent check** with `gh api …/issues/1/events`: `labeled priority/P3`, `labeled blocked`, `unlabeled blocked`; the issue stayed OPEN throughout.
    - **Cleanup:** issue #1 closed with an explanatory comment; both labels deleted (neither existed before the run); local fixture and temp body files removed.

## Implementation plan

Planned inline at pick (2026-10-01). D8 in the hybrid verbs:
- `export` adds the marker and a `Blocked:` comment.
- `import` reads the marker into the `blocked:` field, never into a status.
- `migrate` exports flagged tasks with their marker.
- `block` and `unblock` gain a step 5b that adds or removes the marker and comments.

No verb changes an issue's open/closed state because of the flag.

## Progress log

- 2026-10-01 — Picked; planned inline; edits made; lint OK.
- 2026-10-01 — The owner chose to test on `birko/BardStudio`.
- 2026-10-01 — Drill run 1 found that export never creates labels, which made every export to a fresh repo fail. It is on this task's path, since the `blocked` label must exist, so it was fixed in place:
  - export ensures every label exists and names any it creates;
  - `--repo` comes from `external.repo`;
  - the body goes through `--body-file`;
  - priority labels are `priority/<value>` instead of a hard-coded P0–P2;
  - the block reason falls back to the `> Blocked` note;
  - `block`/`unblock` ensure the label too, and say `no remote issue linked — nothing synced` when there is no link.
- 2026-10-01 — Drill run 2 passed (record above); GitHub cleaned up.
- 2026-10-01 — Close review:
  - **Standards:** pass. It points at [[tasks]] § *Lifecycle*, and creating a label is reported because it changes someone's repo.
  - **Intent:** pass, all 4 criteria met.
  - **Correctness:** pass. The events log confirms label add and remove, and the state was never touched.
  - **Security:** pass. No credentials are handled. `gh` writes are limited to the linked issue and named labels, and label creation is reported.
  - **Comments:** not applicable.
- 2026-10-01 — Out of scope, recorded rather than filed. The runners raised older gaps:
  - `--to` is marked required but has no path when omitted (the config's provider is the obvious default);
  - there is no label rule for `assignee: unassigned`;
  - triage has no time source for its timestamp;
  - the temp body file sits outside a sandboxed session's writable roots, so it cannot be deleted there.
