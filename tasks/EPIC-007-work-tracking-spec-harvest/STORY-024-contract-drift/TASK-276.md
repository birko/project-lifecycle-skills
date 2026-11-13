---
id: TASK-276
parent: STORY-024
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: done
# blocked: <reason> — add this line while the task is blocked, keeping its status; /tasks unblock removes it
priority: P2
assignee: unassigned
created: 2026-10-06
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [SH-103, SH-104]
pr: null
github-issue: null
jira-key: null
picked-by: fix-next
---

# `handoff` has no trigger phrases, and never says where its document went

## Context

Found by the TASK-080 stage 2 spec harvests (2026-10-06, EPIC-007's fifth pass) at `20c038b`, and checked against the files by a second reader before intake.

- **SH-103:** `skills/handoff/SKILL.md:3`'s description has no trigger phrases, no Slovak ones and no "not to be confused with", against AGENTS.md § *Framework / stack*. The same shape as TASK-260 for `grill-me`.
- **SH-104:** `:7` says to save the document to the OS temp directory, but gives no file name and never says to tell the user the saved path. A handoff whose path nobody is told cannot be handed to the next session.

## Acceptance criteria

- [x] The description carries the trigger phrases users type, including Slovak ones, and names the skill it should not be confused with, within AGENTS.md's pi frontmatter rules
- [x] The skill names its file and tells the user the saved path
- [x] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- The refuted points about its suggested-skills section, its no-argument default and redaction markers (dropped at intake)

## Human test plan

N/A: frontmatter and one instruction, checked by the lint and by reading.

## Implementation plan

_Populated by `/tasks plan TASK-276` — leave empty until then._

## Outcome

**The fix.**
- **The description:** `handoff` now carries trigger phrases, English and Slovak ("sprav handoff", "odovzdaj to ďalšej
  session", "zhrň to pre novú session"). It names [[tasks]] and [[fix-next]] as the skills it is not: their task files
  and git already carry a task's state, and a handoff points at them.
- **The body names the file and reports where it went:** it is saved as `handoff-<YYYYMMDD-HHMM>-<slug>.md` in the
  OS temp directory, and the run ends by printing `handoff saved: <absolute path>`.

**Check.**
- One line, 527 characters, and lint check 1 passes.
- The runtime reloaded the new description in this session.

**Judgement calls.**
- **The confusables are the task system, not another document skill.** The real risk is a handoff that re-copies what
  a task file already records, which this skill's own body forbids ("reference them by path").
- **A timestamp and slug in the file name** keep two handoffs from one day apart, and let a person find theirs in a
  shared temp directory.

**Close gate (inline, two lines):**
- **Standards:** frontmatter rules hold, and the new instruction states its reason.
- **Intent:** criteria met.
- **Security, comments:** not applicable.
- **CI:** `ci: main green — 1 workflow read`.

## Progress log

- step 2 — picked; last P2 in STORY-024 (contract-drift): a skill with no triggers is never chosen by request (key 2), and a hand-off whose location is never reported is lost on reset, the one moment it exists for (keys 1 and 3)
- step 3 — verified: held; a bare description, and a save instruction with no file name and no reported path
- step 3b — not planned: two lines in one file
- step 4 — layer: local
- step 5 — fix in skills/handoff/SKILL.md (description; file name and printed path)
- step 6 — lint check 1 passes; the runtime reloaded the description in-session
- step 7 — respecced session-handoff: the save requirement now names the file and the printed path, and its "file name is left to the agent" scenario is replaced; restamped (no other source change since its stamp)
- step 8 — handed to /tasks close --unattended; outcome in status:, commit in git log
