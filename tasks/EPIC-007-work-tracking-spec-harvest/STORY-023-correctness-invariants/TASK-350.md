---
id: TASK-350
parent: STORY-023
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: done
# blocked: <reason> — set by /tasks block, never by hand; status stays as it is; /tasks unblock removes it
priority: P2
# assignee — one of: agent (default), unassigned, human, or an installed agent type's name; ai is read as agent, never written
assignee: agent
created: 2026-11-12
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [DRILL-240-1, DRILL-240-2, DRILL-240-3]
pr: null
github-issue: null
jira-key: null
picked-by: fix-next
---

# `/feature decide`'s verdict question has no answer-less path, and nobody commits what `prototype` writes

## Context

Spawned 2026-11-12 from TASK-240's Human test plan drill: one cold run of `/feature prototype FEATURE-001 --skip …` then
`/feature decide FEATURE-001` on an invented fixture (`%LOCALAPPDATA%/Temp/d240`, report kept there as `report.md`).
Raised by one runner. These three are checked against the files, not taken on its word: each is a plain reading of the
text quoted below.

- **DRILL-240-1 — `decide` step 2 asks with no answer-less path.** "For each, drive a verdict via `AskUserQuestion`"
  gives neither the question's words nor what happens when nobody answers, against AGENTS.md's ask-step rule. The
  runner wrote its own question and, with no answer, treated the row as skipped by inference from step 6.
- **DRILL-240-2 — `decide` step 6 contradicts itself when step 5 ran.** Step 6 lists "`status.md` and
  `docs/features/README.md` from step 5" among the files this run wrote, and also says "A run where every verdict was
  skipped wrote nothing and commits nothing". Step 5 chains `/feature status` on every run, so an all-skipped run did
  write those two files.
- **DRILL-240-3 — `prototype` has no commit step.** Every form, and now `--skip`, writes `idea.md`, the ledger and,
  through the status chain, `status.md` and the index. Nothing commits them, and `decide` step 6 refuses files it did
  not write, so they sit dirty with no owner. That is the case AGENTS.md § *With an upstream, a gate's record goes on
  a `record/<ID>` branch* describes for the other feature verbs.

## Acceptance criteria

- [x] `decide` step 2 states its verdict question and what an unanswered row becomes, recorded so it does not read as decided
- [x] `decide` step 6 says what an all-skipped run commits when step 5 rewrote the rollup and the index
- [x] `prototype` commits what it wrote, in the shape the other feature verbs use (`chore: …` subject, a record branch with an upstream), or states why it does not and who does
- [x] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- The `--skip` path and the prototype line's writers — TASK-240

## Human test plan

- [x] Re-run TASK-240's brief on a fresh copy of its fixture (recipe on TASK-240) with a cold runner. Expected: `decide`'s question is the stated one, the run reports D1 as unanswered, and `git status` is clean or names each file left with the reason
  - **Passed 2026-11-12:** fresh fixture `%LOCALAPPDATA%/Temp/d350`, a clone of TASK-240's committed fixture (`d240/repo`, commit `31cd785 fixture`, origin removed; `d240` left untouched), with `feature`, `roadmap` and `tasks` copied from this fix and TASK-240's `brief.txt` unchanged. Runner `claude -p --disable-slash-commands --permission-mode acceptEdits --allowedTools "Bash(git:*)" "Bash(cd:*)" "Bash(ls:*)" Read Glob Grep Edit Write < brief.txt`, cwd the fixture root. **Result:** `decide` put the stated question verbatim (`D1 — "Quote every field, RFC 4180" (proposed). Verdict: …`), and with no answer left D1 untouched, wrote no History line, skipped the rollup, committed nothing and printed `D1 unanswered — still proposed`. The prototype's writes were committed as `92cf253 chore: prototype FEATURE-001`, and `git status --porcelain` was empty at the end. Coldness: no skills listed. **It also found four gaps in the new text, all fixed before close:** `git commit --only` refuses the untracked `status.md` (the runner improvised a `git add`), step 4e gave no upstream test, a `--skip` run never named its commit, and `decide` step 7 printed nothing for a run that wrote nothing. The `--only` gap also sat in `decide` and `review`, so both were fixed

## Implementation plan

Drafted 2026-11-12 by `/fix-next` (no grill: nobody to answer one). Triggers: three files, four criteria.

1. **DRILL-240-1** — `decide` step 2 states the verdict question. With no answer, the row is left exactly as it was
   (`proposed` already means nobody decided), with no History line, and step 7 names it `D<n> unanswered — still
   <state>`.
2. **DRILL-240-2** — step 5 runs only when step 4 changed something, so an all-unanswered run writes nothing and step
   6's "commits nothing" becomes true.
3. **DRILL-240-3** — `prototype` gains step 4e: commit exactly what it wrote as `chore: prototype FEATURE-NNN`, on
   `record/FEATURE-NNN` with an upstream (the branch `decide` and `review` share, so the three never race). The
   `--skip` path runs it too.
4. Register the new subject and the record-branch site in AGENTS.md § Conventions (register-on-introduce).
5. Respec `feature-lifecycle`.

## Outcome

**The fix.**
- **Verdict question:** `/feature decide` asked for verdicts with no worded question and no rule for silence, so a run
  nobody answered settled the row by inference. It now states the question, and an unanswered row stays exactly as it
  was, named in the confirmation as `D<n> unanswered — still <state>`.
- **Step 5 and 6 clash:** `decide`'s step 5 rollup ran even when nothing changed, which contradicted step 6's
  "commits nothing". It now runs only when a row changed.
- **Prototype commits:** `/feature prototype` committed nothing, leaving its artifact and recorded line dirty with no
  owner. It now commits its own writes as `chore: prototype FEATURE-NNN`, on the shared `record/FEATURE-NNN` branch
  when there is an upstream.
- **Untracked files:** `decide`, `prototype` and `review` now `git add` a file git does not track yet before
  `git commit --only`, which refuses one.

**Step 6 split.** 4 of 4 assertions failed on HEAD's copies and pass on the fix, all fix-dependent: the worded
question, the unanswered-row line, no step 5/6 clash, and `prototype` committing. Contract pin, **not evidence**:
skills-lint passes on both. The four gaps fixed after the drill (the `git add`, the upstream test, the skip run naming
its commit, the nothing-to-commit line) were found by the drill, and are its evidence.

**Judgement calls.**
- **An unanswered row stays as it was, unmarked.** `proposed` is already the "nobody has decided" value, so no marker
  is needed for it to read as undecided. The ask-step rule's alternative, a fallback plus a note, applies to a field
  that cannot be left in its undetermined state, which this one can.
- **`prototype` uses `record/FEATURE-NNN`, the branch `decide` and `review` use**, rather than a branch of its own.
  All three write `decisions.md`, and sharing the name is what makes the record-branch rule stop the second writer
  until the first lands.
- **The `git add` fix applied to `review` too**, not only the two verbs in the findings. Same root cause, one line, and
  `tasks` `close`'s record-branch text already names "a first review's `status.md`" as a file `commit --only` refuses.
  `tasks` `pick` and `close` already stage first.
- **AGENTS.md updated** (register-on-introduce): the record-branch convention names `/feature prototype`, and the
  commit-subject list gains `chore: prototype FEATURE-NNN`. Its count now reads nine.
- **Spec** `feature-lifecycle`: decide's verdict requirement (stated question; an unanswered row is left and named),
  decide's commit requirement (a run that changed no row skips the rollup and commits nothing), and prototype's outcome
  requirement (it commits its own writes). Restamped. `shaped-by` unchanged: the only intervening `skills/feature`
  commit (5746d7d, TASK-240) is not feature-linked and respecced this area itself.
- **Close gate ran inline** on a ~50-line prose diff.
  - Standards: the new ask-step has its question and answer-less path; register-on-introduce satisfied in AGENTS.md.
  - Intent: all three content criteria met, plus the `review` line.
  - Correctness: the four drill-found gaps, fixed.
  - Security: not applicable.
  - Comments: not applicable.

**Flagged, not fixed.** The drill's single-feature `status` readings (timestamp, divergences, empty-task wording, next
step) were already filed as TASK-351.

## Progress log

- step 2 — picked; ranked above TASK-264 and the STORY-024 harvest tasks because `decide`'s verdict question has no answer-less path, so an unattended or unanswered run settles a stakeholder decision by inference (key 1: a verdict nobody gave reads as one; key 3: silent), and `prototype`'s writes sit uncommitted with no owner. `decide` is the approval gate every feature passes. Key 6: `correctness-invariants` sorts above the remaining `contract-drift` pool too
- step 3 — verified: held, all three. `decide` step 2 "drive a verdict via `AskUserQuestion`" with no question text or answer-less path; step 6 lists step 5's files yet says an all-skipped run "wrote nothing"; `prototype` has no commit step
- step 3b — planned: drafted inline as `/tasks plan --no-grill` would (triggers: three files, four criteria)
- step 4 — layer: local
- step 5 — fix in skills/feature/verbs/decide.md (worded question, unanswered row left and named, step 5 conditional, nothing-to-commit line, `git add` before `--only`), prototype.md (step 4e commit with upstream test and `git add`; 4d names its commit; step 5 names the commit), review.md (`git add` before `--only`), AGENTS.md (record-branch site, commit subject, count)
- step 6 — reverted fix (HEAD's copies): 4/4 assertions failed; fix-dependent = all four; contract pins = skills-lint (passes on both); the four drill-found gaps' evidence is the drill
- step 7 — respecced feature-lifecycle (surgical); requirements changed: decide verdicts (stated question; unanswered left and named), decide commit (no change ⇒ no rollup, no commit), prototype outcome (commits its writes); intended — TASK-350's criteria. shaped-by unchanged: intervening 5746d7d (TASK-240) is feature: null and respecced this area itself
- step 8 — handed to /tasks close --unattended; outcome in status:, commit in git log
