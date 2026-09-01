# /specs init — discovery pass, bless the area map

Bootstrap `docs/specs/` for a project: scan the codebase, propose a capability map, let the user bless it, write `.map.yml`.

## Steps

1. **Find project root** — same walk as the [[tasks]] skill (`tasks/.config.yml` marker → `*.slnx`/`*.sln` → `.git`). Polyrepo Shape A: if cwd is inside a subproject, init that subproject's `docs/specs/`; at the meta-root, ask whether the user wants meta-level (cross-cutting) specs or a specific subproject.

2. **Already initialized?** If `docs/specs/.map.yml` exists, this becomes a *re-discovery*: propose additions/renames against the existing map, never drop an existing area without asking. Show the delta, not a fresh map.

   **Read the map's `coverage:` key first (step 6), and say what it says.** A map written `unverified` — or one with no key at all, which predates it and means the same — records that its areas were never checked against a real scan set. Re-discovering "against the existing map" while treating those areas as blessed is how one broken run becomes permanent: this run's scan may succeed, step 4 may report `verified`, and the verdict then covers areas nothing ever validated. So on `unverified`, treat the existing areas as **proposals to re-confirm**, not as a baseline, and say so before showing the delta. On `not-applicable`, the previous run found no code — check whether that is still true before proposing anything.

   **A re-discovery edits the existing file; it does not re-render it.** Step 6 owns that rule and the measurement behind it. It matters here because this is the step that decides there *is* an existing map, and the prose in it — why an area was drawn where it was, why a path is in `ignore` — is the one thing in `docs/specs/` no verb can recompute.

3. **Discovery pass** — propose the capability map from the codebase:
   - Read the project's `CLAUDE.md` / `README.md` first — the architecture section usually names the capabilities already; prefer its vocabulary.
   - Survey structure: source folders, namespaces/modules, public surface. For a large codebase, fan out [[Explore]] agents (or the Workflow tool) — one per top-level source folder — each returning proposed areas + source globs.
   - Target granularity: **capability, not class** — ~5–20 areas. Each area = a name a stakeholder would recognize (`auth-session`, `bulk-filter-updates`), with source globs that collectively cover the behavioral code.
   - Propose an `ignore` list: build output, tests, generated code, vendored deps.

4. **Present the proposed map** as a table (area · title · globs · rough file count). Check coverage: any source file matching neither an area nor `ignore` → list as unmapped and either extend an area or add one.

   **Resolve the scan set by the shared rules before counting anything** — [SKILL.md](../SKILL.md) § *The area map* owns all three, and they are not restated here: the scan is **every file git tracks**; every glob is matched as a git pathspec with **`:(glob)`**; and a **dot-prefixed path is an ordinary member**, not implicit noise. A count taken under any other reading is not reproducible, and an unreproducible count makes the verdict below worthless. Two independent drills each had to invent an answer to the first of these before they could count at all.

   **Always report how many files the scan examined — including zero — and end this step with exactly one `coverage:` verdict, the tree size, and the drift list.** *Zero files discovered* and *zero files unmapped* render identically, and only the second means anything, so the count is what separates them. The verdict is **total**: every run produces one, later steps branch on it, and there is no fourth outcome to improvise.

   | Verdict | When | What it means |
   |---|---|---|
   | `verified` | non-empty scan set, and nothing is left unmapped **after this step's reconciliation** | coverage was actually established |
   | `not-applicable` | empty scan set **and** the repo genuinely has no behavioral code (see *No obvious behavioral code* under Edge cases) | there was nothing to cover; legitimate, and not a claim of coverage |
   | `unverified` | anything else | the run did not establish coverage |

   `unverified` is the catch-all deliberately, because the ways to fail are open-ended and the ways to succeed are not. It covers at least: **discovery returned nothing** while sources exist (wrong roots, an unrecognised stack, behaviour living where this scan did not look); a non-empty scan set with **unmapped files the user declined to map**; and areas proposed as a **partial guess** because the source shape could not be resolved. Say which one, in one line.

   **The verdict describes the map you are about to write, not the map you found.** This step fixes what it finds — that is what *"extend an area or add one"* means — so grading before the fix would mark a run `unverified` on the strength of a gap it went on to close. The earlier moment is not discarded; it becomes `coverage-drift`, below.

   **Classify every file that was unmapped at first scan, because the count alone ranks repos backwards.** Each one leaves the unmapped set in exactly one of two ways, and which one it was is the whole signal:
   - **Into a capability area** — it is behavior the map could not see. These are the paths `coverage-drift` lists.
   - **Into `ignore`** — it was never project source (build files, docs, deploy scripts, committed harness config). Housekeeping; not drift.

   **The classification is a judgement, so record the paths and not a tally.** The boundary cases are real and the text cannot settle them for you — a committed `appsettings.json` whose values are read by three existing areas is defensibly behavior *or* config, and whichever you choose, the next reader must be able to see what you chose. Writing a bare count states a judgement with the confidence of a measurement. If a classification was genuinely close, say which way you went and why in the run's output. **Measured 2026-09-01**: `Symbio` had 33 unmapped and `Latent` 42, all housekeeping; `WorkoutTracker` had 14, of which **6 were real source** that had shipped since the map was last touched and were invisible to every regen in between. Ranked by raw count those come out backwards — which is why the drifted files get named, not just tallied.

   **Telling `not-applicable` from `unverified` takes one question** — *does this repo contain files a maintainer would call its source?* — and it is the whole check, because both come from an empty scan set and only one is an answer.

   **On `unverified`, prefer fixing the discovery to writing a map.** Re-run the scan with corrected roots; that is the outcome worth having. But this is a preference, not a prohibition: `init` is chained by other skills, and a run that must produce the anchor file writes it with the verdict recorded (step 6) rather than silently writing nothing. What must never happen is writing a populated map that reads as blessed.

   *Why this is a floor and not pedantry:* the identical defect was measured on the sibling verb — see [regen](regen.md) step 6, where globbing a polyrepo aggregator's own root found zero files, so the unmapped check reported "nothing unmapped" on every run forever, while the map's globs reached 97 sibling projects. That step also owns the general rule this one follows — report the count even when it is zero, because a check whose output is invisible when it passes cannot be told apart from one that never ran.

5. **Offer a grill** (optional, [[grill-me]]) — for a project with real architectural ambiguity, offer to grill the area boundaries before blessing ("is `auth-login` vs `auth-session` one capability or two?"). Skip silently for small/obvious projects.

6. **Write** `docs/specs/.map.yml` with the blessed areas, and **always write step 4's three coverage keys** beside `areas:` — `coverage:`, `tracked-files-at-scan:` and `coverage-drift:` (a list of paths, `[]` when none).

   **Whether to re-render is decided by the file's existence, and by nothing else.** No `.map.yml` on disk → render [templates/map.yml](../templates/map.yml). A file on disk → this step is an **edit**: apply exactly the changes this run blessed — areas added, renamed, or removed with the user's consent (step 2) — plus any `ignore:` entries step 4's reconciliation added, plus the three coverage keys — and leave everything else as it stands.

   **Do not key this on the word "fresh".** [SKILL.md](../SKILL.md) calls a map with an empty `areas:` list a *fresh discovery*, and it is — there are no areas to propose a delta against. But the **file exists**, usually carrying a seed note saying when and why it was created and a stack-appropriate `ignore:` list somebody chose. This repo's own map is that shape. A fresh *discovery* over an existing *file* is still an edit, and reading "fresh" as licence to re-render deletes the seed's own reasoning — the precise loss this rule exists to prevent, arriving through the one door left open.

   **Re-rendering a map that exists destroys the only content in `docs/specs/` a verb cannot reproduce.** [templates/map.yml](../templates/map.yml) opens by declaring it — *"HAND-EDITABLE: this is the only human-owned file in docs/specs/."* — and what makes it human-owned is its prose: the header saying when and why the map was discovered, the note explaining that one 386-line minimal-API `Program.cs` is mapped to `http-api` rather than smeared across every domain area, the per-entry reasons in `ignore:` for why a path is not source. **Measured 2026-09-01** across four consumer maps: **99 comment lines, ~1,240 words** of it. None is derivable from the codebase; a template re-render deletes all of it and the diff reads as a routine regeneration. Step 2's *"never drop an existing area without asking"* protects the structured data and nothing else — this is the other half.

   **What survives is every line you did not deliberately change** — file-header comments, per-area comments, comments inside `ignore:`, and the ordering the author chose. That is the whole rule, and it is phrased as *"edit, don't re-render"* rather than as a list of things to preserve because a list is what goes one item short.

   **Keys, not comments, for anything a consumer must branch on — and that is not an argument for discarding comments.** A YAML comment cannot be read programmatically, which is why the coverage stamps are keys; [regen](regen.md) carries `shaped-by-derived` / `shaped-by-unresolved` the same way, so a consumer can tell *"derivation ran and found nothing"* from *"nobody ever computed this"*. Separately, the stamps are written on **every** run rather than only on failure — a repo whose broken discovery is later fixed comes back to `verified` by itself, where a failure-only stamp would have nothing that removes it. That is about *when* they are written, not about their being keys; an in-place edit could overwrite a comment just as easily.

   A map absent `coverage:` predates the field — treat that as `unverified`, never as `verified`, on the same reasoning `regen` applies to a missing `shaped-by-derived`. Absent companions read as *not computed*, never as zero or empty: `coverage-drift: []` is a finding — the run looked and found none — while a missing one is silence.

   Note that `coverage: unverified` and an empty `areas:` list are different states: [SKILL.md](../SKILL.md) already treats an empty list as *absent* everywhere, so it cannot pose as validated. The key exists for the dangerous shape — a map that **looks** populated and blessed while nothing checked it.

7. **Offer the first harvest** — suggest `/specs regen --all` (don't auto-run; the first regen on N areas is a real token spend the user should opt into).

## Edge cases

- **No obvious behavioral code** (docs-only, pure contracts/markers) — say so and write a minimal map (or nothing); don't invent areas for a project with no observable behavior.
- **Existing hand-written specs/docs** in `docs/specs/` — never overwrite; ask whether to adopt them as areas (add frontmatter + map entry) or leave them outside the map.
