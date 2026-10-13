---
id: TASK-310
parent: EPIC-003
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: done
# blocked: <reason> — add this line while the task is blocked, keeping its status; /tasks unblock removes it
priority: P3
assignee: agent
created: 2026-10-13
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [CR-309-1, CR-309-2]
pr: null
github-issue: null
jira-key: null
---

# `/tasks new`'s `affects:` question has no answer-less path, and nothing reads the "inferred, not chosen" mark

## Context

Grouped: two follow-ups the correctness pass raised at TASK-309's close (2026-10-13), both about how
`skills/tasks/verbs/new.md` handles a field nobody answered.

- **CR-309-1.** Step 8's `{{AFFECTS}}` says "ask the user which sub-projects it affects" with no question
  text and no answer-less path, the one ask left in `new.md` outside AGENTS.md § Output/prose rules. An
  empty `affects: []` written unasked reads as "affects nothing". TASK-309 drafted a fix and reverted it as
  outside its criteria.
- **CR-309-2.** TASK-309 added the mark `> Filed with nobody to answer — inferred, not chosen: <fields>.`
  under a new file's heading. Nothing reads it: `triage`, `pick`, `close` and `audit` never surface it, so a
  task with an inferred parent or priority can be ranked, picked and closed with the mark still there, and
  "whoever confirms deletes the line" has no verb to prompt it.

## Acceptance criteria

- [x] Step 8's `affects:` question is stated verbatim, with an answer-less path that does not read as decided
- [x] At least one reader surfaces a file carrying the mark (for example `pick` prints it, or `triage`/`audit` lists it)
- [x] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- The questions TASK-309 covered
- `/fix-next` and epic/story readers of the mark — TASK-311 (CR-310-1, CR-310-2)
- `pick` step 6's stale-plan offer wording — TASK-312 (DRILL-310-1)

## Human test plan

- [x] A cold runner creates an epic in an aggregator repo with nobody to answer, then picks a task that
      carries the mark. Expected: `affects` is marked, not silently `[]`, and the pick shows the mark.
  - **Passed 2026-10-13:** the epic got `affects: []` with `> Filed with nobody to answer — inferred, not
    chosen: title, affects.`; the step 8 question was quoted verbatim; the pick printed
    `⚠ TASK-004 was filed with nobody to answer — parent, priority, assignee inferred, not chosen. …`

## Implementation plan

Drafted inline at pick.

1. `new.md` step 8 `{{AFFECTS}}`: the question verbatim; unanswered, write `[]` and mark `affects`
   (§ *Unanswered questions*), since the template always renders the line and a bare `[]` reads as
   "affects nothing". The § *Edge cases* bullet points at step 8 instead of restating the ask.
2. `pick.md` step 9: before handing off, print the mark line when the task file carries one, with what
   to do about it. A print, not a question, so it adds no ask-step.
3. `new.md` § *Unanswered questions*: name `pick` as the reader, so the mark's "whoever confirms deletes
   the line" has a verb behind it.
4. Lint.

## Outcome

**The fix.** `new.md` step 8's `{{AFFECTS}}` puts a stated question; unanswered, it writes `[]` and marks
`affects`, and the § *Edge cases* bullet points there. `pick.md` step 9 prints the mark before the work
brief, as a statement, not a question.

**Drill.** The TASK-308 fixture reset, plus a `CLAUDE.md` declaring it an aggregator of `billing`,
`portal`, `reporting`, and a TASK-004 carrying a mark. Same runner command as TASK-308 (cwd the fixture,
`--disable-slash-commands`, brief on stdin). The brief asked for an epic ("unified logging across the
platform") and a pick of TASK-004 with nobody to answer, and did not mention the mark or `affects`.
**Coldness check:** no skills listed.

**Review passes.**
- Standards: pass. Fidelity: pass, no scope creep.
- Correctness: 4 findings. Fixed: `new.md` said `pick` re-prints the mark "when the task is picked", which
  `/fix-next` does not do (now "with `/tasks pick`"); the `affects` question lacked the caller lead-in.
  Accepted: "inferred" also names a fallback such as `[]`, since either way nobody chose it. Spawned as
  TASK-311: `/fix-next` and epic/story readers never surface the mark.
- Security, comments: not applicable.

**From the drill.** `pick` step 6's stale-plan offer has no fixed wording; spawned as TASK-312.
