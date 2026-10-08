---
id: STORY-027
parent: EPIC-009
# status — one of: planned, in-progress, done, cancelled
status: planned
created: 2026-10-08
---

# Checks that do not depend on anyone running the skill

## User story

As the maintainer, I want broken spec files to fail CI and new OpenSpec releases to arrive as issues, so that
neither depends on someone remembering to look.

## Behaviour

- `skills-lint.sh` fails a spec with a placeholder Purpose, a scenario with no steps, or two requirements whose names differ only in capitals (D4).
- A weekly workflow opens one issue per new OpenSpec release, labelled `upstream: openspec` and assigned to nobody, and never files the same release twice (D7, D10).
