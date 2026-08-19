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

5. **Write + stamp** (accepted areas only): write `docs/specs/<area>.md` with frontmatter — `generated-at:` current `git rev-parse HEAD` (or omit sha in a non-git project and rely on `generated-on:`), `generated-on:` today,

   > `generated-at` is a **floor, not the staleness anchor.** It records what HEAD was when the harvest read the tree, and the spec is committed after that — usually alongside the very sources it was written from. [verify](verify.md) therefore anchors on the later of this stamp and the spec's own last commit. **Do not try to make the stamp exact by re-stamping after the commit**: it needs an amend or a second commit, neither of which works on a dirty tree or in a non-git project, and the stamp would still be wrong for anyone who commits differently. The stamp stays honest about what it knows; the reader resolves the rest.
 `sources:` the resolved file list, `shaped-by:` per step 5a, `shaped-by-derived:` and `shaped-by-unresolved:` per step 5b, and **`source-commits:` per step 5c**.

5c. **Stamp each external source repo** — for every source glob that resolves outside this repo, find its repo root (nearest ancestor with `.git`) and record `<prefix>: <that repo's rev-parse HEAD>` under `source-commits:`. Omit the key entirely when every source is in-repo. **This is not optional bookkeeping where it applies:** `generated-at` measures only this repo, so without it [verify](verify.md)'s staleness check cannot see a sibling repo change and the area reports fresh forever — a guard that is green by construction. If a sibling's HEAD cannot be read (repo absent, not a git checkout), write no entry for it rather than a guess, and say so in the confirmation — `verify` reports a missing entry as *unknown baseline*, which is honest, whereas a wrong sha reads as a measurement.

5a. **Derive `shaped-by` — every regen, not only the flagged ones.** Union of three inputs, append-only:
   - the existing list (never drop a recorded feature — the spec body may still carry its behavior);
   - any `--story`/`--feature`-resolved FEATURE-NNN;
   - **features whose tasks touched this area's `sources`** — the evidence pass below.

   This third input is the one the [[roadmap]] DV8 rule reads, and its absence was a real defect: a `--all` regen resolves no flags, so `shaped-by` stayed `[]` on every area of a project and DV8 could only ever report a miss.

   **Build the task → files map ONCE per invocation, before the per-area loop** — it doesn't depend on the area, and `regen --all` would otherwise re-resolve every task once per area (measured shape: 31 areas × ~160 tasks). Then each area is a set intersection against its resolved file list; any overlap → add that task's feature.

   For each task with a non-null `feature:`:

   **A declared `pr:` outranks the state field; an inferred commit does not.** Where the task declares its reference, the declaration *is* the evidence — verify it (next paragraph) and, if the state disagrees with a reference that landed, **report the contradiction rather than discarding the strongest link in the trail**. Where there is no declaration and the evidence is inferred from a commit message, the state has to corroborate it: a task whose state says the work never landed contributes nothing, because a commit naming it is then a mention by construction. **Resolve which states those are from the vocabulary [[tasks]] owns** — apply the test, never a second copy of the list, which would go quietly wrong the day that vocabulary gains a state. Today it resolves to `todo` (never started) and `cancelled` (abandoned); **`in-progress` passes** — work under way has landed whatever it has committed, and reachability is what proves that, not the label. Read the YAML **value**, not the line: a real task file writes `status: done  # merged 5414637e; 6 unit tests`, and a naive line match rejects every one of them. A `status:` that is missing or unreadable fails the test — count the task unresolved rather than assuming either way.

   **Every path: the evidence must be reachable from the harvested commit.** `shaped-by` claims a feature shaped *the code this spec was written from*, so a commit outside that history is not evidence however solid the reference looks. The fallback gets this for free — plain `git log`, **never `git log --all`**. The `pr:` paths do **not**, and that is where the rule is load-bearing: `git show <sha>` succeeds for any object in the repo and `gh pr diff <n>` works on a PR that is still open, so a task parked at `review` behind an unmerged branch would otherwise attribute files that are not in the harvested tree — the precise false positive this step exists to stop. Check it: `git merge-base --is-ancestor <sha> <generated-at>`; for a PR number, resolve its merge commit first and treat a PR that has not merged as no evidence. This is also what keeps `review` and `blocked` honest in both directions without a status guess.

   **Do not narrow the inferred-evidence gate to `done` alone.** Measured on a real project, `done`-only drops **27 of 96** attributions that are subject-authored and already in the tree — tasks parked at `review` (merged, manual sign-off open) and `blocked` (merge deferred) — while removing no false positive that the subject rule below had not already removed. Measured the other way: **10** attributions come from `todo`/`cancelled` tasks that nonetheless lead a commit subject. That is a self-contradicting trail, not evidence — count it unresolved and say so in step 7, rather than silently believing one side over the other.

   Then resolve its changed files in this order:
   - **`pr:` holds a PR number** (hybrid GitHub projects — `close` writes either form) → `gh pr diff <n> --name-only`. Never hand a PR number to `git show`: it resolves to nothing and the task silently contributes no evidence. Same dual resolution `--story` already uses at the top of this file.
   - **`pr:` holds a commit SHA** → `git show -m --first-parent --name-only --format= <sha>`. **The `-m --first-parent` is required, not cosmetic:** under the PR-per-task default a task lands as a `--no-ff` merge, and plain `git show --name-only` on a merge commit prints **zero** files (verified on a real merge: `0` vs `7` files). Without it, exactly the tasks that followed the documented merge flow contribute nothing.
   - **`pr:` is null** → fall back to commit messages, but read **only the subject line**: `git log --format='%H%x1f%s' --grep '\bTASK-NNN\b'` — the `--grep` is a cheap prefilter over the whole message, and the `\b` boundaries stay, because without them `TASK-11` also matches `TASK-110`…`TASK-119` (measured: 22 false-positive commits vs 0 bounded). Then keep a commit **only when the first task id in its subject is this task's**, and run the same `git show` form on what survives.
     - **A mention is not authorship.** Message bodies cross-reference other work — a finding citing another finding, an out-of-scope line naming deferred work — so a whole-message match attributes a feature to an area on the strength of a sentence. Measured on the same slice as the table below (1414 first-parent commits, 543 of them naming a task): **197** name more than one task id, and 53 name more than one in the *subject* alone — which is why the tie-break is the id that leads. *Both* attributions this path produced for one area were mentions. A false `shaped-by` entry is worse than a missing one: [[roadmap]] DV8 and [[feature]] `review` Gate A read this field, so a wrong entry makes Gate A **pass** on a decision that never shipped, while a gap stays visible as a gap.
     - **First id in the subject — not merely present in it.** The leading id is the author whether or not a prefix precedes it, so both conventions in the wild resolve: `TASK-411: <subject>` and `fix(area): TASK-411 — <subject>`. Ids *after* it in the same subject are cross-references, not co-authors. Do not tighten this to "the subject starts with the id" — on a repo whose log reads `fix(skills): TASK-017 — …` that attributes nothing at all, and a rule that attributes nothing is not a fix.
     - A project whose commits never name the task in a subject resolves nothing here. That is the honest answer — it raises `shaped-by-unresolved` (step 5b) instead of inventing provenance. The durable fix is upstream, not a looser match: [[tasks]] `close` writes the commit SHA into `pr:`, so tasks closed since that shipped never reach this path. It is **not** retroactive — measured on a real project, a run after it shipped still fell back here for 120 of 213 feature-linked tasks — so expect this path to carry old history for a long time.

   **Both rules, measured on one real project** (213 feature-linked tasks, 1414 first-parent commits, 32 areas — the same slice as every figure above). Each rule catches the known false positives on its own, which is why both are stated — neither is load-bearing alone:

   | evidence rule | attributions | area/feature pairs | `shaped-by-unresolved` |
   |---|---|---|---|
   | id anywhere in the message, no gate (the defect) | 246 | 82 | 135 |
   | gate only | 164 | 49 | 157 |
   | subject-first only | 106 | 44 | 163 |
   | **both (this step)** | **96** | **36** | **169** |

   96 of 246 attributions survive — a rule that attributed nothing would be a different bug, so report both directions when you change this. The 150 removed were mentions or non-landed tasks, including both known false positives on the area that exposed the defect; `shaped-by-unresolved` rose 135 → 169, which is the honest price of the correction, not a regression.

   **Attribute only on evidence.** A task the state gate rejects, or one with no `pr:` and no reachable commit leading its subject with the task id, contributes nothing — that is a gap in the trail, not proof that no feature shaped the area. The two rules above narrow what *counts* as evidence; neither licenses the alternative. Never infer provenance from an epic/story name, a folder, or a date range. Count these; step 5b persists the number.

   **Append-only cuts both ways.** Because the first input never drops a recorded feature, a stricter rule stops *new* bad attributions but cannot unwrite ones already stamped into a spec's frontmatter. Re-deriving an area's `shaped-by` from scratch to clean them breaks the append-only property — that is a separate, explicit decision with its own review, never something a routine regen does quietly.

5b. **Stamp whether derivation ran, and how completely.** Two keys, because "did it run" and "how much did it see" are different questions and a consumer needs both:
   - `shaped-by-derived: true` when step 5a's evidence pass was computed, `false` when it could not be (no task tree, no git history). **An empty `shaped-by` means two very different things** — "derivation ran and found no feature" versus "nobody ever computed this" — and a consumer cannot tell them apart from the list alone. A spec written before this stamp existed has neither key; treat a missing `shaped-by-derived` as `false`.
   - `shaped-by-unresolved: <N>` — how many feature-linked tasks contributed **no** evidence *under step 5a's rules*: no `pr:`, or a `pr:` that does not resolve into the harvested history, or commits that name the task without leading a subject, or a state that refuses inferred evidence. Keep this definition and step 5a in step — a count whose definition drifts from its producer is not reproducible from the file, which is the whole reason it is stamped. **`derived: true` on its own is not a claim of completeness**, and without this number a thin answer is indistinguishable from a thorough one — which is the same conflation `shaped-by-derived` exists to remove, one level down. Reporting it only in step 7's confirmation is not enough: that output is transient, while [[roadmap]] DV8 and [[feature]] `review` Gate A read the *file*, later, and would otherwise treat a 16%-evidence answer as authoritative. Measured shape on a real project: 133 of 159 feature-linked tasks unresolvable — a `shaped-by` derived from 16% of the trail, stamped `true`.
     - `0` means genuinely complete. Omit the key only when `shaped-by-derived` is `false` (nothing ran, so there is nothing to count).
     - **Expect this number to rise** under step 5a's subject-scoped fallback and its state gate, and record the rise rather than reworking the rules to flatten it: the increase is mention-only attributions correctly refused, not evidence lost. A stricter rule that leaves the count untouched is the suspicious result, not the clean one.
     - A high count is **not** a reason to withhold the derived list — it's a reason to say how thin it is. Consumers weigh it; they don't get to be surprised by it.

   Also surface both in step 7's confirmation, so the person running the regen sees the shortfall immediately rather than only on the next audit.

6. **Unmapped check:** glob project sources not matched by any area or `ignore` entry; if any, list them and suggest `.map.yml` additions (don't auto-edit the map — it's the human-owned file).

   **Glob the trees the map's own globs reach — not just the project root.** Derive the search roots from
   the `sources:` entries themselves (for `../Birko.Data.SQL/SQL/Connectors/X.cs`, the root is
   `../Birko.Data.SQL`), then report files under those roots that no glob matches. Two failure modes this
   closes, both measured on a real project:
   - **A polyrepo aggregator has no sources of its own.** Globbing the project root there finds **zero**
     files, so the check reports "nothing unmapped" on every run, forever — a silent pass that reads as
     coverage. Measured: 0 own sources, while the map's globs reached 97 sibling projects.
   - **A file inside an already-mapped project is the common gap, not an unmapped project.** Areas
     typically list *specific files* (`Connectors/AbstractConnectorBase.cs`) rather than whole trees, so
     a sibling file added later matches nothing. Measured on the same project: **148 unmapped `.cs` inside
     already-mapped projects**, ~18%, concentrated (one project 27/30 unmapped, another 14/17) — and two
     separate defect fixes had already landed in files no glob reached, each caught only because a human
     noticed while reviewing the spec diff.

   Why this matters more than a missing glob: a regen over an under-covered area produces a **clean diff**,
   which reads as "nothing changed" when it means "nothing was looked at". The diff is supposed to be the
   fix's evidence and the unintended-change detector; over an unmapped file it is neither, and it fails
   without saying so.

   Report the count in step 7 even when it is zero — a check whose output is invisible when it passes is
   indistinguishable from one that never ran.

7. **Confirm:** per area — regenerated / unchanged / rejected; findings raised; unmapped count; and the two provenance numbers from step 5b (`shaped-by-derived`, `shaped-by-unresolved`) plus how many tasks the state gate rejected while a commit led its subject with their id — that last count is a trail contradiction someone should fix at the source, and it is invisible unless this step prints it. Suggest committing the spec changes with the related work (don't auto-commit).

## Edge cases

- **Area's sources resolve to zero files** — the map is stale (code moved/renamed); report it and suggest the map fix instead of writing an empty spec.
- **Dirty working tree** — harvest reads the tree as it is, so `generated-at` names HEAD while the spec was written from content that HEAD does not contain. Note it in the confirmation. This is the normal case, not an unusual one: you regen after editing, and step 7 has you commit the spec with that work. **The staleness math does not fix itself once the work is committed** — [verify](verify.md) compensates by anchoring on the later of `generated-at` and the spec's own last commit. That is where the ordering hazard is handled; do not "fix" it by re-stamping here (see below).
- **Huge area** (sources exceed what one read pass can hold) — that's a map-granularity smell; suggest splitting the area rather than spec-ing a summary of a summary.
