---
id: TASK-026
parent: null
feature: null
# status: todo | in-progress | review (code done, sign-off pending) | blocked | done | cancelled
status: done
priority: P1
assignee: agent
created: 2026-08-19
depends-on: []
blocks: []
# findings: ids this task remediates, from a review/audit/spec-harvest pass (CR-* SEC-* SH-* VC-*)
findings: []
pr: null
github-issue: null
jira-key: null
---

# `/specs regen` attributes provenance on a mention, not on authorship

## Context

Field report from Symbio (`C:\Source\Birko\Consumers\Symbio`), measured 2026-08-14 and re-measured
2026-08-18.

`/specs regen` step 5a ([skills/specs/verbs/regen.md](../../skills/specs/verbs/regen.md), lines
53-55) derives a spec's `shaped-by:` by resolving each feature-linked task's changed files in three
paths: `pr:` as PR number → `pr:` as commit SHA → **`git log --grep '\bTASK-NNN\b'`**. That third
path attributes on a *mention*, not on authorship: a commit whose message merely names a task —
a finding citing another finding, an out-of-scope line naming deferred work — is counted as that
task having touched those files.

`skills/specs/SKILL.md:106` already promises the opposite — *"the files each task's commits/PR
actually touched … never inferred from names or dates"*. So this is the same contract/implementation
split that produced the previous defect in this very field, one level down.

Why it bites: `shaped-by:` is what [[roadmap]] DV8 reads and what [[feature]] `review` Gate A greps
to answer *"did this decision land in a spec?"*. A false positive makes Gate A **pass** on a
decision that never shipped — strictly worse than attributing nothing, because a gap is visible
while a wrong attribution reads as a completed trail.

Measured on Symbio:

| Measurement | Value |
|---|---|
| Tasks with `pr: null` (so path 3 is the only path) | 390 of 392 |
| Commits naming more than one `TASK-NNN` | 419 of 1700 (~25%) |
| Feature-linked tasks tree-wide contributing no evidence | 120 of 213 (56%) |

Both hits path 3 produced on that project's `communication` area were false positives:
`FEATURE-092` via TASK-409 (a wishlist re-key that touched no Communication file; the evidence was
another task's commit saying *"the opposite call from TASK-409/410"*), and `FEATURE-004` via
TASK-005 (`status: todo` — never implemented; the evidence was an out-of-scope line).

**Already shipped, do not redo:** `skills/tasks/verbs/close.md:143` now writes the commit SHA into
`pr:`, so future tasks skip path 3 entirely. It is not retroactive — a run on 2026-08-18 still fell
back to path 3 for 120 of 213 tasks — so it shrinks future exposure and does nothing for history.

The remedy is two independent rules, not one better regex, because a commit message cannot carry
authorship reliably:

1. attribute from path 3 only when the id **leads the commit subject** (`TASK-411: …` is the
   convention this project family writes), and
2. a task not in a **completed** state contributes no evidence, ever — that alone kills the
   TASK-005 class regardless of how well rule 1 matches.

## Acceptance criteria

- [x] Step 5a's path 3 attributes only on a subject-leading id; a body mention cannot attribute. The chosen shape and its rationale are recorded in the file — `git log --format='%H%x1f%s' --grep` prefilter, then keep a commit only when the **first** id in its subject is this task's. Recorded with the rejected alternative: a literal "subject starts with the id" attributes **nothing** on this repo, whose own log reads `fix(skills): TASK-017 — …`
- [x] A task whose state says the work never landed contributes no evidence regardless of commits naming it — stated as its own rule ("Gate first"), ahead of the three resolution paths so it applies to all of them
- [x] "Completed" defers to [[tasks]]' vocabulary rather than restating a growable list — the gate is a *test* ("the state says nothing landed"), resolved against [[tasks]]; `todo`/`cancelled` appear only as today's resolution. Caught by `/verify-conventions` on the first draft, which had copied the list
- [x] Deliberately **not** narrowed to `done`-only: measured, that drops 27 of 96 subject-authored attributions already in the tree (`review` = merged with sign-off open, `blocked` = merge deferred) and removes no false positive the subject rule had not already removed. A reachability rule ("never `git log --all`") carries what the status guess was doing, without a list
- [x] `shaped-by-unresolved:` is allowed and expected to **rise**; step 5b says a stricter rule that leaves it untouched is the suspicious result, and step 7 now prints it
- [x] The `\b`-boundary lesson survives — the `--grep '\bTASK-NNN\b'` prefilter is kept verbatim, with its measurement (22 false-positive commits vs 0 bounded)
- [x] "Attribute only on evidence" is not weakened — reworded to match the new gate and still forbids inference from epic names, folders, dates
- [x] `skills/specs/SKILL.md`'s provenance paragraph states both rules, so contract and step 5a agree
- [x] [[roadmap]] DV8 touched — a high `shaped-by-unresolved` is now explained as possibly the project's commit trail rather than its work. DV11 left alone: it asks whether derivation *ran*, which this does not change
- [x] The append-only hazard is recorded in step 5a: the rule cannot unwrite existing attributions, and a scrub is its own decision
- [x] `skills-lint.sh` OK (16 skills), `skills-lint-test.sh` 25 passed / 0 failed
- [x] **Register-on-introduce** (found by `/verify-conventions`): the change makes "the id leads the commit subject" a load-bearing cross-skill protocol, so it is now stated where the message is written (`tasks/verbs/close.md` step 7) and recorded as a convention in `AGENTS.md` § Code structure

## Out of scope

- **Re-deriving existing specs.** `shaped-by:` is append-only; scrubbing bad attributions already
  stamped breaks that property and needs its own decision. Symbio carries the consumer-side residue.
- Re-scoping Symbio's TASK-431 (misfiled there as repo work) — that is the consuming project's call,
  noted here only so the trail connects.
- Making `close`'s SHA backfill retroactive.
- The three defects `/code-review` found outside this diff, now tracked: **TASK-027** (the
  `present, uncommitted` probe is blind to staged work), **TASK-028** (the inference skip rule
  counts an inapplicable subsection), **TASK-029** (the lint's own 16→25 case growth is unrecorded).

## Human test plan

Run 2026-08-19 against Symbio (`C:\Source\Birko\Consumers\Symbio`) — 213 feature-linked tasks of 475, 1414 commits, 32 spec areas. Both rules were implemented as scripted derivations and run in a 2×2 so each rule's own contribution is visible.

- [x] **Both known false positives are gone.** `communication` went from `[FEATURE-001, FEATURE-004, FEATURE-040, FEATURE-092, FEATURE-093]` to `[FEATURE-093]`. FEATURE-092 (via TASK-409, the wishlist re-key) and FEATURE-004 (via TASK-005, `status: todo`) are both refused, and each rule refuses them independently
- [x] **Both directions reported:**

  | evidence rule | attributions | area/feature pairs | unresolved |
  |---|---|---|---|
  | id anywhere in message, no gate (the defect) | 246 | 82 | 135 |
  | gate only | 164 | 49 | 157 |
  | subject-first only | 106 | 44 | 163 |
  | **both (shipped)** | **96** | **36** | **169** |

  96 of 246 attributions kept (39%), 150 dropped. Of the dropped: 80 gated as `todo`, 2 as `cancelled`, 68 mention-only. 10 attributions come from `todo`/`cancelled` tasks that nonetheless lead a commit subject — a self-contradicting trail, which step 7 now reports instead of silently believing one side
- [x] **`shaped-by-unresolved` rose 135 → 169** on the same slice, as it should; nothing suppresses it
- [x] **Read step 5a cold:** executable without opening [[tasks]] for the state list, because the gate is a test with today's resolution named inline. Two gaps the cold read found and fixed: real task files write `status: done  # merged 5414637e; 6 unit tests`, so the rule now says read the YAML **value**, not the line (the first measurement run rejected all 52 `done` tasks on exactly this); and an unreadable `status:` is now explicitly unresolved rather than assumed either way

### Not covered by this drill

- The PR-number path (`gh pr diff`) — Symbio has 390+ tasks with `pr: null` and no PR-per-task history to exercise it. Unchanged by this task
- Symbio's already-stamped specs still carry attributions written under the old rule (append-only). Out of scope here; it is the consumer repo's residue

## Implementation plan

1. **`skills/specs/verbs/regen.md` step 5a — add the status gate above the three paths.** Only a
   `done` task is evidence; `done` is the one state [[tasks]] defines as *merged*, and `shaped-by`
   claims a feature shaped **the code this spec was harvested from**. Point at [[tasks]] for the
   vocabulary instead of copying the state list (the list can grow; the *`done` means merged*
   invariant cannot). Unreadable status → not `done` → unresolved.
2. **Rewrite path 3 as subject-scoped.** Keep `--grep '\bTASK-NNN\b'` as the cheap prefilter (this
   preserves the measured `\b` lesson verbatim), add `--format='%H%x1f%s'`, and keep a commit only
   when the **first** task id in its *subject* is this task's. First-id-in-subject resolves both
   conventions in play — `TASK-411: …` and `fix(area): TASK-411 — …` — where the handoff's literal
   "id leads the subject" would attribute **nothing** on this repo, whose own log reads
   `fix(skills): TASK-017 — …`. Later ids in the subject and every id in the body are
   cross-references.
3. **Record the escape honestly:** a project that never names tasks in subjects resolves nothing
   here and that raises `shaped-by-unresolved` rather than inventing provenance; the durable fix is
   upstream in [[tasks]] `close`'s SHA backfill.
4. **Step 5b** — state that the count is *expected to rise* under the stricter rule, and that the
   increase is refused mentions, not lost evidence. Forbid relaxing the rule to bring it down.
5. **Append-only caution** next to the "never drop a recorded feature" input: the stricter rule
   cannot unwrite attributions already stamped; a scrub breaks append-only and is its own decision.
6. **`skills/specs/SKILL.md`** provenance paragraph — restate the contract as *authorship, evidenced
   by a commit that names the task in its subject or by `pr:`*, plus the `done`-only gate.
7. **[[roadmap]] DV8** — one clause: a non-zero `shaped-by-unresolved` now also counts mention-only
   attributions refused, so a DV8 flag on such a project is a trail gap as often as a landing miss.
   DV11 is untouched: it is about whether derivation ran, which this change does not alter.
8. Run `bash .github/workflows/skills-lint-test.sh` then `skills-lint.sh`.

**Plan correction, 2026-08-19 (after the drill, not to fit it).** Step 1 above proposed a `done`-only gate. The Symbio measurement showed that drops 27 of 96 subject-authored attributions whose work is already in the tree (tasks parked at `review`/`blocked`), while removing no false positive the subject rule had not already caught. The shipped gate therefore rejects the states that mean *nothing landed* and adds a reachability rule to carry the rest. The original step stays visible — what was planned and what the measurement changed are both the record.

## Review round — `/code-review medium`, 2026-08-19

Six findings landed inside this diff; all six are fixed in it. Re-measured first, so the drill table above still holds: **0 of 213** feature-linked tasks on Symbio carry a `pr:` and **none** are `in-progress`, so neither fix moves a single number.

| # | Finding | Fix |
|---|---|---|
| 1 | The state gate sat ahead of *all* three paths, but its justification only holds for the message fallback — a task with a merged `pr:` and a stale `todo` was discarded, the same contradiction the step elsewhere says to *report* | Gate now applies to **inferred** evidence only. A declared `pr:` outranks the state field; a state that disagrees with a landed reference is reported, not used to discard the strongest link |
| 2 | Reachability was unenforced on exactly the paths that need it: `git show <sha>` succeeds for any object and `gh pr diff` works on an open PR, so a `review` task behind an unmerged branch still attributed | Explicit `git merge-base --is-ancestor <sha> <generated-at>` on the `pr:` paths; a PR that has not merged is no evidence |
| 3 | `in-progress` was addressed by neither the reject list nor the protect list, so two agents could derive different `shaped-by` sets and the table would be unverifiable | Stated: **`in-progress` passes** — work under way has landed whatever it committed, and reachability proves it, not the label |
| 4 | `shaped-by-unresolved`'s definition in 5b ("no `pr:`, no commit naming them") no longer matched its producer, so the stamped number was not reproducible from the file | Definition rewritten to step 5a's actual rules, with the keep-in-step instruction |
| 5 | Two figures for one project in one step: "419 of 1700 commits" vs the table's 1414 | Re-measured on the table's slice: **197 of 1414** first-parent commits name more than one id, **53** name more than one in the subject — which independently justifies the leading-id tie-break |
| 6 | The new sentence in `close.md` was fused onto a parenthetical aside, so the one statement of the writing side of the contract could be skimmed past | Sentence separated |

Also fixed here because the diff already touches the file: `AGENTS.md` § Testing said the lint has "16 cases" when it runs 25.

**Three findings fell outside this diff and are NOT fixed here** — each is now its own task:

- **TASK-027** — `skills/new-project/LAYER.md:104`, the `present, uncommitted` probe matches only `??` and ` M` porcelain lines, so a layer that was written **and staged** but never committed reports plain `present`. Same class as the blindness TASK-018 was reopened for
- **TASK-028** — `skills/adopt-project/INFER.md:91`, the skip rule counts coverage over five subsections, but UI / UX is conditional; on a headless library the arithmetic either never reaches "all covered" or proposes UI rules to a repo with no UI. Needs *applicable* subsections
- **TASK-029** — whether the lint's own coverage grew correctly from 16 to 25 cases (this task only corrected the stale number)
