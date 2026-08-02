---
id: {{ID}}
# status: planned | in-progress | done | cancelled
status: {{STATUS}}
created: {{CREATED}}
owner: {{OWNER}}
affects: {{AFFECTS}}
# kind: omit for a normal epic; `review-intake` marks the epic a review pass was filed into
kind: {{KIND}}
# source: review-intake epics only — where the findings came from (report path, PR, or "security-review <date>")
source: {{SOURCE}}
---

# {{TITLE}}

## Area of concern

What this epic covers, why it exists, what's out of scope at the epic level.

## Success criteria

- High-level outcomes that mark the area as healthy
- Often open-ended for living areas of concern
- For one-shot epics (e.g. migrations), list the concrete done-when state

## Requirement → feature matrix

_Optional — include when this epic owns brief-level requirements (the [[new-project]] seed EPIC always does). One row per explicit requirement, citing `docs/BRIEF.md` as the source. **No status column** — status is read live from `/roadmap`, never persisted here or it rots. Reconcile the rows whenever scope is added, changed, displaced, or shipped._

| Req | Brief quote (abridged, from docs/BRIEF.md) | Feature | Story |
|-----|--------------------------------------------|---------|-------|
| R1  | _"…verbatim fragment…"_                    | FEATURE-NNN | STORY-NNN |
