---
id: TASK-020
parent: STORY-002
feature: null
# status: todo | in-progress | review (code done, sign-off pending) | blocked | done | cancelled
status: done
priority: P1
assignee: agent
created: 2026-08-18
depends-on: []
blocks: []
findings: []
pr: null
github-issue: null
jira-key: null
---

# A defect found mid-adoption gets fixed and never gets an id

## Context

Found in the `adopt-project` drill on `C:\Source\Birko\Consumers\Presenter` (2026-08-18).

The survey turned up two real defects that were not layer gaps:

1. `src/Presenter.Web/tsconfig.json` still pointed its four Birko paths at a directory that does
   not exist — `build.js` had been migrated to the bucket layout in `6182687` and `tsconfig.json`
   was not, so `npm run typecheck` could not resolve anything downstream of `BaseComponent`.
2. `dotnet build` / `dotnet test` were broken outright: a version-less `PackageReference` in an
   imported `.projitems` with no matching `PackageVersion` under central package management
   (NU1010), cascading into a NuGet crash, plus duplicate references the shared projects now
   declare themselves (NU1504).

The run said the right thing — *"I'd file this as a task rather than fix it silently"* — the user
chose *fix it now*, both were fixed and verified (143 tests passing), and **nothing was ever
filed**. Confirmed after the fact: nothing under `Presenter/tasks/` mentions NU1010, NU1504,
tsconfig, CPM or PackageVersion. Two real defects shipped in `4bee0ea` with no tracked record and no
regression check.

The gap is in this skill, not in the choice. `adopt-project` has no rule about defects it finds
while surveying, so "fix it now" reads as *instead of filing* rather than *as well as*. Meanwhile
[[tasks]] § *Findings become tasks, or they evaporate* is unambiguous — and adoption is the one pass
that reads a whole unfamiliar codebase, so it is **the** highest-yield finder of exactly this kind
of defect. It is also, by construction, running in a repo that either has a `tasks/` tree or is
about to get one, so there is nowhere for "we had nothing to file it into" to hide.

A fix that ships with no task is worse here than elsewhere: the fixed repo now has a rulebook and a
lifecycle, so the *next* agent will assume anything untracked was never a problem.

## Acceptance criteria

- [x] `adopt-project` states that a defect found during the survey or fill is **filed as a task**, not just reported — and that this holds whatever the user decides about fixing it now, later, or never
- [x] The two paths are spelled out: **fix now → the task is filed too**, recording the fix and its verification; **not now → the task is the whole outcome**. Never "fixed, mentioned in the report, untracked"
- [x] Ordering is stated: the layer fill is what adoption is *for*, so a found defect never silently displaces it — fill, then defects, unless the defect blocks the fill (a broken build blocking `populate-tests adopt` is the standing example)
- [x] A fix to shipped behaviour carries a regression check per [[tasks]]'s standing rule, or the task records why one is impossible — the Presenter build fix had neither
- [x] Filing goes through the owning verb (`/tasks new`, or `spawn` when adoption is itself running under a task), never a hand-written file — and in a repo whose `tasks/` this same run just created, the task lands after the tree exists
- [x] The report's buckets say where found-defect work shows up, so it is not confused with layer work: a defect fix is neither `created` nor `amended` in the layer sense
- [x] `skills-lint` and `skills-lint-test` stay green

## Out of scope

- Backfilling the two Presenter tasks retroactively — that is Presenter's own tracker's business, and the fixes are already merged and verified there.
- Whether adoption should fix defects at all; it should offer, and the user decides. This task is only about the record.
- `/specs init`'s vacuous coverage check from the same run — a specs-skill defect; **TASK-033** owns it (filed by this task's 5d sweep).
- Deferred to TASK-031 — a `missing, not offered` verdict whose reason a filed task will remove never reopens on a re-run. Surfaced by this task's drill; adjacent to § 3b, not covered by it.
- Deferred to TASK-032 — a divergence cannot be recorded as *accepted*, so `triage` must either nag permanently or skip silently. Surfaced while picking this task.
- Deferred to TASK-034 — this close hand-edited `tasks/README.md` (a generated file) because `triage`'s template cannot reproduce the narrative already in it. Raised as a 🛑 blocker by `/verify-conventions` here; the fix is a `tasks`-skill change, not an `adopt-project` one.
- Deferred to TASK-035 — nothing owns asking for an `integration:` declaration a present config lacks: step 1 is forbidden to look, step 2 is told to ask, and the skip path drops it. Two `/code-review` findings from this close, grouped.
- Deferred to TASK-036 — `/specs regen`'s state gate can read the template's commented `# status:` enum instead of the status line, silently refusing provenance for every template-generated task. P1.
- Two further findings from this close were **linked, not duplicated**: step 1's untracked-only probe → TASK-027 (which already asks whether either skill restates the line shapes); `AGENTS.md`'s "every row with an Owner" overreach → TASK-024 (whose last bullet already flagged it).

## Human test plan

- [x] Drill a repo with a known, obvious defect outside the layer (a dead path, a broken script) and confirm the run offers a task, and that accepting "fix it now" produces **both** the fix and the task
- [x] Confirm declining the fix still leaves a filed task rather than a paragraph in the report
- [x] Confirm a defect that blocks the fill is handled first and says why it jumped the queue
- [x] Re-read the Presenter report against the new rule and confirm it would have produced two tasks

## Implementation plan

⚠ Acceptance criteria question: criterion 6 ("the report's buckets say where found-defect work
shows up") reads as if a found defect needs a *bucket*. It cannot have one — step 4's bucket list is
"one per surveyed state", and `LAYER.md` owns the state list, so adding a defect bucket there would
either invent a layer state or restate a list this repo's § Conventions forbids copying. The plan
below gives found defects their **own section** in the report, sitting beside the buckets rather than
among them, which satisfies the criterion's intent ("not confused with layer work") by the stronger
route. **Resolved 2026-08-19: user approved the own-section reading.** Criterion 6 is left as
written and ticks on the section; the buckets are not touched.

### Where the rule lives

`skills/adopt-project/SKILL.md` only. One new subsection plus three pointers into it:

| Edit | Why there |
|---|---|
| New `### 3b. Defects found along the way` after step 3 | The rule is cross-step (found in 1 or 3, filed after `tasks init`, reported in 4) and needs one home to point at |
| Step 1, after "Print the survey as a table and stop" | A defect found while surveying must reach the user *before* the fill decision, and the table has no row for it |
| Step 3, in the bullet list | The blocking case is decided at the delegation that fails, so the rule has to be visible there |
| Step 4 | A found-defect section in the report — the part that outlives the conversation |

**`new-project` and `LAYER.md` are deliberately untouched.** The layer-parity rule binds changes
that *extend the universal layer*; this adds no artifact and no row, so `LAYER.md` does not change
and parity does not fire. Greenfield also has no pre-existing code to find a defect in. Record this
reasoning in the close gate — a reviewer's first question will be "why is this not a parity change?"

Rejected alternative: a separate `DEFECTS.md` beside `INFER.md`. `INFER.md` earns its file at 120
lines of per-subsection reading detail; this rule is ~20 lines, and splitting it would put the
ordering rule one hop away from the step that has to obey it.

### Two orderings, not one

The criteria bundle two independent sequencing questions. Keeping them separate is the substance of
this task:

1. **Fix ordering** — the layer fill is what adoption is *for*, so a found defect never displaces
   it: fill first, then defects. **Unless the defect blocks the fill**, in which case it is handled
   at the blocked delegation and the report says why it jumped the queue. Standing example: a repo
   whose build is broken cannot have `populate-tests adopt` wire a runner.
2. **Filing ordering** — a task can only be filed once `tasks/` exists, and `/tasks init` runs
   mid-step-3 per `LAYER.md` § *Ordering*. So filing is always **after** that delegation, whatever
   the fix ordering did. A defect found during the survey of a repo with no `tasks/` yet is
   *reported* at step 1 and *filed* later in the same run.

These come apart in the real case and collapsing them is how "file it" becomes unimplementable on a
first adoption. Write both.

### Steps

1. Draft `### 3b` covering, in order: the filing rule (a found defect is filed as a task, whatever
   the user decides about fixing); the two decision paths (**fix now → the fix *and* the task,
   recording the verification**; **not now → the task is the whole outcome**) and the explicit
   ban on the third outcome (fixed, mentioned in the report, untracked); the two orderings above;
   the owning-verb rule (`/tasks new`, or [[tasks]] `spawn` when adoption is itself running under a
   task — spawn inherits the origin's parent and `feature:`, which is what makes it the right verb
   there rather than a shortcut); and the regression-check rule.
2. Regression check wording — it must survive the case that produced this task. Per [[tasks]]
   § *Field feedback*, a fix to shipped behaviour is not `done` without a regression check; but
   `LAYER.md` § *CI a repo cannot pass* means the obvious check (add it to CI) is unavailable in
   exactly the repos where adoption finds build defects — a consumer that cannot build in isolation.
   So: the filed task carries the check, **or records why one is impossible, naming the reason**.
   "Cannot be verified in isolation from its framework tree" is a legitimate recorded reason; silence
   is not. This is the wording most likely to be got wrong, so draft it against the Presenter case
   directly.
3. Step 1 pointer: one sentence — defects surface **beside** the table, not in it, before the fill
   decision. Follow step 2's existing precedent for this ("Not in the survey table: coverage is
   judged here, after that table has printed") so the two read as one habit.
4. Step 3 bullet: the blocking case, pointing at 3b.
5. Step 4: a `**Defects found**` section after the bucket list and before the *Content staleness*
   aside — each entry carrying what was found, whether it was fixed, its verification, and the task
   id. Plus one line stating a defect fix is neither `created` nor `amended`: those describe the
   layer, and a defect fix touches the repo's own code.
6. Re-read the whole of `SKILL.md` once for the never-overwrite and propose-never-assert rules —
   fixing a defect writes to a file the repo owns, so 3b must not read as licence around step 3's
   first bullet. Expect this to need an explicit carve-out sentence.
7. `bash .github/workflows/skills-lint-test.sh` then `bash .github/workflows/skills-lint.sh`.
   No new file and no new `[[link]]` target, so green is the expected result, not a proof of
   anything — the real gate is the drill.

### Risks and open questions

- **Criterion 7 is nearly free here.** A prose-only change to one existing file cannot fail the
  lint. Do not let a green lint read as verification; the drill is the test.
- **The drill needs a defect-bearing repo, and Presenter's two are fixed.** Presenter cannot serve
  as the subject again. Plan: a throwaway fixture repo in the scratchpad with one obvious dead path
  and one broken script covers human-test items 1–3, following this repo's existing fixture habit
  from `skills-lint-test.sh`. Item 4 is a paper exercise.
- **Item 4's subject may not exist.** The Presenter adoption report was conversational output from
  2026-08-18 and is probably gone. `## Context` above reproduces both defects in enough detail to
  run the re-read against it instead; if so, say in the close that the re-read was against the
  task's record of the report, not the report.
- **Possible register-on-introduce candidate, low confidence.** "A skill operating on another repo
  files its findings into *that* repo's tracker" may be a new cross-cutting pattern for
  `AGENTS.md` § Conventions. Leaning no — it is one skill's rule and an application of [[tasks]]
  § *Findings become tasks*, not a new protocol — but let `/verify-conventions` decide at close
  rather than pre-judging it.
- **No split signal.** Every step above is one prose change to one file plus its drill; none is
  independently reviewable or outside the criteria.

### Drill record — 2026-08-19

Subject: `widget-store`, a throwaway TS/Node fixture built for this drill (scratchpad,
`drill-020/`), seeded with two defects outside the layer: a `tsconfig.json` `paths` entry resolving
outside the repo root to a directory that does not exist, and a `test` script pointing at an absent
runner. Skill run through both runtimes' live symlinks, so the drilled text was the edited text.

Answered the two defects **differently in one pass** to exercise all three behavioural items at once:
the blocker fixed, the other declined.

| Item | Result |
|---|---|
| fix now → fix **and** task | ✅ `package.json` + `tests/catalogue.test.js` and TASK-001, both in commit `cc1be1e` |
| declined → task still filed | ✅ TASK-002 on disk, `todo`/P1; `tsconfig.json` still broken, as intended |
| blocker handled at its delegation, reason stated | ✅ handled at the `populate-tests adopt` step, reason in TASK-001 § Context |
| Presenter re-read → two tasks | ✅ run against this task's § Context, the original report being conversational and gone |

Two findings worth keeping:

- **The regression-check escape hatch fired unplanned.** No CI was offerable (external `paths`), so
  TASK-001's guard cannot be automated; the task records the reason and names TASK-002 as the
  blocker. The clause held on a repo it was not designed against.
- **Criterion wording vs. rule.** The human-test line says a blocking defect is "handled first"; the
  rule says *handled at the delegation it blocks*, which is what happened and what is correct. The
  test-plan wording is the loose one — no skill change needed.
- **The drill outran the rule on one point, and the rule was corrected to match.** § 3b originally
  offered [[tasks]] `spawn` "when this adoption is itself running under a task" — which, run from this
  repo against `widget-store`, would have filed the fixture's defects into *this* repo's tree, since
  spawn inherits the origin's parent. The drill used `/tasks new` in the fixture instead: it did the
  right thing while the text said otherwise. `/code-review` caught the gap at this close, and 3b now
  states the task lands in the adopted repo's tracker and confines `spawn` to a same-repo origin.
- **A second correction from the same pass:** step 1's complete-table exit could end a run with a
  defect listed and unfiled, bypassing 3b entirely on an already-adopted repo. 3b now suspends that
  exit while a defect is outstanding. The drill did not catch this — the fixture was unadopted, so the
  early exit never fired.

**`pr:` left null deliberately.** `integration: single-branch`, and `close` step 7's SHA-backfill
instruction for that flow is the defect **TASK-030** already owns — amending to write the SHA changes
the SHA. The close commit is findable from this task's id in its subject, which is what `/specs`
provenance reads anyway. Not written as a trailing comment on the `pr:` field, because that is exactly
the parse hazard TASK-036 is filed about.

### Second drill — the complete-layer re-run, 2026-08-19

Run because the fix above was untested and the first drill structurally could not test it. Same
fixture, now adopted: layer complete, every artifact committed, every owner verb reporting *already
current*, nothing untracked — so step 1's complete-table exit fires. Seeded a third defect
(`package.json` declares `"lint": "node tools/lint-widgets.js --strict"`; no `tools/` exists,
`npm run lint` exits `MODULE_NOT_FOUND`) and **declined the fix**, so a task was the only output the
run could legitimately produce.

Result: ✅ the run continued past the complete table and filed the fixture's TASK-003; commit
`193e223` contains the task file and the dashboard row and nothing else. Under the pre-fix text the
run would have ended at the survey table with the defect listed beneath it and no id — the exact
"mentioned, untracked" outcome § 3b bans, reached by a route the first drill could not reach.

Also confirmed on this path: the *declined* branch behaves the same over a complete layer as it did
over an empty one, and step 4's report carries **created: none · amended: none · left alone: all 11
artifacts · Defects found: 1 → TASK-003** — a report whose only content is a defect, which is what a
re-run over a healthy repo should look like.

Spawned rather than folded in — **TASK-031**: a `missing, not offered` verdict whose premise a filed
task will invalidate (fix TASK-002 and CI becomes offerable) has nothing to reopen the question on a
re-run. Neither 3b nor `LAYER.md` § *CI a repo cannot pass* covers it.
