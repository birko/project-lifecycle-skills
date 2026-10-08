---
id: STORY-026
parent: EPIC-009
# status — one of: planned, in-progress, done, cancelled
status: planned
created: 2026-10-08
---

# The regen review reads one requirement at a time, and loses nothing silently

## User story

As the person reviewing a regenerated spec, I want the diff broken down by requirement, with renames and lost
examples named, so that I can answer *"was this behaviour change intended?"* without reading whole paragraphs.

## Behaviour

- Each requirement in the review is shown as added, removed, renamed (FROM → TO) or changed, and only changed lines appear (D2).
- A scenario that was there before and is gone after is named, and must be explained or restored (D3).
- A requirement that regen writes or rewrites past about 500 characters is flagged, with a split suggested; untouched ones are not (D1).
- `--all` writes each area once its review is accepted, so an interrupted run keeps them (D5).
- A rewrite keeps the file's existing line endings (D6).
