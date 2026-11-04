---
id: TASK-323
parent: EPIC-003
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: verify
# blocked: <reason> — add this line while the task is blocked, keeping its status; /tasks unblock removes it
priority: P3
assignee: agent
picked-by: fix-next
created: 2026-10-14
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [CR-322-3]
pr: null
github-issue: null
jira-key: null
---

# A feature parked at `review` drops out of "verification debt first" while a new row waits to be decomposed

## Context

Found by TASK-322's close review (2026-10-14). Since TASK-322, `skills/feature/verbs/status.md` § *Compute the phase* rule 2 makes any feature with an undecomposed `approved`/`changed` row read `building`, whatever is stored. That is right for an unbuilt change. But `/feature review` step 5 can park a feature at stored `review` with tasks at `verify`, and Gate C's "stakeholder requests changes" path then adds a row through `decide`. Until that row is decomposed and built, the feature reads `building`: the listing orders it after `review`-phase features (`skills/feature/SKILL.md` § verification debt first), and `pick`'s gate E stays silent. `pick` step 5 still surfaces the `verify` tasks at hand-off, but only after decompose.

Undecided: should outstanding `verify` sign-off on such a feature still lead the listing (and if so, by which rule), or is `building` the honest headline because the stakeholder asked for more work?

**Decided 2026-11-04 by the user** (asked with three options: this one; leave `building` to sort with other building features; keep `review` until signed off): **the phase stays `building`, and "verification debt first" keys on tasks, not on phase.** A feature with any linked task awaiting sign-off leads the listing whatever its phase, and its line names the count (`building · N tasks awaiting sign-off`). Keeping `review` was rejected because it re-creates what rule 2 fixed, a label claiming an unbuilt change is built. Leaving it as is was rejected because the waiting tests would only surface after decompose.

## Acceptance criteria

- [x] The rule for a feature that has both `verify` tasks awaiting sign-off and an undecomposed row is written down in `status.md` (or `SKILL.md`'s ordering rule), with the reason
- [x] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- The unbuilt-change case itself (TASK-322)

## Human test plan

- [ ] On a fixture feature stored at `review` with one task at `verify` and one new `approved` row with no tasks, run `/feature` (bare listing) and `/feature pick`. Check the ordering and offers match the rule written.
  - **Failed 2026-11-04:** the ordering matched; the offer did not, because two rules give different next actions → TASK-335.

## Outcome

**What was fixed.** A feature parked at `review` with tasks awaiting sign-off reads `building` as soon as a stakeholder's new change waits to be decomposed (status.md rule 2, which is correct). Because the "verification debt first" ordering keyed on phase alone, the feature then dropped out of the lead, and its waiting tests stopped heading every listing. **The user decided 2026-11-04** (recorded in Context with the two rejected options): the phase stays `building`, and debt keys on tasks as well as phase.

- **Owner rule:** `skills/feature/SKILL.md` § *Verification debt surfaces first*. A debt feature is one in phase `review`, or one with any linked task awaiting sign-off whatever its phase. Debt features lead every listing, with phase order inside the group, and the line names the count (`building · 2 tasks awaiting sign-off`). The reason and the rejected options are inline.
- **Pointers, each with a one-line gloss so the file reads standalone:** `status.md` (rule-2 bullet, step-6 digest and its example, step-7 index note), `pick.md` step 1 (and a new example line), `roadmap/SKILL.md` (full render item 1; the compact slice's `⚠ sign-off <n>`, kept outside the phase buckets so they still sum to `<F>`), and the index template's debt note.
- **Unchanged:** rule 2, gates D and E (E is still phase-based, so it still never fires beside D), and `show.md`.

**Step-6 split: 0/0.** The change is prose only. `skills-lint.sh` passes (20 skills): a contract pin, not evidence. The Human test plan's fixture run is the evidence and has not been run.

**Judgement calls.**
- **Phase `review` stays in the debt set** (raised by the plan, within the decision). Keying on tasks *only* would drop a phase-`review` feature whose tasks are all `done` but whose own sign-off is still owed, which is a new form of this same bug. So the rule widens the old set rather than replacing it.
- **The compact slice's count sits outside the buckets.** A debt feature can be in `building`, so counting it as a bucket would break the invariant that every feature lands in exactly one bucket.

**Respec.** `feature-lifecycle`, *Verification debt is listed first*: the new set and the count, plus one scenario (the TASK-323 shape). `project-roadmap`: *Full render with verification debt first* and *Compact slice for the task snapshot* restated for the new set. The `shaped-by` fields were carried forward, not re-derived.

**Flagged, not fixed.** None.

## Implementation plan

_Drafted 2026-11-04 by the Plan agent (`/fix-next` step 3b, `/tasks plan --no-grill`)._

**Debt set** = a feature in phase `review` **or** with ≥1 linked task awaiting sign-off (`verify`, or the older `review`), whatever its phase. Keying on tasks *only* would drop a phase-`review` feature whose tasks are all `done` but whose feature-level sign-off is still owed, which is a new form of this same bug. So this widens the old rule rather than replacing it.

1. `skills/feature/SKILL.md` § *Verification debt surfaces first*: rewrite it as the single owning rule. Debt features lead every listing (phase order within the group). A nonzero count is named on the line (`building · 2 tasks awaiting sign-off`). State the reason inline and keep "never headline all shipped", widened to the new set. Touch the Collection-pass note on the `review` bucket.
2. `skills/feature/verbs/status.md`: the rule-2 bullet's last sentence points at the SKILL.md rule (rule 2 unchanged). Step 6's digest order points at the rule and its example shows the count. Step 7's debt note uses the debt set.
3. `skills/feature/verbs/pick.md` step 1: point at the rule, with a short gloss and an example line. Gates D and E are unchanged.
4. `skills/roadmap/SKILL.md`: full render item 1 leads with the debt set and shows the count; the compact slice gets a debt count kept outside the phase buckets, so the buckets still sum to `<F>`.
5. `skills/feature/templates/README.md.tmpl`: the debt note's trigger is the debt set, and each id is allowed `(N tasks)`.
6. Don't touch `show.md`, `fix-next`, or `tasks/verbs/pick.md`. Regenerate the `feature-lifecycle` and `project-roadmap` specs.
7. Lint, then the Human test plan fixture.

## Progress log

- step 2 — picked at the user's request, once the open decision was answered (it had lost on key 4 three times while undecided)
- step 3 — verified: held. status.md rule 2 makes the feature `building`; feature/SKILL.md § Verification debt surfaces first orders by phase-`review` only, so its `verify` tasks drop out of the lead. Decision recorded in Context
- step 3b — planned: /tasks plan --no-grill (more than one file)
- step 4 — layer: local (skills/feature, skills/roadmap)
- step 5 — fix in skills/feature/SKILL.md, skills/feature/verbs/status.md, skills/feature/verbs/pick.md, skills/roadmap/SKILL.md, skills/feature/templates/README.md.tmpl; tests: skills-lint.sh (20 skills) green
- step 6 — reverted fix: 0/0 failed — prose only; fix-dependent = none; contract pins = skills-lint.sh; evidence = the Human test plan fixture run, not run
- step 7 — respecced feature-lifecycle, project-roadmap; requirements changed: Verification debt is listed first (+1 scenario), Full render with verification debt first, Compact slice for the task snapshot; intended anyway — TASK-323's criteria and the user's recorded decision, answered by /fix-next; shaped-by carried forward, not re-derived
- step 8 — handed to /tasks close --unattended; outcome in status:, commit in git log
- 2026-11-04 — **Human test plan — cold drill, failed.** Fixture: FEATURE-001 with `idea.md` `status: review`, D1 `approved` → TASK-001 at `verify`, D2 `approved` with no tasks; FEATURE-002 building with one in-progress task; FEATURE-003 at idea with a proposed row; skills `feature`, `tasks`, `roadmap`. **Fixture flaw:** FEATURE-001's hand-written `status.md` said `**Phase:** review` where `/feature status` rule 2 derives `building`. Runner: `claude -p --disable-slash-commands --permission-mode acceptEdits --allowedTools "Bash(git:*)" "Bash(cd:*)" "Bash(ls:*)" Read Glob Grep Edit Write < brief.txt`, cwd `%LOCALAPPDATA%\Temp\d323`, which holds the committed fixture `repo/` and copies of the named skill folders under `skill/`. The brief said it was a drill, barred history and planning docs, said to write any question verbatim and continue unanswered, and asked for the output, the questions, what was left undecided, what was settled, what was inferred, what it read unsent, and its skill list. It stated no expected outcome. Task-specific ask: "Run bare /feature, then /feature pick FEATURE-001 (stop at the hand-off; do not run the next verb). For the listing, quote the sentence that placed each feature where it is." **Coldness:** it listed no skills. **Result:** **ordering matched:** FEATURE-001 led the listing, quoting the debt rule (phase `review` or a linked task awaiting sign-off), with `1 task awaiting sign-off` on its line. **Offers did not:** `pick` reached gate D and gave `/feature decompose` as the single next action without mentioning TASK-001's pending sign-off. § *Verification debt surfaces first* says any "what's next?" answer states the pending sign-off as the next action first, while SKILL.md's pick summary says decompose "outranks sign-off" and gate E never fires beside D; the runner named both and could not reconcile them. Its listing also showed the phase `review` (read off the stale `status.md`, as roadmap step 5 says to) while `pick` derived `building`, and no rule flags the two disagreeing. Also: → TASK-335. Stays at `verify` until TASK-335 lands and a re-run on a corrected fixture passes.
