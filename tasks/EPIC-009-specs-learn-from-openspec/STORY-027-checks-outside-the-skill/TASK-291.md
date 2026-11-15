---
id: TASK-291
parent: STORY-027
feature: FEATURE-004
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: done
# blocked: <reason> — add this line while the task is blocked, keeping its status; /tasks unblock removes it
priority: P2
assignee: unassigned
created: 2026-10-08
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: []
pr: null
github-issue: null
jira-key: null
---

# A weekly workflow opens one labelled issue per new OpenSpec release

## Context

FEATURE-004 D7 and D10. The owner asked for a GitHub watcher on OpenSpec, and chose a plain issue, labelled `upstream: openspec` and assigned to nobody, over auto-assigning Copilot or using a Claude routine. Releases are read from `Fission-AI/OpenSpec`; v1.14.1 was the latest on 2026-10-08.

## Acceptance criteria

- [x] A scheduled workflow under `.github/workflows/` runs weekly, and on manual dispatch, and opens one issue per OpenSpec release not yet seen, with the release name, date, link and notes — `.github/workflows/openspec-watch.yml`, Mondays 06:00 UTC and `workflow_dispatch`
- [x] Each issue carries the label `upstream: openspec`, which the workflow creates if it is missing, and is assigned to nobody — the label is created when missing; `gh issue create` passes no assignee
- [x] A release is never filed twice: the workflow finds the releases already seen from existing labelled issues, not from stored state — seen tags are read from the labelled issues' titles, open or closed
- [x] The first run does not file the whole release history; it starts from the newest release, or from a declared starting version — the newest release only, or every release after `START_AFTER` when it is set
- [x] The workflow needs no secret beyond the default token, and its permissions are limited to issues — `github.token`, `permissions: issues: write`
- [x] `bash .github/workflows/skills-lint.sh` passes — OK (20 skills)

## Out of scope

- Acting on a release: assigning the issue to Copilot was declined (D10)

## Human test plan

- [x] Run the workflow by manual dispatch on the real repo. Exactly one issue appears, for the newest release, with the label; a second run files nothing
  - **Passed 2026-11-15**, run by the owner's go-ahead: dispatch 1 (run 43717484128) created the label and filed
    issue #1, *OpenSpec v2.0.0 — v2.0.0 - Skills in .agents/skills, /opsx commands removed*, labelled
    `upstream: openspec`, no assignee; dispatch 2 printed `no new OpenSpec release` and filed nothing.

## Implementation plan

Not planned: one workflow file and one map entry.

## Outcome

**What was built:** `.github/workflows/openspec-watch.yml` runs weekly and on manual dispatch. It reads
`Fission-AI/OpenSpec`'s published releases, finds the ones already filed from this repo's issues labelled
`upstream: openspec`, and files one issue per release after the newest filed one, with its date, link and notes,
labelled and assigned to nobody. A first run files the newest release only, unless `START_AFTER` names a tag
(FEATURE-004 D7, D10). `docs/specs/.map.yml` ignores it beside `ci.yml`: repo automation, not a skill capability.

**Proof so far:** the job's script, dry-run locally (`DRY_RUN=1`, which files and labels nothing) against the real
OpenSpec API: a first run would file v2.0.0 only; `START_AFTER=v1.14.1` the seven releases after it; with v1.16.1
filed, v1.17.0 and v2.0.0; with v2.0.0 filed, `no new OpenSpec release`; with v1.15.0 and v1.17.0 filed, v2.0.0 only.

**Judgement calls:**
- Prereleases and drafts are skipped: a beta is not a release to adopt from.
- Seen releases come from issue titles, the only state the workflow reads, so closing an issue never re-files it.

**Verified 2026-11-15** by two real dispatches, after the owner's go-ahead (the test plan).

**Close gate (inline; one workflow, the map):** standards and intent met; correctness by the dry runs; security:
`issues: write` only, the default token, nothing executed from release text; layer parity and comments not
applicable; local lint passes; no spec affected (the file is ignored by the map).

## Progress log

- picked 2026-11-15 in FEATURE-004's build, the last task
- built the workflow; dry-run five paths; parked at verify pending the real dispatch
- 2026-11-15 — owner approved the real dispatch; run 1 filed issue #1, run 2 filed nothing; verify → done
