# /feature review — the completeness gate

Three checks before a feature is called done: it's **complete** (every decision built and every task merged — code correctness was already reviewed per task at each `/tasks close` merge gate), the manual tests were actually run, and the stakeholder signs off. This is a *completeness* gate, **not** a wholesale code re-review — reuses existing skills rather than reinventing review.

## Steps

1. **Locate the feature**; read `decisions.md` and collect its tasks (Grep `tasks/` for `feature: FEATURE-NNN`).

2. **Gate A — Completeness** (code correctness was already reviewed per task at each `/tasks close` merge gate — don't re-review wholesale):
   - **Every `approved`/`changed` decision is decomposed**, and **every linked task is merged (`done`)** — Grep `tasks/` for `feature: FEATURE-NNN`; any still-open task means the feature isn't done (list them and stop).
   - **Register-on-introduce confirmed:** if the feature introduced a new cross-cutting pattern, confirm it was recorded in `CLAUDE.md § Conventions` (and `## Architecture` if structure changed) — run [[verify-conventions]] to flag an unrecorded one. (Per-task `verify-conventions` + `code-review` already ran at each `/tasks close`; this is the feature-wide *confirmation*, not a re-run.)
   - **Spec landing check** — only when the project has a **usable** spec map (`docs/specs/.map.yml` with a non-empty `areas:` list; if the map is missing **or still the empty scaffold seed**, the check cannot run: say so and require `/specs init` + a regen before sign-off — or the explicit `no spec surface` carve-out below — rather than skipping silently). The feature's behavioral change should have landed in the specs: Grep `docs/specs/*.md` frontmatter for `shaped-by:` containing FEATURE-NNN — **and read each spec's `shaped-by-derived:` alongside it**, because "not listed" means two opposite things:
     - **Provenance was never derived** (`shaped-by-derived:` is `false` or absent — the [[roadmap]] DV11 condition) → the answer is **unknown, not a miss.** An un-derived `shaped-by: []` says nothing about this feature, and failing the gate on it reports a *generator* gap as a *feature* gap — sending someone to re-spec behavior that may already be specced. Run `/specs regen` over the candidate areas first (regen derives `shaped-by` from task-commit evidence on **every** run — [[specs]] regen step 5a), then re-read and judge the derived answer. DV8 suppresses itself on these areas; **this gate must not be stricter than the audit it mirrors.**
     - **Provenance was derived and the feature still isn't listed** → now it's a real finding. Run `/specs regen --feature FEATURE-NNN` and review the diff (the [[specs]] harvest-with-diff-review pass). Its **expected-but-missing** outcome is a failed completeness check: an `approved` decision whose behavioral change doesn't show up in any spec diff means the feature isn't done — route it back to a task. **Check `shaped-by-unresolved:` before you call it:** a non-zero count means the derivation saw only part of the trail (tasks with no `pr:` and no commit naming them), so "not listed" is weaker than it looks. The `--feature` regen resolves this feature explicitly and settles it either way — so run it *before* routing work back, and say the count out loud if you route anyway.
     - **Genuinely docs-only/internal** — such a feature may legitimately land nowhere. Record a History line containing the literal phrase **`no spec surface`** (e.g. `{{DATE}} — no spec surface (docs-only), confirmed at review`) — [[roadmap]]'s DV8 greps for exactly that phrase to suppress the flag. Use it only once provenance *was* derived; before that there's nothing to carve out of.
   - **Optional cumulative passes** — for a large or cross-cutting feature, run [[code-review]] on the *cumulative* diff to catch cross-task **integration** issues a per-task review can't see, and [[security-review]] if the feature warrants it (pass `--comment` for inline PR comments). **Both are cross-task-seam passes, not backstops** — each task's own `close` already ran `code-review`, and ran `security-review` if its diff touched a security surface. If you find a task that merged a security surface without that pass, that's the finding: route it back to a task, don't quietly cover for it here. These are runtime-provided skills (Claude Code built-ins); **if this runtime lacks them, do the pass inline** — read the cumulative diff for cross-task seams (conflicting assumptions, duplicated logic, merge artifacts) and, when security-relevant, for auth/input-handling/secret-exposure issues. Route any blocker back to a `/tasks` (new or reopened task) — never a silent fix here.

3. **Gate B — Human test plan verification** (the part automated review can't do):
   - For every task with `feature: FEATURE-NNN`, read its `## Human test plan`.
   - Each plan must be either: all steps checked `[x]` (manually run), or explicitly `N/A — fully covered by automated tests`.
   - Any plan with unchecked steps → list them and ask the user to run them (or confirm N/A). This is the same check `/tasks close` runs per-task; here it's enforced feature-wide so nothing slips through.
   - Capture the result (who tested, when) — note it in the feature's `decisions.md` History log.

4. **Gate C — Stakeholder sign-off:**
   - Summarize for the stakeholder (PM / product owner): what was approved, what shipped, what was deferred/removed and why (straight from `decisions.md`).
   - Ask for explicit sign-off. Record it as a History line: `{{DATE}} — FEATURE-012 signed off by <PM> after review`.
   - If the stakeholder rejects or requests changes → add/flip decisions (`/feature decide`), which feeds back into `decompose`. The loop reopens; the feature is not done.

5. **Set the coarse status honestly:**
   - **All three gates pass** → `idea.md` frontmatter `status: done`; run `/feature status` so the phase shows `done`; suggest closing any still-open tasks via `/tasks close`.
   - **Changelog nudge** (don't auto-run): a feature reaching `done` is a genuine ship event, so if the project has a `CHANGELOG.md`, print one line — *"FEATURE-NNN shipped — consider `/roll-changelog` to record what changed for users."* The changelog is a human-curated summary, so leave the call to the user; just make sure they don't forget. Skip the nudge if there's no `CHANGELOG.md`.
   - **Gate A passes + code/tasks complete, but Gate B/C sign-off hasn't happened** (e.g. stakeholder unavailable, or you're parking it for a later playtest) → set `status: review`, **not** `done`. The feature is built but unsigned — verification debt. Park any client tasks at `status: review` too. Never write "done (pending)".

6. **Confirm** — print the gate results (✅/❌ per gate) and the final state.

## Edge cases

- **Some tasks still open / unmerged** — Gate A fails by definition (completeness); list the open tasks and stop. There's nothing to sign off until the work is merged.
- **Optional cumulative pass finds a blocker** — a cross-task integration bug or security issue is real verification debt: open (or reopen) a `/tasks` for the fix and hold the feature at `review` until it's merged. Don't fix silently inside the review step.
- **Stakeholder unavailable** — set `status: review` (not `done`); record sign-off as `pending` in the History log. Close it later by re-running `/feature review` once signed off.
- **Review surfaces a contested decision** — re-grill *just that branch* with [[grill-me]], then `/feature decide` to re-stamp; don't re-grill the whole feature.
