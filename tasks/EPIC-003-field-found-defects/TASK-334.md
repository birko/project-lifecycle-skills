---
id: TASK-334
parent: EPIC-003
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: done
# blocked: <reason> — set by /tasks block, never by hand; status stays as it is; /tasks unblock removes it
priority: P3
# assignee — one of: agent (default), unassigned, human, or an installed agent type's name; ai is read as agent, never written
assignee: agent
created: 2026-11-04
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [DRILL-320-1]
pr: null
picked-by: fix-next
github-issue: null
jira-key: null
---

# `/feature status` templates leave a skipped prototype, the project name and the run mode undefined

## Context

Found by TASK-320's two-runner drill (2026-11-04, recorded on TASK-320), in `skills/feature/`. Both runners settled these the same way, but by guessing:

- `templates/status.md`'s `{{PROTOTYPE_LINK}}` covers a link, "none yet" and a deleted prototype, not an `idea.md` line reading `Skipped — …`.
- `templates/README.md.tmpl`'s `{{PROJECT_NAME}}` has no stated source (both used `README.md`'s H1).
- The index banner says "(all-features mode)" when a single-feature run renders it because it was absent.

## Acceptance criteria

- [x] `{{PROTOTYPE_LINK}}` states how a Skipped (and N/A) prototype line renders, in `status.md` and in the index column
- [x] `{{PROJECT_NAME}}`'s source is stated
- [x] The banner is true for a single-feature run that renders the whole index
- [x] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- The behaviour the originating task fixed, which its drill passed

## Human test plan

- [x] Re-run the originating drill's brief (recorded on that task's Progress log) on a freshly built fixture with a cold runner. Expected: its "left undecided" section no longer lists these findings
  - **Passed 2026-11-05:** TASK-320's brief verbatim, two runners on rebuilt `%LOCALAPPDATA%/Temp/d320a` and `d320b` (`feature` and `tasks` copied after this fix; `roadmap` not copied, as in TASK-320's own drill). Runner `claude -p --disable-slash-commands --permission-mode acceptEdits --allowedTools "Bash(git:*)" "Bash(cd:*)" "Bash(ls:*)" Read Glob Grep Edit Write < brief.txt`. The two `docs/features/README.md` files are byte-identical: `# Features — repo` from the directory rule, a banner naming the verb with no mode, and Prototype cells `skipped`. Each `status.md` carries `Skipped — CLI command, nothing visual to show.` None of the three findings is in either "left undecided" section; one runner quotes the new rules as what it followed. Coldness: neither listed skills

## Outcome

**What was fixed.** `/feature status`'s templates had three gaps that two cold runners each filled by guessing:
- A prototype recorded as Skipped or N/A now renders as its `idea.md` line, reason included, and links nothing; Pending renders "none yet".
- The index's Prototype cell is a link while the artifact stands, else `pending` · `skipped` · `n/a` · `deleted`.
- The index heading's `{{PROJECT_NAME}}` is the name of the directory containing `docs/`.
- The banner no longer claims "all-features mode", which was false whenever a single-feature run rendered an absent index.

**Step-6 split:** 0/0, because this is a template and prose. Evidence is the drill: two runners wrote byte-identical indexes.

**Judgement calls.**
- **The project name is a directory name, not the README's heading.** A path every run derives the same way, matching how `triage` names its own token. A heading can be missing or say something else.
- **The banner drops the mode rather than gaining a token.** That needs no new value and makes no claim a run must fill (AGENTS.md § *A template ships nothing a render cannot make true*).
- **`deleted` joins the index vocabulary.** It is the same gap, in the same column.

**Review (close step 5b, inline).** Adherence: the template now claims nothing a render cannot make true; the vocabulary is stated once in step 7. Fidelity: all three criteria are met. Correctness: the step 7 heading no longer contradicts its absent-index rule.

**Flagged, not fixed.** The drill fixtures for `/feature status` omit the `roadmap` copy, so its drift note stays unexercised. That is a fixture shortcut, not a skill gap.

## Implementation plan

### Steps
1. status.md `{{PROTOTYPE_LINK}}`: a Skipped or N/A prototype renders as the `idea.md` line says, reason included, linking nothing; Pending renders "none yet".
2. status.md step 7: the index Prototype cell is a link while the artifact stands, else `pending` · `skipped` · `n/a` · `deleted`; `{{PROJECT_NAME}}` is the name of the directory containing `docs/`, matching `triage.md`'s rule for its own token. The step heading becomes "the whole file in all-features mode; one row otherwise", which agrees with its own absent-index rule.
3. README.md.tmpl: the banner drops "(all-features mode)", so it is true for every renderer (a single-feature run on an absent index, and `new`'s fresh render); the author comment lists the Prototype vocabulary.
4. Spec `feature-lifecycle`: Status regenerates the rollup and the index (skipped / n/a text; +1 scenario), and Generated files are owned by status (index heading, banner, Prototype cell).

### Risks
- The `idea.md` reason is author prose in a stakeholder file, rendered as recorded.
- `new.md` 6b writes `pending` and `prototype.md` writes a link, which agree with the vocabulary; neither is repointed here.

## Progress log

- step 2 — picked; ranked above the older pool (TASK-224 and others) because key 5: both TASK-320 runners hit all three gaps, where the older tasks are harvested and not re-verified; keys 1–3 tie (silent template gaps); key 7 ties (P3)
- step 3 — verified: held. status.md:54's `{{PROTOTYPE_LINK}}` covers a link, "none yet" and a deleted prototype, not a Skipped line, and the index's Prototype column has the same gap; README.md.tmpl's `{{PROJECT_NAME}}` has no stated source (triage.md defines its own); the index banner hard-codes "(all-features mode)" though step 7 has a single-feature run render the whole index when it is absent
- step 3b — planned: /tasks plan --no-grill (three criteria); no split signal
- step 4 — layer: local
- step 5 — fix in skills/feature/verbs/status.md (Skipped/N/A/Pending prototype rendering; the index Prototype cell's vocabulary; PROJECT_NAME's source; step 7's heading) and skills/feature/templates/README.md.tmpl (banner without a mode; Prototype vocabulary in the author comment); lint OK (20 skills)
- step 6 — reverted fix: 0/0 failed — prose and template only; fix-dependent = none; contract pins = skills-lint.sh; evidence = the Human test plan drill (two runners)
- step 7 — respecced feature-lifecycle; requirements changed: Status regenerates the rollup and the index (+1 scenario), Generated files are owned by status; intended — TASK-334's criteria
- step 8 — handed to /tasks close --unattended; outcome in status:, commit in git log
