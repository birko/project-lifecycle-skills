# /feature new — capture an idea and grill it into a decision tree

Turn a raw idea into a feature folder whose decision ledger is ready to be stamped.

## Steps

1. **Resolve `docs/features/`** — walk up to the project root (`*.slnx`/`*.sln`, then `.git`) and place `docs/features/` under it; create it if absent (don't disturb existing `docs/` content). In a polyrepo family, a cross-cutting feature goes in the aggregator repo's `docs/features/`, a sub-project feature in that sub-repo's own.

2. **Adopt a seeded stub, or generate a fresh ID:**
   - **Adopt-first check.** [[new-project]] seeds `idea.md` stubs (`status: idea`, near-empty sections) for every planned requirement at scaffold time. If the idea being captured matches an existing stub — the user passed `FEATURE-NNN` explicitly, or the title/slug clearly matches a stub folder — **adopt it in place**: keep its ID and folder, grill + fill its `idea.md`, seed its `decisions.md`. Never mint a second ID for a requirement that already has a tracked home (that splits one requirement across two folders and orphans the EPIC matrix's reference). When the match is plausible but not certain, ask.
   - **Otherwise generate** — `FEATURE-NNN` is its own global counter (parallel to EPIC/STORY/TASK): Glob `docs/features/FEATURE-*/`, take the max, increment, zero-pad to 3. Ask for a short title; slug it (lowercase, hyphens, ASCII, max 50).

3. **Grill the idea** (default ON — the heart of this verb):
   - Invoke the [[grill-me]] skill on the raw idea. Its whole job is to drag the implicit assumptions, edge cases, and "what happens when…" branches into the open until each branch of the decision tree is resolved.
   - **Skip only if** the user passes `--no-grill` or says the feature is trivial. Tiny features (one obvious change) don't need a relentless interview — fall back to a couple of `AskUserQuestion` clarifications.
   - The grill's resolved branches are the raw material for the decision tree. Capture each as a candidate decision.

4. **Distill into `idea.md`** — render [templates/idea.md](../templates/idea.md):
   - Problem / Proposed shape / Open questions distilled from the grill / Out of scope.
   - Set frontmatter `status: idea` — the initial value of the stored **coarse marker** (`idea | review | done | dropped | superseded`); the richer displayed *phase* is derived later by `/feature status`, never stored.
   - Keep it stakeholder-readable (a PM or end user reads this). No code jargon.

5. **Seed `decisions.md`** — render [templates/decisions.md](../templates/decisions.md):
   - One row per branch the grill surfaced, each in state `proposed`.
   - Anything the user already flagged as a non-goal → still add it as a row (you'll stamp it `removed` at `decide`, so the ledger records the choice rather than silently dropping it).
   - Do **not** pre-stamp states here — `proposed` is the only state `new` writes. Deciding is the user's call at `/feature decide`.
   - Leave the `Date` and `By` columns as `—` on every seeded row. They record *when/who decided*; the only dated thing at creation is the History log's seed line.

6. **Write both files** under `docs/features/FEATURE-NNN-slug/`.

   **The prototype step is a recorded decision, not a silent skip.** `idea.md` must carry a
   `## Prototype` line, exactly like the per-task Human test plan carries an explicit "N/A":
   - **Built** → `Built — <prototype.html | .md | spike link>` (set by `/feature prototype`)
   - **Skipped** → `Skipped — <reason>` (e.g. "headless engine; the test suite is the proof")
   - **N/A / Pending** → for superseded features, or stubs not yet reached (what `new` writes)

   If the line is missing, that's the bug — an absent prototype reads as an omission, not a
   decision. Lean toward *building* one for pure look/UX features (a static mockup is cheap and
   prevents building the wrong feel); lean toward skipping for headless logic and small
   increments you validate by running.

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
- **Field feedback re-enters here** — a production signal (user report, incident, monitoring
  alert) routes the same way a new idea does: `/feature new`, or a new `proposed` decision on
  the owning feature. A `removed`/`deferred` decision overturned by evidence is reopened via
  `/feature decide` (a new `proposed` row referencing the superseded one). A regression in
  shipped behavior → `/tasks new` (which may revert the owning feature `done → review` — see
  decide.md's surface-dependent-revert rule). Work is a loop, not a line; `done` is never the
  terminus.
