---
id: TASK-299
parent: STORY-023
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: done
# blocked: <reason> — add this line while the task is blocked, keeping its status; /tasks unblock removes it
priority: P2
assignee: unassigned
picked-by: fix-next
created: 2026-10-12
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [FIELD-010]
pr: null
github-issue: null
jira-key: null
---

# `import --jira` ignores the `priority/<value>` label export sends, so a round trip changes the priority

## Context

Found while doing TASK-222 (2026-10-12). **Rescoped at fix-next step 3, before any fix:** the filed description
said export never says how priority reaches Jira. It does: `skills/tasks/verbs/export.md` step 5's label list is
tracker-neutral, and only the blocked marker is swapped for Jira's Flagged field, so a task's priority reaches
Jira as the label `priority/<value>`. The Jira **priority field** is never set, so the ticket keeps the
project's default (Medium in Jira's default scheme).

The defect is on the reading side. `import.md` `--jira` step 3 (TASK-222's table) reads only the priority
field, never that label. So a P3 task exported and imported back returns as P2 (Medium), and P0 returns as P2
too, with nothing recording that it changed. `--github` already reads the label (`priority/P0` → P0).

## Acceptance criteria

- [x] `import --jira` reads a `priority/P<n>` label first and uses the priority field only when there is no such label, as `--github` does
- [x] `export.md` states that on Jira the priority travels as that label and the priority field is left as the project sets it, so the two sides name one route
- [x] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- The GitHub side, which already sends `priority/<value>` for any value
- Deferred to TASK-300 — setting the Jira priority field on export, so the ticket shows the task's priority in Jira itself

## Human test plan

N/A — a mapping rule in a verb file, checked by reading it against `import.md`'s Jira mapping table.

## Implementation plan

_Populated by `/tasks plan TASK-299` — leave empty until then._

## Outcome

**What changed.** A task exported to Jira and imported back could come back at a different priority, with
nothing recording it. Export sends the priority as the label `priority/<value>` and never sets Jira's priority
field, while `import --jira` read only that field. So a P3 and a P0 both came back as P2, which is what Jira's
default Medium maps to. Now:
- `import.md` `--jira` reads a `priority/P<n>` label first, as `--github` already did, and the priority field
  only when there is no such label. The table's fallback row applies only with no priority and no label.
- `export.md` states that on Jira too the label is the priority's only route, and that the field is left as the
  project sets it.
- Respecced `work-tracking`: the import and export requirements, plus a new scenario, *Exported priority
  survives a round trip*.

**Rescoped at step 3.** I filed this task myself while doing TASK-222, saying export never says how priority
reaches Jira. Reading export properly showed that it does: through the tracker-neutral label. The defect was on
the import side, so the Context and criteria were corrected before the fix.

**Step-6 split.** Both runs were cold drills (`claude -p --disable-slash-commands < brief.txt`, run from
`C:/Source/WebChecker`, both `SKILLS-SEEN: none`) on one brief: export a P3 and a P0 task to a Jira project
whose default priority is Medium, then import both tickets back. The brief carried both verb files from `HEAD`
(before) or from the working tree (after), and did not say what was expected. **Before the fix: 0 of 2 kept
their priority (P3 → P2, P0 → P2), and nothing was flagged; the runner itself noted that "the round trip
quietly changes both priorities". After the fix: 2 of 2 (P3 → P3, P0 → P0).** Both cases depend on the fix. The
lint passes either way, so it is a contract pin, not evidence.

**Judgement calls.**
- **The label wins over the field.** The label is what export writes. On a ticket export made, the field holds
  only the project default, so reading the field first loses the one value that was set on purpose.
- **Export still leaves the field alone.** Setting it needs the inverse of import's table and a rule for a
  scheme with no matching value, which is a design question. Leaving it alone is today's behaviour, now stated.
  The visible cost, Jira showing the default priority, is TASK-300.

**Flagged, not fixed.** The Jira priority field on an exported ticket shows the project default: spawned as
TASK-300 (FIELD-011) under STORY-023.

**Merge gate (close step 5b, run inline, each verdict on its own):**
- *Standards*: pass. Both sides of the label contract now state it, as § *A format one skill reads is a contract
  the writing skill must state too* requires. No new cross-cutting pattern.
- *Fidelity*: pass against the rescoped criteria. Criterion 1 is the label-first rule, criterion 2 is export's
  label bullet, and criterion 3 is lint OK. The GitHub side was left untouched.
- *Correctness*: no finding. The fallback row now applies only with no label too, so a labelled ticket with an
  unmapped field name takes the label, not P1.
- *Security* and *Comments*: not applicable.

## Progress log

- step 2 — picked; ranked above TASK-279 because an export-then-import round trip can change a stored priority with nothing showing it (keys 1 and 3), where TASK-279 misreports a run in its own records line; both self-contained correctness-invariants (key 6 not needed)
- step 3 — verified: rescoped — export does send priority to Jira, as the tracker-neutral `priority/<value>` label (only the blocked marker is swapped for Flagged); the defect is import --jira reading only the priority field, which export never sets, so P0 and P3 both come back as P2 (Medium). Context and acceptance criteria corrected before the fix
- step 4 — layer: local
- step 5 — fix in skills/tasks/verbs/import.md (--jira: priority/P<n> label first, field otherwise) and skills/tasks/verbs/export.md (on Jira the label is the route, field left alone); evidence is a cold drill (prose)
- step 6 — reverted fix (HEAD text, same brief, cold runner): round trip kept 0/2 (P3→P2, P0→P2); with fix 2/2; fix-dependent = both cases; contract pins = skills-lint.sh
- step 7 — respecced work-tracking; requirements changed: Importing work (label first; new scenario: Exported priority survives a round trip), Exporting a task (priority label on Jira, field untouched)
- step 8 — handed to /tasks close --unattended; outcome in status:, commit in git log
