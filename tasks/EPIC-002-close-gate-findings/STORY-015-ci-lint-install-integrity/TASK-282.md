---
id: TASK-282
parent: STORY-015
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: todo
# blocked: <reason> — add this line while the task is blocked, keeping its status; /tasks unblock removes it
priority: P1
assignee: agent
created: 2026-10-07
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [CR-143]
pr: null
github-issue: null
jira-key: null
---

# The `.ps1` installers do not parse under Windows PowerShell 5.1, the default `.ps1` host on Windows

## Context

Found by the correctness review at TASK-277's close gate (2026-10-07), and reproduced:
`powershell.exe` 5.1.26100 reports **2 parse errors** in `install.ps1` ("Missing closing '}'"). pwsh 7 parses it
cleanly, which is why every test so far passed.

- **CR-143:** `install.ps1` and `pi-install.ps1` are UTF-8 **without a BOM**, and their `Write-Warning` strings
  contain `—`. Windows PowerShell 5.1 reads a BOM-less script in the system code page, so the bytes of `—` break
  string parsing. The reviewer showed the same file with a BOM prepended runs correctly in 5.1. The defect predates
  TASK-277 (`HEAD` before it fails the same way).

AGENTS.md § Commands documents `install.ps1` as *the* Windows installer, and a stock Windows machine runs `.ps1`
with 5.1. So the documented Windows path to install the skills does not run. TASK-277's own bash error message now
points Windows users at these files, which makes this more pressing.

## Acceptance criteria

- [ ] Both `.ps1` installers parse and run under Windows PowerShell 5.1 and under pwsh 7 (either ASCII-only text, or a BOM the repo keeps)
- [ ] Whatever keeps them parseable is protected: the lint, or its test suite, fails a `.ps1` that 5.1 could not parse (for example, non-ASCII bytes in a BOM-less `.ps1`), with a case that fails without the change
- [ ] `bash .github/workflows/skills-lint.sh` and `skills-lint-test.sh` pass

## Out of scope

- The installers' link and failure behaviour (TASK-277)

## Human test plan

- [ ] Run `powershell.exe -File install.ps1` (5.1) with `USERPROFILE` pointed at a scratch home, and confirm it creates the junctions

## Implementation plan

_Populated by `/tasks plan TASK-282` — leave empty until then._
