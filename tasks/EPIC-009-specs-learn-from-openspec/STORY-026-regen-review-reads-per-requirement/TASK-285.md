---
id: TASK-285
parent: STORY-026
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

# `/specs regen`'s review lists changes per requirement, with renames shown FROM → TO

## Context

FEATURE-004 D2. `skills/specs/verbs/regen.md` step 4 shows the spec diff as a whole-file `git diff`. A renamed or reworded requirement then reads as a large change, which hides the question the review exists to answer. OpenSpec v1.11.0 added `show --diff`: a diff per requirement, with the full text of an added requirement, the reason for a removed one, and FROM/TO for a rename.

## Acceptance criteria

- [x] A removal and an addition are shown as a rename only when their text matches, never because their names look alike (D2, changed 2026-11-15) — the class table and *A rename is recognised by its text, never by its name*

- [x] Step 4 presents the diff per `### Requirement:` block, each classed as added, removed, renamed or changed, and shows only the changed lines of a changed one — changed, renamed, added, removed; a changed one shows only its changed lines
- [x] A rename is detected and shown FROM → TO, not as one removal plus one addition, and the verb states how a rename is recognised — `renamed: "<old>" → "<new>"`, recognised by an identical statement once whitespace is collapsed
- [x] Each change is still classified (matches a decision, intended anyway, or unexplained), now per requirement — per entry; a pure rename is listed and not classified, since it changes no behaviour
- [x] `bash .github/workflows/skills-lint.sh` passes — OK (20 skills)

## Out of scope

- Lost scenarios (TASK-286) and requirement length (TASK-287)

## Human test plan

- [x] Drill: install the changed skill and run `/specs regen <area>` on a real area of this repo, or on a fixture spec staged to exercise the change. Record how the runner was obtained (AGENTS.md § Testing); a renamed and a reworded requirement are each shown as such
  - **Passed 2026-11-15**, cold runner: `claude -p --disable-slash-commands --permission-mode acceptEdits` in
    `%LOCALAPPDATA%/Temp/d285`, the cwd holding only `brief.txt`, `skill/specs` at the fix and an invented repo with a
    committed spec and a staged harvested body; its report says no skills were registered. Told to run `regen` step 4
    alone on that pair, it showed `renamed: "Addition and subtraction" → "Sum and difference"`, `changed: Division`
    with only the one changed line, `removed: Multiplication` with its statement, the look-alike `Clamp to range` /
    `Clamp to a range` as one removal and one addition (statements differ), `added: Negation` in full, and the
    `generated-on` stamp as not behaviour. Its one reading on this change, whether a pure rename is classified, was
    settled in the same change.

## Implementation plan

Not planned: one file (`regen` step 4), five criteria but one section, no unknowns.

## Outcome

**What was built:** `/specs regen`'s review lists the diff one requirement at a time, classed changed, renamed, added
or removed, instead of a whole-file diff. A rename is recognised by an identical statement, never by a look-alike name
(FEATURE-004 D2, changed after OpenSpec v1.15.0).

**Judgement calls:**
- "Text matches" is an identical statement once whitespace is collapsed. A looser similarity would rebuild the
  look-alike trap one level down; a renamed and reworded block honestly shows as a removal and an addition.
- A pure rename is listed and not classified: it changes no behaviour, so asking whether it was intended would make
  every rename a finding.

**Close gate (inline; one skill file, one spec):** standards and intent met; correctness by d285; layer parity,
security, comments not applicable; local lint passes; specs-from-code gained the per-requirement review and the
look-alike scenario.

## Progress log

- picked 2026-11-15 in FEATURE-004's build
- built in skills/specs/verbs/regen.md step 4; drilled d285 (one reading settled); closed inline
