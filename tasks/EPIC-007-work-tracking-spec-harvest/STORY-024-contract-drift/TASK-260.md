---
id: TASK-260
parent: STORY-024
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: done
# blocked: <reason> — add this line while the task is blocked, keeping its status; /tasks unblock removes it
priority: P2
assignee: unassigned
created: 2026-10-06
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [SH-86]
pr: null
github-issue: null
jira-key: null
picked-by: fix-next
---

# `grill-me`'s description has no Slovak triggers and predates the skill it describes

## Context

Found by the `idea-interrogation` spec harvest (2026-10-06, TASK-080, EPIC-007 fourth pass) at `07de657`.

- **SH-86.** `skills/grill-me/SKILL.md`'s `description:` is the upstream one-liner:
  - It carries **no Slovak trigger phrases**, against AGENTS.md § *Framework / stack*: the description carries "the
    trigger phrases users actually type, including the Slovak ones this team uses". The descriptions of 12 other
    skills do.
  - It names no skill it should not be confused with. Here that is [[feature]] `new`, which invokes the grill but
    is not the grill.
  - It still describes the pre-TASK-117 skill: one question at a time, with no lookups.

## Acceptance criteria

- [x] The description carries the Slovak trigger phrases the team uses for a grill, and says how the skill differs from `/feature new`
- [x] It stays one line, uses no unquoted `: ` or ` #`, and stays within budget (AGENTS.md's pi frontmatter table)
- [x] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- The body's behaviour (TASK-258, TASK-259)

## Human test plan

N/A: a frontmatter wording change. The lint's check 1 covers whether it loads in pi, and the trigger phrases are checked by reading.

## Implementation plan

_Populated by `/tasks plan TASK-260` — leave empty until then._

## Outcome

**The fix.** `grill-me`'s description now matches the skill it describes:
- **Rounds:** at most five numbered questions, each with a recommended answer, and facts looked up rather than asked
  (the post-TASK-117 body).
- **Trigger phrases:** the English ones plus four Slovak ones in the team's register: "grilni ma", "vyspovedaj ma z
  toho plánu", "prever mi ten plán", "rozober so mnou ten návrh".
- **What it is not:** distinct from `/feature new`, which captures an idea and runs this grill as one step.

**Check.**
- One line, 558 characters, no unquoted `: ` or ` #`, and lint check 1 passes.
- The runtime reloaded the skill list with the new text in this session, which shows it loads.

**Judgement calls.**
- **The Slovak phrases are the colloquial forms the team's other descriptions use**, with and without diacritics, not
  a translation of "grill me". Nobody types a literal translation.
- **"Works on any plan" stays.** The body says the grill is not only for features, and that is the half of the
  `/feature new` distinction a reader needs.

**Close gate (inline, one line):**
- **Standards:** the description budget and pi-loading rules hold, the trigger phrases are included, and the
  confusable skill is named.
- **Intent:** criteria met.
- **Security, comments:** not applicable.
- **CI:** `ci: main green — 1 workflow read`.

## Progress log

- step 2 — picked; next P2 in STORY-024 (contract-drift): a description is how a skill is chosen, so missing triggers mean a Slovak request never reaches it (key 1), on every such request (key 2)
- step 3 — verified: held; the description is the upstream one-liner, with no Slovak triggers and no confusable named
- step 3b — not planned: one frontmatter line
- step 4 — layer: local
- step 5 — fix in skills/grill-me/SKILL.md frontmatter
- step 6 — lint check 1 passes; the runtime reloaded the new description in-session
- step 7 — no spec change: no spec states the description
- step 8 — handed to /tasks close --unattended; outcome in status:, commit in git log
