---
id: TASK-252
parent: STORY-015
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: done
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

- [x] The root cause is named, with the commit that introduced it
- [x] `skills-lint-test.sh` and `skills-lint.sh` pass on `ubuntu-latest` in CI, and still pass locally on Windows
- [x] A regression case, or a CI change, makes a Linux-only failure impossible to miss again. For example, the close gate checks the last CI run for the default branch, not only the local result — **met by owner decision, 2026-10-04:** check 8 closes this cause, and TASK-253 owns the general case
- [x] Any task closed `done` since 2026-09-19 whose close relied on the lint is listed, with whether the Linux failure could have hidden a real defect in it
- [x] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- Line endings of files other than the CI scripts, unless the same `-text` classification applies to them

## Human test plan

- [x] Push the fix and confirm the CI run on `main` is green in GitHub Actions

## Implementation plan

Planned inline at pick, after locating why git classes the file `-text`: line 182 of `skills-lint.sh` carries a
**literal CR byte** (and a literal tab) inside an awk character class, `[ ^I^M]+$`, added by `3c7a837`. A lone CR
makes git's auto-detection treat the file as binary, so `text=auto eol=lf` stops normalising it, and the editor's
CRLF endings were stored as-is from that commit on.

1. **Reproduce on Linux** in Docker (`ubuntu`, which is what the runner is), on a `git archive` of HEAD: expect the
   CI numbers (28 passed, 39 failed).
2. **Fix:** write the class with escapes (`[ \t\r]`, which every awk reads as tab and CR), normalise the file to LF,
   and confirm `git ls-files --eol` reports it as text (`i/lf`). Keep the guard's meaning: an awk that leaves CR on
   a CRLF line still matches the marker.
3. **Prove it on Linux:** the same Docker run on the fixed tree gives 67/67 and the lint passes. Also re-run
   locally under Git Bash.
4. **Make it impossible to miss again:** a lint check that fails when any tracked `.sh` file is classed `-text`
   or contains a CR. The CR is the mechanism, and the classification is what let it spread. Add a regression case
   to the suite that fails without the check. Exercise the lint itself under Linux in step 3, so a Windows-only
   pass cannot stand in.
5. **Audit the window:** list the tasks closed `done` between 2026-09-19 and today whose close relied on the lint.
   Re-running the fixed suite on Linux against the current tree answers whether the Linux failure hid a real
   defect: anything still failing after the fix would be one.
6. Push, and confirm CI green on `main` (the human test plan).

## Progress log
- 2026-10-04 — Picked; planned inline (see the plan). Root cause located before planning: a **literal CR byte** (with a literal tab) inside the awk class on `skills-lint.sh:182`, added by `3c7a837` (TASK-146). A lone CR makes git's auto-detection class the file as binary (`i/-text`), so `* text=auto eol=lf` stopped normalising it, and the editor's CRLF endings went into the repo from then on (0 CR bytes before that commit, 330 after it, 326 at `adc4c27`).
- 2026-10-04 — **Reproduced on Linux:** `git archive HEAD` in Docker `ubuntu:24.04` (mawk 1.3.4) gives **28 passed, 39 failed**, exactly CI's numbers. The lint itself dies on line 10 (`set: pipefail: invalid option name`, `$'\r': command not found`).
- 2026-10-04 — **Fixed:** the class written with escapes (`[ \t\r]`, and the leading `[ \t]` too), the file normalised to LF. Git now classes it `i/lf`, and no tracked file is CRLF, mixed or `-text`. Only that one line's content changed (`git diff --ignore-cr-at-eol`). **Proved on Linux, mawk and gawk 5.2:** 67/67 before the guard and 71/71 after, lint OK. Locally under Git Bash: 71/71.
- 2026-10-04 — **Guard — lint check 8**, "shell scripts are stored as LF text": fails on a CR inside a line of any `.sh` file (working tree, needs no git), and, in a git work tree, on any `.sh` file the index holds other than as LF. A CRLF working copy passes, because git normalises it on commit. Four cases added (67 → 71). **Shown to bite:** with check 8 stripped out, on Linux, exactly the three failure cases fail (68/71) and nothing else moves. The fourth asserts the pass case and holds either way. Registered in AGENTS.md § Testing (a green local run is not a green gate; write CR or tab as an escape in a regex), and the case count is updated there.
- 2026-10-04 — **Audit of the window (criterion 4):** 65 tasks gained `status: done` between 2026-09-19 and today (`git log --since=2026-09-19 -G'^status: done' -- 'tasks/**/TASK-*.md'`): TASK-081, 122, 125, 141, 143, 144, 148, 151–160, 162–179, 181, 183–192, 196–206, 208, 209, 211, 213–215, 217, 219. During the window CI checked nothing (the lint could not parse on Linux), but every check ran at each close under Git Bash, where it passed. So the only defects that could have hidden are ones that behave differently by platform. The fixed lint and suite pass on Linux, under mawk and gawk, against the current tree, so **no closed task's surviving work hides one.**
- 2026-10-04 — **Comment table (§ Comments) re-measured, fifteenth time**, because the change touched both scripts. Two cold pairs, `claude -p --disable-slash-commands` in `%LOCALAPPDATA%\Temp\d252` and `d252b` (outside every repo, no git; GUIDE.md = AGENTS.md minus the measurement block). Coldness: all four listed no skills. Pair 1 agreed on `skills-lint-test.sh:318` (rationale copied from § Code structure, and "one word" was wrong) and `:354` (restated the `mk_link` calls). Both were cut, and both readers also caught the raw tab left at `skills-lint.sh:182`, which was escaped. Pair 2 agreed only on this task's own new check-8 test comment (it copied the § Testing bullet), now cut to a pointer. Not re-read after that last cut. Single-reader observations recorded, not held: `skills-lint.sh:93`, `:152-155` (the two readers raised different sentences), `:166`, `:193-194`, `:207`; `skills-lint-test.sh:347`, `:387`. Also, outside the rule, three readers noted that `skills-lint-test.sh:87`'s "Each fails a real YAML parser" is not true of the length and name cases below it.
- 2026-10-04 — **Criterion 3 left open:** check 8 makes *this* cause impossible to miss, but the criterion asks that *a Linux-only failure* be impossible to miss. The general guard is `close` reading CI's last result, which changes `close` for every consumer. Spawned as **TASK-253** (depends on this task) rather than widening this one. Whether that satisfies criterion 3 is the owner's call at close.
- 2026-10-04 — **Owner decision: TASK-253 covers criterion 3.** Check 8 makes this cause impossible to miss, and the general Linux-only blind spot is TASK-253's to close.
- 2026-10-04 — **Pushed** `adc4c27..e11c3b2` to `origin/main`. **CI green** for the first time since 2026-09-08: run `37188090654`, `skills-lint-test: 71 passed, 0 failed`, check 8 "every shell script is LF text", `skills-lint: OK (19 skills)`. Human test plan run.
- 2026-10-04 — Close review. **Intent:** the cause named with its commit; Linux CI green; guard plus TASK-253 for criterion 3 (owner); the window audited; the lint passes. **Correctness:** the only content change to existing code is the escaped awk class, proved on Linux under mawk and gawk and on Git Bash. Check 8 is pinned by three cases that fail without it. **Comments:** the two reader pairs above. **Conventions:** registered in AGENTS.md § Testing in the same change, and the case count updated. **Security:** not applicable. → **done**.
