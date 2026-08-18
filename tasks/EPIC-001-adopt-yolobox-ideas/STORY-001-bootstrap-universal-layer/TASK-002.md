---
id: TASK-002
parent: STORY-001
feature: null
# status: todo | in-progress | review (code done, sign-off pending) | blocked | done | cancelled
status: done
priority: P1
assignee: agent
created: 2026-08-18
depends-on: []
blocks: []
findings: []
pr: null
github-issue: null
jira-key: null
---

# Scaffold the universal layer onto this repo

## Context

Backfilled per the task-first gate: the work ran before this file existed, because it *is* the work
that creates the task tree. The gate's prescribed remedy is a task with honest status and criteria
reconstructed from the scaffold spec — not a task written afterwards and dropped into `done`.
This is the only task in the repo permitted that exemption (EPIC-001 § Notes).

Ran `new-project` against a repo with 36 commits, an existing README and LICENSE, and no `.gitignore`.

## Acceptance criteria

- [x] `AGENTS.md` holds the guide content; `CLAUDE.md` is exactly `@AGENTS.md` — never both carrying content
- [x] `§ Conventions` carries a real rule in every subsection; no unrendered tokens ship
- [x] `docs/BRIEF.md` stamped as adopted rather than reconstructed, with both post-adoption asks logged verbatim
- [x] `docs/architecture.md`, `docs/features/README.md`, `docs/specs/.map.yml` (empty `areas:`, treated as absent) written
- [x] `CHANGELOG.md` backfills all 36 commits, bucketed and translated to human language
- [x] `.gitignore` created (repo had none); `.editorconfig` added
- [x] `tasks/` initialized: `.config.yml`, dashboard, EPIC-001 and eight stories
- [x] `skills-lint` written and passing; CI workflow runs it plus the CLAUDE.md bridge check
- [x] Defects found by the scaffold run are fixed or filed, not swallowed
- [x] `code-review` findings on `skills-lint.sh` resolved: frontmatter sliced between the `---` markers rather than a fixed line range; a vacuous pass (empty scan set) now fails; both checks share fence *and* code-span stripping with nested-fence tracking; link targets iterated line-by-line with titles stripped; check 3 widened to companion docs while excluding `templates/`; wikilinks resolved against an exact name list
- [x] Second review pass resolved: failure sentinel moved to mktemp (a stale one no longer poisons later runs, and cannot be committed); wikilink resolution made literal (grep -qxF) so a dot-for-dash typo no longer matches a real skill; unbalanced fences now error instead of failing open; double-backtick spans, tilde fences and aliased links handled; root-relative targets resolved from the repo root; file links checked case-exactly
- [x] Regression suite `.github/workflows/skills-lint-test.sh` — 16 cases, run by CI before the lint, proven to fail when a fix is reverted
- [x] `adopt-project` survey run on this repo reports **zero gaps** — 15/15 artifacts present, agent guide carries § Conventions, bridge intact, .gitignore covers .env. The one incomplete probe (spec map `areas: []`) is STORY-008 deferred work, not a gap. Unblocked by TASK-003

## Out of scope

- Filling `docs/specs/` — deferred to STORY-008; regenerating before the skill set stabilises means reviewing a diff that is pure churn.
- Seeding `docs/features/` with stubs — this epic is deliberately task-only (no stakeholder gate).
- The story-level dependency-edge defect this work exposed → deferred to TASK-001.
- Merge guidance for files the repo already owns → deferred to STORY-002.

## Human test plan

- [x] `bash .github/workflows/skills-lint.sh` exits 0 and reports 15 skills
- [x] `tr -d '[:space:]' < CLAUDE.md` equals `@AGENTS.md`
- [x] CI green on ubuntu-latest (run 32163759063, 12s): skills-lint-test 25/25, skills-lint OK (16 skills), bridge OK — **identical to Windows**, so the case-sensitivity divergence that motivated this check did not materialise
- [x] Confirmed in this session (2026-08-18), which began cold in this repo: the auto-loaded project context arrived as `CLAUDE.md` **plus the full expanded body of `AGENTS.md`**, i.e. the one-line `@AGENTS.md` bridge resolved without anyone naming it. And `§ Conventions` is demonstrably what `/verify-conventions` reads — three close gates this session produced findings quoted from it (the shared-inventory rule, *router SKILL.md files stay small*, register-on-introduce). Stated precisely so it can be disagreed with: the evidence is this session's own loaded context, not a second session opened to watch it
- [x] `/roadmap` renders EPIC-001 across both trees and the **empty `docs/features/` produces findings, not an error**: two DV5 rows (STORY-001 and STORY-002 have tasks with no feature folder), correctly flagged and correctly left for a human — this epic is internal tooling, and § How we work reserves `docs/features/` for stakeholder-facing work. The empty spec map (`areas: []`) was treated as absent exactly as its own comment promises, so nothing false-fired. One real finding came out of the run and got an id: **TASK-025** — DV10 cannot see a repo whose source is prose, so the rule that exists to catch a silently-absent spec layer is silently absent here
- [x] Unblocked and run: **zero gaps.** All thirteen layer artifacts present (README, `CLAUDE.md` + `AGENTS.md` bridge, `docs/BRIEF.md`, `docs/architecture.md`, `docs/features/` + index, `docs/specs/.map.yml`, `tasks/` config + dashboard, `CHANGELOG.md`, `.gitignore`, `.gitattributes`, `.editorconfig`, CI workflow), `integration:` declared in the config, and **nothing untracked** — the `present, uncommitted` probe came back empty, which is not a given: the same probe caught Symbio's brief and Latent's spec map

## Implementation plan

_Executed ahead of the file, per the recorded exemption. The scaffold order followed
`new-project` steps 1–6: intake → ground truth → universal layer → task init → CI → git._
