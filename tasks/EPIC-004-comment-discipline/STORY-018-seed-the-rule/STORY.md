---
id: STORY-018
parent: EPIC-004
# status — one of: planned, in-progress, done, cancelled
status: done
created: 2026-09-18
---

# Seed the comment-discipline rule into both rulebooks

## User story

As a developer starting a project from these skills, I want the rulebook I am handed to say what a
comment is for, so that the agents working in my repo stop filing changelogs and defect notes into
the source.

## Behaviour

- A project scaffolded by [[new-project]] carries the rule in its own `CLAUDE.md` § Conventions,
  where it is auto-loaded into every task's context and linted by [[verify-conventions]].
- The rule states **necessity per line, not a line count** — a long comment is legal when every
  line carries something, a short one is not when it carries nothing.
- It ships with a test a reader can apply the same way twice: delete the line, ask where its
  content already lives — code, version history, the ticket, a decision record, or nowhere. Only
  *nowhere* survives, at any length.
- It names the concrete cases it bans, because a test without instances gets re-invented per
  reader: changelog, QA log, rationale essay above a declaration, a ten-line block on one
  property/const/enum/field.
- This repo follows it too, and the one file that would be misread as violating it carries a
  recorded measurement saying otherwise.

**Edge case that defines the rule.** `.github/workflows/skills-lint.sh` is 42% comments with a
35-line block. Under a length cap it is a pile of violations; under this rule it passes, because
nothing else in the repository records what those lines say. A rule that cannot explain why that
file is fine is the wrong rule.
