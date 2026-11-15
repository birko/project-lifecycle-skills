---
id: TASK-290
parent: STORY-027
feature: FEATURE-004
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: done
# blocked: <reason> — add this line while the task is blocked, keeping its status; /tasks unblock removes it
priority: P2
assignee: unassigned
created: 2026-10-08
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: []
pr: null
github-issue: null
jira-key: null
---

# `skills-lint.sh` fails a structurally broken spec file

## Context

FEATURE-004 D4. Nothing checks `docs/specs/*.md`. OpenSpec's validator (v1.9.0 to v1.13.1) reports a placeholder Purpose, a scenario with no body, and requirement names that differ only in case. The owner chose the CI lint, so a broken spec fails the build here.

## Acceptance criteria

- [x] A new lint check fails a spec whose `## Purpose` is empty or a placeholder
- [x] It fails a `#### Scenario:` without a Given or When line **and** a Then line (D4, changed 2026-11-15)
- [x] It fails a heading with no space after its `#` run (`###Requirement:`), and reads a closing `#` run (`## Purpose ##`) as the plain heading
- [x] It fails text under a section it does not recognise, and prose between `## Requirements` and the first requirement
- [x] It fails two `### Requirement:` names in one spec that differ only in case
- [x] Each of these has a case in `skills-lint-test.sh`, labelled with its check, that fails without the change, and AGENTS.md § Testing names the new check
- [x] Every current spec passes, or each failure is fixed by `/specs regen` within this task — all 15 pass as they stand
- [x] `bash .github/workflows/skills-lint.sh` passes — OK (20 skills); `skills-lint-test.sh` 108/108

## Out of scope

- Checking consumers' specs: the owner chose this repo's CI, not `/specs verify`

## Human test plan

N/A — covered by the new lint cases, which must fail without the change (AGENTS.md § Testing).

## Implementation plan

Not planned as a section: the check, its cases and the AGENTS.md line, in that order.

## Outcome

**What was built:** `skills-lint.sh` check 10 fails a malformed `docs/specs/*.md`, naming the file and line: an empty
or placeholder Purpose; a scenario without a Given-or-When and a Then; two requirement names differing only in case;
a heading with no space after its `#` run; any heading outside the spec shape; prose between `## Requirements` and
the first requirement. A closing `#` run reads as the plain heading (FEATURE-004 D4, as changed 2026-11-15).

**Proof:** eleven `[10]` cases in `skills-lint-test.sh`. A throwaway mutation run (scratchpad `mut290.py`, not kept)
removed the whole check and each of its seven rules in turn: every removal turned its labelled case red, and the
intact lint kept them all green. Every one of this repo's 15 specs passes as it stands.

**Judgement calls:**
- Fences and code spans are stripped with the lint's existing `strip_noise`, so a heading inside an example block is
  not read; that inherits TASK-384's inline-fence false alarm, which TASK-384 fixes for every check at once.
- The recognised headings are the template's shape exactly. A spec that grows another section has to change the
  template and this check together, which is the point.

**Found on the way, fixed in the same change:** `docs/specs/skill-authoring-rules.md` still said the suite runs "71
cases", twice, a count TASK-029 removed from AGENTS.md; both now name the label convention instead.

**Close gate (inline; the lint, its tests, AGENTS.md, one spec):** standards and intent met; correctness by the cases
and the mutation run; layer parity, security not applicable; comments: one pointer line in each script, noted in
AGENTS.md's comment table as not yet walked by a pair; local lint and lint tests pass; skill-authoring-rules gained
the requirement.

## Progress log

- picked 2026-11-15 in FEATURE-004's build; STORY-027 rolled up to in-progress
- built check 10 and eleven cases; mutation-proved; AGENTS.md § Testing names ten checks; closed inline
