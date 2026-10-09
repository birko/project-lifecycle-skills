---
id: STORY-028
parent: EPIC-010
# status — one of: planned, in-progress, done, cancelled
status: in-progress
created: 2026-10-09
---

# A UX baseline that the review and prototype skills read

## User story

As a developer whose project records no UX rules, I want `/verify-conventions` and `/feature prototype` to
question interaction-design choices the way the code-smell baseline questions code, so that defaults like a
confirm dialog on a reversible action are a decision rather than an accident.

## Behaviour

- `/verify-conventions` reports a baseline row as `smell:` on UI files, after the repo's own rules, never blocking
- A rule the repo recorded suppresses a conflicting row
- `/feature prototype` checks a mockup against the same list, and a choice the list questions becomes a decision row
