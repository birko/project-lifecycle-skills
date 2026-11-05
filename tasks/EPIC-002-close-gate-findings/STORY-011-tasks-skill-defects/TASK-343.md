---
id: TASK-343
parent: STORY-011
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: done
# blocked: <reason> — set by /tasks block, never by hand; status stays as it is; /tasks unblock removes it
priority: P3
# assignee — one of: agent (default), unassigned, human, or an installed agent type's name; ai is read as agent, never written
assignee: agent
created: 2026-11-05
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [DRILL-340-1, DRILL-340-2, DRILL-340-3]
pr: null
picked-by: fix-next
github-issue: null
jira-key: null
---

# `/tasks new` leaves the shortened body question, a quoted description, and the FIELD-NNN scan to the reader

## Context

Raised by TASK-340's drill (2026-11-05, recorded on TASK-340), in `skills/tasks/verbs/new.md`:

- **DRILL-340-1:** step 9 says sections a step-0 flag already drafts "are not offered", but the question names all four sections and no shortened wording is given. The runner trimmed it by its own choice, so the ask-step's text differs per run.
- **DRILL-340-2:** § *Unanswered questions* counts "a title in quotes" as stated. A request that quotes a sentence describing the defect, not a title, reads both ways.
- **DRILL-340-3:** the `FIELD-NNN` mint takes "the current max over every `findings:` list" but gives no search pattern, unlike the `^id:` scan, so two runs may scan differently.

## Acceptance criteria

- [x] Step 9's question is stated for the case where some sections are already drafted
- [x] § *Unanswered questions* says when quoted text counts as a stated title
- [x] The `FIELD-NNN` max scan names its pattern
- [x] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- The behaviour the originating task fixed, which its drill passed

## Human test plan

- [x] Re-run TASK-340's drill brief (on its Progress log) with a cold runner. Expected: none of the three in its "left undecided" section
  - **Passed 2026-11-05:** TASK-340's brief verbatim on a rebuilt `%LOCALAPPDATA%/Temp/d340` (`tasks` copied after this fix). Runner `claude -p --disable-slash-commands --permission-mode acceptEdits --allowedTools "Bash(git:*)" "Bash(cd:*)" "Bash(ls:*)" Read Glob Grep Edit Write < brief.txt`. Step 9 put `Shall I draft the Out of scope and Human test plan from what we have discussed?`. The quoted defect was read as a description by the new edge, quoted back, and `title` was marked. `findings: [FIELD-001]` was minted with the stated pattern. None of DRILL-340-1…3 is in its "left undecided" section. Coldness: it listed no skills

## Outcome

**What was fixed.** Three gaps in `/tasks new`:
- Step 9's body question now names only the sections no step-0 flag drafted, in a fixed order. Each flag's list is spelled out, and there is no question when none is left.
- Quoted text counts as a stated title only when the request introduces it as the title or passes it as the argument; any other quote is a description, and the title composed from it is marked.
- The `FIELD-NNN` mint searches with `^findings:.*FIELD-[0-9]+`, as § ID generation searches for `^id:`, taking every match on a line. `SKILL.md` and `intake.md` point at that one pattern.

**Step-6 split:** 0/0, because this is prose only. Evidence is the drill, which passed. The pattern was also run on this repo: 16 `findings:` lines found, 24 prose mentions skipped.

**Judgement calls.**
- **The title rule is strict** (introduced as the title, or the argument). A strict rule costs an extra mark, never a value recorded as chosen that nobody chose.
- **Pointers, not a spawn:** the two other descriptions of the scan were pointed at `new` step 0 in this change, because three unaligned descriptions are the drift "defer to a shared inventory" forbids.

**Review (close step 5b, inline).** Adherence: one pattern, two pointers, and the ask-step's text is now fixed per case. Fidelity: all three criteria are met. Correctness: `^findings:` excludes the template's comment line.

**Flagged, not fixed** (the runner's other readings):
- `new` step 12 says "skip silently" on `--no-plan` while step 13 prints a skipped-plan hint.
- `body sections` in the mark does not say which sections it covers.
- No wording is given when `--from-field` has no repo or version to record.

## Implementation plan

### Steps
1. **Step 9 names only the sections no step-0 flag drafted**, in a fixed order with a stated join: `--from-feature` drafts Context; `--from-review` and `--from-field` draft Context and Acceptance criteria. The three resulting lists are spelled out. When no section is left, there is no question and no mark. The no-answer path covers the sections the question named.
2. **§ Unanswered questions, a fourth edge:** quoted text is a stated title only when introduced as the title (`called`, `titled`, `named`, `title:`) or passed as the verb's argument. Other quoted text is a description, and the title composed from it is marked.
3. **The `FIELD-NNN` mint searches as § ID generation does for `^id:`**, with `^findings:.*FIELD-[0-9]+`. It takes every match on a line and compares them as numbers; `^findings:` skips the template comment and any prose. `SKILL.md` § ID generation and `intake.md` point at this pattern instead of describing the scan again.
4. **Spec `work-tracking`:** the creation-questions requirement (the body-section offer; quoted text). Lint, then re-run TASK-340's brief.

### Risks
- A hand-written block-style `findings:` list would slip past the scan. The template writes a one-line list.
- The title rule is strict on purpose: an unmarked quote costs a mark, never a wrong declaration.

## Progress log

- step 2 — picked; ranked above TASK-342 because key 5: drill-verified on three points, where TASK-342 rests on one planning observation; key 1: DRILL-340-1 makes an ask-step's text differ per run, against TASK-342's doubled wording that no runner has yet tripped on; key 7 ties (P3)
- step 3 — verified: held. new.md step 9 puts the four-section question and says sections a step-0 flag drafts are not offered, with no wording for the shortened question; § Unanswered questions counts "a title in quotes" as stated with no rule for a quoted description; step 0's FIELD-NNN mint names no search pattern
- step 3b — planned: /tasks plan --no-grill (three criteria); no split signal; SKILL.md and intake.md pointed at the one pattern rather than spawned, since a third description of the scan is the drift the rule forbids
- step 4 — layer: local
- step 5 — fix in skills/tasks/verbs/new.md (step 9 question per flag; fourth edge on quoted text; FIELD-NNN pattern), skills/tasks/SKILL.md and skills/tasks/verbs/intake.md (pointers to the pattern); `git grep -h -E "^findings:.*FIELD-[0-9]+" -- tasks/` here finds 16 lines and skips 24 prose mentions; lint OK (20 skills)
- step 6 — reverted fix: 0/0 failed — prose only; fix-dependent = none; contract pins = skills-lint.sh; evidence = the Human test plan drill
- step 7 — respecced work-tracking; requirements changed: Creation questions and the inferred-values mark (the body offer names undrafted sections; quoted text rule); intended — TASK-343's criteria
- step 8 — handed to /tasks close --unattended; outcome in status:, commit in git log
