---
id: TASK-338
parent: STORY-011
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: todo
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

- [ ] Export step 6 takes the repo (and Jira project) from the caller when migrate runs it, and says so
- [ ] Export step 5 names the milestone lookup command, and a migrate dry run previews milestone links as `would link to "<title>"` instead of a lookup that cannot succeed
- [ ] The dry run's payload output is defined for epics and stories, and its position is stated
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- TASK-330: migrate step 2's repo/project prompt

## Human test plan

- [ ] Re-run TASK-218's drill brief (on its Progress log) on a freshly built fixture with a cold runner. Expected: none of these appears in its "left undecided" section

## Implementation plan

_Populated by `/tasks plan TASK-338` — leave empty until then._
