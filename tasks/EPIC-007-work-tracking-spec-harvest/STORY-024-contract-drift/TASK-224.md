---
id: TASK-224
parent: STORY-024
feature: null
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
findings: [SH-1, SH-7]
pr: null
github-issue: null
jira-key: null
picked-by: fix-next
---

# Two restated lists of verbs have drifted from the verbs

## Context

Found by the work-tracking spec harvest (2026-10-03, EPIC-007). Same root cause twice: a list of verbs written
out by hand, which went wrong the moment a verb was added — the failure AGENTS.md § *Defer to a shared inventory*
names.

- **SH-1 — `--across` refusals.** `tasks/SKILL.md` says "Every other verb rejects it", calls that a blanket rule
  needing no list, and then lists eleven verbs — leaving out `plan`, `init`, `help` and `unblock`. Whether those
  four refuse depends on which half a reader follows.
- **SH-7 — who chains `triage`.** `triage.md` says it is chained by `new, pick, close, import, export,
  migrate`; `block`, `cancel`, `move`, `spawn`, `intake` and `audit --fix` chain it too.

## Acceptance criteria

- [x] The `--across` rule is stated once as a blanket rule — every verb not named as accepting it refuses it — with
      no list that can go stale, and `pick` and `triage`'s own reasons kept
- [x] `triage.md` says it is chained by every verb that changes the tree, without a list, or with one that is
      complete and pointed at rather than restated
- [x] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- Adding a lint check for verb lists

## Human test plan

N/A — prose consistency, checked by reading every verb file against the two rules.

## Implementation plan

Drafted 2026-11-12 by `/fix-next` (no grill: nobody to answer one). Trigger: three acceptance criteria.

1. **SH-1** — `tasks/SKILL.md` § `--across`: drop the list of eleven refusing verbs, and state the rule as a blanket
   rule over every verb not named as accepting, a later verb included. Point at `pick` and `triage`'s own reasons. The
   same paragraph cites AGENTS.md's § *A flag that declares an absent capability*, which a consumer install lacks
   (TASK-271's defect), so state that reason inline while rewriting the sentence.
2. **SH-7** — `triage.md` intro: "chained by every verb that changes the tree", with each verb's own steps saying
   where, and no list.

## Outcome

**The fix.** Two hand-written verb lists had drifted from the verbs:
- **`--across`:** `tasks/SKILL.md` called refusing it a blanket rule, then listed eleven refusing verbs and left out
  `plan`, `init`, `help` and `unblock`. It is now a blanket rule with no list: every verb not named as accepting the
  flag refuses it, including any verb added later. `pick` and `triage` keep their own reasons in their files.
- **Triage chaining:** `triage.md` named six verbs that chain it, while `block`, `cancel`, `move`, `spawn`, `intake`
  and `audit --fix` do too. It now says every verb that changes the tree chains it, each saying where in its own
  steps.

**Step 6 split.** 3 of 3 assertions failed on HEAD's copies and pass on the fix. All are fix-dependent: there is no
list of refusing verbs, no citation of a guide section a consumer lacks, and no list of chaining verbs. Contract pin,
**not evidence**: skills-lint passes on both.

**Judgement calls.**
- **No list at all, rather than a complete one.** The criterion allowed either. A complete list is correct until the
  next verb, which is how both of these went wrong (AGENTS.md § *Defer to a shared inventory*). The blanket rule
  cannot drift, and each verb's own file already says what it does.
- **The `§ A flag that declares an absent capability` citation removed in the same sentence.** Not in the findings,
  but it sat in the sentence being rewritten, and it is exactly TASK-271's defect: an AGENTS.md section cited from a
  shipped skill. Its reason fits in a clause, so it was stated inline.
- **No spec change.** `work-tracking` already states both rules in blanket form.
- **Close gate ran inline** on a ~10-line prose diff.
  - Standards: no finding; the change applies the shared-inventory rule.
  - Intent: both content criteria met, plus the citation above.
  - Correctness: the router's verb table and every verb file were read for another restated list; none.
  - Security: not applicable.
  - Comments: not applicable.

**Flagged, not fixed.** Nothing.

## Progress log

- step 2 — picked; ranked above TASK-236 because both are lists that drifted from what they describe (key 1 wrong results), but `tasks`' `--across` list and `triage`'s chain list sit in the verb set every tree runs, while `roadmap`'s renders are one skill's output model (key 2, reachability). Last run's runner-up. Key 6 did not separate them: both `contract-drift`
- step 3 — verified: held, both. SKILL.md lists eleven refusing verbs, missing `plan`, `init`, `help`, `unblock`; triage.md names six chaining verbs of twelve. Also found in the same sentence: a citation of AGENTS.md § *A flag that declares an absent capability*, which a consumer lacks
- step 3b — planned: drafted inline as `/tasks plan --no-grill` would (trigger: three acceptance criteria)
- step 4 — layer: local
- step 5 — fix in skills/tasks/SKILL.md, skills/tasks/verbs/triage.md
- step 6 — reverted fix (HEAD's copies): 3/3 assertions failed; fix-dependent = all three; contract pins = skills-lint (passes on both)
- step 7 — work-tracking: already states both as blanket rules; unchanged
- step 8 — handed to /tasks close --unattended; outcome in status:, commit in git log
