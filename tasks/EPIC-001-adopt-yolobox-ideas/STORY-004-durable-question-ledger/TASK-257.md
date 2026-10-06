---
id: TASK-257
parent: STORY-004
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: done
# blocked: <reason> — add this line while the task is blocked, keeping its status; /tasks unblock removes it
priority: P2
assignee: agent
created: 2026-10-04
depends-on: [TASK-115]
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: []
pr: null
github-issue: null
jira-key: null
---

# Two sessions never answer the same open question — `claimed-by`

## Context

**Cut out 2026-10-04 by TASK-195** under `skills/tasks/slicing.md`, from criteria that used to sit on
TASK-114 (the column and its claim rules) and TASK-115 / TASK-116 (claiming on resume). Separated because
a reviewer could approve resuming at the frontier and reject the claim policy (spawn's scope test,
turned around), and because the resume path is verifiable without it. **Edge:** this task *extends* the
shape TASK-115 defines (a sixth column), so TASK-115 `blocks` it.

The story's sixth column: `claimed-by` stops two parallel sessions answering the same question. It is the
same problem the pushed task branch solves for tasks in FEATURE-001 (D25): *taken* must be visible to
another session, and a claim must be able to end.

## Acceptance criteria

- [x] The question table in `skills/feature/templates/idea.md` gains its sixth column, `claimed-by`. (This is the
      part of TASK-114's six-column criterion split off at the re-cut; the other five columns are TASK-115's.)
- [x] `claimed-by` states what claims it, when a claim is released, and what a reader does with a stale
      claim — a claim that cannot expire is a deadlock *(from TASK-114)*
- [x] Resuming marks the question `claimed-by` per the shape, and releases the claim when the session
      ends or the question resolves *(from TASK-116)*
- [x] Nothing restates TASK-115's states or frontier query
- [x] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- The table's other five columns, `/feature new` writing it and `/feature pick` resuming — TASK-115.
- Reconciling older `idea.md` files — TASK-114.

## Human test plan

- [x] Resume the same feature in two sessions at once. Expected: the second sees the first's claim on the
      question it is working and offers a different one. Then abandon the first session without resolving
      its question, and confirm a later session can tell the claim is stale and proceed as the rules say.

## Implementation plan

Planned inline at pick (2026-10-06).

1. **`questions.md`:** a sixth column `claimed-by`, holding `—` or `<name> on <YYYY-MM-DD>` (name from `git config user.name`, else `unnamed session`). Claim rules: who claims (the step that puts the question), release (resolve or drop clears it; stopping releases this session's own claims), stale (dated before today: may be taken over, saying so). A five-column table reads as all `—` (read side accepts both; writers write six). The current-table header check matches on its first five columns, so it holds. The limit is stated: a claim is visible to sessions reading the same file, and across clones only once committed.
2. **Template, `new.md`, the upgrade procedure:** write the sixth column (`—`).
3. **`pick.md` step 3b:** never offer a question claimed by someone else unless the claim is stale; claim each question just before putting it; release on stop.
4. Spec (`feature-lifecycle`), lint.
5. Drill on a fixture with a live claim and a stale one.

## Progress log

- 2026-10-06 — Picked; planned inline. `questions.md` gains the sixth column and § *Claims*:
  - **Who claims:** the step that puts the question writes `<name> on <date>`, the name from `git config user.name` or `unnamed session`.
  - **Release:** resolving or dropping clears the claim with the state change; stopping clears every claim this session wrote, and no others.
  - **Stale:** a claim dated before today may be taken over, saying so.
  - **Live:** a claim from today is on the frontier but is not offered, and is reported.
  - **The limit, stated:** a claim is a courtesy across clones, not a lock.
  - A five-column table reads as unclaimed, and the current-table header check accepts either width.

  The template, `new.md` (rows written `—`) and the upgrade procedure (every row `—`) write the column. `pick.md` step 3b leaves out live claims, offers stale ones with a takeover line, claims each question just before putting it, releases on resolve, drop or stop, and does not offer at all when every frontier question is held by someone else.
- 2026-10-06 — **Spec:** `feature-lifecycle`'s table requirement carries the column and the claim rules, plus a scenario (a live claim skipped, a stale one taken over). Re-stamped at `d97f2f9`.
- 2026-10-06 — **Human test plan — passed.** The two sessions are staged in the fixture rather than run concurrently: a `-p` runner cannot hold a session open while another starts. A live claim from "today" stands in for the first session, and one from two days ago for the abandoned session. Folder `%LOCALAPPDATA%\Temp\d257`, outside every repo, with a copy of `skills/` and a git fixture whose `user.name` is Carol. FEATURE-001's frontier is Q4 (`Alice on 2026-10-06`), Q6 (`Bob on 2026-10-04`) and Q7 (unclaimed); Q5 waits on Q4. Runner: `claude -p --disable-slash-commands --permission-mode acceptEdits`, told today is 2026-10-06, with Carol answering Y, then one answer, then silence. Expected results were written down first. **Cold:** it listed no skills.
  - It printed `Q4 is being answered by Alice (claimed today)` and `taking over Q6 — claimed by Bob on 2026-10-04`.
  - The offer named Q6 and Q7 only.
  - It claimed Q6 as Carol, put it, recorded the answer as `resolved → D2` (new `proposed` row) and cleared the claim.
  - It claimed Q7, and on silence "cleared the one claim this session still held (Q7). Alice's claim on Q4 is untouched."
  - The final table matches the expectation exactly.
- 2026-10-06 — Close review. Intent: all five criteria and the test plan. Correctness: prose only; the drill shows each rule. Conventions: the rules live in one owner file; the read side accepts the old width, and writers write the new one. → **done**.
