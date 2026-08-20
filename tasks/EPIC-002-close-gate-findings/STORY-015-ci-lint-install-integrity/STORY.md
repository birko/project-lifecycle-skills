---
id: STORY-015
parent: EPIC-002
# status: planned | in-progress | done | cancelled
status: planned
created: 2026-08-20
# theme: review-intake stories only — this story's slug on intake's subject ladder.
# fix-next reads it as tie-break key 6; omit it on an ordinary story.
theme: docs-i18n-coverage
---

# CI lint and install integrity — the repo's only gate, and what it cannot see

## User story

As a maintainer trusting `skills-lint.sh` as the single automated gate, I want its coverage documented
and its blind spots closed, so that a green run means what the team believes it means.

## Behaviour

- **The lint's own test suite grew case by case with nothing recording what the newer ones pin.**
  TASK-029 was filed at 25 cases; `AGENTS.md § Testing` and the file itself now say 31, which is the
  point — the count is a moving target and the gap it names is what each case exists to catch, not how
  many there are. The suite is the repo's only gate on the gate — a silent regression in it disables checking
  entirely with no signal — so cases whose purpose is undocumented are cases nobody can safely change
  or delete.
- **Nothing detects a `skills-pi/` stub shadowing a real built-in.** `skills-pi/` is frozen precisely
  because installing its fallbacks into the Claude Code skills root would shadow the runtime's native
  passes; that constraint is documented in prose and enforced by nothing, so the failure it prevents is
  one installer change away.
- Common thread: both concern the gate's own trustworthiness rather than any skill's behaviour. They
  are the tasks whose absence would be discovered last, because the thing that would report them is
  the thing that is broken.
