---
id: TASK-335
parent: EPIC-003
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
findings: [DRILL-323-1, DRILL-323-2]
pr: null
picked-by: fix-next
github-issue: null
jira-key: null
---

# `/feature pick` names decompose as the next action while a sign-off waits, against the debt rule

## Context

Found by TASK-323's cold drill (2026-11-04), which **failed** on it and stays at `verify` until this lands. Recorded on TASK-323.

- **DRILL-323-1:** `skills/feature/SKILL.md` § *Verification debt surfaces first* says any "what's next?" answer states the pending sign-off as the next action first. The same file's `pick` summary says approved rows with no tasks go to `decompose`, which "outranks sign-off", and `verbs/pick.md` gate E never fires beside D. On a feature with a task at `verify` and a new undecomposed row, the runner gave decompose as the single next action and never mentioned the waiting sign-off. Both rules are stated; nothing says which wins, or that step 6 can name both.
- **DRILL-323-2:** bare `/feature` reads the phase off `status.md` (roadmap step 5: renderers do not re-derive), while `pick` derives it by `status.md` rule 2. A `status.md` written before a new row was decided shows `review` in the listing and `building` in `pick`, and no rule flags the disagreement. (The drill's fixture had such a stale file by hand, so this half is partly a fixture artefact. But `/feature decide` adding a row after the last status run produces the same state.)

**Rescoped 2026-11-04 (fix-next step 3).** Every verb that changes a phase input (`decide`, `decompose`, `review`, and `close`'s feature rollup) re-runs `/feature status`, so a stored phase disagreeing with the derived one comes only from a hand edit or a skipped write path. The drill's fixture had one by hand. Making the listing re-derive would contradict roadmap step 5 ("renderers do not re-derive") to cover a case the writers already prevent. `pick` already reads `status.md` (step 2) and derives the phase (step 3), so it is the one place that sees both and can report the gap.

## Acceptance criteria

- [x] `pick` step 6's next action on a debt feature with undecomposed rows is stated once, and agrees with § *Verification debt surfaces first*: either it names the pending sign-off too, or the debt rule says where pick is the exception and why
- [x] `/feature pick`, which reads the stored phase and derives its own, reports a disagreement between them with the command that refreshes it (rescoped at step 3: see the Context note)
- [x] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- The behaviour the originating task fixed, which its drill passed

## Human test plan

- [x] Re-run TASK-323's drill brief (on its Progress log) on the same fixture shape with a `status.md` that `/feature status` would write. Expected: the listing leads with FEATURE-001 labelled `building · 1 task awaiting sign-off`, and `pick`'s confirmation names the pending sign-off as well as the decompose offer. Then re-run TASK-323's plan step and close it
  - **Passed 2026-11-04 (re-run):** fixture `%LOCALAPPDATA%/Temp/d323` rebuilt with FEATURE-001's `status.md` reading `building`, as `/feature status` writes it (the first run's hand-written `review` was the fixture flaw), with `feature`, `tasks` and `roadmap` copied after TASK-335's fix. Runner `claude -p --disable-slash-commands --permission-mode acceptEdits --allowedTools "Bash(git:*)" "Bash(cd:*)" "Bash(ls:*)" Read Glob Grep Edit Write < brief.txt`, the TASK-323 brief verbatim. Result: the listing led with `FEATURE-001  Export data   building · 1 task awaiting sign-off`, quoting the debt rule; `/feature pick FEATURE-001` reached gate D, took its no-answer path and printed `Next: sign off TASK-001 (run its human test plan, then /tasks close TASK-001), then decompose D2`; no stale-phase line, correctly, since both phases read `building`. Coldness: it listed no skills

## Outcome

**What was fixed.** `/feature pick` gave "decompose" as the single next action on a feature whose tasks were waiting for sign-off, and never mentioned the sign-off. It contradicted the rule that debt is named first. Step 6 now states the next action once: the tasks awaiting sign-off first, then the fired gate's offer. The skill's summary now says decompose outranks `/feature review` (the feature-level sign-off), never a task's. When the stored `status.md` phase differs from the derived one, `pick` also reports it, with `/feature status FEATURE-NNN` as the refresh, and writes nothing.

**Step-6 split:** 0/0, because this is prose only. Evidence is the drill, which passed; the lint is a contract pin.

**Judgement calls.** Naming both actions keeps one rule, the user's TASK-323 decision. Making `pick` a stated exception to the debt rule was rejected: it would keep two orders for one question. Criterion 2 was rescoped at step 3 (see Context) from "the listing re-derives or reports" to "pick reports". Every writer re-runs `/feature status`, and re-deriving in the listing would break roadmap step 5's "renderers do not re-derive".

**Review (close step 5b, inline).** Adherence: the debt definition is linked, not restated, and no ask-step was added. Fidelity: all three criteria are met. Correctness: gate E's "never fires beside D" still holds; the change is to the confirmation only.

**Flagged, not fixed.** The bare listing still shows a stored phase it does not check. The drill's FEATURE-003 read `idea` where the rules derive `deciding`; that was a hand-written fixture file again. Only `pick` reports the gap, by this task's rescope. The runner's open-questions and gate-D wording points are TASK-336.

## Implementation plan

### Approach
- Criterion 1 takes its first branch: step 6 names the pending sign-off too, so `pick` is not an exception to the debt rule. That rule is the user's decision on TASK-323, and this task's test plan expects both in the confirmation. "Outranks" narrows to gate E, `/feature review`, the only sign-off gate D displaces (status.md rule 2).
- Criterion 2 is a report line only: there is no new question, and nothing re-derives in the listing, so roadmap step 5 still holds.

### Steps
1. `feature/SKILL.md`, the `pick` summary: "it outranks `/feature review`, the feature-level sign-off, but tasks already awaiting sign-off are still named first, per pick step 6". § *Verification debt* is untouched.
2. `pick.md` step 6: the next action is stated once. On a debt feature it names the tasks awaiting sign-off first and the fired gate's offer second, with an example line, and says why decompose never outranks a task's sign-off.
3. `pick.md` step 6: when `status.md`'s Phase differs from the derived phase, report `status.md says <stored>, derived <phase> — refresh with /feature status FEATURE-NNN`, compared after any chained verb, and write nothing. Step 2 notes that the Phase line is read for this.
4. `feature-lifecycle` spec, *Pick enters a feature at the stage that unblocks it*: the SHALL gains both rules, plus two scenarios. *Verification debt is listed first* is unchanged.
5. Lint, then the test plan: TASK-323's brief on a fixture whose `status.md` is what `/feature status` writes.

### Risks
- Restating the debt definition in pick.md would break "defer to a shared inventory", so step 6 links to the § instead.
- Gate E's "lead with this" still never fires beside D, so it is left alone.

## Progress log

- step 2 — picked; ranked above TASK-336 because key 1: a next action that omits a waiting sign-off is a plausible wrong answer that hides verification debt, where TASK-336 is a gate reading of a missing section that both runners resolved the same way; keys 3 and 5 tie (silent, drill-verified); key 7 P2 vs P3. It also holds TASK-323 at verify
- step 3 — verified: DRILL-323-1 held (pick step 6 asks for "the single concrete next action"; SKILL.md says decompose "outranks sign-off"; § Verification debt says the sign-off comes first). DRILL-323-2 rescoped: decide, decompose, review and close all chain /feature status, so the mismatch needs a hand edit; criterion 2 now has pick report it, since pick reads both values
- step 3b — planned: /tasks plan --no-grill (two skill files plus the spec); no split signal
- step 4 — layer: local
- step 5 — fix in skills/feature/SKILL.md (decompose outranks /feature review, never a task's sign-off) and skills/feature/verbs/pick.md (step 6 names the sign-off first and the gate's offer second; reports a stale status.md phase; step 2 reads the Phase line for it); lint OK (20 skills)
- step 6 — reverted fix: 0/0 failed — prose only; fix-dependent = none; contract pins = skills-lint.sh; evidence = the Human test plan drill
- step 7 — respecced feature-lifecycle; requirements changed: Pick enters a feature at the stage that unblocks it (+2 scenarios: sign-off named before the decompose offer; stale rollup reported, not rewritten); intended — TASK-335's criteria; Verification debt is listed first unchanged
- step 8 — handed to /tasks close --unattended; outcome in status:, commit in git log
