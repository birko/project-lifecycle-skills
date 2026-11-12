---
id: TASK-240
parent: STORY-024
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: done
# blocked: <reason> — add this line while the task is blocked, keeping its status; /tasks unblock removes it
priority: P2
assignee: unassigned
created: 2026-10-03
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [SH-45, SH-46, SH-47, SH-51]
pr: null
github-issue: null
jira-key: null
picked-by: fix-next
---

# Three `feature` records name no writer, or several: the prototype line, `superseded`, and the index row

## Context

Found by the feature-lifecycle spec harvest (2026-10-03, EPIC-007, spec committed in b24eb8b). One root cause: a
value the skill reads has no single verb that writes it.

- **SH-46 — nobody writes `Skipped — <reason>`.** `skills/feature/verbs/prototype.md` 4b says the skipped form "is set
  at `/feature new`/`decide` time, not here". `new.md` step 6 writes only the pending form, and `decide.md` never
  mentions the prototype line. The skill calls an absent or unrecorded choice "the bug", and no verb records it.
- **SH-47 — two formats for one line.** `new.md` step 6 writes `Built — <…>`. `prototype.md` 4b writes
  `**Built** — <…>`. [[roadmap]] step 2 reads the line, so the format is a contract.
- **SH-51 — `superseded` has no owner.** `SKILL.md`'s status table says `superseded` is set "when a feature is re-homed
  into another" and gives no verb. `pick` and `status` read it, and *Never silently displace planned scope* requires
  re-homing, but no verb performs the transition or writes `superseded-by:`.
- **SH-45 — the index row has several writers, and one sets a derived value by hand.** `templates/README.md.tmpl`
  says "Do not hand-edit — re-run the verb" and `status` owns the index (AGENTS.md lists it under generated files).
  `new` 6b appends a row, `prototype` 4c edits one, and `SKILL.md` says `decide`/`review`/re-home update rows.
  `prototype` 4c sets the Phase column to `prototyping` by hand, though phase is derived only by `status`, and by
  `status`'s own rule a feature with approved decisions is not `prototyping`.

## Acceptance criteria

- [x] One verb is named as the writer of `Skipped — <reason>`, and that verb's file says when it writes it
- [x] The prototype line has one format, used by every writer and matched by [[roadmap]]'s reader
- [x] One verb owns setting `superseded` and `superseded-by:`, and `SKILL.md`'s table names it
- [x] Every index-row write either goes through `/feature status` or is listed by `status.md` as an allowed exception,
      and no verb writes a phase that `status` would compute differently
- [x] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- The phase rules themselves — TASK-234
- `decide`'s unanswered verdict question, its step-6 commit clash, and `prototype`'s missing commit step, found by this task's drill — TASK-350
- Four rendering readings in `/feature status`'s single-feature mode, found by this task's drill (one runner) — TASK-351

## Human test plan

- [x] On an invented feature, run `/feature new`, skip the prototype, then `/feature decide`. The `## Prototype` line
      reads `Skipped — <reason>` and the index row's phase matches what `/feature status` then computes
  - **Passed 2026-11-12:** fixture `%LOCALAPPDATA%/Temp/d240`: a git repo with `tasks/.config.yml` (`mode: local`, `integration: single-branch`) and FEATURE-001 rendered from the `new` templates. Its `## Prototype` line reads `Pending`, `decisions.md` has one `proposed` row (D1), and the index has the row `new` produces (phase `idea`, prototype `pending`). **`/feature new` itself was not run**: its grill needs a person, so the feature was pre-built in exactly the shape `new` writes, and the test starts at the skip. `skill/` holds copies of `feature`, `roadmap` and `tasks` from this fix. The brief (`brief.txt` there) ran `/feature prototype FEATURE-001 --skip "headless CSV writer; the test suite is the proof"` then `/feature decide FEATURE-001`, and withheld the expected line and phase. Runner `claude -p --disable-slash-commands --permission-mode acceptEdits --allowedTools "Bash(git:*)" "Bash(cd:*)" "Bash(ls:*)" Read Glob Grep Edit Write < brief.txt`, cwd the fixture root. **Result:** the `## Prototype` line reads `Skipped — headless CSV writer; the test suite is the proof`. The index row reads phase `deciding`, prototype `skipped`, written by the chained `/feature status` (its rule 7: a Skipped line gives `deciding`), not by hand. Coldness: it listed no skills and had no Skill tool. It also raised: a `--skip` run defines no output (fixed in this task, step 4d's confirmation line); three defects in `decide` and `prototype` → TASK-350; four single-runner rendering readings → TASK-351

## Implementation plan

Drafted 2026-11-12 by `/fix-next` (no grill: nobody to answer one). Triggers: five files, five criteria.

1. **SH-46** — `prototype` owns the prototype decision both ways: a `--skip "<reason>"` flag writes `Skipped — <reason>`,
   with a worded question and an answer-less path when the reason is missing. `new` names it.
2. **SH-47** — one format, `<Label> — <detail>` with no emphasis, as `new` writes it; `prototype` 4b drops the bold.
   [[roadmap]] no longer reads the line (TASK-236 dropped its collection), so the reader is `/feature status`, which
   matches the label.
3. **SH-51** — `decide` step 4 supersedes a feature when a verdict moves its whole scope (writes `status: superseded`,
   `superseded-by:`, the `N/A — superseded by …` line), and `SKILL.md`'s table names it. The idea template gains a
   commented `superseded-by:` line naming its writer.
4. **SH-45** — every index-row write goes through `/feature status FEATURE-NNN`: `new` 6b and `prototype` 4c chain it
   instead of writing the row, and `prototype` sets no phase by hand. `SKILL.md` says so.
5. Respec `feature-lifecycle`.

## Outcome

**The fix.** Four records in `feature` had no single writer, or several:
- **`Skipped — <reason>`:** nobody could write it, because `prototype` deferred it to `new`/`decide`, and neither
  wrote it. `/feature prototype FEATURE-NNN --skip "<reason>"` now records it.
- **Prototype line format:** written in two formats. Every writer now uses `<Label> — <detail>`, unemphasised.
- **`superseded`:** no verb set it, or `superseded-by:`. `decide` step 4 now does, when a verdict moves a feature's
  whole scope into another.
- **Index rows:** written by hand by `new` and `prototype`, which also set the phase that `status` alone derives. Both
  now chain `/feature status`, which writes the row with the phase it computes.

**Step 6 split.** 5 of 5 assertions failed on HEAD's copies and pass on the fix, all fix-dependent: one writer of
Skipped stated in its file, one line format, `decide` owning `superseded`/`superseded-by:`, no hand-written row in
`new`, and no hand-set phase in `prototype`. Contract pin, **not evidence**: skills-lint passes on both. Its check 4
now also verifies `new`'s `--skip` names a flag `prototype` declares.

**Judgement calls.**
- **`prototype` writes the skip, not `new` or `decide`.** The verb already says it "*is* the prototype decision". A
  skip is the other answer to the same question. `new` runs before anyone has seen the decisions, and `decide` stamps
  ledger rows, not the prototype line. A flag keeps the skip one command, with no form question.
- **`decide` owns `superseded`**, at step 4 where verdicts are written. My first placement, inside its *Changing a
  closed (`done`) feature* section, would have limited superseding to done features. It was moved before close.
- **Index rows: all through `/feature status`, no listed exceptions.** The criterion allowed exceptions. But
  `status`'s single-feature mode already writes one row, and renders the whole index when it is missing, so `new`'s and
  `prototype`'s hand writes had no job left that the chain does not do better.
- **`superseded-by:` ships commented out** in the idea template, naming its writer, per AGENTS.md § *A template ships
  nothing a render cannot make true*: the field's absence is what "not superseded" means.
- **Human test without `/feature new`.** Its grill needs a person, so the feature was pre-built in `new`'s shape, and
  the drill started at the skip. Recorded on the plan line.
- **The `--skip` confirmation line** was added after the drill showed the path defined no output. It is my own new
  path, so it was fixed here rather than spawned.
- **Spec** `feature-lifecycle`: the prototype-line requirement (formats, writers, `--skip`'s no-reason path and its
  scenario), prototype's index refresh and its scenario, the coarse-status requirement (`superseded-by:` written only
  by `decide`), and index ownership (no hand-written row) and its scenario. Restamped. `shaped-by` unchanged:
  the two intervening `skills/feature` commits (e60e426 TASK-334, b928881 TASK-236) are not feature-linked, and both
  respecced their areas.
- **Close gate ran inline** on a ~50-line prose diff.
  - Standards: no finding. The new ask-step carries its question and answer-less path, and the template field ships
    commented.
  - Intent: all five criteria met. Criterion 2's "[[roadmap]]'s reader" no longer exists after TASK-236, so it is met by
    `/feature status`, the remaining reader.
  - Correctness: the supersede was moved out of the done-only section; `review` was confirmed to chain `/feature
    status` before `SKILL.md` claimed it.
  - Security: not applicable.
  - Comments: the template comment names its writer and the absent state.

**Flagged, not fixed.** Three drill findings in `decide` and `prototype` → TASK-350 (P2). Four single-runner rendering
readings in `status` → TASK-351 (P3).

## Progress log

- step 2 — picked; ranked above TASK-250 because both leave a reader acting on a record nobody writes correctly (key 1 wrong results, key 3 silent: SH-46's `Skipped — <reason>` can never be written, so every skipped prototype reads as the "unrecorded choice" the skill calls the bug), but `feature` runs in both runtimes while TASK-250's stubs are pi-only (key 2, reachability). Key 6 did not separate them: both `contract-drift`
- step 3 — verified: held, all four. `prototype` 4b defers Skipped to `new`/`decide`, neither writes it; `new` writes `Built — …`, `prototype` `**Built** — …`; no verb sets `superseded` or `superseded-by:`; `new` 6b and `prototype` 4c write index rows by hand, 4c setting phase `prototyping`
- step 3b — planned: drafted inline as `/tasks plan --no-grill` would (triggers: five files, five criteria)
- step 4 — layer: local
- step 5 — fix in skills/feature/verbs/new.md, prototype.md (`--skip`, its ask-step, one format, the status chain, the skip confirmation), decide.md (step 4 supersede), SKILL.md, templates/idea.md (commented `superseded-by:`)
- step 6 — reverted fix (HEAD's copies): 5/5 assertions failed; fix-dependent = all five; contract pins = skills-lint incl. check 4 (passes on both)
- step 7 — respecced feature-lifecycle (surgical); requirements changed: prototype decision recorded (formats, writers, `--skip`; its scenario), prototype outcome (index through status; its scenario), coarse status (`superseded-by:` by `decide` only), index ownership (no hand-written row; its scenario); intended — TASK-240's criteria. shaped-by unchanged: intervening e60e426 (TASK-334) and b928881 (TASK-236) are feature: null and respecced their areas
- step 8 — handed to /tasks close --unattended; outcome in status:, commit in git log
