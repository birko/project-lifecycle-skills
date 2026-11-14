---
id: TASK-378
parent: STORY-024
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: done
# blocked: <reason> — set by /tasks block, never by hand; status stays as it is; /tasks unblock removes it
priority: P3
# assignee — one of: agent (default), unassigned, human, or an installed agent type's name; ai is read as agent, never written
assignee: agent
picked-by: fix-next
created: 2026-11-14
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [DRILL-269-1]
pr: null
github-issue: null
jira-key: null
---

# `/specs init`'s blessing question and unblessed confirmation print "1 areas"

## Context

Filed 2026-11-14 at TASK-269's close, from its drill (`%LOCALAPPDATA%/Temp/d269`, `report.md` § 7) compared with
d365 (TASK-365's drill, `report.md` line 80). Both runners met `/specs init` through `/adopt-project` on a one-area map.

- **DRILL-269-1.** `skills/specs/verbs/init.md`'s blessing question reads "`<N>` areas over `<M>` tracked files", and
  its unblessed confirmation reads "wrote `<N>` areas **unblessed**". With one area both print `1 areas`. TASK-349 made
  every `/specs` *count line* singular for one (`verify.md` step 4), but these two are a question and a confirmation,
  and neither runner read the rule as covering them. d269 raised it as undecided; d365 printed `` `1` areas `` without
  comment, which is the same output.

## Acceptance criteria

- [x] The blessing question and the unblessed confirmation in `init.md` take the count rule `verify.md` step 4 states
      (singular for exactly 1), by pointing at it rather than restating it
- [x] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- Any other `/specs` output: TASK-349

## Human test plan

- [x] Re-run TASK-269's brief (`%LOCALAPPDATA%/Temp/d269/brief.txt`, on a fresh copy of `d065/adopted` and `skills/` at
      the fix) with a cold runner. Expected: the blessing question reads `1 area`
  - **Passed 2026-11-14**, cold drill `%LOCALAPPDATA%/Temp/d378` (`claude -p --disable-slash-commands`, cwd holding only
    `skill/` at the fix, the d065b brief and a fresh copy of `d065/adopted`; the runner listed no skills). The question
    read "1 area over 13 tracked files", the confirmation "wrote 1 area unblessed", and no count came up undecided.

## Implementation plan

Inline: one sentence under the question pointing at verify's count rule.

## Outcome

**The fix (`skills/specs/verbs/init.md`).** A sentence under the blessing question: `<N> areas` and `<M> tracked files`
take `verify.md` step 4's count rule, singular for exactly 1, in every line the verb prints. It points rather than
restating. The unblessed confirmation is one of those lines.

**Close gate (inline; one skill file plus a restamp):**
- **Standards:** a pointer to the count rule's owner.
- **Intent:** all criteria met.
- **Correctness:** d378.
- **Security, comments:** not applicable.
- **CI:** local lint passes; main is unpushed.
- **Specs:** specs-from-code already states the count rule for every `/specs` count line (TASK-349). Restamped, no
  content change.

## Progress log

- step 2 — picked; ranked above TASK-268 on key 4 (self-containment): one sentence in one file against a 26-file contract audit; neither is silent or security-relevant; STORY-024 already in-progress
- step 3 — re-verified: init.md's blessing question and unblessed confirmation print `<N>` areas with no count rule
- step 5 — fixed in init.md
- step 6 — behavioural: d378 (`1 area` in the question and the confirmation)
- step 7 — specs-from-code restamped, no content change
- step 8 — closed inline; commit in git log
