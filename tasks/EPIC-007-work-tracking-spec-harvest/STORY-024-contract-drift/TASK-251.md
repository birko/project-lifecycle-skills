---
id: TASK-251
parent: STORY-024
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: done
# blocked: <reason> — add this line while the task is blocked, keeping its status; /tasks unblock removes it
priority: P2
assignee: unassigned
created: 2026-10-04
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [SH-80, SH-81]
pr: null
github-issue: null
jira-key: null
picked-by: fix-next
---

# `review-comments` miscounts its PATH rules and offers a range it has no syntax for

## Context

Found by the change-review spec harvest (2026-10-04, TASK-080, EPIC-007 third pass) and confirmed by a second reader
against the files at `adc4c27`. Both are in `skills/review-comments/SKILL.md`.

- **SH-81 — count.** Step 2's PATH paragraph says "Four rules, and each one is a question…", and five bullets follow.
  The section's stated purpose is that two readers behave identically, which a wrong count works against.
- **SH-80 — a range with no form (partly).** Step 2 says "use a branch or PR range only if the user names one".
  - § Invocation offers the default, `PATH …`, `--all` and `--batch`, and every positional token is a PATH. So
    `/review-comments main..HEAD` is read as a path.
  - The report's "three scopes" header has no rendering for a range run.
  - A range can still be named in plain language.

## Acceptance criteria

- [x] The rule count matches the bullets, or is dropped
- [x] A range has a defined form (a flag, or a stated conversational-only rule) and a Scope-line rendering, and `a..b` is not read as a PATH
- [x] `bash .github/workflows/skills-lint.sh` passes, including check 4 if a flag is added

## Out of scope

- Ranges in `verify-conventions` and `verify-intent`, which have no PATH positional for a range to collide with

## Human test plan

N/A — invocation text, checked by parsing `/review-comments main..HEAD` and `/review-comments src/` by hand against § Invocation.

## Implementation plan

_Populated by `/tasks plan TASK-251` — leave empty until then._

## Outcome

**The fix.**
- **The count:** step 2's PATH paragraph says "Five rules", matching its five bullets.
- **A range now has a form:** `/review-comments --range A..B`, the diff scope over that range. A range named in
  words is passed as the flag.
  - **Refusals:** a positional containing `..` that names no tracked path is refused with *"did you mean `--range
    …`?"* rather than swept as a path, and `--range` with `PATH` or `--all` is refused by name, like the other scope
    conflicts.
  - **Report:** the `Scope:` paragraph names four scopes, and gives the range line
    `Scope:        range main..HEAD — N changed files, K carrying comments in range.`

**Step-6 split.** The plan's check is a hand parse against § Invocation:
- **`/review-comments main..HEAD`:** the old text read it as a PATH. The fixed text refuses it and suggests `--range`.
- **`/review-comments src/`:** a PATH, unchanged.
- **Contract pin, not evidence:** skills-lint, including check 4, which now sees `--range` declared.

**Judgement calls.**
- **A flag, not a conversational-only rule.** A range said only in words still needs a `Scope:` rendering and a way
  to stop `a..b` being read as a path. Once those exist, the flag is the cheap part, and it gives two readers one
  form.
- **A refusal, not a silent reinterpretation, for `main..HEAD` as a positional.** Treating it as a range unasked would
  guess the caller's intent. Treating it as a path sweeps nothing and prints a clean pass. The skill's own rule is that
  a flag silently dropped is worse than one refused by name.

**Close gate (inline, about 12 lines in one file):**
- **Standards:** new ask-free refusals state their words, and the flag is declared for check 4.
- **Intent:** criteria met.
- **Correctness:** a broken sentence from the edit ("Of those, and…") was fixed.
- **Security, comments:** not applicable.
- **CI:** `ci: main green — 1 workflow read`.

**Spec.** `change-review` is respecced: the comment axis now has four scopes and the new refusals. It is restamped,
since no other source in its map changed since its stamp.

## Progress log

- step 2 — picked; next P2 in STORY-024 (contract-drift): a skill that promises a range syntax it does not have fails the user on use (key 1), reached whenever someone asks for a range (key 2)
- step 3 — verified: held; "Four rules" over five bullets, and "use a branch or PR range only if the user names one" with no form, no Scope line, and `a..b` falling to PATH
- step 3b — not planned: one file, three criteria with a stated shape
- step 4 — layer: local
- step 5 — fix in skills/review-comments/SKILL.md (count; `--range A..B` in § Invocation with its refusals; step 2 points at it; Scope paragraph names four scopes and the range line)
- step 6 — hand parse per the plan: `main..HEAD` refused with a `--range` suggestion (was swept as a PATH), `src/` unchanged; contract pin = skills-lint check 4
- step 7 — respecced change-review (comment axis: four scopes and the refusals), restamped
- step 8 — handed to /tasks close --unattended; outcome in status:, commit in git log
