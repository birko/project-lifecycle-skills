---
id: TASK-215
parent: STORY-022
feature: FEATURE-003
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: done
# blocked: <reason> — add this line while the task is blocked, keeping its status; /tasks unblock removes it
priority: P2
assignee: unassigned
created: 2026-10-03
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [CR-141, VC-058]
pr: null
github-issue: null
jira-key: null
---

# The `blocked:` writers do not quote their value, and two readers of the block note are undeclared

## Context

Found by `/feature review FEATURE-003` (2026-10-03).

- **CR-141 — unquoted values break strict YAML.** `close` step 6 writes
  `blocked: merge deferred: <reason>; code complete on task/TASK-NNN`. It contains `: `, so unquoted it is a
  YAML error, and pi parses frontmatter strictly (AGENTS.md § Framework / stack). `block` step 4 writes
  `blocked: <reason>` with no quoting rule at all. `init` step 3b already has the rule (quote last, single
  quotes, the non-string scalars).
- **VC-058 — format contracts stated on one side only.** `skills/tasks/verbs/export.md` reads the
  `> Blocked <date> — <reason>` note, but `block.md`'s "keep that shape" names only `init` 3b. Tracker comments
  starting `Blocked:` are written by `block` step 5b and `export`, and read by `import` ("newest comment
  starting `Blocked:`"); neither writer says so. AGENTS.md § *A format one skill reads is a contract the
  writing skill must state too*.

## Acceptance criteria

- [x] Every writer of a `blocked:` value (`block` step 4, `close` step 6, `import`) applies one quoting rule,
      stated once and pointed at, not copied three times (AGENTS.md § *Defer to a shared inventory*)
- [x] `block.md` step 5's shape contract names every reader of the note (`init` 3b and `export`)
- [x] The `Blocked:` tracker comment's writers state that `import` parses it
- [x] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- The wording sweep — TASK-213; `close`'s blocked refusal — TASK-214

## Human test plan

- [x] Run `/tasks close` with a deferred merge on an invented task, then load its frontmatter with a strict
      YAML parser: it parses, and `blocked` is the full string

## Implementation plan

_Drafted at pick, 2026-10-03; grill skipped._

1. State the quoting rule once, in `skills/tasks/SKILL.md` § Lifecycle right after the reading table (it owns the `blocked:` field), and move `init` 3b's copy there; every writer points at it: `block` step 4, `close` step 6 (shown quoted), `import` (both trackers), `init` 3b.
2. `block.md` step 5's shape contract names both readers of the note (`init` 3b, `export`).
3. The `Blocked:` tracker-comment writers (`block` 5b, `export`) say `import` reads the prefix.
4. Lint; check the rule against the parser pi actually uses (`yaml`, under pi's install); drill `block` with three hazardous reasons on two cold runners, then parse every resulting frontmatter with that parser.

## Progress log

- 2026-10-03 — Picked (in place; single-branch). Rule stated once in `tasks/SKILL.md` § *Writing a `blocked:` value*; `init` 3b's copy replaced by a pointer; `block` step 4, `close` step 6 and `import` point at it; `block` step 5 names `init` and `export` as readers of the note; `block` 5b and `export` say `import` reads the `Blocked:` prefix. Lint OK.
- 2026-10-03 — Checked on pi's own parser (`@earendil-works/pi-coding-agent/node_modules/yaml`): unquoted `blocked: merge deferred: waiting on review` is a parse error ("Nested mappings are not allowed in compact mappings"), the quoted form parses to the full string. It also showed my rationale was wrong: that parser reads `blocked: no` as the string `no` (YAML 1.2), while `true` → boolean, `42` → number, `~`/`null` → null, and `waiting #3` → `waiting` silently. Rationale rewritten from those measurements; the rule's list already covered every case. Drill: fixture `%TEMP%\d215base`, oracle written first, two cold runners.
- 2026-10-03 — Drill: **both runners match the oracle and agree** (cold: no skills listed, no prior exposure). Each wrote `blocked: 'waiting on legal: contract unsigned'`, `blocked: 'true'` and `blocked: 'ticket #42 must merge first'`, status left `in-progress`, the note appended; pi's parser reads all three back as the full string. Raised by one, codified because both runners did it the same way: the note carries the raw reason, never its YAML quotes (one phrase in `block` step 5). **Intent** (inline): criterion 1 — the rule is stated once in `tasks/SKILL.md` and `block` 4, `close` 6, `import` and `init` 3b point at it, `init`'s copy removed; 2 — `block` step 5 names `init` 3b and `export`; 3 — `block` 5b and `export` state that `import` reads the `Blocked:` prefix; 4 — lint OK. Standards and correctness passes running.
- 2026-10-03 — Close review, one reviewer, two verdicts. **Standards:** pass with findings, no blocker — fixed: `block` step 5 said "two verbs read it" while `fix-next` reads the note too (named, count dropped); the example used real task ids (now invented); "quote it **last**" meant nothing outside `init` (reworded). **Correctness:** rule sound — quoted values round-trip ~60 cases on pi's parser — with findings, fixed: the indicator characters are now listed, with "when in doubt, quote"; an empty value is forbidden (`reason unknown` instead), since it reads as null; readers use the parsed value, never the raw line — `export` read the raw line, so each export/import round trip added a layer of quotes (fixed in `export`, and `blocked` added to the Collection pass capture list); `close`'s shown note now matches what `block` writes. Pre-existing, moved to TASK-212 before it started: the `TASK.md` template invites a hand-added `blocked:` (VC-061). `block` step 5's question with no answer-less path was already TASK-212's VC-055. Not re-drilled: the three drilled values write the same lines under the expanded rule (checked on pi's parser, including the new example); the export read-path change is not drilled. **Security / comments:** not applicable. Out-of-scope sweep: 1 boundary (TASK-213, TASK-214). Closed `done`.
