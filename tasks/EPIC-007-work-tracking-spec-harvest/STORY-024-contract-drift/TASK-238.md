---
id: TASK-238
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
findings: [SH-31, SH-32, SH-33, SH-34, SH-35, SH-36, SH-40]
pr: null
github-issue: null
jira-key: null
picked-by: fix-next
---

# `/specs verify` and `show` restate the router's and `regen`'s rules, and the copies have drifted

## Context

Found by the specs-from-code spec harvest (2026-10-03, EPIC-007, spec committed in b24eb8b). All seven are in
`skills/specs/verbs/verify.md` and `show.md`, and would be fixed in one pass over the two files. Each verb file must
be readable standalone (AGENTS.md § Output / prose rules), so where a verb restates a rule it must restate it right.

**The no-map case:**
- **SH-31.** The router (`SKILL.md`) prints `No usable spec map — run /specs init to bootstrap.` for a missing map **or**
  an empty `areas:` list. `verify` step 1 prints `No docs/specs/.map.yml — run /specs init to bootstrap.` and checks
  only a missing file, so an empty map read through `verify` alone is processed as zero areas.
- **SH-40.** `show` step 1 loads `.map.yml` and has no step for a missing or empty map.

**The unmapped check:**
- **SH-32.** `verify` step 3 globs "project sources". `regen` step 6 derives its search roots from the map's own
  `sources:` globs, because globbing the project root finds nothing in a polyrepo aggregator. That blind spot is fixed
  in `regen` and still open in `verify`. `SKILL.md` also says the scan covers every tracked file, which neither verb's
  wording states.

**The baseline:**
- **SH-33.** `show`'s stale footer names `<generated-at short sha>`, while `verify` anchors on the later of
  `generated-at` and the spec's own last commit. The footer can name a sha the check did not use.
- **SH-34.** `verify` diffs `<anchor>..HEAD`, so source edits left uncommitted after a regen are never reported stale.
  Whether that is intended is not stated (the *Known bias* paragraph covers a different case).
- **SH-36.** Step 3 defines **stale (unknown baseline)** for an in-repo anchor that resolves to nothing. The render's
  `unknown baseline` line describes only a missing `source-commits` entry for an external repo.
- **SH-35 (cosmetic).** The non-git sentence appears twice on consecutive lines at the end of *The stamp predates its
  own spec*.

## Acceptance criteria

- [x] `verify` and `show` handle a missing **and** an empty map the way the router does, with the same message
- [x] `verify`'s unmapped check uses the same search roots as `regen` step 6, stated once and pointed at from the other
- [x] `show`'s footer names the anchor `verify` actually used
- [x] `verify` says whether uncommitted source edits count, with the reason
- [x] The render has a line for an in-repo unknown baseline, or step 3 reports it under an existing line
- [x] The non-git sentence appears once
- [x] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- `regen`/template disagreements — TASK-239
- `regen`'s ask-steps — TASK-230
- Three rendering readings this task's drill raised (one runner) — TASK-349

## Human test plan

- [x] On an invented git fixture with an empty map, then a populated map whose spec was regenerated and committed, run
      `/specs verify` and `/specs show <area>`. Both print the router's message for the empty map, and the footer's sha
      matches the anchor `verify` reports
  - **Passed 2026-11-12:** fixture `%LOCALAPPDATA%/Temp/d238` built for this run: `empty/` (a git repo whose map has `areas: []`) and `mapped/` (area `core` over `src/**/*.rs`; `c0` 01dd32d initial; `c1` ef4347b adds `sub` and the spec stamped `generated-at: c0`; `c2` eecc26e adds `mul`). `skill/specs` copied from this fix. The brief (`brief.txt` there) asked for the four runs, the git commands, and the baseline with the sentence that chose it, and withheld the expected anchor. Runner `claude -p --disable-slash-commands --permission-mode acceptEdits --allowedTools "Bash(git:*)" "Bash(cd:*)" "Bash(ls:*)" Read Glob Grep < brief.txt`, cwd the fixture root. Runs 1 and 2 both printed `No usable spec map — run /specs init to bootstrap.` Run 3 reported `core` stale, 1 changed source. Run 4's footer read `⚠ stale — 1 sources changed since ef4347b`, the anchor run 3 resolved, not `generated-at` (01dd32d). It listed uncommitted edits, the scan set and the footer anchor as settled. Coldness: it listed no skills and had no Skill tool. **It also found DRILL-238-1:** `c0` and `c1` share a committer date (the fixture was built within one second), and "the later by committer date" had no tie rule. It chose `c1` by inference. Fixed in this task (ties take the spec commit, which the ancestor test proves descends from the stamp), since it sits in the step this task changes. Three cosmetic readings → TASK-349

## Implementation plan

Drafted 2026-11-12 by `/fix-next` (no grill: nobody to answer one). Triggers: three files, seven criteria.

1. **SH-31, SH-40** — `verify` step 1 and `show` step 1: a missing map **or** an empty `areas:` list prints the router's
   `No usable spec map — run /specs init to bootstrap.` and exits.
2. **SH-32** — one owner for the unmapped scan: `regen` step 6 gains the router's "every tracked file", in this repo and
   in each external root, and `verify` step 3 points at it.
3. **SH-33, SH-36** — `show`'s footer names the anchor `verify` step 3 resolved, with an unknown-baseline form. The
   render's `unknown baseline` line gains the in-repo case.
4. **SH-34** — `verify` step 4: uncommitted edits are not counted, because after a regen the tree holds exactly the
   edits the spec was written from, and nothing distinguishes them from later ones.
5. **SH-35** — one non-git sentence.
6. Respec `specs-from-code`.

## Outcome

**The fix.** `/specs verify` and `show` restated rules from the router and `regen`, and the copies had drifted:
- **Empty map:** `verify` checked only for a missing map, so an empty `areas:` list was processed as zero areas, a
  silent all-clear. `show` had no map step at all. Both now print the router's `No usable spec map …` message for a
  missing or empty map.
- **Unmapped scan:** `verify` globbed "project sources", the root-only scan `regen` step 6 had already abandoned
  because it reports nothing on a polyrepo aggregator. `regen` step 6 now owns the scan set (every tracked file, in this
  repo and under the external roots), and `verify` points at it.
- **Footer anchor:** `show`'s footer named `generated-at`, a sha the check may not have used. It now names the anchor
  `verify` resolved.
- **Uncommitted edits:** `verify` now says they are not counted, and why.
- **Unknown baseline:** the render's line covers an unresolvable in-repo anchor as well as a missing external entry.
- **Non-git sentence:** the duplicate is gone.
- **Equal committer dates** (found by the drill): ties now take the spec commit.

**Step 6 split.** 8 of 8 assertions failed on HEAD's copies and pass on the fix, all fix-dependent, one per corrected
statement. The tie rule was added after the split was taken. Its evidence is the drill run that exposed the gap, which
picked the spec commit only by inference. Contract pin, **not evidence**: skills-lint passes on both.

**Judgement calls.**
- **Uncommitted edits stay uncounted**, rather than diffing against the working tree. The tempting fix would report
  every just-regenerated spec stale: regen stamps `generated-at` before the commit that carries the edits, so the tree
  then holds exactly the edits the spec was written from. That is the same false-positive storm *The stamp predates its
  own spec* measured at 60%. The cost is that an uncommitted edit made after a regen surfaces only once committed.
- **The scan set's owner is `regen` step 6**, not `verify` or the router. It carries the measurement (0 own sources, 97
  sibling projects, 148 unmapped files), and the criterion asked for one statement and a pointer. The router keeps its
  definition of *what* is scanned; step 6 now says *where*.
- **The tie rule folded in** rather than spawned. It sits in the step this task already changed (the footer must name
  the anchor, and with a tie the anchor was undefined). The ancestor test immediately above makes the answer mechanical.
- **Drill fixture built fresh** (`d238`); no earlier fixture had this shape.
- **Spec** `specs-from-code` updated in five requirements (verify's anchor including the tie, its uncommitted-edit
  exclusion, its no-map message, its unmapped scope; regen's tracked scan set; show's map exit and footer anchor) and
  restamped. `shaped-by` unchanged: the one intervening `skills/specs` commit (8815b8b, TASK-239) is not feature-linked
  and updated this spec itself.
- **Close gate ran inline** on a ~25-line prose diff.
  - Standards: no finding. The rule now has one owner and a pointer, as § *Defer to a shared inventory* asks.
  - Intent: all seven criteria met, plus the tie.
  - Correctness: the regen step-6 pointer from `verify` resolves, and step 6's own numbering is unchanged.
  - Security: not applicable.
  - Comments: not applicable.

**Flagged, not fixed.** Three single-runner rendering readings → TASK-349, P3.

## Progress log

- step 2 — picked; ranked above TASK-239's siblings in STORY-024 and TASK-264 because SH-31 makes `/specs verify` process an empty map as zero areas and report nothing, a silent all-clear on the very check meant to find spec drift (keys 1 and 3), on a verb any project with specs runs; TASK-264 is a weaker phrasing of one capability check (key 1). Last run's runner-up. Key 6 did not separate them against the other STORY-024 tasks: all `contract-drift`
- step 3 — verified: held, all seven. verify step 1 checks only a missing map and prints a different message; show step 1 has no map step; verify step 3 globs "project sources"; show's footer names `generated-at`; step 4 diffs `<anchor>..HEAD` with no word on uncommitted edits; the render's unknown-baseline line covers only external entries; the non-git sentence repeats
- step 3b — planned: drafted inline as `/tasks plan --no-grill` would (triggers: three files, seven criteria)
- step 4 — layer: local
- step 5 — fix in skills/specs/verbs/verify.md, show.md, regen.md (step 6 owns the scan set); plus the equal-date tie rule in verify step 3, found by the drill
- step 6 — reverted fix (HEAD's copies): 8/8 assertions failed; fix-dependent = all eight; contract pins = skills-lint (passes on both); the tie rule's evidence is the drill that exposed it
- step 7 — respecced specs-from-code (surgical); requirements changed: verify anchoring (tie; uncommitted edits), verify output (no-usable-map message; unmapped scope), regen unmapped scope (tracked files), show (map exit; footer anchor); intended — TASK-238's criteria plus the drill's tie. shaped-by unchanged: intervening 8815b8b (TASK-239) is feature: null and respecced this area itself
- step 8 — handed to /tasks close --unattended; outcome in status:, commit in git log
