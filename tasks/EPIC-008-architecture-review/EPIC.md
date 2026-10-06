---
id: EPIC-008
parent: null
kind: review-intake
source: improve-architecture 30f9716 2026-10-06 — report: https://claude.ai/artifact/TZrbBBvu9jhHfCum6aB737 (private; author run, TASK-078)
# status — one of: planned, in-progress, done, cancelled
status: planned
owner: human
affects: []
created: 2026-10-06
---

# architecture — rung 2 review 2026-10

## Area of concern

The first `/improve-architecture` run on this repo, at `30f9716`, filed by TASK-078 as its end-to-end author run (not a cold drill: the skill cites measurements from this repo).

**Scope:** rung 2. Window: 353 commits in 6 months. Hot spots, kept at the top five of eight that cleared the bar (median touched directory 13, bar 26): `skills/tasks/verbs` (150), `skills/feature/verbs` (57), `skills/new-project` (53), `.github/workflows` (49), `skills/tasks` (37). Then a second tier of files from 50 co-change pairs and 75 subject-line fix landings. Record trees dropped: `tasks/`, `docs/`, `CHANGELOG.md`, `AGENTS.md`, `CLAUDE.md`, `README.md`. A skill folder is the module, because the installers link one folder per skill. 8 live decision records read, none contradicted.

**Results:**
- 4 co-change sets. Two are candidates (class 4). The lint scripts and the pi installers are each 2 files in one module: ordinary cohesion, not candidates.
- 2 deletion-test candidates: `help.md` in `tasks` and in `feature`. Both duplicate the open TASK-261, so they were linked to it rather than filed again.
- 1 rejection.

4 findings (IA-1 … IA-4) → 2 new tasks (TASK-268, TASK-269) · 2 linked to TASK-261 (IA-3, IA-4) · 1 dropped (below) · none routed to a decision.

### Findings dropped at intake

- 2:skills/tasks/slicing.md — Deletion test: merely moves, two or more callers, interface not shallow — callers checked: skills/feature/verbs/decompose.md, skills/tasks/SKILL.md, skills/tasks/verbs/new.md, skills/tasks/verbs/plan.md, skills/tasks/verbs/spawn.md (callers: skills/feature/verbs/decompose.md, skills/tasks/SKILL.md, skills/tasks/verbs/new.md, skills/tasks/verbs/plan.md, skills/tasks/verbs/spawn.md; at 30f9716)

## Stories

- STORY-025 — correctness and invariants: changes that ripple across skill folders (2 tasks)
