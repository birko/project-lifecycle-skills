---
id: TASK-264
parent: EPIC-002
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: done
# blocked: <reason> — add this line while the task is blocked, keeping its status; /tasks unblock removes it
priority: P3
assignee: agent
picked-by: fix-next
created: 2026-10-06
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [VC-062]
pr: null
github-issue: null
jira-key: null
---

# `feature prototype` decides whether it can publish from "the runtime", not from the session's tools

## Context

Found by `/verify-conventions` at TASK-077's close gate (2026-10-06), while it checked the instances of AGENTS.md's
new rule *A runtime-provided capability degrades the means or the delivery, never the pass*.

- **VC-062.** `skills/feature/verbs/prototype.md` (state-model playground bullet) says *"When the runtime can
  publish a file as a private shareable page, publish it and send the link."* `skills/improve-architecture/SKILL.md`
  § *Delivery* states the same capability and decides it from **the tools this session actually has, never from
  the runtime's name**, and treats a surface that cannot publish privately, or a publish that fails, as absent.
  Two skills phrasing one capability check two ways is how the weaker phrasing gets copied: "the runtime can" invites a
  guess from what a runtime usually offers.

## Acceptance criteria

- [x] `prototype.md` decides publishing from the session's tool list, keeps it private, and says what happens when a publish fails (the file in the feature folder is still the output)
- [x] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- Anything else in `prototype.md`

## Human test plan

N/A: a one-sentence wording alignment. Its behaviour, the file being written either way, is unchanged; the lint and a read of the diff cover it.

## Implementation plan

Inline: replace the one sentence with improve-architecture § *Delivery*'s check, in prototype's words.

## Outcome

**The fix (`skills/feature/verbs/prototype.md`, state-model playground bullet).** "When the runtime can publish" is
replaced by the check [[improve-architecture]] § *Delivery* states:
- publish when this session's tool list includes a tool that publishes a page only the user can see, decided from
  those tools and never from the runtime's name;
- keep it private, since sharing it further is the user's act;
- no such tool, or a publish that fails or cannot be kept private, leaves the file in the feature folder as the
  output, and the report says where it is.

The bullet points at § *Delivery*, so the two skills phrase one check one way.

**Human test plan:** N/A as filed. The behaviour, a file written either way, is unchanged; the diff was read against
§ *Delivery*.

**Close gate (inline; one skill file plus one spec):**
- **Standards:** the AGENTS.md rule *A runtime-provided capability degrades the means or the delivery, never the
  pass* now holds at this site in the same words as its other instance.
- **Intent:** the criterion is met.
- **Correctness:** by reading.
- **Security:** the publish stays private, and nothing widens who can see it.
- **Comments:** not applicable.
- **CI:** local lint passes; main is unpushed.
- **Specs:** feature-lifecycle's prototype requirement had no publish clause; it now states the check. Restamped.

## Progress log

- step 2 — picked; ranked above TASK-085 because it is self-contained in one sentence, where TASK-085 reshapes LAYER.md's state list; EPIC-002 already in-progress
- step 3 — re-verified: prototype.md still reads "When the runtime can publish a file as a private shareable page"
- step 5 — fixed in prototype.md
- step 6 — by reading (plan N/A); lint passes
- step 7 — respecced feature-lifecycle (the publish check), restamped
- step 8 — closed inline; commit in git log
