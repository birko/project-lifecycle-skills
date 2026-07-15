# /specs regen — harvest, diff-review, stamp

Regenerate spec(s) from code, present the spec diff as a behavioral-change review, stamp provenance. This verb is the heart of the skill — **never** a silent overwrite.

## Args

- `<area> [<area> ...]` — regen the named area(s) from `.map.yml`.
- `--all` — every area in the map (fan out; see step 3).
- `--story STORY-NNN` — resolve areas from the story's merged work (the [[tasks]] `close` hook passes this): read the story's tasks, resolve their `pr:` commits/PRs to changed files (`git show --name-only <sha>` / `gh pr diff <n> --name-only`), match against `.map.yml` globs. Missing references → fall back to asking which areas. Also resolves the story's tasks' `feature:` links for step 6's stamp.
- `--feature FEATURE-NNN` — resolve areas from all of the feature's tasks (same mechanics); used by [[feature]] `review` Gate A.

## Steps

1. **Find project root + load `.map.yml`.** Unknown area name → list valid areas and stop.

2. **Per area — harvest:**
   - Resolve the area's `sources` globs to a concrete file list.
   - Read the **existing spec first** (if any), then the sources.
   - Rewrite the spec per [templates/spec.md](../templates/spec.md): Purpose → `### Requirement:` blocks ("The system SHALL …") → `#### Scenario:` Given/When/Then blocks. Ground every requirement in the code as it **is** — including behavior that looks like a bug (spec it as-is, flag it in step 4).
   - **Stable-wording rule:** change only what the code contradicts; keep untouched requirements verbatim so the diff means "behavior changed", not "rephrased". First-ever harvest of an area writes the full spec (no diff review — nothing to compare; just present the new spec for a skim).

3. **`--all` fan-out:** harvest areas in parallel via the Workflow tool (one agent per area, each returning the new spec body); then run the diff reviews **serially** — review is a human conversation, not a fan-out.

4. **Diff review (per changed area):**
   - Show the spec diff (old vs new — `git diff` if the old spec was committed, otherwise render both).
   - Classify each behavioral change in the diff:
     - **Matches an approved decision** — when `--story`/`--feature` context resolves to features, check the diff against their `decisions.md` `approved`/`changed` rows. Match → clean.
     - **Intended anyway** — user confirms it's expected (e.g. covered by task acceptance criteria).
     - **Unexplained** — a behavioral change nobody decided → a **finding**. Offer `/tasks new` (regression or follow-up) or, if it invalidates a `deferred`/`removed` decision, `/feature decide` to reopen it. Record the outcome; don't just shrug past it.
   - **Expected-but-missing:** in `--feature` context, an approved decision whose change does NOT appear in the diff means the feature isn't done — report it back to the caller ([[feature]] review treats it as a failed completeness check).
   - Suspected bugs found while harvesting: raise them here (offer `/tasks new`), spec the behavior as-is.
   - User rejects the regen → discard the new body, write nothing.

5. **Write + stamp** (accepted areas only): write `docs/specs/<area>.md` with frontmatter — `generated-at:` current `git rev-parse HEAD` (or omit sha in a non-git project and rely on `generated-on:`), `generated-on:` today, `sources:` the resolved file list, `shaped-by:` existing list plus any `--story`/`--feature`-resolved FEATURE-NNN not already present (append-only, machine-written).

6. **Unmapped check:** glob project sources not matched by any area or `ignore` entry; if any, list them and suggest `.map.yml` additions (don't auto-edit the map — it's the human-owned file).

7. **Confirm:** per area — regenerated / unchanged / rejected; findings raised; unmapped count. Suggest committing the spec changes with the related work (don't auto-commit).

## Edge cases

- **Area's sources resolve to zero files** — the map is stale (code moved/renamed); report it and suggest the map fix instead of writing an empty spec.
- **Dirty working tree** — harvest reads the tree as it is; note in the confirmation that `generated-at` refers to HEAD while uncommitted changes were included (staleness math stays honest once the work is committed).
- **Huge area** (sources exceed what one read pass can hold) — that's a map-granularity smell; suggest splitting the area rather than spec-ing a summary of a summary.
