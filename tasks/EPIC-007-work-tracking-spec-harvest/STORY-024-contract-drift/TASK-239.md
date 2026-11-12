---
id: TASK-239
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
findings: [SH-37, SH-38, SH-41]
pr: null
github-issue: null
jira-key: null
picked-by: fix-next
---

# The spec template emits a key `regen` says to omit, and `regen`'s steps run out of order

## Context

Found by the specs-from-code spec harvest (2026-10-03, EPIC-007, spec committed in b24eb8b).

- **SH-37 — template vs regen.** `skills/specs/verbs/regen.md` step 5b says to omit `shaped-by-unresolved` when
  `shaped-by-derived` is `false`. `skills/specs/templates/spec.md` always emits `shaped-by-unresolved: {{N}}`, with no
  note that the line is conditional. A faithful render therefore writes a count for a derivation that never ran, which
  is the shape § Conventions *A template ships nothing a render cannot make true* forbids. (`source-commits:` is
  conditional too, and its template line already says so.)
- **SH-41 — step order.** `regen.md`'s steps run 5, 5c, 5a, 5b. Step 5 refers forward to 5a, 5b and 5c, and 5c sits
  before the two it follows by letter.
- **SH-38 — root marker (cosmetic).** `verbs/init.md` step 1 names the root marker `tasks/.config.yml`. `SKILL.md`
  § Project root names it `.config.yml`. The [[tasks]] walk it defers to uses `tasks/.config.yml`.

## Acceptance criteria

- [x] `templates/spec.md` marks `shaped-by-unresolved` as omitted when derivation did not run, in the way the template
      already marks `source-commits`
- [x] `regen.md`'s steps appear in the order they run, with no forward reference
- [x] `SKILL.md` and `init.md` name the root marker identically
- [x] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- `verify`/`show` drift — TASK-238

## Human test plan

N/A — template and step order, checked by rendering the template once for a run where derivation did not run.

## Implementation plan

Drafted 2026-11-12 by `/fix-next` (no grill: nobody to answer one).

1. **SH-37** — `skills/specs/templates/spec.md`: put a trailing `# omit entirely when shaped-by-derived is false`
   on the `shaped-by-unresolved:` line, the shape `source-commits:` already uses, and say the same in the template's
   closing comment block.
2. **SH-41** — `skills/specs/verbs/regen.md`: move 5a, 5b and 5c ahead of the write step and relabel the write
   step `5d`. **Keep the labels 5a, 5b, 5c, 6 and 7**, because other files cite them: `regen step 5a` in
   `feature/verbs/review.md`, `roadmap/SKILL.md` and `specs/SKILL.md` (twice); `regen step 6` in `specs/verbs/init.md`;
   `regen step 7` in `specs/verbs/verify.md`. Nothing outside cites regen's bare `step 5`, so renaming it costs nothing.
   Move `(accepted areas only)` up to 5a, and reword 5a's two pointers at 5b so 5a does not refer forward.
3. **SH-38** — `skills/specs/SKILL.md` § Shape detection: `.config.yml` → `tasks/.config.yml`, matching `init.md`
   and the [[tasks]] walk.
4. Respec `specs-from-code`: only the stamp requirement, whose "`shaped-by-unresolved`, and `source-commits` where
   applicable" the new 5d contradicts.

## Outcome

**The fix.** `/specs regen` was told to leave `shaped-by-unresolved` out of a spec when provenance was never derived,
but the template it renders from always emitted the line. So an agent following the template correctly wrote a count
for a derivation that never ran. The template line now carries the same `# omit entirely when …` marker
`source-commits:` already had. Separately, `regen.md`'s stamp steps are now written in the order they run
(5a derive → 5b stamp the derivation → 5c stamp external repos → 5d write), and `specs/SKILL.md` names the root marker
`tasks/.config.yml`, as `init.md` and the [[tasks]] walk do.

**Step 6 split.** 4 of 4 assertions failed on the HEAD copies of the four files and pass on the fix. All four are
fix-dependent: step order 5a–5d, no 5b–5d reference inside 5a, the template marks the line conditional, and the root
marker matches. Contract pin, **not evidence**: skills-lint passes on both versions and checks none of this. The
assertions were a one-off script, not committed. This repo has no harness for prose-shape checks, and the lint is
not the place for a check that pins one file's step order.

**Judgement calls.**
- **Relabelled the write step `5d` and kept 5a/5b/5c, rather than renumbering 5–8.** Renumbering is the cleaner
  read, but `regen step 5a` is cited from `feature/verbs/review.md`, `roadmap/SKILL.md` and `specs/SKILL.md`, and
  `regen step 6`/`7` from `specs/verbs/init.md` and `verify.md`. Renumbering would have broken five cross-file
  citations, and the lint cannot check them. Nothing cited regen's bare `step 5`.
- **Removed 5a's two forward pointers at 5b** by rewording ("each such task counts as unresolved"; "that count is
  `shaped-by-unresolved`"), so the criterion "no forward reference" holds inside the 5x block. References to step 7
  (the confirmation report) from earlier steps were left alone: they point at where a result is printed, not at a
  step the reader must run first, and SH-41 did not name them.
- **Template: trailing-comment marker, not a commented-out line.** § Conventions *A template ships nothing a render
  cannot make true* has absence-encoded fields ship commented out. This field is present in the normal case and absent
  only when derivation did not run, the same shape as `source-commits:`. The acceptance criterion names that shape, and
  commenting the line out would make a faithful render drop it on every run. The stricter option was rejected for
  that reason.
- **Respec was surgical.** Only the stamp requirement's wording was contradicted ("`shaped-by-unresolved`, and
  `source-commits` where applicable"). Step order and the root-marker wording change no behaviour. `shaped-by` and its
  unresolved count were not re-derived, because the only commit to `skills/specs` since the last stamp
  (3a6bdd7, TASK-345) is `feature: null`, and only feature-linked tasks count toward either value.
- **The close gate ran inline**, not as invoked skills: the diff is ~15 lines of prose. Standards: one finding, fixed
  before close (a sentence added to the template's closing comment block repeated the line-11 marker in the same file,
  so the destination test removed it). Intent: all four criteria met, no scope added beyond the one spec sentence step 7
  requires. Correctness: no remaining citation of a regen step whose meaning moved (grepped `skills/`, `skills-pi/`,
  `docs/specs/`). Security: not applicable, no security surface. Comments: the one comment added is a rendering instruction whose
  only other copy is regen 5b, which a renderer does not read while filling the template, so it was held.

**Human test plan.** Its stated check was rendering the template once for a run where derivation did not run. The
template line now instructs that render to omit the key, and the step-6 assertion pins the marker.

**Flagged, not fixed.** Nothing new.

## Progress log

- step 2 — picked; ranked above TASK-346 because both are wrong-results defects reachable on a routine verb (key 1, 2), but SH-37 makes `/specs regen` — which `/fix-next` step 7 and `close`'s spec offer run unattended — write a plausible false count into a consumer's spec, while TASK-346's ask-step gap fires only when nobody answers an interactive `pick` (key 3, silence). Key 6 did not discriminate here: it would favour TASK-346 (`correctness-invariants` over `contract-drift`) but the pair separated on key 3 first
- step 3 — verified: held. SH-37: `templates/spec.md` line 11 emitted `shaped-by-unresolved: {{N}}` unconditionally while regen 5b says omit it when `shaped-by-derived` is false. SH-41: steps ran 5, 5c, 5a, 5b, and step 5 cited 5a/5b/5c forward. SH-38: `SKILL.md` said `.config.yml`, `init.md` said `tasks/.config.yml`
- step 3b — planned: drafted inline as `/tasks plan --no-grill` would (triggers: three files touched)
- step 4 — layer: local
- step 5 — fix in skills/specs/templates/spec.md, skills/specs/verbs/regen.md, skills/specs/SKILL.md; no test file (a prose repo: the guard is the step-6 check); skills-lint OK (20 skills)
- step 6 — reverted fix (HEAD copies of the four files): 4/4 assertions failed; fix-dependent = order is 5a 5b 5c 5d, no 5b-5d reference inside 5a, template line marks unresolved conditional, root marker identical in SKILL.md and init.md; contract pins = skills-lint (passes on both, checks none of this)
- step 7 — respecced specs-from-code (surgical, stable wording); requirements changed: "Accepted specs are written with a provenance stamp" (`shaped-by-unresolved` only when derivation ran; `source-commits` only when a source is outside the repository). generated-at → 1913051. shaped-by / shaped-by-unresolved unchanged: the only commit to skills/specs since the last stamp (3a6bdd7, TASK-345) is feature: null and already specced
- step 8 — handed to /tasks close --unattended; outcome in status:, commit in git log
