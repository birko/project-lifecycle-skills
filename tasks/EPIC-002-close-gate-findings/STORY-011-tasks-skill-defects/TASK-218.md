---
id: TASK-218
parent: STORY-011
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: done
# blocked: <reason> — add this line while the task is blocked, keeping its status; /tasks unblock removes it
priority: P2
assignee: unassigned
picked-by: fix-next
created: 2026-10-03
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [DRILL-217-1, DRILL-217-2, DRILL-217-3, DRILL-217-4]
pr: null
github-issue: null
jira-key: null
---

# `/tasks migrate` leaves its dry run, its confirmation and its hand-off to `export` undefined

## Context

Found by the two cold runners of TASK-217's drill (2026-10-03), each running
`/tasks migrate --to github --repo example-org/shop --dry-run` on an invented tree. They are older than TASK-217,
which only changed which tasks `migrate` selects, so they are filed together here.

| Id | Raised by | Where | Problem |
|---|---|---|---|
| DRILL-217-1 | both runners | `migrate.md` step 2, `--dry-run — show plan + payloads, push nothing` | Does not say whether a dry run still flips `mode: local` to `hybrid` (step 7) or regenerates the dashboard (step 8). Both runners had to decide |
| DRILL-217-2 | both runners | `migrate.md` step 4, "Proceed? (y/n)" / "Confirm before pushing anything" | An ask-step with no answer-less path (AGENTS.md § Output/prose rules), and meaningless under `--dry-run` |
| DRILL-217-3 | one runner | `migrate.md` step 6 vs `export.md` | Step 6 says "track the milestone number for child tasks", but `export`'s `gh issue create` passes no `--milestone` and nothing consumes the number, so tasks are never linked to their epic's milestone |
| DRILL-217-4 | one runner | `migrate.md` step 6 vs `export.md` step 1 | `migrate` runs "the `/tasks export` logic", whose step 1 refuses unless `mode: hybrid`; `migrate` flips the mode only in step 7, after the push. Read literally, every export call errors |

Two of the four were raised by one reader only; they are filed because each is checkable by reading the two
files side by side, not a judgement call.

## Acceptance criteria

- [x] `--dry-run` states exactly which steps it skips (no push, no mode flip, no dashboard regeneration) and what
      it prints
- [x] The confirmation question carries its words and an answer-less path — nobody to answer means nothing is
      pushed and the run reports that; `--dry-run` does not ask it
- [x] Tasks created under an epic are linked to that epic's milestone, or the instruction to track the number is
      removed with the reason — `migrate` and `export` agree
- [x] `migrate`'s use of the `export` logic does not trip `export`'s mode check: the order or the check is stated
      so a literal run succeeds
- [x] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- Which tasks `migrate` selects — TASK-217
- Step 2's interactive repo/project prompt, which has no question text or answer-less path either — TASK-330, spawned by this run

## Human test plan

- [x] A cold `--dry-run` on an invented tree with nobody to answer: it prints the plan, asks nothing, and changes
      no file, `.config.yml` included
  - **Passed 2026-11-04:** the runner printed the plan and every payload, ended with `Dry run — nothing pushed; task files and tasks/.config.yml unchanged.`, put no question (quoting step 4's "never under `--dry-run`"), and `git status --porcelain` was empty afterwards
- [x] Reading `migrate` step 6 against `export` steps 1 and 5: a literal run creates linked issues without an error
  - **Passed 2026-11-04 (reading, by the author):** export step 1 states migrate bypasses its mode check; step 4's duplicate question cannot fire, since migrate pushes only unlinked tasks; step 5 reads `default-labels` from a config with no `external:` block as an empty list, and finds each milestone by `<EPIC-ID> <title>` because migrate creates the milestones first. Just outside the plan's steps, export **step 6** names the repo as `external.repo` from `.config.yml`, which a migrate run has not written yet; only migrate's "repo/project come from this run's args" covers it → TASK-338

## Outcome

**What was fixed.** Four findings from TASK-217's drill, all in `/tasks migrate` and its hand-off to `export`:

- **DRILL-217-1, dry run:** `--dry-run` now runs steps 1–5 only, printing the plan and every payload. It skips the push, label and milestone creation, frontmatter write-back, the `.config.yml` flip and the dashboard. It asks nothing and ends with a fixed `Dry run — nothing pushed …` line.
- **DRILL-217-2, confirmation:** step 4 puts an exact question. Only `yes` proceeds. Anything else, or no answer, pushes nothing and prints `Not migrated — the confirmation was not answered yes; …`. A dry run never asks.
- **DRILL-217-3, milestones:** tasks are now linked. The milestone title format is fixed (`<EPIC-ID> <epic title>`), and `export` step 5 looks the parent epic's milestone up by that title and passes `--milestone`. When there is none, it names the task as not linked and never creates one. `migrate` finds an existing milestone by title before creating one, so a resumed run makes no duplicate.
- **DRILL-217-4, mode check:** `migrate` step 6 runs `export` steps 3–7 with its own provider and repo/project, naming each skipped step and why. `export` step 1 says its `hybrid` check guards a direct call only. `migrate` step 7 flips the config only after every push succeeded.

**Step-6 split: 0/0.** The change is prose only. `skills-lint.sh` passes (20 skills): a contract pin, not evidence. Both Human test plan steps (a cold dry run, and a cold side-by-side read) are the evidence and have not been run. The author's read is not cold.

**Judgement calls** (plan drafted at step 3b, before any edit).
- **Link, don't drop.** `import.md` maps a milestone back to an EPIC, so an unlinked task loses its epic on the round trip. The lookup is by title because a number held for one run is gone on a resumed run or a standalone `export`.
- **Config written last, not first.** Writing it first would make a failed run read `hybrid`, so the re-run would abort at migrate step 1 with half the work pushed, and § Resumability would stop being true.
- **No `--yes` flag.** An unattended migrate can only report, never push. That is the safe direction, and a flag would be new scope.
- **Known gap stated, not fixed:** `--epic-as=parent-issue` still does not link tasks as sub-issues. It is now named in Edge cases, since the criterion covers milestones only.

**Respec.** `work-tracking`: *Migrating to hybrid mode* (confirmation, milestone lookup, the export hand-off, the dry run; plus two scenarios) and *Exporting a task* (milestone linkage, and the migration bypass). The `shaped-by` fields were carried forward, not re-derived.

**Flagged, not fixed.** TASK-330 (step 2's repo/project prompt, spawned).

## Implementation plan

_Drafted 2026-11-04 by the Plan agent (`/fix-next` step 3b, `/tasks plan --no-grill`)._

**Decisions.** (3) Link tasks to the milestone, looked up by title. Don't drop the instruction: `import.md` maps a milestone back to its EPIC, so an unlinked task loses its epic on the round trip, and a number held only for one run is gone in a resumed run or a standalone `export`. (4) `migrate` runs `export` steps 3–7 under its own provider and repo/project, and writes `.config.yml` last. Writing the config first was rejected because a failed run would then read `hybrid`, abort at migrate step 1 on re-run, and break § Resumability.

1. `migrate.md` step 2 `--dry-run`: run steps 1–5, print the payloads, skip steps 6–8 (no push, no label or milestone creation, no write-back, no config change, no dashboard), and never ask at step 4. Print a fixed closing line.
2. `migrate.md` step 4: an exact question; only `yes` proceeds. Anything else, or no answer, pushes nothing and prints a fixed line.
3. `migrate.md` step 6, EPIC: find the milestone by title, create it only if missing; drop "track the number".
4. `migrate.md` step 6, TASK: run export steps 3–7 directly and say which steps are skipped and why. Already-linked tasks are skipped before the call.
5. `migrate.md` step 7: runs only after every push succeeded. § Resumability: an epic is resumed by its milestone title.
6. `migrate.md` step 9: collect export's label and Jira-priority lines; add the count linked to milestones.
7. `export.md` step 1: one sentence saying migrate bypasses the mode check by design.
8. `export.md` step 5/6: a Milestone bullet (GitHub, TASK) passing `--milestone "<title>"`, or reporting the task as not linked; never creating a milestone.
9. `export.md` § Exporting STORY or EPIC: fix the milestone title format `<EPIC-ID> <epic title>`.
10. Lint. Spawn the step-2 interactive-prompt gap (no answer-less path) as its own task.

## Progress log

- step 2 — picked; ranked above TASK-212 because a literal migrate run errors at its first export (DRILL-217-4) and a dry run may flip mode: local→hybrid (DRILL-217-1) — a destructive write from a flag that promises none (key 1); key 6 inert — both are correctness-invariants
- step 3 — verified: held, all four. migrate step 2 --dry-run names no skipped steps; step 4 "Proceed? (y/n)" has no answer-less path; step 6 tracks a milestone number export never passes (no --milestone); export step 1 refuses unless mode: hybrid, which migrate sets only at step 7
- step 3b — planned: /tasks plan --no-grill (more than one file, five criteria)
- step 4 — layer: local (skills/tasks/verbs/migrate.md, skills/tasks/verbs/export.md)
- step 5 — fix in skills/tasks/verbs/migrate.md (steps 2, 4, 6, 7, 9, § Resumability, § Edge cases), skills/tasks/verbs/export.md (steps 1, 5, 6, 9, § Exporting STORY or EPIC); spawned TASK-330; tests: skills-lint.sh (20 skills) green
- step 6 — reverted fix: 0/0 failed — prose only; fix-dependent = none; contract pins = skills-lint.sh; evidence = the two Human test plan steps, not run
- step 7 — respecced work-tracking; requirements changed: Migrating to hybrid mode (+2 scenarios), Exporting a task; intended anyway — TASK-218's criteria, answered by /fix-next; shaped-by carried forward, not re-derived
- step 8 — handed to /tasks close --unattended; outcome in status:, commit in git log
- 2026-11-04 — **Human test plan — cold drill and reading, passed.** Fixture `%LOCALAPPDATA%\Temp\d218`: `repo/` with `mode: local`, no `external:` block, two epics, three stories, six tasks (one done, one verify, one todo with a `blocked:` field, one in `_loose/`, two todo); skill `tasks` copied under `skill/`. Runner: `claude -p --disable-slash-commands --permission-mode acceptEdits --allowedTools "Bash(git:*)" "Bash(cd:*)" "Bash(ls:*)" "Bash(gh auth status:*)" "Bash(gh repo view:*)" "Bash(gh label list:*)" Read Glob Grep Edit Write < brief.txt`, cwd the fixture. `gh` was limited to those three read-only commands so nothing could be created; the target was the public `cli/cli`, so the pre-flight passes and the run reaches the payloads. The brief said it was a drill, barred history and planning docs, said to write any question verbatim and continue unanswered, and asked for the output, the questions, what was left undecided, what was settled, what was inferred, what it read unsent, and its skill list. It stated no expected outcome. Task-specific ask: "Run /tasks migrate --to github --repo cli/cli --dry-run." **Coldness:** it listed no skills. **Result:** as the ticked step says. Also raised → TASK-338: **DRILL-218-1**, export step 5 gives no command for the milestone lookup, and in a dry run the milestones do not exist yet, so a literal lookup reports every task `not linked`; **DRILL-218-2**, the dry run's payloads have no stated position or shape (epic and story payloads, which body sections, the API-call count). → `verify` → **done**.
