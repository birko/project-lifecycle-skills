# /specs regen — harvest, diff-review, stamp

Regenerate spec(s) from code, present the spec diff as a behavioral-change review, stamp provenance. This verb is the heart of the skill — **never** a silent overwrite.

## Args

- `<area> [<area> ...]` — regen the named area(s) from `.map.yml`.
- `--all` — every area in the map (fan out; see step 3).
- `--story STORY-NNN` — resolve areas from the story's merged work (the [[tasks]] `close` hook passes this): read the story's tasks, resolve their `pr:` commits/PRs to changed files (`git show --name-only <sha>` / `gh pr diff <n> --name-only`), match against `.map.yml` globs. Missing references → fall back to asking which areas. Also resolves the story's tasks' `feature:` links for step 5's stamp.
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

5. **Write + stamp** (accepted areas only): write `docs/specs/<area>.md` with frontmatter — `generated-at:` current `git rev-parse HEAD` (or omit sha in a non-git project and rely on `generated-on:`), `generated-on:` today, `sources:` the resolved file list, `shaped-by:` per step 5a, `shaped-by-derived:` and `shaped-by-unresolved:` per step 5b.

5a. **Derive `shaped-by` — every regen, not only the flagged ones.** Union of three inputs, append-only:
   - the existing list (never drop a recorded feature — the spec body may still carry its behavior);
   - any `--story`/`--feature`-resolved FEATURE-NNN;
   - **features whose tasks touched this area's `sources`** — the evidence pass below.

   This third input is the one the [[roadmap]] DV8 rule reads, and its absence was a real defect: a `--all` regen resolves no flags, so `shaped-by` stayed `[]` on every area of a project and DV8 could only ever report a miss.

   **Build the task → files map ONCE per invocation, before the per-area loop** — it doesn't depend on the area, and `regen --all` would otherwise re-resolve every task once per area (measured shape: 31 areas × ~160 tasks). Then each area is a set intersection against its resolved file list; any overlap → add that task's feature.

   For each task with a non-null `feature:`, resolve its changed files in this order:
   - **`pr:` holds a PR number** (hybrid GitHub projects — `close` writes either form) → `gh pr diff <n> --name-only`. Never hand a PR number to `git show`: it resolves to nothing and the task silently contributes no evidence. Same dual resolution `--story` already uses at the top of this file.
   - **`pr:` holds a commit SHA** → `git show -m --first-parent --name-only --format= <sha>`. **The `-m --first-parent` is required, not cosmetic:** under the PR-per-task default a task lands as a `--no-ff` merge, and plain `git show --name-only` on a merge commit prints **zero** files (verified on a real merge: `0` vs `7` files). Without it, exactly the tasks that followed the documented merge flow contribute nothing.
   - **`pr:` is null** → the commits whose message names the task id: `git log --format=%H --grep '\bTASK-NNN\b'`, then the same `git show` form on each. Keep the `\b` boundaries — without them `TASK-11` also matches `TASK-110`…`TASK-119` (measured: 22 false-positive commits vs 0 bounded).

   **Attribute only on evidence.** A task with no `pr:` and no commit naming it contributes nothing — that is a gap in the trail, not proof that no feature shaped the area. Never infer provenance from an epic/story name, a folder, or a date range. Count these; step 5b persists the number.

5b. **Stamp whether derivation ran, and how completely.** Two keys, because "did it run" and "how much did it see" are different questions and a consumer needs both:
   - `shaped-by-derived: true` when step 5a's evidence pass was computed, `false` when it could not be (no task tree, no git history). **An empty `shaped-by` means two very different things** — "derivation ran and found no feature" versus "nobody ever computed this" — and a consumer cannot tell them apart from the list alone. A spec written before this stamp existed has neither key; treat a missing `shaped-by-derived` as `false`.
   - `shaped-by-unresolved: <N>` — how many feature-linked tasks contributed **no** evidence (no `pr:`, no commit naming them). **`derived: true` on its own is not a claim of completeness**, and without this number a thin answer is indistinguishable from a thorough one — which is the same conflation `shaped-by-derived` exists to remove, one level down. Reporting it only in step 7's confirmation is not enough: that output is transient, while [[roadmap]] DV8 and [[feature]] `review` Gate A read the *file*, later, and would otherwise treat a 16%-evidence answer as authoritative. Measured shape on a real project: 133 of 159 feature-linked tasks unresolvable — a `shaped-by` derived from 16% of the trail, stamped `true`.
     - `0` means genuinely complete. Omit the key only when `shaped-by-derived` is `false` (nothing ran, so there is nothing to count).
     - A high count is **not** a reason to withhold the derived list — it's a reason to say how thin it is. Consumers weigh it; they don't get to be surprised by it.

   Also surface both in step 7's confirmation, so the person running the regen sees the shortfall immediately rather than only on the next audit.

6. **Unmapped check:** glob project sources not matched by any area or `ignore` entry; if any, list them and suggest `.map.yml` additions (don't auto-edit the map — it's the human-owned file).

7. **Confirm:** per area — regenerated / unchanged / rejected; findings raised; unmapped count. Suggest committing the spec changes with the related work (don't auto-commit).

## Edge cases

- **Area's sources resolve to zero files** — the map is stale (code moved/renamed); report it and suggest the map fix instead of writing an empty spec.
- **Dirty working tree** — harvest reads the tree as it is; note in the confirmation that `generated-at` refers to HEAD while uncommitted changes were included (staleness math stays honest once the work is committed).
- **Huge area** (sources exceed what one read pass can hold) — that's a map-granularity smell; suggest splitting the area rather than spec-ing a summary of a summary.
