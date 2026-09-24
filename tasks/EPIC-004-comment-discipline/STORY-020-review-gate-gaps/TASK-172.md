---
id: TASK-172
parent: STORY-020
feature: FEATURE-002
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: done
priority: P2
assignee: agent
created: 2026-09-24
depends-on: []
blocks: []
findings: [VI-F002-4, VC-F002-3, VC-F002-4]
pr: null
github-issue: null
jira-key: null
---

# Three things Gate A's second run found in this story's own fixes

## Context

`/feature review FEATURE-002`, Gate A re-run, 2026-09-24: both passes **PASS**, with three ⚠ — all in
wording STORY-020 itself wrote. Grouped because they share an origin and each is a line or two.

| Id | Site | Finding |
|---|---|---|
| VI-F002-4 | `skills/review-comments/SKILL.md`, § *The only copy*, the standing-rule route (TASK-170) | *"the same file Step 1 found the comment rule in"* is wrong on the **no-rule path**: at rung 3 (D14) Step 1 reads the rule from the shipped `new-project/templates/CONVENTIONS-universal.md`, so the route would relocate a project's content **into the skill's own template** — and installs are links, so that edits the product for every consumer. The ask-first question limits the damage; the target is still wrong |
| VC-F002-3 | `README.md` § 6, the line introducing the questions line (TASK-168) | *"The two answer different questions:"* above a line that now names four passes — already wrong at three |
| VC-F002-4 | `AGENTS.md` § *Independent review axes* (TASK-167) | *"(it has gained axes twice; a copy here went stale both times)"* is a hard count and history inside a standing rule — it goes stale on the next axis, the failure its own sentence warns about |

## Acceptance criteria

- [x] The standing-rule route names the project's guide as the target on every rung, and says so for rung 3 explicitly: the project's `CLAUDE.md` (or its agent guide), **never** the shipped template the floor was read from.
- [x] The README introduction no longer counts the passes.
- [x] The AGENTS.md parenthetical carries no count and no history — or goes.
- [x] `bash .github/workflows/skills-lint.sh` passes; check 5 agrees.

## Out of scope

- The two Gate A notes — `CONVENTIONS-universal.md`'s partial list in the not-CI-enforced sub-bullet (still true, still neutral) and the record line's "block above" reading ambiguously under the measurement block (predates this story). Recorded on FEATURE-002's ledger at sign-off.

## Human test plan

N/A — three wording corrections; the gate agent that found them re-checks the sites. The rung-3 clause is covered by D14's existing drill shape, and the ask-first question already stands between the route and any write.

## Implementation plan

Name the target by what it is (the project's guide), not by where Step 1 happened to read from; drop the count from the README lead-in; cut the parenthetical to a bare pointer.

**Outcome (2026-09-24).** The standing-rule route now names the project's `CLAUDE.md` or agent guide and
says outright that on rung 3 it is still the project's guide, never the shipped template. The README reads
*"Each pass at that gate answers a different question"*. The AGENTS.md parenthetical became a reason with
no count: *"a copy here goes stale the day an axis is added"*. Lint OK, check 5 agrees. Filed and closed in
one pass, straight from the gate re-run's report; **gate, inline:** the gate agent's own findings are the
criteria, each checked at its site.
