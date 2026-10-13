---
id: TASK-302
parent: STORY-023
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: done
# blocked: <reason> — add this line while the task is blocked, keeping its status; /tasks unblock removes it
priority: P2
assignee: unassigned
created: 2026-10-12
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [CR-300-1]
pr: null
github-issue: null
jira-key: null
picked-by: fix-next
---

# A Jira priority someone edits after export is lost on re-import, because the export label still wins

## Context

Found by the correctness pass at TASK-300's close (2026-10-12). `skills/tasks/verbs/import.md` step 3 (`--jira`) reads a `priority/P<n>` label before the priority field. TASK-300 made `export --to jira` set that field as well (`skills/tasks/verbs/export.md` step 5). The field is the value people in Jira see and edit. If a P3 task is exported with its field at Low and a PM then raises the field to Highest, a re-import still reads the stale `priority/P3` label, writes P3 and says nothing. The PM's change is gone.

This was already possible before TASK-300, when the field held only the project's default: a PM who changed it was overruled the same way. TASK-300 makes it likelier, because the field now shows a real value that invites editing. TASK-300's criteria kept import's label-first rule unchanged on purpose, so the precedence question is this task's.

## Acceptance criteria

- [x] `import --jira` states what it does when the label and the field disagree, read through export's inverse mapping (`export.md` step 5): which one wins, and that the disagreement is reported in step 7's confirmation, never resolved silently
- [x] The rule keeps TASK-299's round trip: a ticket whose field is the project default, or was never set by export, still imports with the label's value
- [x] `docs/specs/work-tracking.md` is respecced for *Importing work*
- [x] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- Export's mapping itself (TASK-300)
- Case-insensitive matching of Jira priority names: neither verb defines it, and no drill has met a project whose names differ only in case

## Human test plan

- [x] A cold reader given only the final `import.md` (`claude -p --disable-slash-commands` in a scratch dir, no skills listed) and six tickets: label and field agree, an edited field, an untouched default, no label, an unmapped field with an unreadable changelog, and a label added after the edit. It writes P3/P0, reports or stays silent exactly as step 3's table says, and adds no Context line. Passed 2026-10-13. The rule changes behaviour, not only reporting, so this replaces the original `N/A`

## Implementation plan

Not drafted: `/fix-next` picked this task and offers no plan step (TASK-135 owns that gap). The work followed the Progress log below, step by step.

## Outcome

**The fix.** `/tasks import --jira` no longer drops a priority that someone changed in Jira after the ticket was exported. When a ticket has both a `priority/P<n>` label and a priority field, import maps the field and compares the two. If they agree, it uses that value. If they differ and the issue's changelog shows the priority was changed after creation, the field wins, because a person chose it. Otherwise the label wins. That covers a field nobody touched, a field export never set, an empty or unmapped field, and a changelog that cannot be read. Every disagreement is reported in step 7, whichever side was written.

**Step-6 split.** Two cold readers each got only `import.md`, one the HEAD copy and one the fixed copy, and 5 tickets × 3 questions. 4/15 answers depend on the fix: ABC-1's value (an edited field, P3 → P0) and the step-7 lines for ABC-1, ABC-2 and ABC-5. Contract pins, not evidence: ABC-2's value P3 (criterion 2's round trip holds), all of ABC-3 (agreement prints nothing), all of ABC-4 (no label, field mapped), ABC-5's value, and every Context answer.

**Judgement calls.**
- *The changelog decides, not the field's value.* A field that disagrees with its label is normal on a ticket nobody touched: export sets the field only where the project has a match, and exports from before TASK-300 never set it. So "the field differs" cannot tell an edit from no edit, and the changelog can. Two simpler rules were rejected. Field-always-wins would break TASK-299's round trip for every old export, which is criterion 2. Label-always-wins-but-report would still discard the edit a person made, which is the defect, now with a warning on top.
- *The comparison is anchored to the change that set the label, not to the issue's creation.* The correctness pass at close showed the creation anchor breaks when the label is added later. A priority edited before the label was added would then beat it, and the report would wrongly say "after export". The changelog records label changes too, so the last-change comparison works whatever created the ticket. Re-drilled on the final text with that case added.
- *An unreadable changelog keeps the label and says so.* It is the outcome that changes nothing from before this task, and the report makes the possible loss visible instead of guessing that an edit happened.
- *The two ABC-5 gaps* the new reader found were closed after the drill and not re-drilled: an empty or unmapped field reads no changelog and gets its own line, and step 7's P1 fallback line applies only to tickets that got P1. Both are one-line wording rules.

**Close-gate fixes.** From the correctness pass: the anchor above. Also: the table is now first-match, with the empty/unmapped row first. An empty field has its own line. Several `priority/P<n>` labels count as none. Step 2 asks for the changelog explicitly, because without it every disagreement would land on "unreadable". The spec's P1-fallback clause applies only to tickets with no usable label.

**Flagged, not fixed.** Nothing new. Case-insensitive priority-name matching is still undefined in both verbs; it stays recorded under Out of scope.

## Progress log

- step 2 — picked; ranked above TASK-296 because this is silent loss of a person's edit (key 1: data loss, above TASK-296's unmeasured uncommitted-record gap), reachable from any re-import of an exported ticket, and silent (key 3); key 6 inert (both `correctness-invariants`)
- step 3 — verified: held — `import.md` step 3 (`--jira`) takes a `priority/P<n>` label whenever one exists and never compares it with the field, so a field edited in Jira after export is discarded with no report. Scope note: whether the field was edited cannot be read off the field alone (an old export before TASK-300 also leaves a field that disagrees with its label, and criterion 2 requires that one to keep the label), so the rule reads the issue's changelog, which records whether the priority changed after creation
- step 4 — layer: local
- step 5 — fix in `skills/tasks/verbs/import.md` (step 3: a label/field comparison table that reads the issue changelog, and step 7 confirmation lines) and `skills/tasks/verbs/export.md` (the label bullet's pointer to import); lint OK (20 skills)
- step 6 — revert-and-split by two cold readers (`claude -p --disable-slash-commands`, cwd a scratch dir holding only `import.md` at HEAD vs fixed; both listed no skills), 5 tickets × 3 questions: 4/15 answers fix-dependent = ABC-1 value (edited field: P3 → P0) and the step-7 lines for ABC-1 (edit reported), ABC-2 (old-export disagreement reported, label kept) and ABC-5 (unmappable field reported); contract pins = ABC-2 value P3 (criterion 2: the round trip holds), ABC-3 all three (agreement prints nothing), ABC-4 all three (no label, field mapped), ABC-5 value P3, and every Context answer. The new reader found two ABC-5 gaps (whether the changelog matters to an unmappable field; step 7's fallback line firing for a labelled ticket). Both were closed after the drill: the row now says the changelog is not read and gives its own line, and step 7 limits the fallback line to tickets that got P1. An empty field joins the same row. Not re-drilled
- step 6 (addendum, close gate) — the correctness pass moved the anchor from issue creation to the change that set the label; the final text was re-drilled by one cold reader with a sixth ticket (label added after the edit): 6/6 as intended, recorded as the Human test plan step
- step 7 — respecced work-tracking; requirements changed: *Importing work* (the label/field comparison replaces label-first; two new scenarios; the round-trip scenario now also reports the disagreement)
- step 8 — handed to /tasks close --unattended; outcome in status:, commit in git log
