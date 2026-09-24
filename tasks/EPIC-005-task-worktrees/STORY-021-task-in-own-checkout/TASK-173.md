---
id: TASK-173
parent: STORY-021
feature: FEATURE-001
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: done
priority: P1
assignee: ai
created: 2026-09-24
depends-on: []
blocks: [TASK-174, TASK-177, TASK-178]
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: []
pr: null
github-issue: null
jira-key: null
---

# Declare `workspace:` and `worktree-root:` in the tasks config

## Context

FEATURE-001 D2 and D5. Where a task's work happens gets its **own** declaration, separate from
`integration:` (which answers how work *lands*): `workspace: in-place | worktree`. Where worktrees
live is a second declaration, `worktree-root:`, because nothing in a repository determines it — the
same reasoning `siblings.root` already carries in `skills/tasks/templates/config.yml`.

Both are declarations, so both follow AGENTS.md § *A template ships nothing a render cannot make
true*: the template ships them **commented out**, carrying a choice (`<in-place|worktree>`) and never
a value, and the line's absence means undeclared. Absent `workspace:` means `in-place` — today's
behaviour, unchanged. `/tasks init` reconciles an older config by adding the commented block, never by
filling a value (`skills/tasks/verbs/init.md` step 3).

D2's rationale names one incoherent pair: `integration: single-branch` with `workspace: worktree`
(there is no task branch to put in a worktree). What the verbs *do* with that pair is not decided
yet — settle it in the plan and record it with `/feature decide FEATURE-001`, since it is observable
behaviour.

## Acceptance criteria

- [x] `skills/tasks/templates/config.yml` carries a commented `workspace:` and `worktree-root:` block, each saying what absence means, in the style of the `integration:` and `siblings:` blocks.
- [x] `skills/tasks/verbs/init.md` reconciles a config lacking the block (adds it commented, never a live value) and reports it as **brought up to date**.
- [x] `skills/tasks/SKILL.md` names the two fields next to *Declare the integration model, don't infer it*, and states that `workspace:` is read, never inferred from whether worktrees happen to exist (`git worktree list`).
- [x] The `single-branch` + `worktree` pair has a defined behaviour, recorded as a new decision row on FEATURE-001.
- [x] AGENTS.md § Conventions records the new cross-cutting declaration (register-on-introduce), as a pointer where the skill owns the detail.
- [x] `bash .github/workflows/skills-lint.sh` passes.

## Out of scope

- What `pick` does with the fields — TASK-174, TASK-175.
- Front-door parity (`new-project`, `adopt-project`, `LAYER.md`) — TASK-177.
- Two pre-existing `init.md` contradictions the re-drill surfaced (when mode detection runs; whether a re-run writes) — TASK-180 (DRILL-173-1, -2).
- Invalid `workspace:` values, and the `pick`-side D11 report line — TASK-174 (criteria added from this task's review).

## Human test plan

- [x] On a scratch copy of a consumer repo whose `tasks/.config.yml` predates the fields, run `/tasks init`. Expected: the commented block is added, no live `workspace:` or `worktree-root:` key appears, and the report says *brought up to date* naming both.
- [x] Re-run it. Expected: *already current*, file unchanged.

## Implementation plan

⚠ Acceptance criteria question (resolved 2026-09-24): the `single-branch` + `worktree` behaviour is *defined* here, but `pick.md` step 7's single-branch branch returns before `workspace:` is read, so no verb would carry it out. TASK-174 now carries a criterion for the report line, and D11's `→ Tasks` names both tasks.

**Proposed decisions (put to the stakeholder via `/feature decide FEATURE-001` before editing):**

- **D11 — `integration: single-branch` + `workspace: worktree`:** work in place and print one fixed line on every `pick` that reaches the branch step: `workspace: worktree has no effect under integration: single-branch — there is no task branch to put in a worktree; working in place.` Rewrite neither field, ask nothing, cache nothing — the effective workspace is derived from two declarations the repo still holds, so it is recomputed every run and starts working the moment `integration:` changes. Rejected: refuse at init (init writes no live `workspace:` yet, and a hand edit skips init anyway); ask at `pick` which field to change (re-decides a declaration inside a verb); silent in-place (indistinguishable from a working setup).
- **D12 — config shape:** two top-level scalars, `workspace:` and `worktree-root:`, placed after `integration:`. Top level because `worktree-root:` also serves drills under `in-place` (D10), and nesting would turn D2's scalar into a map and complicate the anchored `^workspace:` probe. Absolute path used as written; relative resolves against the repo root (parent of `tasks/`), as `siblings.root` does. Absent `workspace:` = `in-place` (not a gap); absent `worktree-root:` = undeclared (the verb needing it asks — TASK-174). Commented examples carry a choice, never a value, and no `../wt` — that suggestion's one home is `pick`'s question.

**Steps**

1. Record D11 (→ TASK-173, TASK-174) and D12 (→ TASK-173) via `/feature decide`; History line closes the question the decomposition left open. Mark provenance: both are the agent's derivations.
2. `skills/tasks/templates/config.yml` — commented block after `integration:`, one paragraph per field: what it declares, what absence means, read never inferred from `git worktree list` (an existing worktree may be someone's review checkout), where a relative root resolves, D11 in one line. Meaning and absence only — no description of `pick`'s question or the adopter's gap handling.
3. `skills/tasks/verbs/init.md` step 3 — Present branch: name all commented declarations, and state **a field counts as present when its commented line is there** (else a re-run re-adds the block). Absent branch: widen "omit the line / keep the comment" to all of them. Real-choice bullet: `workspace:` and `worktree-root:` are **not asked by init**. Step 5: adding the block reports *brought up to date*, naming both as "added commented, undeclared — nothing asked".
4. No new init args — TASK-177 AC2 owns declaring `workspace=`/`worktree-root=` with the invocation that passes them.
5. `skills/tasks/SKILL.md` — ~4-line paragraph after *Declare the integration model, don't infer it*: the two fields, absence meanings, not inferred from `git worktree list`, relative-root resolution, D11 in one clause.
6. `AGENTS.md` § Code structure — one sub-bullet under *Read the declaration, never infer it* naming both as declarations of the same kind, pointing at [[tasks]] and FEATURE-001 D2/D5/D11/D12.
7. `bash .github/workflows/skills-lint.sh`; no new lint case (no check changes). Run the human test plan on a scratch consumer copy.

**Risks:** re-run duplicating the block (step 3's "commented counts as present" guards it); init starting to ask for `workspace:` by analogy with `integration:` (explicit sentence guards it); template comments drifting into TASK-174/177 prose.

**Drill (2026-09-24) — human test plan run, both steps pass.** Runner: `claude -p --permission-mode acceptEdits --add-dir "C:/Users/FinStat/.claude/skills" "C:/Source/project-lifecycle-skills"`, brief on stdin, cwd a scratch git fixture holding an unmodified copy of Presenter's `tasks/.config.yml` (written by `/tasks import` 2026-05-28; `integration: pr-per-task` live, no `workspace:`/`worktree-root:`/`siblings:`). **Coldness: not cold on names** — the runner listed the full installed roster including `tasks`; acceptable because this drills *behaviour* (does `init` reconcile the new block correctly), not wording, and the brief withheld every expected outcome. Run 1: both blocks added commented, after `integration:`, no live key; `siblings:` block added too (a pre-existing gap in that config, correctly reconciled); report *brought up to date*, both named "added commented, undeclared — nothing asked", "Unresolved fields: none" — no question invented for either field. Run 2: *already current*, nothing written. Side note from the runner, outside this task: Presenter's live `integration: pr-per-task` may have been minted from an old template default by `/tasks import` rather than chosen; `init` correctly does not re-decide it.

**Close gate (2026-09-24), one verdict per pass.** *Standards* (verify-conventions): pass with warnings — two copied field lists in `init.md` (fixed: the lists were dropped, since a list that can grow must be a pointer); the AGENTS.md pointer landed one paragraph early (fixed: now § *Where the work happens is declared too*); pick-only behaviour in the router (fixed: removed, and TASK-174 carries it). *Fidelity* (verify-intent): pass — every criterion met; the TASK-174 criterion is sanctioned scope; the "`pick` says so" wording was broader than D11 (fixed by removing it). *Correctness* (code review): **one high finding, fixed** — "a commented line counts as present" also covered `integration:` and contradicted LAYER.md's rule that a commented line reads as absent, so a template-shaped config would silently skip the integration question. It now says only that the comment block is not re-added; the field stays undeclared. Also fixed: behaviour promised before TASK-174 lands (medium). Two low findings (invalid values; a hard-coded list in step 5) were moved to TASK-174 and generalised in place. *Comments* (review-comments): no 🛑; "today's behaviour" removed from the template (no referent in a consumer repo); the two other ⚠ lines kept, matching the `integration:`/`siblings:` precedent, as they are the consumer's only copy. *Security*: not applicable — no auth, input, secret or dependency surface.

**Re-drill after the fixes (same runner command), two fixtures in parallel.** (a) Presenter's config: identical outcome to the first run, with no regression. (b) The pre-change template's shape, with `integration:` present only as a comment and no workspace block: run 1 asked the integration question (quoted verbatim), left it absent, reported it **unresolved**, and added the workspace/worktree-root/siblings blocks commented; run 2 reported *already current* for the config, still named `integration` unresolved, and added no block twice. The high finding's failure scenario no longer reproduces. Both runners also surfaced two pre-existing `init.md` contradictions, filed as TASK-180. `skills-lint`: OK; `skills-lint-test`: 56 passed, 0 failed.
