---
id: TASK-250
parent: STORY-024
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: todo
# blocked: <reason> — add this line while the task is blocked, keeping its status; /tasks unblock removes it
priority: P2
assignee: unassigned
created: 2026-10-04
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [SH-71, SH-79, SH-82]
pr: null
github-issue: null
jira-key: null
---

# The pi review fallbacks have drifted from the axes they stand in for

## Context

Found by the change-review spec harvest (2026-10-04, TASK-080, EPIC-007 third pass) and confirmed by a second reader
against the files at `adc4c27`. All three are in `skills-pi/`. That tree is frozen against new skills (ADR 0010), but
editing an existing stub is allowed.

- **SH-71 — the code-review stub says Claude Code does not ship it.**
  - `skills-pi/code-review/SKILL.md` says: "Claude Code does not currently surface a `code-review` skill … as of CLI
    2.1.220, so `[[code-review]]` does not resolve there". `README.md` repeats it.
  - ADR 0010 (filed later), AGENTS.md § Architecture, `close.md`, `verify-intent`, `review-comments` and
    `verify-conventions` all say Claude Code ships it, and current sessions list it.
  - So the stub's note is stale.
- **SH-79 — the review stub answers the intent question (partly).** `skills-pi/review/SKILL.md` step 3 asks "do the
  combined changes satisfy the task's acceptance criteria?" inside its PR-level correctness pass, and posts one
  severity-grouped list.
  - That answers `verify-intent`'s question inside the correctness verdict, which recreates the mixing that
    "independent review axes are reported side by side" exists to prevent.
  - It is one pass's own list, not two passes merged.
  - The stub predates `verify-intent`.
- **SH-82 — the security trigger list is a shorter copy.** The `skills-pi/security-review` description lists
  auth/session, data access, user input, crypto, secrets/config, new dependencies and exposed endpoints. Its own
  step 2 and `code-review` step 3 also include file/path handling. A caller reading the description would skip the
  pass on a path-handling diff.

## Acceptance criteria

- [ ] The code-review stub and README.md no longer claim Claude Code lacks the skill; the don't-install/shadowing reasoning stays
- [ ] The review stub's step 3 no longer judges acceptance criteria, or reports that as a separate fidelity verdict
- [ ] The security-review description's trigger list matches step 2, or points at it
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- CHANGELOG history entries
- Whether `skills-pi/` should exist at all (ADR 0010)

## Human test plan

N/A — stub text. pi loads these files, and the lint's frontmatter checks cover pi's parser.

## Implementation plan

_Populated by `/tasks plan TASK-250` — leave empty until then._
