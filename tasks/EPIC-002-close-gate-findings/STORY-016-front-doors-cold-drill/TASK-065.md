---
id: TASK-065
parent: STORY-016
feature: null
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: done
priority: P2
assignee: agent
created: 2026-08-22
depends-on: []
blocks: []
# findings: ids this task remediates, from a review/audit/spec-harvest pass (CR-* SEC-* SH-* VC-*)
findings: [DRILL-053-7, DRILL-053-8, DRILL-063-1]
pr: null
github-issue: null
jira-key: null
picked-by: fix-next
---

# `adopt-project` assumes every run is a full run

## Context

**From the 2026-08-22 cold drill** (STORY-016 § Provenance). Two findings, deliberately one task — they
are the same assumption seen from two sides, and TASK-060's routing criteria called for considering them
together.

### DRILL-053-7 — no state for a present row whose owner verb has not run

Three rules combine into a hole:

- `adopt-project/SKILL.md:47-51` — *"From outside you cannot see a version… Where the artifact's row
  names a verb, **step 3's delegation is what answers, so leave the version question to it rather than
  guessing here**."*
- `SKILL.md:73-78` — a "complete" table ends the run *"only when no row names a verb to delegate to, or
  every such verb has already answered."*
- `LAYER.md:61-66` — *"'nothing to do' is not 'up to date' … Where that is the whole answer available,
  report the row **unknown** and name the init that could not answer."*

A survey scoped to § 1 (a pre-flight check, a read-only pass) is told not to guess the version, told the
answer comes from a step it is not running, and given no state for the result. The drill hit this on
**both** target repos — `tasks/` and `docs/specs/.map.yml` — and had to invent
*"present, currency unresolved"*, then state in both reports that its survey certified
*nothing-missing* rather than *complete*.

**Its reasoning for rejecting `unknown` is worth preserving:** `unknown` means "I could not determine
it" about **existence**, and `SKILL.md:139` scopes it to *"an `unknown` that came from a verb's
silence"* — a verb that ran and declined. Reusing it for a verb never invoked would print one word for
two different situations, which is the collapse the survey's own rules warn about elsewhere.

### DRILL-053-8 — § 4 owes output only § 2 produces

`SKILL.md:90-93` requires the inference round's skip to be stated *"in this step's own output, **and
again in step 4's report**… A silent skip is indistinguishable from a skill that forgot the step."*
`SKILL.md:274` similarly requires the `not applicable yet` bucket to say that glossary candidates travel
as a finding — and candidates are collected in § 2 (`INFER.md`).

So a run scoped to § 1 + § 4 owes a report the skill's own text calls defective if omitted. The drill
produced both anyway, labelled *"would have been step 2's own output"*, because staying silent would
have triggered the exact failure that passage names.

### The shared root

The skill is written as though it always runs start to finish. A **scoped run is a reasonable thing to
want** — a pre-flight before touching anything, a re-survey to see whether a blocker cleared, a
read-only audit of someone else's repo — and it currently cannot express its own central result. Decide
whether scoped runs are supported: if yes, they need a state and a report contract; if no, say so
plainly so nobody builds on it.

### Merged in 2026-09-26: TASK-090 — The survey cannot say whether this is a first adoption or a re-run

_Merged because both are the adopt-project survey not knowing whether a run is a first adoption or a re-run. The original file stays, cancelled, at `tasks/EPIC-002-close-gate-findings/STORY-016-front-doors-cold-drill/TASK-090.md`._

**From the 2026-09-01 cold drill of `adopt-project`'s survey** (TASK-063's).

The skill has **two** advertised use cases, and its description gives them equal billing: bring a repo onto
the layer, and *"the UPGRADE path — re-run it whenever the universal layer grows, to reconcile a repo that
adopted an older version."* Which one a given run is doing changes what nearly every row means — `missing`
on a first adoption is expected, `missing` on a re-run means something regressed or the layer grew.

**The survey has nowhere to say which it is.** The drill surveyed two repos and found that **both** carried
`docs/BRIEF.md` whose `## Origin` reads *"Adopted 2026-08-18"* — so both runs were reconciliation passes,
not first adoptions. It surfaced that only because it happened to **open** the file rather than stat it,
and said so plainly: *"nothing in step 1 asks the survey to characterize whether this is a first adoption
or a re-run — I inferred it mattered because the skill's own framing depends on it."*

**Why this outranks its size.** The fact is free — it is one line in an artifact the survey already visits,
and the adopted-repo brief is *designed* to carry exactly this stamp. An agent that stats `docs/BRIEF.md`
for presence and moves on has the answer in its hand and discards it. And the consequence is not cosmetic:
a reader handed a table of `missing` rows reads a young repo being onboarded, when they may be looking at a
mature repo that has drifted or a layer that has grown three artifacts since.

**Related, not duplicate:** the states in § *Detect what the repo has* describe **one artifact each**. This
is a property of **the run**, so it is not a state and must not become one — the risk in fixing this is
inventing a nineteenth row for something that belongs in the report's header.

## Acceptance criteria

- [x] Whether a scoped / read-only run is a supported mode is **stated**, either way
- [x] If supported: a present row whose owner verb was not invoked has a named state, distinct from `unknown` (a verb that answered with silence) and from plain `present`
- [x] If supported: the report contract says what § 4 owes when an earlier step did not run, so a scoped report is not defective by its own definition
- [x] If not supported: the passages that imply a partial run is possible are corrected, and `adopt-project` says a run is all-or-nothing — **not applicable: supported was chosen (2026-11-12, the user)**
- [x] Either way, `SKILL.md:73-78`'s completeness rule still distinguishes *nothing missing* from *complete* — that distinction was right and the drill relied on it
- [x] `bash .github/workflows/skills-lint.sh` passes

*From TASK-090:*

- [x] The survey establishes whether the repo has been adopted before, from evidence it already collects — `docs/BRIEF.md`'s `## Origin` stamp is the obvious source, and the row already exists
- [x] The answer appears where a reader sees it before the table, not as a row inside it
- [x] A repo with no brief, or a brief with no origin stamp, yields an honest "cannot tell" rather than an assumption of first adoption
- [x] The distinction changes something concrete in the report — at minimum, how a `missing` row is worded on a re-run versus a first pass — or the task records why it is presentation-only
- [x] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- Teaching the owner verbs to report a delta — **TASK-024**. This task is about the state a survey assigns when it has not asked them.
- The other drill findings — separate tasks under STORY-016.
- Adding a `--survey-only` flag as such. Whether the mode gets a flag is downstream of deciding it exists; if it does, the flag's every-step contract is `close`'s `--unattended` lesson to reapply.

*From TASK-090:*

- Changing what any row's state means. This is about the run, not the artifacts.
- `docs/BRIEF.md`'s own shape — [[new-project]] and `LAYER.md` § *The adopted-repo brief* own that, and the stamp this task reads already exists.

## Human test plan

- [x] Run a scoped survey (§ 1 + § 4 only) against a repo with a present `tasks/` tree and confirm the row's state and the report both read correctly without the delegation having run
  - **Passed 2026-11-12:** fixture `%LOCALAPPDATA%/Temp/d065/adopted` (a git repo with `docs/BRIEF.md` stamped `## Origin` *Adopted 2026-08-18*, `tasks/.config.yml` declaring `mode: local` and `integration: single-branch`, `tasks/README.md`, a `CLAUDE.md` with one convention, `src/app.py`), the whole `skills/` tree copied to `skill/`. The brief (`brief.txt` there) asked for "/adopt-project — survey only, read-only" and withheld the expected states. Runner `claude -p --disable-slash-commands --permission-mode acceptEdits --allowedTools "Bash(git:*)" "Bash(cd:*)" "Bash(ls:*)" Read Glob Grep < brief.txt`, cwd the fixture root. The `tasks/` row read `present, owner not asked` ("`/tasks init` would answer whether it is current"), quoting § *Scoped runs*. The report carried it in its own bucket as `present — currency not checked; /tasks init would answer (scoped run)`, and printed `step 2|3|3b|3c not run — scoped run`. Both repos were unchanged afterwards. Coldness: no skills listed, no Skill tool
- [x] Confirm the report distinguishes *nothing is missing* from *the layer is complete* — the drill found that distinction load-bearing and it must survive
  - **Passed 2026-11-12**, same run: neither repo was called complete. The runner quoted step 1's "A scoped run cannot meet that, so it reports *nothing missing*" and § *Scoped runs*' "never 'complete'", and reported "Not complete" with counts, since both repos had missing rows
- [x] Run a full pass on the same repo and confirm the scoped and full reports do not contradict each other
  - **Not run 2026-11-12.** A full adoption delegates to `/tasks init`, `/specs init` and the other owners and writes files, so it needs a person or a longer drill than a defect run carries. The scoped report it compares against is kept at `%LOCALAPPDATA%/Temp/d065/report.md`
  - **Passed 2026-11-13**, run at the user's request. Both sides were redone against `skills/` at `0bc573d`, since the
    11-12 copy predated the unasked-questions bullet. Fixture `%LOCALAPPDATA%/Temp/d065b/{scoped,full}`: each got its own
    copy of `d065/adopted` and of `skills/`, and its own cold runner. The command was 11-12's, run with cwd at that
    fixture's root. The full runner was also allowed `Bash(mkdir:*)`, `Write` and `Edit`. Briefs and reports are kept
    there as `brief.txt` and `report.md`.
    - **Coldness:** both runners listed no skills and had no Skill tool.
    - **Repo state after:** the scoped repo was left unchanged. The full run wrote 12 files and committed nothing.
    - **No contradictions.** Before anything was written, the two runs gave every row the same state:
      - Both printed the same `run: re-run — … adopted 2026-08-18` line.
      - The same seven rows were `missing`, worded for a re-run.
      - `LICENSE` was `unknown`.
      - `.env.example` and `Dockerfile` were a derived `not applicable`.
      - The glossary and ADR rows were `not applicable yet`.
      - The `.gitignore` gap on `.env.*` was named.
    - **The rows that differ, differ only where the scoped run said why:**
      - The scoped `tasks/` row read `present, owner not asked` ("/tasks init would answer"). In the full run `/tasks
        init` did answer, *brought up to date*, and the row went to **amended**.
      - The scoped run's one `asked by a full run, not this one:` question, the licence posture, is the full run's
        question 1, nearly word for word.
      - The scoped run said CI "would be offered by a full run", and the full run offered it.
    - **Neither run called the layer complete:** the scoped run said "not complete — 7 rows missing, 1 present with its
      owner not asked, 1 unknown", and the full run left `docs/architecture.md`, the CI gate and `LICENSE` open.
    - **One gap, and it is not a contradiction.** Of the full run's other offers, the scoped report carries the
      `.gitignore` and CI ones but not the README "How we work" pointer, and its README row reads plain `present`. A
      scoped run owes every *question* step 2 would put, and whether a fill offer is one of those is TASK-102's open
      question. Recorded there.
    - **New readings, not about scoped runs:** filed as TASK-354.

*From TASK-090:*

- [x] Run the survey against a repo whose brief carries an adoption stamp and one that has never been adopted, and confirm a reader can tell the two runs apart without opening any file themselves
  - **Passed 2026-11-12**, same run, second repo `d065/fresh` (README and `src/app.py` only): its report opened `run: cannot tell whether this repo was adopted before — no docs/BRIEF.md`, against `adopted/`'s `run: re-run — this repo was adopted 2026-08-18 (docs/BRIEF.md § Origin)`. Only the adopted repo's `missing` rows carried the re-run wording

## Implementation plan

Drafted 2026-11-12 by `/fix-next` (no grill: nobody to answer one). Triggers: two files, eleven criteria, an open
decision.

1. **TASK-090 half, independent of the decision** — `adopt-project` step 1 heads the survey table with a `run:` line
   read from `docs/BRIEF.md`'s `## Origin` stamp: a dated re-run, or `cannot tell` (no brief, or no stamp), never an
   assumed first adoption. On a re-run, a `missing` row reads as gained or removed since the adoption. Step 4's report
   opens with the same line.
2. **The decision** — put to the user, with supporting scoped runs recommended. **Answered 2026-11-12: support it.**
3. **Scoped runs** — a `### Scoped runs` section in `adopt-project`: when a run is scoped, that it runs steps 1 and 4,
   and what it owes (the new state, a `step <n> not run` line per skipped step, every unasked question, and *nothing
   missing* never *complete*). A new survey state `present, owner not asked` goes in LAYER.md § *Detect what the repo
   has*, the single inventory, and step 4 says what it owes. Hooks in step 1's version bullet and completeness rule.
4. Respec `project-baseline`.

## Outcome

**The fix.**
- **Run line:** `adopt-project`'s survey now heads its table with what kind of run this is, read from the adopted
  brief's `## Origin` stamp. On a re-run, each `missing` row says the layer gained it or it was removed since the
  adoption date. With no stamp, the run says it cannot tell, and never assumes a first adoption.
- **Scoped runs:** on your decision, a survey-only, read-only run is now a supported mode. Its present rows whose owner
  verb never ran read `present, owner not asked`, a new state in LAYER.md. Its report prints
  `step <n> not run — scoped run` for each skipped step and lists the questions a full run would have put. It reports
  *nothing missing*, never *complete*.

**Step 6 split.** 6 of 6 assertions failed on HEAD's copies and pass on the fix, all fix-dependent: the mode stated, the
named state, the per-step line, nothing-missing versus complete, the run line with its cannot-tell case, and the
re-run wording of `missing`. Contract pin, **not evidence**: skills-lint passes on both. The unasked-questions bullet was
added after the split, from the drill; its evidence is the drill reading that prompted it.

**Judgement calls.**
- **The decision was asked, not taken.** The task's own Context says "decide whether scoped runs are supported", and
  the guardrail sends such a question to a person. The run line, independent of it, was built first. The user chose
  *support it* (the recommendation): drills keep wanting this mode, and two cold runners each invented the missing
  state.
- **A new state, not a reused one.** `unknown` already means an owner that ran and gave no answer, and the drill's own
  reasoning (kept in Context) rejected reusing it. `present` would claim a currency nobody checked.
- **The run line is a header, not a row**, as the merged TASK-090 required. It is a property of the run, and a
  nineteenth row would say an artifact is missing something.
- **`cannot tell` covers a scaffolded repo too.** A repo `new-project` built has a verbatim brief and no `## Origin`.
  Calling that a first adoption would be the assumption the criterion forbids.
- **No flag.** The mode is taken from the request ("survey only", "read-only"). The Out of scope makes a flag
  downstream of the decision, and none is needed for the stated behaviour.
- **Layer parity:** the state lives in LAYER.md, the one inventory both front doors read. `new-project` scaffolds and
  never surveys, so it gains nothing to change.
- **Parked at `verify`**, not `done`: the full-pass comparison step was not run (Human test plan).
- **Spec** `project-baseline`: four requirements updated (survey states, the table header, scoped runs, the report
  contract). Restamped. `shaped-by` unchanged: the intervening commits (6eaa977 TASK-092, 80f52f9 TASK-248, be3e932
  TASK-275) are not feature-linked.
- **Close gate ran inline** on a ~70-line prose diff.
  - Standards: the new state is defined once, in the shared inventory, and pointed at. The run line's three cases are a
    table.
  - Intent: every criterion met, the "if not supported" one moot by the decision.
  - Correctness: the section heading was renamed to match its `§ *Scoped runs*` citations, and its item count corrected
    after the fourth bullet.
  - Security: not applicable.
  - Comments: not applicable.

**Flagged, not fixed.** Three pre-existing readings from the drill (LAYER.md and step 4 disagree on reporting a derived
`not applicable`; an undeclared `workspace:` under `single-branch`; the next step on a repo without `tasks/`) →
TASK-353, P3. The 2026-11-13 full-pass drill raised three more about a full run (guide sections written without
consent, `## Commands` stale on arrival, `populate-tests adopt`'s `.gitignore` lines) → TASK-354, P3. Two more
instances of fill offers and delegated questions outside step 2's round → added to TASK-102.

**Closed `verify → done` 2026-11-13**, after the full-pass step passed. That close changed only task files, so the
review passes were not re-run. The diff they judged is the one they reviewed at the first close.

## Progress log

- step 2 — picked; ranked above TASK-274 because both leave a run without a defined result (key 1 wrong results), but `adopt-project`'s survey runs on every adoption and every upgrade re-run while `roll-changelog`'s empty-release case is reached only when a release is cut with nothing in it (key 2). Number 3 in the re-ranked order, after TASK-250 and TASK-275 (both closed). Key 4 counts against it: the scoped-run half needs a decision, and the guardrail's path is taken for that half (non-controversial work first, then ask)
- step 3 — verified: held. DRILL-053-7: `adopt-project` step 1 defers currency to step 3's delegation, the completeness rule needs every owner to answer, and LAYER.md's `unknown` is for an owner that ran, so a scoped run has no state. DRILL-053-8: step 4 owes step 2's skip line and glossary candidates. TASK-090: nothing in step 1 reads the brief's `## Origin` stamp
- step 3b — planned: drafted inline as `/tasks plan --no-grill` would (triggers: two files, eleven criteria, an open decision)
- step 4 — layer: local
- step <guardrail> — decision put to the user: support scoped runs (recommended) / all-or-nothing / decide later. Answered: support it
- step 5 — fix in skills/adopt-project/SKILL.md (run line; § Scoped runs; step 1 and step 4 hooks), skills/new-project/LAYER.md (`present, owner not asked`); spawned TASK-353 for three pre-existing drill readings
- step 6 — reverted fix (HEAD's copies): 6/6 assertions failed; fix-dependent = all six; contract pins = skills-lint (passes on both)
- step 7 — respecced project-baseline (surgical); requirements changed: survey states, survey table header and scoped runs, report contract; intended — TASK-065's criteria and the user's decision. shaped-by unchanged: intervening commits are feature: null
- step 8 — handed to /tasks close --unattended; outcome in status:, commit in git log
