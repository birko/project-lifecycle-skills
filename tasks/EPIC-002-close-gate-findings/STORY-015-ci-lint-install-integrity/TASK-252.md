---
id: TASK-252
parent: STORY-015
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: todo
# blocked: <reason> — add this line while the task is blocked, keeping its status; /tasks unblock removes it
priority: P1
assignee: unassigned
created: 2026-10-04
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [FIELD-008]
pr: null
github-issue: null
jira-key: null
---

# CI has been red on Linux since 2026-09-19 while the lint suite passes locally

## Context

Found in passing on 2026-10-04 while working TASK-191 (`gh run list`), not by any review pass.

- **What fails.** On `ubuntu-latest`, `skills-lint-test.sh` reports **28 passed, 39 failed** (run `37154366475`, on
  `adc4c27`). The same suite passes **67 of 67** under Git Bash on Windows. The `clean fixture` case fails with
  exit 1, and many cases that expect a specific error exit with 2 instead.
- **Since when.** The last green run is `34223494117` (2026-09-08). The first red one is `35430688625` (2026-09-19,
  TASK-142: *review-comments — the command, both scopes*), whose failures are already the fixture and link cases.
  Every push to `main` since then has been red, including all of FEATURE-002, FEATURE-001 and FEATURE-003's merges.
- **Why nobody saw it.** Every `/tasks close` gate in this repo runs the lint locally, where it is green. AGENTS.md
  calls this suite *"the repo's only gate"*, and its own warning applies: a silent regression in the gate disables
  checking with no signal. The gate is still running. It is only being read on the platform where it passes.
- **Strong lead: `skills-lint.sh` is committed with CRLF line endings.** Counted as CR bytes in each committed
  blob of the file (`git cat-file -p <commit>:.github/workflows/skills-lint.sh | tr -cd '\r' | wc -c`):
  **0** at `042a031` (TASK-108, 2026-09-16), **330** at `3c7a837` (TASK-146, 2026-09-19), and 312–330 at every
  commit since, **326** at `adc4c27`. `skills-lint-test.sh` has 0 throughout. Bash on Linux reads `fi\r` and
  similar lines as syntax errors, which fits the exit-2 failures. Git Bash on Windows tolerates the CRs, which
  fits the local green. `.gitattributes` says `* text=auto eol=lf`, yet `git ls-files --eol` reports the file as
  `i/-text`. Auto-detection classes it as non-text, so the `eol=lf` normalisation never applies. Confirm on Linux
  before fixing, and find out why it is detected as `-text`, or the next Windows edit reintroduces the CRs.

## Acceptance criteria

- [ ] The root cause is named, with the commit that introduced it
- [ ] `skills-lint-test.sh` and `skills-lint.sh` pass on `ubuntu-latest` in CI, and still pass locally on Windows
- [ ] A regression case, or a CI change, makes a Linux-only failure impossible to miss again. For example, the close gate checks the last CI run for the default branch, not only the local result
- [ ] Any task closed `done` since 2026-09-19 whose close relied on the lint is listed, with whether the Linux failure could have hidden a real defect in it
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- Line endings of files other than the CI scripts, unless the same `-text` classification applies to them

## Human test plan

- [ ] Push the fix and confirm the CI run on `main` is green in GitHub Actions

## Implementation plan

_Populated by `/tasks plan TASK-252` — leave empty until then._
