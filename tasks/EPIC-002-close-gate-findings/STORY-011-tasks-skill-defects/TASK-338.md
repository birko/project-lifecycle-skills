---
id: TASK-338
parent: STORY-011
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: done
# blocked: <reason> — set by /tasks block, never by hand; status stays as it is; /tasks unblock removes it
priority: P3
# assignee — one of: agent (default), unassigned, human, or an installed agent type's name; ai is read as agent, never written
assignee: agent
created: 2026-11-04
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [DRILL-218-1, DRILL-218-2]
pr: null
picked-by: fix-next
github-issue: null
jira-key: null
---

# `/tasks export` assumes a config `migrate` has not written yet, and the dry run's milestone lookup has no command

## Context

Found while running TASK-218's test plan (2026-11-04, recorded on TASK-218). TASK-218's own steps passed; these
sit just outside them.

- **From the author's reading:** `skills/tasks/verbs/export.md` step 6 says "the repo is `external.repo` from
  `.config.yml`". `migrate` step 6 runs export steps 3–7 before its own step 7 writes that field, so a reader
  who starts at export finds it absent. Only migrate's sentence "the provider and repo/project come from this
  run's args" covers the case, and export does not defer to it.
- **DRILL-218-1:** export step 5 says to look the parent epic's milestone up by its title, with no command (the
  only one, `gh api repos/<repo>/milestones`, is in migrate step 6, which a dry run skips). In a dry run the
  milestones do not exist yet, so a literal lookup prints `no milestone … not linked` for every task. That is
  the wrong preview of the real run. The runner printed `(lookup not performed)` by its own choice.
- **DRILL-218-2:** migrate's `--dry-run` says to print "for every item, the payload export.md step 5 builds",
  but step 5 describes only a TASK payload. Nothing says what an epic's or story's payload is, where the
  payloads go relative to the plan and the pre-flight, which body sections are included, or how "Total API
  calls" is counted.

## Acceptance criteria

- [x] Export step 6 takes the repo (and Jira project) from the caller when migrate runs it, and says so
- [x] Export step 5 names the milestone lookup command, and a migrate dry run previews milestone links as `would link to "<title>"` instead of a lookup that cannot succeed
- [x] The dry run's payload output is defined for epics and stories, and its position is stated
- [x] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- TASK-330: migrate step 2's repo/project prompt

## Human test plan

- [x] Re-run TASK-218's drill brief (on its Progress log) on a freshly built fixture with a cold runner. Expected: none of these appears in its "left undecided" section
  - **Passed 2026-11-05:** TASK-218's brief verbatim on a rebuilt `%LOCALAPPDATA%/Temp/d218` (`tasks` copied after this fix). Runner `claude -p --disable-slash-commands --permission-mode acceptEdits --allowedTools "Bash(git:*)" "Bash(cd:*)" "Bash(ls:*)" "Bash(gh auth status:*)" "Bash(gh repo view:*)" "Bash(gh label list:*)" Read Glob Grep Edit Write < brief.txt`, against the public `cli/cli` with read-only `gh` only. It printed the plan, the pre-flight result, then epics, stories and tasks in push order, each task under an epic in the run as `would link to "<EPIC-ID> <epic title>"` and the loose task with no milestone line, bodies by section name, and the fixed closing line; `git status` was empty. None of DRILL-218-1, DRILL-218-2 or the step-6 repo finding is in its "left undecided" section. Coldness: it listed no skills

## Outcome

**What was fixed.**
- `/tasks export` step 6 named the repo as `external.repo` from the config, which a migration only writes after its pushes. It now takes the caller's repo, or Jira project, when `migrate` runs it, and states that on export's side of the contract.
- Export's milestone lookup has a command, `gh api "repos/<repo>/milestones?state=all" --paginate`, which also finds closed milestones.
- A migrate dry run previews `would link to "<EPIC-ID> <epic title>"` instead of a lookup that cannot succeed.
- The dry run's output is defined: epic and story payloads, their position after the plan and pre-flight, push order, bodies by section name, and the basis of the API-call count.

**Step-6 split:** 0/0, because this is prose only. Evidence is the drill, which passed.

**Judgement calls.**
- **`state=all` was taken into scope,** on migrate step 6's duplicate check as well. The default lists open milestones only, so a closed epic's would be missed and then created twice. It is the very command criterion 2 names.
- **Export's flags are written as "the caller's",** never as `/tasks export --repo`. Export declares no such flag, and lint check 4 would rightly fail.
- **Found by the drill and fixed inline:** the container payload sentence (new in this task) gave no reading for a list that cannot be read and no label-list command. It now says `— not checked: <reason>`, never `would create`. A re-run was not needed for one added clause, which the drill reported as the only gap.

**Review (close step 5b, inline).** Adherence: both sides of the export/migrate contract now state it. Fidelity: all four criteria are met. Correctness: the dry run reaches no write path.

**Flagged, not fixed.**
- Export step 5's `default-labels` is also read from a config that has no `external:` block during a migration (an empty list, harmless).
- The dry run does not say whether to report task labels missing from the repo.

## Implementation plan

### Steps
1. Export step 6: the repo is the caller's `--repo` when migrate runs the step, and `external.repo` otherwise; Jira's project is the caller's `--project`, else `external.project`. Phrase it as "the caller's", never as an export flag, because export declares no `--repo` and lint check 4 would fail.
2. Export step 5's Milestone bullet names `gh api "repos/<repo>/milestones?state=all" --paginate`. Under migrate's `--dry-run`, a task whose epic is in the run shows `would link to "<EPIC-ID> <epic title>"` and is not looked up; any other task is looked up as usual, and a loose task gets no milestone line.
3. Export § *Exporting STORY or EPIC* defines the container payloads (`exists | would create`). Migrate's `--dry-run` prints them after the plan and the pre-flight, in push order, with bodies shown by section name. Step 4 states the API-call basis (one create per planned item, 5 + 12 + 34 = 51).
4. Spec `work-tracking`: Exporting a task, and Migrating to hybrid mode plus its dry-run scenario.

### Taken into scope from the plan's risk list
- `state=all` on both milestone lookups, the new one and migrate step 6's. The default lists open milestones only, so a closed epic's would read as missing, and migrate would create a duplicate. It is the command criterion 2 names, so it is the same work.

### Left out
- Export step 5's `default-labels` is also absent during a migration, but harmlessly (an empty list).

## Progress log

- step 2 — picked; ranked above TASK-339 because key 1: export step 6 reads `external.repo` that a migrate run has not written, on a path that creates issues in a real tracker, and the dry run previews every milestone link wrongly; TASK-339 is wording in intake that runners resolved alike; keys 3 and 6 tie (silent, correctness-invariants)
- step 3 — verified: held. export.md step 6 "the repo is `external.repo` from `.config.yml`" while migrate step 7 writes that field only after step 6's pushes; export step 5's milestone lookup names no command and in a dry run finds no milestone; migrate's --dry-run says "for every item, the payload export.md step 5 builds", and step 5 defines only a TASK payload
- step 3b — planned: /tasks plan --no-grill (four criteria, two files); no split signal
- step 4 — layer: local
- step 5 — fix in skills/tasks/verbs/export.md (step 6 repo/project from the caller under migrate; step 5 milestone lookup command with state=all and the dry-run `would link to` preview; container payloads under § Exporting STORY or EPIC) and skills/tasks/verbs/migrate.md (dry-run payload order and shape; API-call basis; state=all in step 6's lookup); lint OK (20 skills)
- step 6 — reverted fix: 0/0 failed — prose only; fix-dependent = none; contract pins = skills-lint.sh (check 4 still passes, export flags named only as "the caller's"); evidence = the Human test plan drill
- step 7 — respecced work-tracking; requirements changed: Exporting a task (milestones open and closed; repo/project from a migration), Migrating to hybrid mode (dry-run order, container payloads, `would link to`, API-call basis, state=all) and its dry-run scenario; intended — TASK-338's criteria
- step 5 (amended after the drill) — container payload: unreadable list → `— not checked: <reason>`; label-list command named
- step 8 — handed to /tasks close --unattended; outcome in status:, commit in git log
