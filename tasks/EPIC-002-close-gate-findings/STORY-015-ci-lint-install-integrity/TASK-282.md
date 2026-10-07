---
id: TASK-282
parent: STORY-015
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: done
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

- [x] Both `.ps1` installers parse and run under Windows PowerShell 5.1 and under pwsh 7 (either ASCII-only text, or a BOM the repo keeps)
- [x] Whatever keeps them parseable is protected: the lint, or its test suite, fails a `.ps1` that 5.1 could not parse (for example, non-ASCII bytes in a BOM-less `.ps1`), with a case that fails without the change
- [x] `bash .github/workflows/skills-lint.sh` and `skills-lint-test.sh` pass

## Out of scope

- The installers' link and failure behaviour (TASK-277)

## Human test plan

- [x] Run `powershell.exe -File install.ps1` (5.1) with `USERPROFILE` pointed at a scratch home, and confirm it creates the junctions

## Implementation plan

Stated at pick on 2026-10-07 and written here at close: the plan was given in conversation but not recorded on the task before work started, which the standards review flagged.
1. Make both `.ps1` installers plain ASCII (each `—` becomes `-`) rather than rely on a BOM, which editors drop silently.
2. Lint check 9, built like check 8: fail any `.ps1` with non-ASCII bytes and no byte-order mark, with test cases that fail without it.
3. Record the rule in AGENTS.md § Testing (check 9's pointer target), and update the test count and the comments table.

## Progress log

- 2026-10-07 — Picked. Both installers made ASCII (four `—` became `-`). Lint check 9 added: any `.ps1` in the tree with non-ASCII bytes and no UTF-8 or UTF-16 BOM fails, naming the cause. AGENTS.md § Testing gained the rule (check 9's pointer target), the test count history and a re-measured comments table.
- 2026-10-07 — **Proven:**
  - On a BOM-less non-ASCII `.ps1`, the committed lint exits 0 and prints nothing about it, while the new lint fails saying "no UTF-8 BOM". So the new case fails without the change.
  - The UTF-16 case fails against check 9's UTF-8-only first version and passes against the fix.
  - `skills-lint-test.sh`: 75 passed, 0 failed.
- 2026-10-07 — **Human test plan, under Windows PowerShell 5.1** (`powershell.exe` 5.1.26100, `USERPROFILE` pointed at a scratch home): both `.ps1` parse with 0 errors, down from 2. `install.ps1` created 17 junctions, and a re-run read 17 "already linked", so TASK-277's `Resolve-Real` works in 5.1 too, where a junction's `Target` is an array. `pi-install.ps1` created 20. The test junctions were removed with `rmdir` without `/s`, and the repo was checked intact.
- 2026-10-07 — **Close gate (step 5b), each axis reported separately:**
  - **Correctness:** no blocking defect. The byte range, the BOM probe on empty and short files, and `set -uo pipefail` were all tested. Fixed from it: a UTF-16 `.ps1` with its BOM, valid for 5.1, was wrongly flagged (check 9 now accepts `fffe`/`feff`, pinned by a fourth case). Its "tracked" wording point matched the standards one.
  - **Standards:** pass. Two warnings, both fixed: the bullet said "tracked" while the check scans the tree (reworded to match check 8's scan), and the implementation plan was still the placeholder (backfilled above, with the reason).
  - **Fidelity:** pass, no findings. Its baseline note, that `docs/specs/installation.md` quoted the old warnings, led to a regen of `installation` with diff review. Every change traces to TASK-277 or this task; only the `.ps1` warnings went ASCII, and the bash ones keep `—`, rightly.
  - **Security:** not applicable, because nothing here takes outside input. **Comments:** checked by the standards pass (two pointer comments).
  - **Out of scope (5d):** 1 boundary, 0 spawned, 0 declined.
