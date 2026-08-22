# Decision record: a ranking key is declared in frontmatter, and a key that cannot discriminate says so

- **Date:** 2026-08-20 — the rule landed in `AGENTS.md` in `bcf9d8e`, alongside TASK-044
- **Decided by:** the maintainer, via TASK-044. The reasoning was written at the time; this record consolidates it out of the § Conventions bullet that had been carrying it inline.
- **Status:** accepted
- **Rule it produced:** `AGENTS.md § Conventions › Code structure & patterns` — the one-line entry pointing here.

## Context

[[fix-next]] orders defect work by eight keys in sequence. Key 6 is the story's **theme** — its position on
`intake`'s subject ladder.

Two problems surfaced together in TASK-044. The theme was being **inferred from the story's title**, which
works only while stories are titled the way `intake` happens to title them and fails silently the moment a
backlog is grouped any other way — a subject-grouped adoption, a retitled story. And when every candidate
shares one theme, the key **cannot discriminate**, yet a run that never mentions it reads exactly like a
run where the key did the work.

The second half is the subtle one, and it is not hypothetical here: a prose-rule codebase produces almost
only correctness defects, so this repo's review-intake stories genuinely cluster on one theme.

## Decision

**Declare the key, and announce degeneracy.** `theme:` is written into STORY frontmatter by
`/tasks intake` and *read* by `/fix-next`; the ranking paragraph names the key that actually broke the tie.

Degeneracy is normal and is **not** the defect. *Silent* degeneracy is the defect.

## Rejected alternatives

**Keep inferring the theme from the title.** Cheaper and needs no new field. Rejected because it fails
exactly where the backlog was not built by `intake` — which is the case `intake --adopt` exists to serve.
An inference that happens to be right is still unreproducible, and this repo's broader rule already covers
it: *read the declaration, never infer it.*

**Store the ladder's row number instead of the slug.** Sorts trivially. Rejected because it freezes the
ladder's ordering into every already-stamped story: inserting or reordering a theme would silently remap
them all with nothing to signal it. Slugs stay stable while the table is free to grow.

**Skip a degenerate key silently.** The status quo, and the reason the rule exists. A run that quietly
omits a key it could not apply is indistinguishable from one where the key discriminated — so a reader
believes the ordering carries information it does not.

**Drop key 6 on repos where it is always degenerate.** Tuning per repo, rejected because degeneracy is a
property of the current *backlog*, not of the repo. The moment one security finding lands, the key matters
again — and a key removed by configuration would not be there to matter.

## Consequences

**Easier.** Ranking is reproducible and auditable: the field says what the theme is, and the output says
which key decided. An adopted backlog can be stamped rather than guessed at.

**Harder.** `intake --adopt` now has to *ask* for a theme per story rather than inferring one, and a story
the user will not classify stays unstamped rather than mis-stamped — which means key 6 is genuinely
unavailable there, honestly. It also adds a field that can be **wrong**, which inference could not be in
the same way: a measured instance is STORY-015, stamped `docs-i18n-coverage` over four correctness defects
in the repo's only gate, ranking them last (TASK-058). A declared field trades an unreproducible guess for
a reproducible error, and the error is at least fixable.

**Not affected.** The other seven keys, and the ladder table itself — which stays the single source of the
theme list and its order, restated nowhere.
