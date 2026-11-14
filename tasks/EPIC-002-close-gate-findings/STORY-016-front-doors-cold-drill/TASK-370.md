---
id: TASK-370
parent: STORY-016
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: done
# blocked: <reason> — set by /tasks block, never by hand; status stays as it is; /tasks unblock removes it
priority: P3
# assignee — one of: agent (default), unassigned, human, or an installed agent type's name; ai is read as agent, never written
assignee: agent
picked-by: fix-next
created: 2026-11-13
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [DRILL-067-1, DRILL-067-2]
pr: null
github-issue: null
jira-key: null
---

# The seed's hint comments sit above their tokens, and `.gitignore` creation disagrees with its own check

## Context

Filed 2026-11-13 at TASK-067's close, from comparing its drill (`%LOCALAPPDATA%/Temp/d067`, `report.md`, § 4) with
earlier ones. Both readings now meet FEATURE-002 D10's two-runner bar.

- **DRILL-067-1 — hint comments above the token.** The seed rule removes "the hint comment (`<!-- … -->`) directly
  beneath" a filled token. In `templates/CLAUDE.seed.md` the Code structure, Naming and UI/UX hints sit **above**
  their tokens, so a faithful render leaves them in the consumer's rulebook. Raised by d360 (point 7) and d067
  (point 2), and a third time by d132 (2026-11-14, a Python scaffold, point 7: it kept the hints above their tokens).
- **DRILL-067-2 — `.gitignore`, creation against check.** LAYER.md's `.gitignore` row creates an absent file "with
  the same entries the Present check looks for … the `!.env.example` negation" unconditionally. Its check offers the
  negation only where the `.env.example` row applies (TASK-357). A file created for a repo whose `.env.example` row
  is `not applicable` therefore carries a line its own check would never offer. Raised by d102b (point 2) and d067
  (point 6).

## Acceptance criteria

- [x] Each seed hint comment's position matches the removal rule, or the rule names both positions, so a faithful
      render leaves no hint in a consumer's rulebook
- [x] The `.gitignore` row's create branch and check branch agree on the `!.env.example` negation
- [x] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- The no-stack `## Conventions` shape: TASK-067 (done)

## Human test plan

- [x] Re-run TASK-067's brief (`%LOCALAPPDATA%/Temp/d067/brief.txt`, on a fresh empty `fieldnotes/` and `skills/` at the
      fix) with a cold runner. Expected: no `<!-- -->` hint left in `## Conventions`, and the `.gitignore` it creates
      matches what its check would ask for
  - **Passed 2026-11-14**, cold drill `%LOCALAPPDATA%/Temp/d370` (`claude -p --disable-slash-commands`, cwd holding only
    `skill/` at the fix, `brief.txt` and an empty `fieldnotes/`; the runner listed no skills), d067's request with
    only step 1 kept. The guide holds no hint comment, only the universal `comment-rule` markers spliced verbatim
    (the UI/UX subsection was dropped as docs-only, so its hint was not exercised). `.gitignore` carries `.env`,
    `.env.*` and `.claude/settings.local.json` and no `!.env.example`, the row the runner settled `not applicable`.

## Implementation plan

Inline: move the three hints beneath their tokens (and the Testing line's inline one), and make the `.gitignore` create branch read the check's answer for the negation.

## Outcome

**The fix.**
- **DRILL-067-1:** `templates/CLAUDE.seed.md`'s UI/UX, Code structure and Naming hints now sit beneath their tokens, and the
  Testing line's inline hint moved onto its own line beneath it. Every hint in the seed templates is now where the
  removal rule ("directly beneath") looks. Text assertion: hints not under a token line — 3 at HEAD, 0 at the fix.
- **DRILL-067-2:** LAYER.md's `.gitignore` row creates the `!.env.example` negation only where its check asks for it,
  and the check now also states the `unknown` case (not offered; it arrives with the Yes that settles the row).

**Found by this task's drill, fixed in it:** the first rewording said "exactly the entries the Present check looks
for", which d370's runner read (point 4) as forbidding the stack's own ignores. It now reads "its usual ignores, plus
every entry the Present check looks for". Checked by reading, not re-drilled.

**One-runner readings left unfiled** (FEATURE-002 D10): d370 points 1-3 and 5-14 (Kind's missing ask wording,
stakeholders from "the team", the `{{STACK}}` line under no stack, `.editorconfig` indent with no stack, an empty
`## Amendments`, a checklist line for the docs-only CI skip, and wordings the scaffolder leaves free).

**Close gate (inline; two skill files plus one spec):**
- **Standards:** the row stays the one list both doors read; no copy added.
- **Intent:** all criteria met.
- **Correctness:** d370.
- **Security, comments:** not applicable.
- **CI:** local lint passes; main is unpushed.

## Progress log

- step 2 — picked; ranked above TASK-365 because both are P3 cold-drill readings and this one's first reading is raised by three runners and leaves scaffolder notes in every scaffolded rulebook (wrong output on every run), where TASK-365's are adoption-report details
- step 3 — re-verified: three seed hints sit above their tokens at HEAD; the create branch writes the negation unconditionally
- step 5 — fixed: hints moved beneath their tokens; the create branch reads the check's answer
- step 6 — behavioural: d370 (no hint in the guide, no negation in a `not applicable` repo); text: 3 hints above tokens at HEAD, 0 at the fix
- step 7 — respecced project-baseline (the gitignore requirement with a docs-only scenario, hint position), restamped
- step 8 — closed inline; commit in git log
