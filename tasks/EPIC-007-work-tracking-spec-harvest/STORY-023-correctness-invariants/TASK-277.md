---
id: TASK-277
parent: STORY-023
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: done
# blocked: <reason> — add this line while the task is blocked, keeping its status; /tasks unblock removes it
priority: P1
assignee: agent
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

- [x] Each installer checks that what it created is a link (or junction) and reports a failure, not success, when it is not; on Git Bash the bash installer either creates a real link or stops and points at the `.ps1` installer
- [x] A failed junction in the `.ps1` installers is reported as a failure and stops or continues the same way the bash versions do (one stated behaviour for both)
- [x] The same-target comparison resolves both paths in the `.ps1` installers
- [x] The warning names what exists: a directory or a file
- [x] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- Pruning old links (the installers only ever add, by design)
- Deferred to TASK-282 — the `.ps1` installers do not parse under Windows PowerShell 5.1 (BOM-less UTF-8 with `—`); found by this task's correctness review, and older than it

## Human test plan

- [x] Run `install.sh` under Git Bash with `MSYS` unset into a scratch HOME, and confirm it either creates junctions or stops with a clear message; never prints success over a copy

## Implementation plan

Drafted inline at pick, 2026-10-07.
1. **Bash installers:** on Git Bash, export `MSYS=winsymlinks:nativestrict`, so `ln -s` makes a real symlink or fails, never a silent copy. After each link, check `[ -L ]`. On failure, remove only what this run just made (the path did not exist a line earlier), print an error pointing at the `.ps1` installer, and `exit 1`.
2. **PowerShell installers:** `New-Item -ItemType Junction … -ErrorAction Stop` inside `try`; on failure print the error to stderr and `exit 1`, the same stop-at-first-failure behaviour as bash's `set -e`. Compare the stored target and the source after `GetFullPath` and trimming a trailing `\`.
3. **All four:** the warning names what is in the way, a directory or a file.
4. Re-measure the four installer rows of AGENTS.md's comments table.

## Progress log

- 2026-10-07 — Picked (status flipped after the edits had started, recorded here rather than hidden); plan drafted inline. All four installers edited; the AGENTS.md comments table re-measured (rows, date, the shebang-excluded figures). Lint OK.
- 2026-10-07 — **Tested in scratch homes (never the real roots):**
  - `install.sh` under Git Bash with `MSYS` unset and no symlink rights: `ln` fails, no copy is left, the error points at `install.ps1`, exit 1. Before the fix, this run printed success over copies.
  - `pi-install.sh`, the same: exit 1, nothing left behind.
  - `install.ps1`, fresh: 17 junctions. Re-run: 17 "already linked" (the resolved-path comparison holds), also against the real roots.
  - A plain file in the way: the warning now says "a file".
  - A junction that cannot be created (the skills root planted as a file): `install.ps1` and `pi-install.ps1` each print the error and exit 1, with no "Done".
  - The repo was checked untouched after each scratch cleanup.
- 2026-10-07 — **Close gate (step 5b), each axis reported separately:**
  - **Correctness** (code-review pass, tested in a sandbox): no bug introduced by the diff. Fixed from it:
    - `TrimEnd('')` (my `\\` escape lost in the edit) trimmed whitespace, not `\`; it is now `[char]92`, immune to escaping;
    - an empty stored target threw outside the `try`, and now counts as "links elsewhere";
    - the `MSYS` export overwrote the user's options, and now appends (`MSYS=enable_pcon` survives).

    Its pre-existing finding: the `.ps1` installers do not parse under Windows PowerShell 5.1 (BOM-less UTF-8 with `—`). Reproduced (5.1.26100: 2 parse errors) and filed as TASK-282 at P1, not widened into this task.
  - **Standards** ([[verify-conventions]]): pass. Two warnings, both recorded rather than changed: the guarded `rm -rf` is safe only while the `[ -e ]` check stays above it (the inline comment says so); the late pick is recorded above.
  - **Fidelity** ([[verify-intent]]): two findings on the criteria as written, both fixed rather than reworded.
    - Criterion 3 said "resolves both paths", and `GetFullPath` only normalises. Both `.ps1` now use `Resolve-Real`, which follows a link at every path component, like bash's `pwd -P`. Tested: a scratch home installed through a junction to the repo re-runs as 17 "already linked" from the real path, where normalisation alone would have said "links elsewhere" for all 17.
    - Criterion 1: the `.ps1` scripts never checked that what they made is a junction; they now check `LinkType` after creating it.
  - **Re-run after the fixes:** both `.ps1` parse (pwsh 7); the real roots read 17 and 20 "already linked"; the repo was confirmed intact after every scratch cleanup, with junctions removed by `rmdir` without `/s`.
  - **Security:** the installers touch only the user's own skill roots, with no input from outside, so the security surface is none. **Comments:** checked by the standards pass against the destination test.
  - **Out of scope (5d):** 1 boundary and 1 spawned (TASK-282).
