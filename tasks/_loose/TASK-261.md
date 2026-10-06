---
id: TASK-261
parent: null
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: todo
# blocked: <reason> — add this line while the task is blocked, keeping its status; /tasks unblock removes it
priority: P3
assignee: agent
created: 2026-10-06
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: []
pr: null
github-issue: null
jira-key: null
---

# Run the deletion test on the three `help` verb files, and keep or fold each one

## Context

Found while doing **TASK-075**. Its human test plan said to run the new deletion test (`skills/tdd/deep-modules.md`
§ *The deletion test*) on a small module in this repo's `skills/` tree.

- **`skills/tasks/verbs/help.md`** (11 lines, one caller: the router) **concentrates**. The `tasks` router already
  says, at `skills/tasks/SKILL.md:35`, "If user types `/tasks help` → print the verb table above and exit". Inlined,
  the file collapses into that line, and the only thing left over is its one-line hint, "Bare `/tasks` shows the
  status snapshot."
- **`skills/specs/verbs/help.md` and `skills/feature/verbs/help.md`** follow the same pattern, but they are **not
  checked yet**. `specs`' file carries its own menu text rather than repeating the router's table, so it may
  **merely move**. Check each one separately.

**Why this is a trade-off and not a plain deletion:** AGENTS.md § *Naming* says "verb files are named for the
verb", and every router row points at a file. Folding a verb into its router breaks "one file per verb" for the one
verb that has nothing to say. That is a convention question to settle, not a cleanup to do quietly.

**This is not a defect, so it is deliberately loose.** Nothing is broken; it is a simplification candidate. It is
the kind of output the planned architecture-review skill (STORY-007) will file through `/tasks intake`.

## Acceptance criteria

- [ ] The deletion test is run on each of the three `help.md` files, and each outcome (concentrates or merely moves) is recorded here with the caller checked
- [ ] For each file that concentrates, the task either folds it into its router (router table row and any links updated, nothing else lost) or records why the one-file-per-verb convention keeps it
- [ ] If any file is folded, AGENTS.md § *Naming* says how a verb with no file is written in a router table
- [ ] `bash .github/workflows/skills-lint.sh` passes (check 3: every file a `SKILL.md` references exists)

## Out of scope

- Any other verb files, and the architecture-review skill itself (TASK-076)

## Human test plan

- [ ] With the change installed, run `/tasks help`, `/specs help` and `/feature help` in a real repo. Confirm each prints its full menu, including the hint line any folded file carried
- [ ] For a file that was folded, confirm its router row still tells a reader what the verb does, with no dangling link

## Implementation plan

_Populated by `/tasks plan TASK-261` — leave empty until then._
