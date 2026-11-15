---
id: TASK-029
parent: STORY-015
feature: null
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: done
priority: P3
assignee: agent
created: 2026-08-19
depends-on: []
blocks: []
# findings: ids this task remediates, from a review/audit/spec-harvest pass (CR-* SEC-* SH-* VC-*)
findings: [SH-117]
pr: null
github-issue: null
jira-key: null
picked-by: fix-next
---

# The lint's own coverage grew 16 to 25 cases with nothing recording what the nine pin

## Context

Noticed while closing TASK-026 (2026-08-19). `AGENTS.md` § Testing said
`.github/workflows/skills-lint-test.sh` carries **16 cases**; it now runs **25**. TASK-026 corrected
the number because it was already editing the file, and deliberately did no more.

The stale number matters more here than a typo would, because of what the guide says next: the lint
is *the repo's only gate*, so "a silent regression in it disables checking entirely with no signal",
and *a change to `skills-lint.sh` is not done until a case here fails without it*. The case count is
what a reviewer uses to check that rule was honoured. A count that lags turns the check into a
formality — and nobody can now say from the records whether the nine new cases arrived with the lint
changes that needed them.

**Data point added 2026-09-20 from TASK-151.** The count has now moved a **seventh** time: the suite
runs **56** cases, while `AGENTS.md:366` still says 47 and lists the drift as `16 → 25 → 36 → 40 → 43
→ 47`. So the number went stale again between TASK-146 landing and the next read of that line — which
is the concrete evidence for criterion 3 below, not merely an argument for it. TASK-151 deliberately
did not patch 47 → 56: a hand-synced number fixed by hand is the same defect re-armed, and deciding
whether the guide should carry a raw count at all is this task's job.

**Linked 2026-10-06 (EPIC-007 fifth pass, SH-117):** the skill-authoring-rules harvest found lint branches with no case: a name over 64 characters, a file not starting with frontmatter, no skill folders found, the quote/`|`/`>` exemptions, and the `RUNTIME_REFS` allowance.

## Decision (2026-11-15, the user)

- **The guide carries no count.** One hand-copied number moved twelve times. `AGENTS.md` § Testing gives a command
  that counts the cases without running anything.
- **Each case's label opens with the check it pins** (`[1]` … `[9]`, `[pre]` for the tree and skill-folder guards,
  `[all]` for a case every check shares). Labels rather than regrouping: the script is already partly grouped,
  reordering 460 lines risks the suite, and a label is on every line the suite prints.
- **Every branch with no case gets one**, each proven to fail without its branch.

## Acceptance criteria

- [x] Each of the 25 cases maps to the lint behaviour it pins, and the **thirty-one** added since the count was written are identified (the criterion originally said nine; the suite has grown twice more since) — every case now names its check in its label, so which ones were added when no longer matters to reading them; the mapping is proven by the mutation run in the test plan
- [x] Any lint behaviour with **no** case is either given one or recorded as deliberately unpinned, with the reason — seven cases added: no frontmatter at the top, a name over 64 characters, a description starting `#`, a `|` block-scalar description, no skill folders, a runtime-provided wikilink (`RUNTIME_REFS`), and external/anchor/mailto links. Shared-branch values (`null` beside `~`, `!` beside `&`, a `?` indicator beside the others) are deliberately left to the case for the same branch: one case per branch, not per value
- [x] Whether the guide should carry a raw count at all is decided explicitly — a number that must be hand-synced drifts again next week, so prefer a pointer or have the count come from the script — no; the guide gives the counting command
- [x] `skills-lint-test.sh` still passes and still runs before the lint in CI — 97/97; CI order unchanged

## Out of scope

- Rewriting the lint itself. This is about its test coverage and how the guide describes it.
- Adding new lint rules; a gap found here becomes its own task.

## Human test plan

- [x] Break one lint rule at a time and confirm a named case fails for each — the mapping is only real if it is exercised
  - **Passed 2026-11-15**, by a throwaway script (scratchpad `mut029.py`, not kept): for each check 1–9 it deleted
    the check's body, ran only the cases labelled for it, and required at least one `FAIL`; then ran the same cases
    on the unbroken lint and required none. The same for the two setup guards and the six branches the new cases
    pin. All 17 passed after one fix: **`[pre] a whole skill tree is missing` did not pin its guard** (deleting
    `skills-pi/` also breaks a `[[gamma]]` link, so the case failed for the wrong reason); it now requires the
    guard's own message.
- [x] Confirm a fresh reader can get the true case count from the guide without running the script
  - **Passed 2026-11-15:** the command `AGENTS.md` § Testing gives prints 97, the number the suite reports.

## Implementation plan

Inline, from the decision above.

## Outcome

- **`.github/workflows/skills-lint-test.sh`:** every case label opens with its check; seven new cases; the tree-guard
  case tightened to require its own message. 97 cases.
- **`AGENTS.md` § Testing:** the count and its drift history replaced by the label convention and the counting
  command; § Comments' table row for the test script notes the one new comment not yet walked by a reader pair.
- **`docs/specs/skill-authoring-rules.md`:** the note that no case pins the 64-character limit removed; restamped.
- **The lint itself is unchanged.**

**Close gate (inline):**
- **Standards:** a change to the test suite only; each new case fails without its branch (AGENTS.md § Testing).
- **Intent:** all criteria met.
- **Correctness:** the mutation run; the suite 97/97, the lint OK.
- **Layer parity, security:** not applicable. **Comments:** one new comment line (the group's origin), a pointer.
- **CI:** local; main is unpushed.
- **Specs:** skill-authoring-rules.

## Progress log

- step 2 — picked; a decision task, in the user's order (after TASK-107)
- step 4 — decided by the user 2026-11-15
- step 5 — labels, seven cases, the AGENTS.md entry
- step 6 — mutation run (one weak case found and tightened); suite and lint green
- step 7 — respecced skill-authoring-rules
- step 8 — closed inline; commit in git log
