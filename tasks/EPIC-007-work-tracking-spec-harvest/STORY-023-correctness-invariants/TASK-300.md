---
id: TASK-300
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
findings: [FIELD-011]
pr: null
github-issue: null
jira-key: null
picked-by: fix-next
---

# A task exported to Jira shows the project's default priority in Jira's own priority field

## Context

Found while doing TASK-299 (2026-10-12). `skills/tasks/verbs/export.md` step 5 sends a task's priority to Jira
only as the label `priority/<value>` and leaves the ticket's priority field as the project sets it. TASK-299 made
`import --jira` read that label first, so the round trip now keeps the value. But anyone reading the ticket in
Jira sees the field: a P0 task exported to a project whose default is Medium shows as Medium there. A cold runner
in TASK-299's drill pointed this out.

Setting the field means mapping `P<n>` onto the project's priority scheme. `import.md`'s table maps Jira's
default scheme (Highest–Lowest to P0–P4) and a scheme already named `P<n>`. Export would need the inverse, plus a
rule for a scheme it cannot read or that has no matching value. That rule is the open part.

## Acceptance criteria

- [x] `export --to jira` sets the ticket's priority field when the project's scheme has a value for the task's
      priority, by the inverse of `import.md`'s table, and states what it does when there is none
- [x] The `priority/<value>` label is still sent, and import's label-first rule is unchanged
- [x] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- The round trip itself, which TASK-299 fixed
- Deferred to TASK-302 — what import does when an edited Jira priority field disagrees with the export label

## Human test plan

N/A — a mapping rule in a verb file, checked by reading it against `import.md`'s Jira table.

## Implementation plan

Not drafted: `/fix-next` picked this task and offers no plan step (TASK-135 owns that gap). The work followed the Progress log below, step by step.

## Outcome

**The fix.** `/tasks export --to jira` now sets the ticket's own priority field, so a P0 no longer shows as the project's default (often Medium) to someone reading the ticket in Jira. It reads the priorities the project offers for the issue type and inverts `import.md`'s Jira table: a priority named exactly the task's value wins, then Jira's default scheme maps P0–P4 to Highest–Lowest. Otherwise the field is left alone and step 9's confirmation names the task and why. The `priority/<value>` label is still always sent, and import's label-first rule is unchanged. Only the sentence giving its reason was rewritten, because "export never sets the priority field" stopped being true.

**Step-6 split.** Two cold readers each got only `export.md`, one the HEAD copy and one the fixed copy, and 3 cases × 3 questions. 3/9 answers depend on the fix: A2 (P0, default scheme: unset → Highest), B2 (P2, P-named scheme: unset → P2) and C3 (P7: no line → the left-at-default line). Contract pins, not evidence: A1, B1, C1 (label sent) and C2 (P7 leaves the field at the default before and after).

**Judgement calls.**
- *The open part (no match) leaves the field unset and reports it, and never picks the nearest name.* The stricter-looking alternative was to refuse the export, and it was rejected: the label carries the value, so nothing is lost, and refusing would block every project with a custom scheme over a display field. Guessing a nearest name was rejected because it is the decided-looking guess the repo forbids, and it would disagree with the label.
- *An exact `P<n>` name outranks the default-scheme mapping*, in the same row order as import's table, so export and import invert each other row for row.
- *The confirmation-line wording for a field that was set* was pinned after the drill, once the new reader marked it unspecified. It is a one-line format, so it was not re-drilled.

**Close-gate fixes.** The correctness pass found a blocker: this change had deleted export's `Assignee` (GH only) line, and it is now restored. It also found three edges left undefined, all now closed in `export.md`. A STORY or EPIC has no `priority:`, so its field is left alone and no line is printed. A value that is not `P<n>` never sets the field, because import would read the field back and change the value. "Default scheme" means the project offers all five names, whatever else it offers. `--dry-run` shows the field too.

**Flagged, not fixed.** TASK-302 (CR-300-1): with the field now set, a priority edited in Jira after export is overruled on re-import by the stale label. TASK-300 kept the label-first rule unchanged on purpose, so the precedence question is that task's. Case-insensitive name matching is left undefined in both verbs and is recorded as out of scope on TASK-302. The spec's round-trip scenario now states a project with no matching priority, because with the fix a P3 on Jira's default scheme would set the field to Low and the old wording would no longer fit.

## Progress log

- step 2 — picked; ranked above TASK-296 because both are wrong-record defects (key 1), but this one is silent (a P0 shows as Medium in Jira, key 3), reachable from any `export --to jira`, contained in one verb file (key 4) and field-confirmed by a cold runner (key 5), where TASK-296 is unmeasured and needs a fixture drill first; key 6 inert (both `correctness-invariants`)
- step 3 — verified: held — `export.md` step 5 leaves the Jira field as the project sets it (lines 32-34); `import.md`'s Jira table (step 3) is the mapping to invert; `import.md`'s rationale sentence ("export never sets the priority field") also becomes false and is in scope, the label-first rule itself unchanged
- step 4 — layer: local
- step 5 — fix in `skills/tasks/verbs/export.md` (step 5 priority-field table, label bullet, step 9 confirmation lines) and `skills/tasks/verbs/import.md` (step 3 rationale sentence; label-first rule unchanged); lint OK (20 skills)
- step 6 — revert-and-split by two cold readers (`claude -p --disable-slash-commands`, cwd a scratch dir holding only `export.md` at HEAD vs fixed; both listed no skills), 3 cases × 3 questions: 3/9 answers fix-dependent = A2 (P0 on default scheme: field unset → Highest), B2 (P2 on a P-named scheme: unset → P2), C3 (P7: no line → the named left-at-default line); contract pins = A1, B1, C1 (`priority/<value>` label sent in all) and C2 (P7 leaves the field at the default both before and after). A3/B3 changed too but the new reader marked the set-field line's wording unspecified, so it was pinned (`Jira priority field: <the priority set>`) after the drill, not re-drilled
- step 7 — respecced work-tracking; requirements changed: *Exporting a task* (priority field set by the inverse mapping, left and reported otherwise; two new scenarios), *Importing work* round-trip scenario's Given narrowed to a project with no matching priority
- step 8 — handed to /tasks close --unattended; outcome in status:, commit in git log
