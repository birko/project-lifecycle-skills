---
id: TASK-080
parent: STORY-008
feature: null
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: done
priority: P2
assignee: agent
created: 2026-08-26
depends-on: [TASK-079]
blocks: []
# findings: ids this task remediates, from a review/audit/spec-harvest pass (CR-* SEC-* SH-* VC-*)
findings: []
pr: null
github-issue: null
jira-key: null
---

# `/specs regen` — generate the specs, and review the diff as the deliverable

## Context

The second half of STORY-008, and **the half that genuinely runs last.**

### The ordering constraint is real, and it is not expressible in frontmatter

`depends-on: [TASK-079]` covers the map. What it cannot express is the story-level rule:

> **Runs last, and stays last.** STORY-002 through STORY-007 all change skill behaviour and STORY-003 changes
> the vocabulary the specs would be written in. Regenerating before the set stabilises means regenerating
> twice and reviewing a diff that is pure churn.

**Outstanding when this task was filed: STORY-004, STORY-006, STORY-007.** (STORY-002, 003 and 005 are done.)
STORY-007 in particular *adds a skill*, which adds an area — so a regen before it lands produces a spec set
that is incomplete by construction. `STORY.md` has no `blocked-by` field, which is why EPIC-001 keeps its
dependency edges in a Sequence table; this paragraph is that edge, written where whoever picks the task will
read it.

**Do not start this while those three are open.** If they slip, this slips — the story says so outright:
*"It is the natural stopping point, not a nice-to-have."*

### The diff review is the deliverable, not the files

*"The regen **diff** is reviewed as an intended-versus-unintended behavioural-change check — that review is
the point, not the file."* On a first generation there is no diff to review, which is worth saying plainly:
the **first** run's deliverable is the baseline plus a read of whether each spec describes what the skill
actually does. The diff-as-check property starts with the *second* run.

### The self-check STORY-008 flags

> *This repo is a polyrepo-free, markdown-only project — the exact shape where the staleness anchor bugs
> fixed in the 2026-08 commits were found. A regen here is also a live test of those fixes.*

Two of those fixes are now testable here for the first time, and both were touched this month:

- **`shaped-by` provenance via the subject rule.** TASK-030 settled that `single-branch` repos leave `pr:`
  null permanently and resolve through the commit subject instead — and verified on three real closes that
  the leading id in each subject is that task's own. This regen is the first run that actually exercises it,
  so `shaped-by-unresolved` is a **measurement**, not a nuisance: a high count here would mean that fix is
  wrong.
- **The anchored status read.** TASK-036 fixed `regen` step 5a's state gate, which had been able to read the
  frontmatter's enum comment instead of the field. TASK-073 then removed the comment's trap shape repo-wide.
  A run here confirms both.

## Acceptance criteria

- [x] **STORY-004, 006 and 007 are `done` before this starts** — or the reason for proceeding anyway is recorded on this task, naming what churn is accepted
- [x] Every area in `.map.yml` has a generated spec, each stamped with `generated-at`, `sources`, and `shaped-by` provenance
- [x] Each spec is read against the skill it describes, and any place the spec is right while the **skill** is wrong becomes a spawned task — a harvest that only produces documents wastes its best output
- [x] `shaped-by-unresolved` is **reported as a number with an interpretation**, not left as a field: this repo's commits lead their subjects with task ids, so a high count contradicts TASK-030's fix and is a finding against it
- [x] `shaped-by-derived:` is `true` on every area — an unfilled field makes [[roadmap]] DV11 read a generator gap as a project gap
- [x] `/roadmap --check` afterwards reports DV7 fresh for every area, with no unknown baselines — checked with the staleness rule DV7 calls (`/specs verify`: the later of `generated-at` and the spec's own last commit), not by a full `/roadmap` run: 15 of 15 fresh, every source in-repo, so no baseline can be unknown
- [x] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- The area map — **TASK-079**, which this depends on.
- Fixing anything the diff review surfaces. Findings get spawned; fixing them inside a harvest task would make the diff unreviewable, which is the one thing this task must not do.
- Re-running after STORY-004/006/007 land, if this is somehow run early.
- Deferred to TASK-281 — three specs omit behaviour their sources state (found by the idempotence re-run) That would be a second task with a stated reason.

## Human test plan

- [x] Read two generated specs against the skills they describe and confirm they state what the prose **actually says**, not what it ought to say
- [x] Confirm `shaped-by` is non-empty where a task genuinely shaped an area, and that the `unresolved` count is explained rather than merely printed
- [x] Re-run `/specs regen` immediately and confirm the diff is **empty** — a generator that is not idempotent makes every future diff review worthless
- [x] Change one skill's prose deliberately, re-run, and confirm the diff shows exactly that change and nothing else — the property the whole story is for

## Implementation plan

Run in two stages, because the gate in criterion 1 holds for some areas and not others.

**Stage 1 — now: `project-baseline` and `change-review`.** These are the only two areas whose spec landing FEATURE-001 and FEATURE-002 still wait on, and neither is touched by the work the gate is about.
1. Harvest both areas per `/specs regen` (first harvests, so a full spec plus a skim, with no diff).
2. Derive `shaped-by` under step 5a's rules, using a script, so the count can be reproduced: feature-linked tasks, the state gate, `pr:` null on `single-branch` → subject-first commits reachable from HEAD, intersected with each area's resolved sources. Stamp `shaped-by-derived: true` and `shaped-by-unresolved: N`, and interpret N (criterion 4).
3. Read each spec against its skills. Where the spec is right and the skill is wrong, or the skill is internally inconsistent, file it as a finding in a pool, not inline (criterion 3).
4. Unmapped check (reported even at 0), lint, commit the specs.
5. Hand off to `/feature review` for FEATURE-001 and FEATURE-002. Their Gate A now has an answer.

**Stage 2 — after STORY-004 and STORY-007 are `done`: the remaining 7 areas** (`glossary-and-adrs`, `test-authoring`, `changelog-maintenance`, `idea-interrogation`, `session-handoff`, `installation`, `skill-authoring-rules`, plus the new `improve-architecture` area STORY-007 adds), then the human test plan's idempotence and deliberate-change re-runs over the whole set. Re-harvest `feature-lifecycle` and `idea-interrogation` if STORY-004 changed their sources.

## Progress log

- 2026-10-03 — **Partial work done outside this task, recorded here so the task reflects it.** At the owner's request, to unblock FEATURE-003's sign-off, `/specs regen` ran as first harvests for 5 of the 14 areas: `work-tracking` (`0c84b8a`), `feature-lifecycle`, `project-roadmap`, `defect-draining`, `specs-from-code` (`b24eb8b`). Each has `shaped-by-derived: true`, `shaped-by-unresolved: 7`. The task was not picked first, and the run came ahead of the EPIC-001 sequence (after STORY-004/006/007) — a lapse against the task-first gate, noted rather than hidden. The map gained `skills/review-comments/**` under `change-review` (0 unmapped). The 51 suspected bugs those harvests raised are filed as EPIC-007. Still to do: the other 9 areas, then this task's own criteria — including the deliberate-change re-run.
- 2026-10-04 — **Picked, and criterion 1 answered: proceeding before the gate, for two areas only.** STORY-004 (4 tasks todo) and STORY-007 (4 tasks todo) are open; STORY-006 is open only for TASK-124's outside-reader sign-off, which is blocked on a tester. TASK-124's code is merged, so it adds no regen churn. Reason for proceeding: FEATURE-001 and FEATURE-002 are signed off and wait only on spec landing in `project-baseline` and `change-review`. Neither area's sources are touched by STORY-004 (`feature`, `grill-me`) or STORY-007 (`improve-architecture`, `tdd`), so no churn is accepted for them. The other 7 areas stay gated (stage 2 of the plan). Planned inline at pick.
- 2026-10-04 — **Stage 1 harvested: `project-baseline` (38 requirements) and `change-review` (38), first harvests at `adc4c27`.** Each was harvested by one reader. A second reader then checked every suspected bug against the files and spot-checked 8 requirements per spec: 7 of 8 were accurate in each. The two overstated lines were corrected before commit. `change-review`'s advisory rule had applied the intent axis's limits to all three axes; `project-baseline`'s worktree-root requirement had picked one side of a contradiction, and now states both. **Provenance:** derived with a script implementing regen step 5a, which reproduces the earlier runs exactly (unresolved 7; `defect-draining` = FEATURE-001, FEATURE-003). `project-baseline` is shaped by FEATURE-001, 002 and 003; `change-review` by FEATURE-002. **`shaped-by-unresolved: 7` of 64 feature-linked tasks, interpreted:** TASK-193 and TASK-194 are `todo`, correctly not evidence. TASK-145 is `cancelled` although a commit leads its subject — a trail contradiction, correctly refused by the state gate (its work shipped, then the task was cancelled for an unmeetable criterion). TASK-176, 187, 188 and 189 landed inside commits led by a sibling id (TASK-179, TASK-186) — batched commits, not a failure of the subject rule. Every landed task with a commit of its own resolved, so the count does not contradict TASK-030's fix. **Unmapped: 0** (38 map globs). **Findings:** 30 (SH-53 … SH-82) → EPIC-007's third pass: 10 tasks (TASK-242 … TASK-251), 2 linked to TASK-085, 2 dropped with reasons. 7 of 14 areas are now harvested.
- 2026-10-04 — **First real "deliberate change" re-run** (human test plan, step 4), by way of TASK-193. Its rename of "remote mode"/"local mode" in `skills/tasks/**` and `skills/fix-next/**` was followed by a scoped regen of `work-tracking` and `defect-draining`, whose diff was exactly the rename (18 lines changed, 18 removed) and nothing else. Recorded here as evidence. The step itself is ticked when stage 2 re-runs it over the whole set.
- 2026-10-06 — **`idea-interrogation` harvested (first harvest, 15 requirements) at `07de657`, ahead of STORY-007 by the owner's decision.** STORY-004 is done, so this area's source (`skills/grill-me/SKILL.md`, changed by TASK-117) is stable. STORY-007 does not touch it, so no churn is accepted. **Provenance:** a script implementing regen step 5a reproduces the stage-1 results (`defect-draining` = FEATURE-001 and 003; `project-baseline` = FEATURE-001, 002 and 003). `idea-interrogation` has `shaped-by: []`, a real empty result: no feature-linked task's subject-first commit touched `skills/grill-me/`, because STORY-004's tasks carry `feature: null`. **`shaped-by-unresolved: 5` of 64**, down from 7 because TASK-193 and TASK-194 have since landed. The remaining five are the known TASK-145 contradiction and the four batched commits (TASK-176, 187, 188, 189), so the count does not contradict TASK-030's fix. **Unmapped: 0.** **Findings:** 4 (SH-83 … SH-86) → EPIC-007's fourth pass, as TASK-258 … TASK-260. 8 of 14 areas are now harvested; the remaining 6 wait for STORY-007.
- 2026-10-06 — **Stage 2, after STORY-007 closed (STORY-004 done earlier; STORY-006 open only for TASK-124's outside tester, as recorded on 2026-10-04).**
  - **Map:** gained `code-shape-review` (`skills/improve-architecture/**`), the only unmapped skill folder. 15 areas.
  - **Seven first harvests, in parallel:** `test-authoring` 31 requirements, `glossary-and-adrs` 15, `changelog-maintenance` 13, `session-handoff` 6, `installation` 10, `skill-authoring-rules` 16, `code-shape-review` 41.
    - A spot-check reader tested 6 requirements per spec against its sources: 38 of 42 accurate. The 5 corrections (two overstated, one unsupported by the declared sources, one stated as behaviour where the source is silent, one boundary stated where the source is ambiguous) were applied before commit.
  - **Provenance** (the stage 1 script): `test-authoring` = FEATURE-001, `installation` and `skill-authoring-rules` = FEATURE-002; the rest `[]`, derived. **`shaped-by-unresolved: 5` of 64**, down from 7 because TASK-193 and TASK-194 have landed: TASK-145 is cancelled although a commit leads with it (the state gate refuses it, correctly), and TASK-176/187/188/189 landed inside commits led by a sibling id. Every landed task with a commit of its own resolved, so the count does not contradict TASK-030's fix.
  - **Unmapped:** 0.
  - **Findings:** 37 (SH-87 … SH-123), each checked by a second reader: 23 confirmed, 8 partly, 6 refuted. → EPIC-007's fifth pass: 10 tasks (TASK-271 … TASK-280; TASK-277 at P1, the installers reporting success for copies, reproduced), 2 linked (SH-89 → TASK-024, SH-117 → TASK-029), 6 dropped with reasons.
  - **Deliberate-change re-run (test plan, step 4):** `work-tracking` was stale by three commits (TASK-262, 263, 270, all `intake` changes). Its regen diff was 22 lines, every one tracing to those commits: the dropped-entry shapes, `source:` naming the pass, the `IA-*` prefix and its exceptions, the all-dropped `done` epic. Nothing else moved. Classified intended; applied with a fresh stamp.
  - **Idempotence (test plan, step 3):** all **15** areas regenerated with no source change, one harvester each; every body byte-identical, confirmed with `diff`. Three harvesters noted behaviour their specs omit, which the stable-wording rule correctly left alone → TASK-281. The `work-tracking` worktree point is an omitted exception, not a contradiction of the general case, so it is deferred too, not fixed here.
  - **Freshness (criterion 6):** 15 of 15 fresh under `/specs verify`'s rule.
  - **Close gate:**
    - **Standards** ([[verify-conventions]]): pass with 3 warnings, all fixed: EPIC-007's story counts, a dated changelog clause in the map comment, and an unbacked naming claim there.
    - **Fidelity** ([[verify-intent]]): every criterion met except the record of stage 2, which is this entry.
    - **Correctness:** the spot-check and the second reader above, which ran independently of the harvesters.
