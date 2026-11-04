---
id: TASK-331
parent: STORY-011
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: done
# blocked: <reason> — set by /tasks block, never by hand; status stays as it is; /tasks unblock removes it
priority: P2
# assignee — one of: agent (default), unassigned, human, or an installed agent type's name; ai is read as agent, never written
assignee: agent
created: 2026-11-04
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [DRILL-318-1, DRILL-318-2, DRILL-318-3]
pr: null
picked-by: fix-next
github-issue: null
jira-key: null
---

# `/tasks new` marks a parent the user named as inferred, and `plan` can cut its own section short

## Context

Found by TASK-318's cold drill (2026-11-04, recorded on TASK-318). Three findings in `skills/tasks/verbs/new.md` and `plan.md`:

- **DRILL-318-1:** the request said "under STORY-001", in words, not as an argument. `new` steps 3 and 4 skip their question only when a caller set the value, so the runner put the parent question, took the no-answer path and wrote "inferred, not chosen: … parent" about a parent the user gave. The record now misstates who chose it.
- **DRILL-318-2:** `plan` step 6 replaces the `## Implementation plan` body with the plan agent's output. That output had `##` headings, which end the section early. The runner demoted them, which nothing licensed.
- **DRILL-318-3:** `new` step 13 and `plan` step 8 each print a confirmation ending "Start work with `/tasks pick`", with no stated order or merge.

## Acceptance criteria

- [x] `new` says whether a value the user stated in the request counts as answered, and the inferred-values line names only fields nobody stated
- [x] `plan` step 6 says what happens to headings in the agent's output at or above the section's level
- [x] When `new` chains `plan`, one confirmation is printed, or the order of the two is stated
- [x] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- The behaviour the originating task fixed, which its drill passed

## Human test plan

- [x] Re-run the originating drill's brief (recorded on that task's Progress log) on a freshly built fixture with a cold runner. Expected: its "left undecided" section no longer lists these findings
  - **Passed 2026-11-04:** a fresh cold runner on the rebuilt `d318` fixture (the TASK-318 brief, verbatim; skill copied after this fix) did not ask for level, title or parent ("Not asked, because the request stated them"), and its mark line named only `priority, assignee, body sections`. The plan sat wholly inside `## Implementation plan` (every heading `###`; the agent followed step 5, so step 6's demotion did not trigger). The run printed one confirmation with one hint, `Start work with /tasks pick TASK-002`. Its "left undecided" section names none of DRILL-318-1…3. Coldness: it listed no skills

## Outcome

**What was fixed.** `/tasks new` now treats a value the person names in the request (an id, a quoted title, a priority or assignee, the level) as answered. It asks nothing about it and does not mark it "inferred, not chosen", so the record no longer says nobody chose a parent somebody named. A value the run picks from the request's subject is still marked. `/tasks plan` demotes the plan agent's headings so a `##` in its output can no longer end `## Implementation plan` early. When `new` chains `plan`, the run prints one confirmation with one next-step hint.

**Step-6 split:** 0/0, because this is prose only and there is nothing executable to revert. Evidence is the Human test plan drill, which passed; the lint is a contract pin, not evidence.

**Judgement calls.**
- **"Stated" is defined literally** (the request names the value itself). A looser "the request makes it clear" would let "fits STORY-001" count as stated and bring inference back unmarked, which is the defect the mark exists to prevent.
- **Three edges are stated:** an unresolvable id counts as not stated; a stated `cancelled` parent is still asked about; a stated `done` parent reopens without the inferred suffix.
- **The bullet covers a person's request only,** so `close --unattended` and `spawn` keep their caller-set basis.
- **Every heading shifts by the same amount** rather than each being raised to `###`, which keeps the plan's own hierarchy. Briefing the agent alone was rejected: the original drill shows it ignored the output shape.
- **Merging the confirmations was chosen over stating an order,** because an order keeps the duplicate hint.

**Found at review and fixed in scope:** deferring `plan`'s lines to `new` step 13 would have dropped them silently for `import`, `decompose` and `spawn`, whose own summaries replace that confirmation and which can chain `plan`. SKILL.md's relay duty now covers them, and `new` step 13 points there.

**Review (close step 5b, inline):** Adherence: every changed ask-step keeps its question and answer-less path, nothing restates a shared list, and each verb file still reads standalone. Fidelity: all four criteria are met. Correctness: the relay gap above was the one finding, and it is fixed.

**Flagged, not fixed:** TASK-340 (P2). The template has no `{{FINDINGS}}` token for `new` to fill, so a literal render writes `findings: []` and the task leaves `/fix-next`'s pool. SKILL.md's N/A wording also differs from the others. The spec line `P1 and ai` was drift left by TASK-120 and is corrected in this respec.

## Implementation plan

### Step 1 — DRILL-318-1: define "stated" once, in `new.md` § Unanswered questions
- New bullet beside "A field a calling verb sets…": **a value the request states is answered, not inferred** — the request names the value itself (an id such as `under STORY-001`, a title in quotes, a priority or assignee by name, the level in words). Write it, ask nothing, mark nothing.
- Same bullet, the counter-case: **a value read off the request's subject is still the fallback and still marked** (choosing the parent whose title fits; a noun phrase the runner composes as a title). The runner chose it, so "never a value that reads as decided" holds.
- Edge rows: a stated id that does not resolve, or is the wrong level, counts as not stated, so put the step's question. A stated `cancelled` parent still gets step 4's cancelled question, because naming it did not choose a reopen. A stated `done` parent reopens without the `(placement inferred …)` suffix.
- The mark names only fields nobody stated and no caller set. Its wording is unchanged, so the verbs that cite it (pick 9, show 4, fix-next, close, spawn 4) need no edit.

### Step 2 — the per-step guards in `new.md`
- Steps 2, 3, 4, 5 and step 8's `{{AFFECTS}}` question: "Unless a caller set it" becomes "Unless a caller set it or the request states it". The question texts and answer-less paths are unchanged.
- Step 2: the level skip covers a level stated in words as well as the argument.
- Step 9 (body sections) is unchanged: drafting is the runner's composition, so it stays marked.

### Step 3 — DRILL-318-2: plan headings (`plan.md` steps 5 and 6)
- Step 5 output shape: only `###` or deeper headings.
- Step 6: when any heading outside a fenced block is at `##` or above, shift every heading by the same number of levels so the shallowest is `###`, capped at `######`, and report `plan headings demoted by N` in step 8. Reason, inline: a `##` line ends the section, so step 3's capture and step 4's guard read a truncated plan, and the rest reads as a new section.

### Step 4 — DRILL-318-3: one confirmation
- `plan.md` step 8: when `new` step 12 chained it, print nothing; hand the lines to `new` step 13. This covers the plan-failure line too.
- `new.md` step 12 says the confirmation is deferred. Step 13 includes plan's lines, and the task hint becomes one `Start work with /tasks pick TASK-NNN`.

### Step 5 — spec and lint
- `docs/specs/work-tracking.md`: Creation questions and the inferred-values mark (stated value unmarked, plus a scenario); Implementation plans (demotion, one confirmation); New work under a closed container (suffix only when inferred).
- `bash .github/workflows/skills-lint.sh`.

### Tradeoffs and risks
- Merging the confirmations beats stating an order, because an order keeps the duplicate hint. Demoting beats only briefing the agent, because agents ignore output-shape rules (the drill shows it).
- Keep "stated" literal, or "fits STORY-001" drifts back into stated. `close --unattended` and `spawn` set values as callers, and the new bullet must not read as covering them. The heading shift skips `#` lines inside fenced blocks.

## Progress log

- step 2 — picked; ranked above TASK-335 because key 1: DRILL-318-2 lets plan step 6 cut `## Implementation plan` short and DRILL-318-1 writes a false "inferred, not chosen" provenance into the task record, both silent corruption of a record, where TASK-335 is a wrong next action (wrong result); keys 3 and 5 tie (both silent, both drill-verified); key 6 agrees (correctness-invariants vs an epic-parented task with no theme)
- step 3 — verified: held. new.md § Unanswered questions exempts only a value a calling verb sets, so a user-stated parent is asked, defaulted and marked (DRILL-318-1); plan.md step 6 replaces the section body with the agent output with no heading rule (DRILL-318-2); new step 12 chains plan, whose step 8 prints its own Start-work hint before new step 13 prints another (DRILL-318-3)
- step 3b — planned: /tasks plan --no-grill (two files, four criteria); no split signal
- step 4 — layer: local
- step 5 — fix in skills/tasks/verbs/new.md (§ Unanswered questions: a stated value is answered; guards in steps 2–5 and 8; step 12 defers plan's confirmation; step 13 carries plan's lines and one hint), skills/tasks/verbs/plan.md (step 5 asks for `###`; step 6 demotes; step 8 prints nothing when chained), skills/tasks/SKILL.md (the relay duty covers plan's lines — found at review: import, decompose and spawn replace new's confirmation and can chain plan, so deferring alone would have dropped those lines); lint OK (20 skills)
- step 6 — reverted fix: 0/0 failed — prose only, nothing executable; fix-dependent = none; contract pins = skills-lint.sh link resolution; evidence = the Human test plan drill
- step 7 — respecced work-tracking; requirements changed: Creation questions and the inferred-values mark (stated values unmarked, +1 scenario; `ai` → `agent`, drift left by TASK-120), Implementation plans (heading demotion, one confirmation or relay, +1 scenario); intended — TASK-331's criteria; New work under a closed container unchanged (its suffix already reads "when the parent was inferred")
- step 8 — handed to /tasks close --unattended; outcome in status:, commit in git log
