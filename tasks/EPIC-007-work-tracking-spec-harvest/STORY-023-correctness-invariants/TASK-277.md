---
id: TASK-277
parent: STORY-023
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: todo
# blocked: <reason> — add this line while the task is blocked, keeping its status; /tasks unblock removes it
priority: P1
assignee: unassigned
created: 2026-10-06
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [SH-108, SH-109, SH-111, SH-112]
pr: null
github-issue: null
jira-key: null
---

# The installers report success for links they did not make, and the bash and PowerShell versions fail differently

## Context

Found by the TASK-080 stage 2 spec harvests (2026-10-06, EPIC-007's fifth pass) at `20c038b`, and checked against the files by a second reader before intake.

- **SH-108 (reproduced by the second reader):** under Git Bash with `MSYS` unset, `install.sh:33` and `pi-install.sh:35` run `ln -s`, which **copies** the folder. The scripts still print `+ <name> -> <src>` and "resolve from this repo via symlinks". Skill edits then stop reaching the runtime silently, against ADR 0009 (link, never copy), and every later run warns "a real directory already exists … move it aside" for each skill. AGENTS.md § Testing already records that MSYS `ln -s` copies, for the lint tests, but the installers do not handle it.
- **SH-109:** `install.ps1:26-27` and `pi-install.ps1:31-32` call `New-Item -ItemType Junction` without `-ErrorAction Stop`, so a failure still prints `+ <name>` and "Done". The bash versions stop at the first failure under `set -e`. One falsely reports success; the other stops part-way.
- **SH-111 (partly confirmed):** the PowerShell scripts compare a junction's stored target string without resolving it, while bash resolves with `pwd -P`. The only outcome is a false "links elsewhere" warning.
- **SH-112:** the "a real directory already exists" warning also fires for a plain file.

## Acceptance criteria

- [ ] Each installer checks that what it created is a link (or junction) and reports a failure, not success, when it is not; on Git Bash the bash installer either creates a real link or stops and points at the `.ps1` installer
- [ ] A failed junction in the `.ps1` installers is reported as a failure and stops or continues the same way the bash versions do (one stated behaviour for both)
- [ ] The same-target comparison resolves both paths in the `.ps1` installers
- [ ] The warning names what exists: a directory or a file
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- Pruning old links (the installers only ever add, by design)

## Human test plan

- [ ] Run `install.sh` under Git Bash with `MSYS` unset into a scratch HOME, and confirm it either creates junctions or stops with a clear message; never prints success over a copy

## Implementation plan

_Populated by `/tasks plan TASK-277` — leave empty until then._
