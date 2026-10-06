---
id: TASK-078
parent: STORY-007
feature: null
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: done
priority: P2
assignee: agent
created: 2026-08-26
depends-on: [TASK-263, TASK-262, TASK-077]
blocks: []
# findings: ids this task remediates, from a review/audit/spec-harvest pass (CR-* SEC-* SH-* VC-*)
findings: []
pr: null
github-issue: null
jira-key: null
---

# Findings end at `/tasks intake`, and the skill is actually installed

## Context

The last task in STORY-007, and it carries the story's sharpest sentence:

> **Findings end at `/tasks intake`, not at a grill.** The report is the means; tracked, ranked, pickable
> refactor tasks are the deliverable. Ending at "here is a report, pick one" means the other findings
> evaporate — `intake` already exists to drain exactly this kind of pass.

**This repo has the measurement that proves it.** `AGENTS.md § Findings become tasks, or they evaporate`
exists because review passes write no files; 17 correctly-written defect tasks once sat in `_loose/` where
`/fix-next` could see 2 of them (TASK-040, TASK-042). An architecture pass is a *pass*, so `intake` is the
entry point — not `spawn`, which is for a single adjacent finding.

**And the pool rule applies, which is the part easy to get wrong.** Filing the tasks is not enough: a task
outside a pool is filed but unranked. `intake` stamps the epic `kind: review-intake`, which is what puts them
in [[fix-next]]'s pool — so the handoff must go through `intake` rather than a batch of `/tasks new` calls
that would land the findings somewhere nothing ranks them.

### The second half: it has to be installed

A **new skill folder needs an installer re-run** before either runtime can resolve it — one junction is made
per folder, at install time ([ADR 0009](../../../../docs/adr/0009-installers-link-rather-than-copy.md)).
This is not a footnote: **TASK-011 exists because `adopt-project` shipped invisible to both runtimes** for
exactly this reason. The lint's advisory install-root check will report the drift, and it is advisory, so
nothing fails the build to remind anyone.

New skills go in `skills/` — the only tree linked into *both* roots
([ADR 0010](../../../../docs/adr/0010-skills-pi-is-frozen-and-pi-only.md)).

## Acceptance criteria

- [x] The skill's findings hand off to [`/tasks intake`](../../../../skills/tasks/verbs/intake.md), producing an epic stamped `kind: review-intake` with stories by theme — **not** a batch of `/tasks new` calls
- [x] The handoff states that ending at the report is the failure mode, and why: an unfiled finding is invisible to `pick`, to the `Next up` snapshot, and to [[fix-next]]
- [x] Each filed task carries enough of its candidate's report content to be picked **without** re-reading the report — the report is provenance, not the brief (`intake`'s own rule for `--source`)
- [x] The handoff passes a `source:` that names `improve-architecture`, writes each filed task's candidate key (`<class>:<path>`) where a later run reads it, and files every rejection into the epic's dropped list in the shape TASK-262 states, even when the run has only one or two candidates (added 2026-10-06 from TASK-076's close-gate reviews)
- [x] A theme slug is chosen from `intake`'s ladder for each story, so `fix-next`'s key 6 has something to read — never inferred from a title
- [x] Both installers are re-run and the skill resolves in **both** roots; `skills-lint`'s install-root section reports no drift for it
- [x] The skill is registered where the repo expects a new one: `README.md`'s skill list and `docs/architecture.md` if it changes the picture
- [x] `bash .github/workflows/skills-lint.sh` and `skills-lint-test.sh` both pass

**Note from TASK-263 (2026-10-06):** a rejection a later run reports as gone (`rejected file gone` / `rejected member gone`) stays in the earlier epic's dropped list, because the pass never edits it. The handoff that files the later run decides how its record says so, or every run after it reports the same entry again. Also, the key this task writes onto each filed task is the pass's `<key>`, `<n>:<path>` or `<n>:<path>#<member>` (`skills/improve-architecture/SKILL.md` Step 4), not a bare `<class>:<path>`.

**Note from TASK-077 (2026-10-06), a proposal for this task to confirm, not a settled answer:** the report's six candidate parts (`skills/improve-architecture/SKILL.md`
§ *Every candidate, one shape*) are the content each filed task carries, so it can be picked without the report.
The report's Rejected section prints each record line verbatim, and those lines are what goes into the epic's
dropped list.

## Out of scope

- The scan, the finding classes and the report — **TASK-076** and **TASK-077**.
- Changing `intake` itself. If the architecture pass needs something `intake` cannot express, that is a finding against `intake` and gets its own task rather than a local workaround.
- Draining the tasks the first run files. That is `/fix-next`'s job afterwards, and deliberately a separate session.
- Deferred to TASK-270 — intake's small-pass and re-run rules, which Step 7's new-epic-per-run needs changed

## Human test plan

- [x] Run the whole pass on this repo end to end and confirm the deliverable is **tracked tasks in a pool**, not a report — then check `/fix-next` can actually see them
- [x] Pick one filed task and confirm it is workable without opening the report
- [x] Confirm the skill resolves in both `~/.claude/skills` and `~/.pi/agent/skills` after the installer re-run — the TASK-011 failure mode, which is silent
- [x] Confirm at least one finding is *rejected* by the deletion test and does **not** become a task, so the filter is visibly doing work

## Implementation plan

Drafted 2026-10-06 by the `Plan` agent, against the skill as TASK-263/266/267 left it.

**Criterion 7 reading:** README §1 *The skills at a glance* lists core skills only; no satellite skill is in it (`domain`, `verify-intent` and `review-comments` all sit in §5). So "README's skill list" is §5's satellite diagram plus §3's intake paragraph, and §1 is left alone. That is the repo's existing practice, not a choice made here.

1. **`## Step 7 — File the findings`**, after Step 6 and before the report, so the records line is true when the report is written.
   - It states the failure mode: a run that ends at the report has failed, because an unfiled finding is invisible to `pick`, to `Next up` and to [[fix-next]].
   - It chains `/tasks intake` with `--source "improve-architecture <short HEAD> <date> — report: <path>"`.
2. **A new epic for every run, never `--epic`.** Each run's dropped list is the full standing set of rejections:
   - this run's rejections;
   - `held by ADR` lines;
   - every `previously rejected, unchanged` entry, copied verbatim.

   A gone entry is not copied; its absence is the record, named in the epic's Area of concern. Step 1 then reads only the latest earlier run's list. That settles TASK-263's note with intake's existing shapes.
3. **The key:** a fixed `Candidate key: <key> — IA-<n>` line in each filed task's Context. It is a declaration, read back by Step 4's parse rule; no template change, so intake is untouched. Step 1 reads open and done tasks by their `IA-*` findings and those lines.
4. **Themes by class,** passed as `{{THEME}}`: 1 and 2 → `reuse-dead-code`; 3 and 4 → `correctness-invariants`; 5 → `docs-i18n-coverage`. A task mixing themes takes the one earlier in intake's table. Severity is always `suggestion`, so P2; strength is never passed as severity. A `contradicts ADR` candidate is filed with "reopen ADR NNNN through [[domain]]" as its first criterion. `recurs after` is filed fresh, as a regression. `already filed` is not filed again.
5. **No confirmation before filing,** as with publishing. The answer-less case is no task tree: then nothing is created, and the records line says `not filed — no task tree; run /tasks init, then /tasks intake --source <report path>`.
6. **Registration:** README §5 satellite diagram and §3 intake paragraph; `docs/architecture.md` "How the skills compose".
7. **Installers:** `install.ps1` and `pi-install.ps1`. Then check both roots, check that lint check 6 no longer names the skill, and run `skills-lint-test.sh`. No lint change, so no new lint case.
8. **Human test plan:** an **author run** on this repo, recorded as such and not as a cold drill (the skill cites measurements from this repo). If it yields no deletion-test rejection, run that step on the ClientApi clone instead.

## Progress log

- 2026-10-06 — Picked after TASK-262, 263 and 077 closed; plan drafted by the `Plan` agent. Step 7 was written and Step 1 updated to read what it writes, both registration sites edited, and both installers run: `+ improve-architecture` in both roots, as junctions. Lint check 6 reported both roots in sync, `skills-lint-test.sh` gave 71 passed and 0 failed, and the skill appeared in this session's own skill list.
- 2026-10-06 — **Human test plan: author run on this repo**, invoked through the installed skill. Recorded as an author run, not a cold drill, because the skill cites measurements from this repo.
  - **Rung 2.** 353 commits; eight hot directories cleared the bar (median 13, bar 26) and the top five were kept. 50 co-change pairs formed 4 sets.
  - **Filed** EPIC-008 (`kind: review-intake`, `source:` naming the pass), STORY-025 (`correctness-invariants`), and TASK-268 (IA-1: 26 files across 7 skills) and TASK-269 (IA-2: `adopt-project` with `LAYER.md`), each with its `Candidate key:` line and all six parts. IA-3 and IA-4 (the `help.md` verbs) were linked to the open TASK-261 under intake's duplicate rule.
  - **Dropped list:** `2:skills/tasks/slicing.md` (deletion test: merely moves, 5 callers). Step 4 counts the deletion-test rejection, and no task was filed for it.
  - **Report:** published privately at https://claude.ai/artifact/TZrbBBvu9jhHfCum6aB737.
  - **The pool:** fix-next's Step 1 rule, applied to the tree, gives 72 tasks, including TASK-261, TASK-268 and TASK-269. TASK-261 was outside the pool until its IA ids were added.
  - **Pickable without the report:** a cold reader (`claude -p --disable-slash-commands`, run in `C:/Source/WebChecker`, no skills listed) given only TASK-269 said a developer could start it, and named a concrete first step. It also found two criteria uncheckable at merge, one needing future history and one with an escape clause. Step 7 now requires merge-checkable criteria, and both tasks' criteria were rewritten before work started (scope added beyond the criteria, named here as the fidelity review asked).
- 2026-10-06 — **Close gate (step 5b), each axis reported separately:**
  - **Standards:** pass, with two warnings, both fixed: a linked duplicate task gets the `Candidate key:` line (the contract's writing side), and `theme:` is a story field, so a mixed-theme task goes under the first theme's story. Notes: the dashboard was stale (regenerated here). The dropped entry repeats its callers, because the reason is the gate line verbatim, which is the contract; left as is.
  - **Fidelity:** all 8 criteria met. Its three "wrong" items: TASK-261's linked evidence lacked a Before/after part (now carries all six named parts); Step 7 overrode intake's small-pass and re-run rules without saying so (now stated, and the intake side is TASK-270, as this task's own Out of scope requires); the installer re-run leaves no diff trace (the junctions are the evidence).
  - **Correctness:** 6 findings, all fixed or filed:
    1. a cancelled task's key was never read, so a declined candidate came back every run (now `declined: TASK-NNN`; open means any status but done and cancelled);
    2. intake's small-pass rule goes to TASK-270;
    3. linked duplicates got no key line;
    4. `held by ADR` entries outside the scope were lost from the carry-forward (Step 6 now recomputes every held entry read);
    5. "file before the report" versus `--source` naming the report (it is the predicted temp path);
    6. undecided candidates are filed as `tentative`.
  - **Security:** not applicable, because the diff is prose with no security surface. **Comments:** not applicable, because there are no code comments in range.
  - **Out of scope (5d):** 4 boundaries (TASK-076, TASK-077, draining, TASK-270) and 1 spawned (TASK-270), 0 declined.
