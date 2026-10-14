---
id: TASK-322
parent: EPIC-003
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: done
# blocked: <reason> — add this line while the task is blocked, keeping its status; /tasks unblock removes it
priority: P2
assignee: agent
picked-by: fix-next
created: 2026-10-14
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [FIELD-018]
pr: null
github-issue: null
jira-key: null
---

# A signed-off feature with an unbuilt `changed` decision reads phase `review`, as if built

## Context

Found by TASK-319's post-fix drill (2026-10-14). Since TASK-319, a `changed` decision whose change is not built yet sets `idea.md` `done → review`, leaves the old task `done`, and empties the row's task column so the change gets decomposed. `skills/feature/verbs/status.md` § *Compute the phase* rule 1 then mirrors the stored `review`, and rule 2 would say `review` anyway, since every linked task is `done`. But `review` means built and awaiting sign-off, and the change is not built. Consequences: the rollup tells stakeholders the work awaits sign-off, and `/feature pick` meets gate D (decompose) and gate E (review, "lead with this") at once. The runner resolved that by gate order and said the text reads both ways.

## Acceptance criteria

- [x] A feature with an `approved`/`changed` row whose task column is empty never derives phase `review`, whatever its stored status or its other tasks
- [x] `decide.md`'s unbuilt case sets the stored status to whatever makes the phase say the work is not built, and says why
- [x] `/feature pick` cannot meet gates D and E at once for such a feature
- [x] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- The built case, which is correctly `review`

## Human test plan

- [x] On a no-upstream fixture, record a `changed` decision on a `done` feature whose change is not built, then run `/feature status FEATURE-001` and `/feature pick FEATURE-001`. Expected: the phase is not `review`, and pick offers decompose with no competing review offer.
  - Passed 2026-10-14 as a cold drill (`skills/populate-tests/SKILL.md` § *The cold drill*). Runner: `claude -p --disable-slash-commands --permission-mode acceptEdits`, brief on stdin, cwd a fresh git fixture in the session scratchpad (`d322-fixed`: one `done` feature, one `done` task, no remote) holding copies of `decide.md`, `status.md`, `pick.md`. The brief gave the situation and withheld the expected phase and gate. Coldness: the runner skipped the brief's first ask (list your skills); a scan of its report found no skill name beyond those in the brief and the three files. Result: `idea.md` `done → idea`, phase `building` by the not-decomposed rule, gate D alone (offer printed), E's condition does not hold. The same brief over the HEAD copies (`d322-orig`) reproduced the defect: `review`, phase `review` by rule 1, E leading while D also fails.

## Implementation plan

Written by `/fix-next` after step 3's verification, before the edits (it runs no `/tasks plan`):

1. `status.md` step 2: split stored `review` out of rule 1 and put a not-decomposed rule (`building`) ahead of both `review` rules, using gate D's condition.
2. `decide.md` step 4: give the table a feature column — built → `review`, not built → `idea` — with the reason.
3. `pick.md` gate E: read the computed phase, and say it never fires beside D.
4. Ripple: `feature` SKILL.md coarse table, `new.md`'s pointer, `roadmap` DV2 (otherwise the new state reads as drift), the `new-project` seed's copy of the rule.
5. Lint, a cold revert-and-split drill, then respec `feature-lifecycle` and `project-roadmap`.

## Outcome

- **The fix.** Recording a change to a signed-off feature whose change is not in the code yet used to mark the whole feature "built, awaiting sign-off", so stakeholders were told unbuilt work only needed approving. Now the feature goes back to `idea`, and the rollup reads `building` until the change is decomposed and built. More generally, any approved or changed decision with no tasks keeps a feature out of `review`, whatever is stored. Files: `skills/feature/verbs/status.md` (new not-decomposed rule ahead of both `review` rules; the table now has 8 rules), `decide.md` step 4 (feature column: built → `review`, not built → `idea`), `pick.md` (gate E reads the computed phase; gate D's offer names changed rows), `feature` SKILL.md (coarse table, router line), `new.md` (pointer), `roadmap` SKILL.md DV2 (exception for a not-decomposed row), `new-project/templates/CLAUDE.seed.md` (the seeded copy of the rule), and specs `feature-lifecycle`, `project-roadmap`.
- **Step-6 split (cold drill, original vs fixed verb files, one fixture):** 3 of 3 fix-dependent outcomes flip: the stored status (`review` → `idea`), the phase (`review` by rule 1 → `building` by rule 2), and the gate collision (E leads with D also failing → D alone). Contract pins, identical on both sides: TASK-001 stays `done`, and the D1 cell is emptied into a History line. Lint (90/90 tests, `OK (20 skills)`) is a pin, not evidence.
- **Judgement calls.**
  - The stored value is `idea`. `review` would claim the work is built, `done` would hide the feature from every work listing, and the coarse set has no `building`. Rejected: adding a `building` coarse value. Phase is derived by design, and a new stored value would ripple into DV6 and every reader of the coarse set for no gain over `idea` plus the derived phase.
  - The not-decomposed rule runs ahead of a stored `review` and below `done`/`dropped`/`superseded`. Rejected, as the stricter option: putting it above `done` too. `decide.md` now never leaves `done` for an unbuilt change (its lead sentence says so), so ranking above `done` would only override a sign-off record.
  - The rule's condition is gate D's own (empty cell, or a task missing on disk), and DV2's exception uses the same test, so the three readers cannot disagree.
  - The gate-D wording fix ("approved or changed") was made in place rather than spawned: it is one line, in a file already being edited, on the exact path this task fixes. Both drill runners noticed it.
- **Specs.** Respecced by `/fix-next` step 7 as targeted edits under regen's stable-wording rule, restamped `generated-at` to HEAD. `shaped-by` was carried, not re-derived: this task has `feature: null` and contributes nothing to it. Each change is *intended anyway — TASK-322's criteria, answered by /fix-next*, except the DV2 exception and the seed, which no criterion names and which are the ripple needed so the new state is not flagged as drift and new repos are not seeded with the old rule. `project-baseline` does not spec the seed's sentence, so it was not regenerated.
- **Review gate.** Standards: no blockers. Its warnings were the stale seed (fixed), the empty plan (filled after the fact, and says so), and spec provenance (above). Fidelity: all four criteria met, with one wrong-in-part (the DV2 test was narrower than the spec's), fixed. Correctness: 5 findings, none blocking. Fixed: the seed, the test-covered unbuilt case in `decide.md`, the false rationale in `status.md`, DV2's narrower test, and the coarse table's `review` row. One was not fixed, below. Security and review-comments: not applicable (prose only, no code comments).
- **Flagged, not fixed.** A feature parked at `review` with `verify` tasks, which then gains a new undecomposed row, reads `building` and drops out of "verification debt first" until that row is decomposed. Whether that is right is an ordering decision, filed as TASK-323.

## Progress log

- step 2 — picked; ranked above TASK-317 because key 3 (silence): TASK-322 makes the rollup tell stakeholders unbuilt work awaits sign-off, a plausible wrong answer reachable from every `changed` decision on a done feature, while TASK-317 drops a report line about a branch that still exists on the remote; both drill-verified (key 5)
- step 3 — verified: held. `decide.md` step 4 sets `done → review` for every human-verifiable change, built or not; `status.md` rule 1 mirrors stored `review`, and rule 2 says `review` anyway because the old tasks still back-link through `feature:`; `pick`'s gate E reads that phase while gate D fails on the emptied cell. Same root reaches further than the report: a feature with any approved row left undecomposed and every linked task done also derives `review` (rule 2), and `roadmap` DV2 would flag the not-built state as drift once the phase stops saying `review`
- step 4 — layer: local
- step 5 — fix in skills/feature/verbs/status.md (new rule 2 ahead of both `review` rules; stored `review` split out of rule 1), decide.md step 4 (feature column: built → `review`, not built → `idea`), pick.md gate E, feature SKILL.md coarse table, new.md wording, roadmap SKILL.md DV2 exception; test = lint + cold drill (step 6)
- step 6 — reverted fix (cold runners, original vs fixed verb files on one fixture): 3/3 outcomes flip. Fixed: `idea.md` `done → idea`, phase `building` by rule 2, gate D alone. Original: `review`, phase `review` by rule 1, gate E leads while D also fails — the report's defect, reproduced. fix-dependent = stored status, phase, gate collision; contract pins = TASK-001 stays `done`, D1 cell emptied into a History line (identical both sides); lint 90/90 + OK is a pin, not evidence
- step 7 — respecced feature-lifecycle, project-roadmap; requirements changed: "Changing a signed-off feature reverts it by surface" (unbuilt → `idea`), "Coarse status is stored, phase is derived" (eight rules), the `/feature pick` gate requirement (E never beside D), DV2 (not-decomposed exception); scenarios added: an undecomposed row outranks a stored review, and an unbuilt change waiting for decompose is not drift
- step 8 — handed to /tasks close --unattended; outcome in status:, commit in git log
