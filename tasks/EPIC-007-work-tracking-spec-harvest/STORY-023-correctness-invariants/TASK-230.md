---
id: TASK-230
parent: STORY-023
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: done
# blocked: <reason> — add this line while the task is blocked, keeping its status; /tasks unblock removes it
priority: P2
assignee: unassigned
picked-by: fix-next
created: 2026-10-03
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [SH-39]
pr: null
github-issue: null
jira-key: null
---

# `/specs regen`'s two ask-steps carry no question and no answer-less path

## Context

Found by the specs-from-code spec harvest (2026-10-03, EPIC-007, spec committed in b24eb8b). AGENTS.md § Output /
prose rules requires an ask-step to state its question and its unattended outcome. `regen` is chained from
`/tasks close` at story close and from `/fix-next` step 7, and both can run with nobody present.

- **SH-39.** `skills/specs/verbs/regen.md`:
  - Args, `--story`: "Missing references → fall back to asking which areas". No question, and no outcome when nobody
    answers;
  - step 4, **Intended anyway**: "user confirms it's expected". No question, and no path for an unattended run, where
    the only other classes are *matches an approved decision* and *unexplained*.

## Acceptance criteria

- [x] Each site states the question actually put and its unattended outcome as a reported unresolved state (for
      step 4, for example: classify as unexplained and say nobody confirmed it), never an area list or a confirmation
      the run supplied itself
- [x] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- `/specs init`'s questions (TASK-128, and the DRILL-109 record in AGENTS.md)
- The other specs findings from this pass — TASK-238, TASK-239

## Human test plan

- [x] On a fixture with a stale `import` spec and a story whose only task records no `pr:`, run
      `/specs regen --story STORY-001` and `/specs regen import`, each twice, unattended. Expected: no run guesses
      an area or classifies a change as intended on its own reading, and the two runs of each agree.
  - **Passed 2026-10-11:** `%TEMP%\d230`. `--story`: both runs regenerated nothing and printed
    `unresolved for STORY-001: TASK-001 — no resolvable pr:; their areas were not regenerated`. `import`: both
    runs classified the blank-line change **Unexplained — nobody confirmed it was intended**, naming TASK-001's
    criterion as support only. The brief said only that the run was unattended. The runner holds the installed
    skills, which this behaviour drill needs

## Implementation plan

_Populated by `/tasks plan TASK-230` — leave empty until then._

## Outcome

**The fix.** `/specs regen` asked two things without saying what to ask or what to do when nobody answers:
- which areas to regenerate when a story's tasks name no commit;
- whether a spec change with no decision behind it was intended.

It runs unattended from story close and from `/fix-next`, so both mattered. Each now has its question word for
word:
- **Areas:** with no answer, regen does no area for those tasks and reports them as unresolved. It never guesses
  from a title or a path.
- **Intended:** with no answer, the change is **Unexplained**, marked `nobody confirmed it was intended`, and the
  offers are reported, not acted on.

There is one exception. The verb that made the change in the same run, `/fix-next` step 7 today, answers from its
task's criteria and is named in the classification. `/fix-next` step 7 says so too. Without that exception, every
unattended `/fix-next` respec would turn into a finding.

**Step 6 split.** Pre-fix text, 4 runs on the same fixture:
- **both `--story` runs regenerated `import` anyway**: one guessed from what was recent, the other from sources
  changed since the stamp;
- **both `import` runs classified the change intended on their own reading**: "expected, but not formally
  confirmed" in one, "Intended" in the other.

The pre-fix `--story` runs then classified intended too. Fixed text: **0/2** `--story` runs regenerated
anything, and **2/2** `import` runs classified Unexplained, nobody confirmed. **Fix-dependent:** both outcomes.
**Contract pins, not evidence:** the harvested wording of the import spec and the provenance stamp. The
`/fix-next` exception was not drilled, so it rests on the text.

**Judgement calls.**
- *The caller that made the change may answer, and nobody else.* Story close made no change in that run, so it
  cannot vouch. `/fix-next` did, against criteria it is about to close on.
- *Report unresolved tasks; never fall back to "changed since the stamp".* That evidence is real, but it is not
  the story's. Using it silently attributes another commit's behaviour to the story.

**Flagged, not fixed.** Nothing new. The drill runners noticed fixture defects: the map used `paths:` for
`sources:`, the specs had no scenarios, and CRLF was not trimmed. These are fixture noise.

## Progress log

- step 2 — picked; ranked above TASK-231 because `regen` runs unattended from `/fix-next` step 7 and story close, and its unworded confirmation leaves such a run to invent "the user confirmed it's expected", which reads as decided in a spec diff nobody reviewed (keys 1, 3); reached on every unattended respec with an unexpected diff (key 2). TASK-231 is a contradiction a reader notices. Key 6 inert: both `correctness-invariants`
- step 3 — verified: held as written. `--story`'s "fall back to asking which areas" and step 4's "user confirms it's expected" carry no question and no unattended outcome. Also found: `/fix-next` step 7 runs `regen` and itself judges whether the diff was intended, so a rule that only a person may confirm would turn every unattended respec into a finding; the caller that made the change has to be named as the one that may answer
- step 4 — layer: local (`skills/specs/verbs/regen.md`; one sentence in `skills/fix-next/SKILL.md` step 7)
- step 5 — fix in `skills/specs/verbs/regen.md` (`--story`: verbatim area question, unattended → no area for unresolved tasks + `unresolved for` line; step 4: verbatim intended question, unattended → Unexplained, `nobody confirmed it was intended`; the change-making caller may answer from its task's criteria) and `skills/fix-next/SKILL.md` step 7 (answers from its criteria, never beyond). Lint green; drill 4/4 on `%TEMP%\d230`
- step 6 — reverted `regen.md`: pre-fix `--story` 2/2 regenerated `import` by inference, and all 4 pre-fix runs classified the change intended unconfirmed; fixed `--story` 0/2 regenerated, `import` 2/2 Unexplained-nobody-confirmed. Fix-dependent = both outcomes; contract pins = harvested wording, stamp; `/fix-next` exception not drilled
- step 7 — respecced specs-from-code ("Regen resolves which areas": question + unattended outcome, scenario; "Every behavioural change … is classified": who may confirm, scenario "Nobody confirms an expected-looking change") and defect-draining ("Respec the fixed area": answers from its criteria); `generated-at` restamped on both
- step 8 — handed to /tasks close --unattended; outcome in status:, commit in git log
