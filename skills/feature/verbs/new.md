# /feature new — capture an idea and grill it into a decision tree

Turn a raw idea into a feature folder whose decision ledger is ready to be stamped.

## Steps

1. **Resolve `docs/features/`** (see [SKILL.md](../SKILL.md#where-docsfeatures-lives)). Create it if absent.

2. **Generate the ID** — `FEATURE-NNN` (see [SKILL.md](../SKILL.md#id-generation)). Ask for a short title; slug it (lowercase, hyphens, ASCII, max 50).

3. **Grill the idea** (default ON — the heart of this verb):
   - Invoke the [[grill-me]] skill on the raw idea. Its whole job is to drag the implicit assumptions, edge cases, and "what happens when…" branches into the open until each branch of the decision tree is resolved.
   - **Skip only if** the user passes `--no-grill` or says the feature is trivial. Tiny features (one obvious change) don't need a relentless interview — fall back to a couple of `AskUserQuestion` clarifications.
   - The grill's resolved branches are the raw material for the decision tree. Capture each as a candidate decision.

4. **Distill into `idea.md`** — render [templates/idea.md](../templates/idea.md):
   - Problem / Proposed shape / Open questions distilled from the grill / Out of scope.
   - Set frontmatter `status: idea` (the initial coarse marker — see [SKILL.md](../SKILL.md#feature-status-coarse-vs-phase-derived)).
   - Keep it stakeholder-readable (a stocktaker or PM reads this). No code jargon.

5. **Seed `decisions.md`** — render [templates/decisions.md](../templates/decisions.md):
   - One row per branch the grill surfaced, each in state `proposed`.
   - Anything the user already flagged as a non-goal → still add it as a row (you'll stamp it `removed` at `decide`, so the ledger records the choice rather than silently dropping it).
   - Do **not** pre-stamp states here — `proposed` is the only state `new` writes. Deciding is the user's call at `/feature decide`.
   - Leave the `Date` and `By` columns as `—` on every seeded row. They record *when/who decided*; the only dated thing at creation is the History log's seed line.

6. **Write both files** under `docs/features/FEATURE-NNN-slug/`.

6b. **Add the index row** — append this feature's row to `docs/features/README.md` (the index,
   [templates/README.md.tmpl](../templates/README.md.tmpl)): link · title · phase `idea` ·
   decision counts · `0/0` tasks · prototype `pending`. If the index doesn't exist yet, render the
   template fresh. (Full regeneration is `/feature status`'s job; `new` just adds its own row so
   the index never lags a freshly-created feature.)

7. **Confirm + next step** — print the folder path and:
   - "Build a stakeholder prototype: `/feature prototype FEATURE-NNN`"
   - "Or stamp decisions directly: `/feature decide FEATURE-NNN`"
   - Note how many `proposed` decisions are awaiting a verdict.

## Edge cases

- **No `docs/` at all** — create `docs/features/`; don't scaffold a full docs tree (that's [[new-project]]'s job).
- **Idea is really a bug, not a feature** — say so; suggest `/tasks new task` instead. Features carry stakeholder decisions; a one-line bugfix doesn't.
- **User pastes a big spec** — still grill the gaps, but lead with extracting the decisions already implied by the spec into `proposed` rows.
- **Slug collision** — append `-2`, `-3`.
