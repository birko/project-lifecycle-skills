---
id: TASK-201
parent: STORY-022
feature: FEATURE-003
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: done
priority: P2
assignee: unassigned
created: 2026-09-30
depends-on: [TASK-196]
blocks: [TASK-204]
findings: []
pr: null
github-issue: null
jira-key: null
---

# Migrate: both front doors ship the new status vocabulary

## Context

A migrate batch of FEATURE-003 (owner group: `skills/new-project/` + `skills/adopt-project/`, one owner under
the layer-parity rule). The seeded rulebook and the templates the scaffolder renders name the task
statuses. Rendered copies in consumer repos are out of reach, which is why the legacy reading is permanent.

## Acceptance criteria

- [x] Every seeded or rendered text naming a task status uses the new vocabulary, with no copy of the status list: it points at the `tasks` skill — **already true, measured**: no front-door file names `review` or `blocked` as a task status
- [x] `skills/new-project/LAYER.md` is changed if it names task statuses, and the adopter reconciles the same wording — it names none, so nothing changes
- [x] The comment-rule markers are untouched, so lint check 5 stays green
- [x] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- Rewriting consumer repos' already-rendered guides — out of reach by design

## Human test plan

- [x] Scaffold a throwaway project with `/new-project` and read its guide: the statuses named are the new ones, and nothing lists them twice.
  - **Not run as a scaffold; replaced by a direct check, and the reason is recorded.** This change edits no front-door file, so a scaffold run would render exactly what it renders today and could not fail on anything this task did. The check that could fail is the one the plan's expectation rests on: grep every file the front doors render or read (`new-project/templates/{CLAUDE.seed,CONVENTIONS-universal,README.seed}.md`, `new-project/LAYER.md`, `adopt-project/{SKILL,INFER}.md`) for an old task-status value. Result (2026-10-01): the only hit is `status: todo`, which is unchanged. The task files a new project gets come from the `tasks` template via `/tasks init`, and that template's status comment is switched by TASK-204.

## Implementation plan

Planned at pick (2026-10-01): measure first, because the front doors may only point at the vocabulary rather than name it. They do: the measurement found nothing to change.

## Progress log

- 2026-10-01 — Picked; measured every front-door file. The lifecycle line's `review` is the feature review gate, a different vocabulary. The status-change rule names verbs (`/tasks block`), not values. `LAYER.md` names no task status. **No edit is needed.** New projects receive the new vocabulary through `/tasks init` rendering the `tasks` template, which TASK-204 switches.
- 2026-10-01 — Close review. **Standards:** pass. Nothing changed, and the layer-parity rule is satisfied vacuously, since neither door changed. **Intent:** pass, all 4 criteria met by measurement and annotated so. **Correctness:** not applicable, no diff. **Security / Comments:** not applicable.
