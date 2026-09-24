---
id: TASK-169
parent: STORY-020
feature: FEATURE-002
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: done
priority: P2
assignee: agent
created: 2026-09-24
depends-on: []
blocks: []
findings: [VI-F002-2]
pr: null
github-issue: null
jira-key: null
---

# The measurement table cannot be re-run from what AGENTS.md says

## Context

Found by `/feature review FEATURE-002` Gate A (fidelity), 2026-09-24: **D10 (changed) is partly built.**
The table covers all six scripts and every count matches a re-measurement, but:

| Site | Problem |
|---|---|
| `AGENTS.md` § Comments, the text around the table | D10's pass bar — *no finding raised by both of two cold readers* — is on TASK-141 and in `decisions.md`, not beside the table. The table tells a reader to **re-run it**, and a re-run cannot reproduce the verdicts without the bar |
| the verdict column | mixed wording — one row says **passes**, another *no finding two readers agree on is open*, the rest describe contents; `decisions.md` says all six pass |
| *"Its longest block survives at 30 lines"* | stale: the table's own column says 22 (TASK-166 cut the `ARG_RE` block) |
| *"Record: FEATURE-002 (D1, D2, D3, D10, D11, D12, D13)"* | omits D15, which added a row inside the marker block |

## Acceptance criteria

- [x] The pass bar is stated where the table is, in a form a re-runner can apply: two cold readers, the guide minus the table, all six scripts, *passes = no finding both raise* — pointing at `skills/populate-tests/SKILL.md` § *The cold drill* for method rather than restating it.
- [x] Every verdict cell says **passes** or names what is open — one vocabulary.
- [x] The prose's figures agree with the table, or stop quoting figures the table already carries.
- [x] The record line names D15.
- [x] Nothing inside the `comment-rule` markers changes (the table is outside them); `bash .github/workflows/skills-lint.sh` passes with check 5 agreeing.

## Out of scope

- Re-running the measurement — TASK-141's third re-run is current.

## Human test plan

- [x] A cold reader given only the `AGENTS.md` § Comments section (table included) is asked: "how would you re-run this table's verdicts, and what counts as a pass?" Expected: two cold readers and the pass bar as stated — without needing any task file.

## Implementation plan

State the bar beside the table with a pointer for method; one verdict word; drop the stale figure; name D15.

**Outcome (2026-09-24).** `AGENTS.md` § Comments now states the pass bar beside the table — two cold
readers, the guide minus the **whole measurement block**, the six scripts and nothing else, *passes = no
finding both raise*, single-reader findings recorded on the drill's task — and points at `populate-tests`
§ *The cold drill* for obtaining a cold reader. Every verdict cell reads **passes** with its evidence. The
stale *"survives at 30 lines"* now defers to the *Longest run* column. The record line names D15.

**Human test, run:** a cold reader given only the § Comments section (86 lines, table included; listed no
skills) reconstructed the procedure and the pass bar with no task file — criterion met. It raised two
ambiguities in the new paragraph, both fixed in-task because both are reproducibility: *"minus this table"*
did not say the surrounding prose goes too (every drill withheld the whole block, since the prose argues
verdicts), and nothing said what readers may access (only the guide and scripts — a destination outside
them is *could not find*, never assumed). Its other points — how two findings count as "the same", PowerShell
block comments in the count — are recorded here, not acted on: the first is the reader's judgement by design,
and the `.ps1` files carry no `<# #>` blocks today.

**Gate, inline:** standards ✅ pointer for method, no restated list · fidelity ✅ criteria 1-5 · correctness ✅
lint OK, check 5 agrees (all edits outside the markers). Security: n/a.
