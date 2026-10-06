---
id: TASK-275
parent: STORY-024
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: todo
# blocked: <reason> — add this line while the task is blocked, keeping its status; /tasks unblock removes it
priority: P2
assignee: unassigned
created: 2026-10-06
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [SH-93, SH-94, SH-96]
pr: null
github-issue: null
jira-key: null
---

# `domain` is told it audits ADR drift but has no pass for it, and two of its pointers are wrong

## Context

Found by the TASK-080 stage 2 spec harvests (2026-10-06, EPIC-007's fifth pass) at `20c038b`, and checked against the files by a second reader before intake.

- **SH-93:** `skills/new-project/LAYER.md`'s `docs/adr/` row says ADR drift "belongs" to `/domain`'s cross-reference pass. `skills/domain/SKILL.md:34-35` and `:52` define that pass as glossary versus code only. No pass reads ADRs, so the drift LAYER says was measured has no owner.
- **SH-94 (partly confirmed):** `:139`'s "Live instance: `0006` was withdrawn" omits `0007`, which `docs/adr/0000-retired.md` also retires, and ships this repo's history inside a generic skill. (The `0005, 0007` example at `:136` is hypothetical, which is fine.)
- **SH-96 (partly confirmed):** `:90` says "read the standing-rule paragraph below"; no paragraph has that name. The content it means is the scope check directly below (`:94-107`).

SH-93 needs a decision: either `domain` gains an ADR pass, or LAYER.md stops assigning one to it.

## Acceptance criteria

- [ ] LAYER.md and `domain` agree on who checks ADRs against the code: either `domain` has a stated pass for it, or LAYER.md names no owner it lacks
- [ ] The live-instance note is generic or removed, so no repo-specific history ships in the skill
- [ ] `:90`'s pointer names the paragraph it means
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- `domain`'s ask-steps (TASK-273) and its AGENTS.md citations (TASK-271)

## Human test plan

N/A: wording and ownership, checked by reading LAYER.md and `domain` side by side.

## Implementation plan

_Populated by `/tasks plan TASK-275` — leave empty until then._
