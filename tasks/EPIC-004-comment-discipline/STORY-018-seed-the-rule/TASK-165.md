---
id: TASK-165
parent: STORY-018
feature: FEATURE-002
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: done
priority: P3
assignee: unassigned
created: 2026-09-24
depends-on: []
blocks: []
findings: [DRILL-164-1]
pr: null
github-issue: null
jira-key: null
---

# Three comments that restate the line beside them

## Context

Found while doing **TASK-164**, by its human test plan: two cold readers (G, H) on the TASK-162 brief and
fixture shape. All three are the rule's first destination row — the content already lives in the code —
and all three are minor. Verified against the tree 2026-09-24.

| Site | Comment | Already carried by | Readers |
|---|---|---|---|
| `skills-lint.sh:81` | *"Aliased links ([[name\|text]]) are never skipped."* | `cut -d'\|' -f1` on the next line keeps the name half; `m_aliasbad` pins it | G, H — and C in TASK-162's re-run: **three readers** |
| `skills-lint.sh:100` | *"A leading / is repo-root-relative, not a child of this file's directory."* | `case "$path" in /*) full=".${path}"` below it | G |
| `skills-lint-test.sh:200` | *"A flag aimed at something that is not a skill must be ignored, not reported."* | `case_is "flag aimed at a non-skill path" 0 m_flagforeign` | H |

**The case for keeping each is real and should be weighed, not assumed away.** `:81` may be saying the
opposite of what a reader expects — that aliased links are *checked*, not skipped as decoration — which
the `cut` alone does not announce. `:100`'s "not a child of this file's directory" names the mistake the
line avoids, which the `case` does not. Dismissing any of them with that reason recorded closes the row.

## Acceptance criteria

- [x] Each row is acted on or dismissed with a reason recorded.
- [x] `bash .github/workflows/skills-lint.sh` and `skills-lint-test.sh` both pass, case count unchanged.
- [x] `AGENTS.md` § Comments table re-measured if either script's counts move.

## Out of scope

- The EVIDENCE/PIN lines G and H read as QA logs — accepted as by-design on **TASK-153**.
- `skills-lint.sh:144-146`'s ANCHORED mechanic (G) — kept deliberately on **TASK-163**: it is the mechanism at the line where it bites; `AGENTS.md:279` states the rule.
- `skills-lint.sh:218-219` — **TASK-081**; `ARG_RE` block and `pi-install` headers — **TASK-141**.

## Human test plan

- [x] Two cold readers, same fixture shape as TASK-163's. Expected: none of the three reported, or reported and the recorded reason explains why it stands. — **ran 2026-09-24 (I, J; TASK-162's brief unchanged; both cold): none of the three reported.**

## Implementation plan

All three deleted; the case for keeping each (Context) was weighed and does not survive the code:

| Site | Decision | What carries it |
|---|---|---|
| `skills-lint.sh:81` | delete | `cut -d'\|' -f1` keeps the name half of every alias — that *is* "never skipped"; `m_aliasbad` pins it failing on a bad alias |
| `skills-lint.sh:100` | delete | the `case` spells both branches: `/*) full=".${path}"` and `*) full="$dir/$path"` — the "not a child of this file's directory" alternative is the second branch, on the same line |
| `skills-lint-test.sh:200` | delete | `case_is "flag aimed at a non-skill path" 0 m_flagforeign` |

Then both suites; `AGENTS.md` table re-measured (both files lose lines); two cold readers.

**Outcome:** all three deleted. `skills-lint.sh` 317 → 315, test file 393 → 392; table re-measured.
`skills-lint.sh`'s committed CRLF line endings were stripped by `sed -i` mid-task and restored before
commit — the commit carries three deleted lines and nothing else.

**Drill, what else I and J raised** — recorded here under TASK-141's clean bar (no finding both readers
raise) rather than filed: **both** raised the `ARG_RE` block and the `pi-install` headers (TASK-141's own)
and the EVIDENCE/PIN lines (accepted by-design on TASK-153 — see TASK-141). **J alone** raised
`skills-lint.sh:142-145`'s clauses beside their pointer, `:156`'s *"FATAL, unlike the advisory…"* as a
§ Testing restatement, and `:288-290`'s *"not by gating"* as history plus the test name cited by prefix.
Single-reader, so recorded, not filed.

**Gate, inline** — three deleted comment lines: standards ✅ · fidelity ✅ · correctness ✅ no executable
line changed, 56/56, lint exit 0 · comments ✅ cleared by the drill. Security: not applicable.
