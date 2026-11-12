---
id: TASK-250
parent: STORY-024
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: done
# blocked: <reason> — add this line while the task is blocked, keeping its status; /tasks unblock removes it
priority: P2
assignee: unassigned
created: 2026-10-04
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [SH-71, SH-79, SH-82]
pr: null
github-issue: null
jira-key: null
picked-by: fix-next
---

# The pi review fallbacks have drifted from the axes they stand in for

## Context

Found by the change-review spec harvest (2026-10-04, TASK-080, EPIC-007 third pass) and confirmed by a second reader
against the files at `adc4c27`. All three are in `skills-pi/`. That tree is frozen against new skills (ADR 0010), but
editing an existing stub is allowed.

- **SH-71 — the code-review stub says Claude Code does not ship it.**
  - `skills-pi/code-review/SKILL.md` says: "Claude Code does not currently surface a `code-review` skill … as of CLI
    2.1.220, so `[[code-review]]` does not resolve there". `README.md` repeats it.
  - ADR 0010 (filed later), AGENTS.md § Architecture, `close.md`, `verify-intent`, `review-comments` and
    `verify-conventions` all say Claude Code ships it, and current sessions list it.
  - So the stub's note is stale.
- **SH-79 — the review stub answers the intent question (partly).** `skills-pi/review/SKILL.md` step 3 asks "do the
  combined changes satisfy the task's acceptance criteria?" inside its PR-level correctness pass, and posts one
  severity-grouped list.
  - That answers `verify-intent`'s question inside the correctness verdict, which recreates the mixing that
    "independent review axes are reported side by side" exists to prevent.
  - It is one pass's own list, not two passes merged.
  - The stub predates `verify-intent`.
- **SH-82 — the security trigger list is a shorter copy.** The `skills-pi/security-review` description lists
  auth/session, data access, user input, crypto, secrets/config, new dependencies and exposed endpoints. Its own
  step 2 and `code-review` step 3 also include file/path handling. A caller reading the description would skip the
  pass on a path-handling diff.

## Acceptance criteria

- [x] The code-review stub and README.md no longer claim Claude Code lacks the skill; the don't-install/shadowing reasoning stays
- [x] The review stub's step 3 no longer judges acceptance criteria, or reports that as a separate fidelity verdict
- [x] The security-review description's trigger list matches step 2, or points at it
- [x] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- CHANGELOG history entries
- Whether `skills-pi/` should exist at all (ADR 0010)

## Human test plan

N/A — stub text. pi loads these files, and the lint's frontmatter checks cover pi's parser.

## Implementation plan

Drafted 2026-11-12 by `/fix-next` (no grill: nobody to answer one). Triggers: four files, four criteria.

1. **SH-71** — `skills-pi/code-review/SKILL.md`: say Claude Code ships `code-review`, as it ships the other two, and
   keep the shadowing and aliasing reasoning. `README.md`: drop the "currently load-bearing" parenthetical.
2. **SH-79** — `skills-pi/review/SKILL.md`: step 3 checks the aggregate for correctness only, and says intent is
   [[verify-intent]]'s separate axis. Step 1 stops noting acceptance criteria it no longer uses.
3. **SH-82** — `skills-pi/security-review/SKILL.md` description: add file/path handling, matching its step 2.
4. Respec `change-review`.

## Outcome

**The fix.** The pi fallbacks for the review skills had drifted from the passes they stand in for:
- **`code-review` stub:** it, and `README.md`, still said Claude Code does not ship `code-review`. It does, and this
  session lists it. Both now say so, and the stub keeps its reason not to be installed (it would shadow the native
  pass).
- **`review` stub:** it judged acceptance criteria inside its PR-level correctness verdict, folding the fidelity axis
  into one severity list. It now checks correctness only and points at [[verify-intent]].
- **`security-review` stub:** its description omitted file/path handling, which its own step 2 lists, so a caller
  reading the description would skip it on a path-handling diff.

**Step 6 split.** 4 of 4 assertions failed on HEAD's copies and pass on the fix, all fix-dependent. Contract pin,
**not evidence**: skills-lint, whose check 1 re-validates the security description against pi's YAML rules, passes on
both.

**Judgement calls.**
- **The `review` stub drops the intent question rather than reporting it as a separate verdict.** The criterion
  allowed either. `close` step 5b already runs [[verify-intent]] as its own axis in both runtimes (`verify-intent` lives
  in `skills/`). A second fidelity verdict from the stub would be a duplicate the two might disagree on.
- **No ADR citation in the stub.** My first wording cited ADR 0010 for "Claude Code ships all three". That record
  exists only in this repo, and a pi user's project lacks it (TASK-271's defect class), so it was removed before close.
  The sentence carries its own reason.
- **The aliasing argument was rephrased, not dropped.** It used to argue from a reference that "still wouldn't
  resolve" in Claude Code. With the built-in present, the argument is now that callers' `[[code-review]]` would not
  resolve to an alias, and repointing them would prefer the stub permanently.
- **Spec** `change-review`: the pi `review` requirement no longer checks acceptance criteria, and says intent is left
  to the fidelity axis. Restamped. `shaped-by` unchanged: the intervening commits (34fe2a9 TASK-120, 4bc23d8 TASK-247)
  are not feature-linked. The `code-review` stub's requirement and the security trigger requirement already read
  correctly.
- **Close gate ran inline** on a ~30-line prose diff.
  - Standards: no finding (the description still passes pi's rules, per lint check 1).
  - Intent: all three content criteria met.
  - Correctness: the one repo-local citation, removed.
  - Security: not applicable; the diff edits a security pass's description, not a security surface.
  - Comments: not applicable.

**Flagged, not fixed.** Nothing.

## Progress log

- step 2 — picked; ranked above TASK-275 because both leave a gap nobody sees (keys 1 and 3), but SH-79's `review` stub answers `verify-intent`'s question inside its correctness verdict at the merge gate, on every pi PR close, while `domain`'s missing ADR-drift pass matters only when ADR drift is looked for (key 2, reachability). Key 6 did not separate them: both `contract-drift`
- step 3 — verified: held, all three. The `code-review` stub and README.md:796 say Claude Code does not surface `code-review` (this session lists it); the `review` stub's step 3 asks whether the changes satisfy acceptance criteria; the security description omits file/path handling that step 2 lists
- step 3b — planned: drafted inline as `/tasks plan --no-grill` would (triggers: four files, four criteria)
- step 4 — layer: local
- step 5 — fix in skills-pi/code-review/SKILL.md, skills-pi/review/SKILL.md, skills-pi/security-review/SKILL.md, README.md (editing existing `skills-pi/` stubs is allowed; ADR 0010 freezes only new ones)
- step 6 — reverted fix (HEAD's copies): 4/4 assertions failed; fix-dependent = all four; contract pins = skills-lint incl. check 1 (passes on both)
- step 7 — respecced change-review (surgical); requirements changed: pi `review` fallback (no acceptance-criteria judgement; intent left to the fidelity axis); intended — TASK-250's criteria. shaped-by unchanged: intervening 34fe2a9 (TASK-120) and 4bc23d8 (TASK-247) are feature: null
- step 8 — handed to /tasks close --unattended; outcome in status:, commit in git log
