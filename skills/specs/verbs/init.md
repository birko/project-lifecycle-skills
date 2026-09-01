# /specs init — discovery pass, bless the area map

Bootstrap `docs/specs/` for a project: scan the codebase, propose a capability map, let the user bless it, write `.map.yml`.

## Steps

1. **Find project root** — same walk as the [[tasks]] skill (`tasks/.config.yml` marker → `*.slnx`/`*.sln` → `.git`). Polyrepo Shape A: if cwd is inside a subproject, init that subproject's `docs/specs/`; at the meta-root, ask whether the user wants meta-level (cross-cutting) specs or a specific subproject.

2. **Already initialized?** If `docs/specs/.map.yml` exists, this becomes a *re-discovery*: propose additions/renames against the existing map, never drop an existing area without asking. Show the delta, not a fresh map.

   **Read the map's `coverage:` key first (step 6), and say what it says.** A map written `unverified` — or one with no key at all, which predates it and means the same — records that its areas were never checked against a real scan set. Re-discovering "against the existing map" while treating those areas as blessed is how one broken run becomes permanent: this run's scan may succeed, step 4 may report `verified`, and the verdict then covers areas nothing ever validated. So on `unverified`, treat the existing areas as **proposals to re-confirm**, not as a baseline, and say so before showing the delta. On `not-applicable`, the previous run found no code — check whether that is still true before proposing anything.

3. **Discovery pass** — propose the capability map from the codebase:
   - Read the project's `CLAUDE.md` / `README.md` first — the architecture section usually names the capabilities already; prefer its vocabulary.
   - Survey structure: source folders, namespaces/modules, public surface. For a large codebase, fan out [[Explore]] agents (or the Workflow tool) — one per top-level source folder — each returning proposed areas + source globs.
   - Target granularity: **capability, not class** — ~5–20 areas. Each area = a name a stakeholder would recognize (`auth-session`, `bulk-filter-updates`), with source globs that collectively cover the behavioral code.
   - Propose an `ignore` list: build output, tests, generated code, vendored deps.

4. **Present the proposed map** as a table (area · title · globs · rough file count). Check coverage: any source file matching neither an area nor `ignore` → list as unmapped and either extend an area or add one.

   **Resolve the scan set by the shared rules before counting anything** — [SKILL.md](../SKILL.md) § *The area map* owns all three, and they are not restated here: the scan is **every file git tracks**; every glob is matched as a git pathspec with **`:(glob)`**; and a **dot-prefixed path is an ordinary member**, not implicit noise. A count taken under any other reading is not reproducible, and an unreproducible count makes the verdict below worthless. Two independent drills each had to invent an answer to the first of these before they could count at all.

   **Always report how many files the scan examined — including zero — and end this step with exactly one `coverage:` verdict.** *Zero files discovered* and *zero files unmapped* render identically, and only the second means anything, so the count is what separates them. The verdict is **total**: every run produces one, later steps branch on it, and there is no fourth outcome to improvise.

   | Verdict | When | What it means |
   |---|---|---|
   | `verified` | non-empty scan set, and nothing is left unmapped | coverage was actually established |
   | `not-applicable` | empty scan set **and** the repo genuinely has no behavioral code (see *No obvious behavioral code* under Edge cases) | there was nothing to cover; legitimate, and not a claim of coverage |
   | `unverified` | anything else | the run did not establish coverage |

   `unverified` is the catch-all deliberately, because the ways to fail are open-ended and the ways to succeed are not. It covers at least: **discovery returned nothing** while sources exist (wrong roots, an unrecognised stack, behaviour living where this scan did not look); a non-empty scan set with **unmapped files the user declined to map**; and areas proposed as a **partial guess** because the source shape could not be resolved. Say which one, in one line.

   **Telling `not-applicable` from `unverified` takes one question** — *does this repo contain files a maintainer would call its source?* — and it is the whole check, because both come from an empty scan set and only one is an answer.

   **On `unverified`, prefer fixing the discovery to writing a map.** Re-run the scan with corrected roots; that is the outcome worth having. But this is a preference, not a prohibition: `init` is chained by other skills, and a run that must produce the anchor file writes it with the verdict recorded (step 6) rather than silently writing nothing. What must never happen is writing a populated map that reads as blessed.

   *Why this is a floor and not pedantry:* the identical defect was measured on the sibling verb — see [regen](regen.md) step 6, where globbing a polyrepo aggregator's own root found zero files, so the unmapped check reported "nothing unmapped" on every run forever, while the map's globs reached 97 sibling projects. That step also owns the general rule this one follows — report the count even when it is zero, because a check whose output is invisible when it passes cannot be told apart from one that never ran.

5. **Offer a grill** (optional, [[grill-me]]) — for a project with real architectural ambiguity, offer to grill the area boundaries before blessing ("is `auth-login` vs `auth-session` one capability or two?"). Skip silently for small/obvious projects.

6. **Write** `docs/specs/.map.yml` from [templates/map.yml](../templates/map.yml) with the blessed areas, and **always write step 4's verdict as a real `coverage:` key** beside `areas:`.

   **A key, not a comment, and written on every run — both halves matter.** A comment is the part of a YAML file any re-serialization drops, and nothing can branch on it; [regen](regen.md) already carries `shaped-by-derived` / `shaped-by-unresolved` as keys for exactly this reason, so a consumer can tell *"derivation ran and found nothing"* from *"nobody ever computed this"*. Writing it unconditionally is what keeps it honest: the key is **overwritten every run**, so a repo whose broken discovery is later fixed comes back to `verified` by itself. A stamp added only on failure has nothing that removes it, and a permanently stale `unverified` is indistinguishable from a current one.

   A map absent this key predates it — treat that as `unverified`, never as `verified`, on the same reasoning `regen` applies to a missing `shaped-by-derived`.

   Note that `coverage: unverified` and an empty `areas:` list are different states: [SKILL.md](../SKILL.md) already treats an empty list as *absent* everywhere, so it cannot pose as validated. The key exists for the dangerous shape — a map that **looks** populated and blessed while nothing checked it.

7. **Offer the first harvest** — suggest `/specs regen --all` (don't auto-run; the first regen on N areas is a real token spend the user should opt into).

## Edge cases

- **No obvious behavioral code** (docs-only, pure contracts/markers) — say so and write a minimal map (or nothing); don't invent areas for a project with no observable behavior.
- **Existing hand-written specs/docs** in `docs/specs/` — never overwrite; ask whether to adopt them as areas (add frontmatter + map entry) or leave them outside the map.
