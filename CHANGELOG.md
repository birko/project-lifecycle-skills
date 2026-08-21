# Changelog

All notable changes to this project are documented here.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

This is the *code* changelog — what changed for people who install these skills. *Why* a choice
was made lives in `docs/adr/` (technical) and `docs/features/*/decisions.md` (per-feature).

## [Unreleased]

_No release has been cut yet, so the whole history sits here. Backfilled 2026-08-18 from the first
36 commits (2026-07-15 → 2026-08-18), then rolled 2026-08-20 across the 42 commits since, and 2026-08-21 across the 16 after that._

### Added

- **The lifecycle pipeline** — seven skills that carry an idea to shipped, reviewed, tested code: `new-project` (universal layer), `tasks` (Epic/Story/Task tracking), `feature` (idea → prototype → decisions → decompose → review), `roadmap` (cross-tree view + divergence audit), `populate-tests` (coverage backbone + `[auto]`/`[manual]` ledger), `specs` (capability specs harvested from code), `fix-next` (drains a defect backlog unattended).
- **Supporting skills** — `grill-me`, `tdd`, `verify-conventions`, `roll-changelog`, `handoff`.
- **`/tasks intake`** — file a review pass as tracked work, then drain it, so findings become fixed code instead of a report nobody actions. Paired with `fix-next`.
- **Lifecycle gates** — `/feature pick` (resolves what stage a feature is really at and offers the verb that unblocks it) and `/tasks spawn` (work discovered mid-flight becomes its own task instead of widening the one in hand).
- **The spec layer** — `docs/specs/` with a hand-edited `.map.yml` and generated capability specs, reviewed as a diff at story close as an intended-vs-unintended behavioural-change check.
- **Divergence checks** — `roadmap` grew a numbered DV1–DV12 audit for feature/task drift, including a ledger-backfill check and a flag for real code with no spec map.
- **Installers for both runtimes** — `install.sh` / `install.ps1` link `skills/` into Claude Code; `pi-install.sh` / `pi-install.ps1` link `skills/` + `skills-pi/` into the pi runtime.
- **`skills-pi/`** — pi-only fallback definitions of the review skills Claude Code ships natively (`code-review`, `review`, `security-review`), deliberately never installed into `~/.claude/skills` where they would shadow the native passes.
- MIT license; `.gitattributes` LF normalization.
- **`adopt-project` — the brownfield front door.** Point it at a repo that already has code and it surveys what the repo already solved, fills only what is missing, and reports both. Re-run it whenever the layer grows: it is the upgrade path, not a one-shot. Where [[new-project]] creates the layer, this reconciles an existing repo against it.
- **Conventions are inferred from your code, then confirmed** — `adopt-project` reads the answers your source already gives (structure, naming, testing, error handling) and proposes them **with the evidence**, so you can disagree specifically rather than rubber-stamp. An unconfirmed inference is dropped, never written as a guess. The round scopes itself to what your guide does not already answer, and says when it skips.
- **`LAYER.md` — one inventory both front doors read.** What a lifecycle-ready repo contains, who owns each artifact's shape, and what to do when one already exists. Adding an artifact there adds it for greenfield and brownfield at once, instead of two lists drifting apart.
- **Defects found during adoption become tracked work.** A dead path or broken script turned up while surveying is filed as a task whatever you decide about fixing it — "fixed, mentioned in the report, untracked" is now explicitly the outcome the skill refuses.
- **Adoption regenerates what it invalidated.** Creating an input to a generated file re-runs that file's owning verb, so you do not end up with a dashboard that went stale during the very run that reshaped the repo — and it stops rather than overwrite content a generator cannot reproduce.
- **The lint detects install drift.** `skills-lint` now reports a skill folder with no junction in either install root, and a junction whose source folder is gone. Advisory only: the fix is re-running an installer, which no code change can do for you.

### Changed

- **The skill set is now stack-agnostic.** Framework-specific references were removed and the stack-scaffolder dependency inverted: the generic front door knows only the *hook*, never a specific framework, so a team's wiring skill plugs in without either side hard-coding the other.
- **Verbs are standalone.** Rule sections moved out of router `SKILL.md` files and into the verb that owns them, so a verb file reads correctly on its own and the routers stay small.
- **Generated files are owned by their verbs** — dashboards, status rollups and specs must be regenerated, never hand-edited; a hand edit is a lie with a countdown.
- **The task-first gate hardened** — tests count as code, and work starts via `/tasks pick` rather than by editing.
- **`verify-intent` — a third review axis: did the diff build what was asked?** Separate from whether it follows your conventions and whether it is correct, because clean, conventional, correct code implementing the wrong thing passes both. Three finding classes — missing, scope creep, wrong — each quoting the requirement it came from. It reads the task's acceptance criteria and the feature's approved decisions as *intent*, and `docs/specs/` as a *baseline*: a spec is harvested from your code, so it states what an area already does, not what anyone asked for. Runnable standalone mid-work, not only at a gate.
- **`domain` — a glossary and decision records, written only when there is something to write.** `docs/glossary.md` fixes what your terms mean; `docs/adr/NNNN-slug.md` records why a hard-to-reverse choice was made so nobody re-litigates it, and only when the decision is *also* surprising without context and the result of a real trade-off. Four behaviours applied during a design rather than as a one-shot command: challenge a term used against its definition, sharpen two names for one concept, stress-test a relationship with a concrete case, and cross-reference the glossary against the code. Drilled on a real consumer repo, where it found two vocabularies for one physical thing meeting inside a single event handler.
- **`verify-conventions` now says something useful on a repo that documented nothing** — a fixed code-smell baseline applies as a floor. Your documented rules always win and *suppress* a conflicting smell rather than reporting both; every smell is labelled a judgement call and never a blocker; anything your own linter already reports is skipped.
- **`tasks close --unattended`, for an autonomous drain.** Every step that would otherwise stop for input has a declared behaviour, listed at the flag itself: an out-of-scope work bullet is spawned instead of offered, the merge decision resolves to *merge*, the commit happens without asking, and an unresolvable prompt is skipped and reported. An ask reachable under the flag but missing from that list is treated as a defect in the list, not a runtime judgement call.
- **Review-intake stories declare their ladder theme**, so `fix-next`'s tie-breaker reads a field instead of inferring it from a story title — which resolves to nothing the moment a backlog is grouped any other way, and did.
- **`feature` delegates its collection pass to `roadmap`'s cross-tree engine**, so the two trees are read by one implementation instead of two that drift.
- **Runtime-skill references degrade gracefully** — a skill that names a runtime-provided pass now says what to do inline when that pass does not resolve, instead of silently skipping the gate.
- The seeded agent guide became filename-agnostic (renders to `CLAUDE.md` or `AGENTS.md`) and names the changelog leg.
- **The merge gate reports three verdicts side by side and never reranks across them.** Standards, fidelity and correctness answer different questions, and one ranked list lets a convention warning sit above an unbuilt requirement and read as the larger problem. The merge decision now states each verdict, because *standards pass, intent fail* is a distinct outcome a single summary cannot express.
- **Every `verify-conventions` report opens with the rulebook it read** — the file, the headings treated as normative in your guide's own language, and which rung of the ladder matched. Clean passes too: a bare `✅` states a verdict and hides what produced it, so a pass that read the wrong section is indistinguishable from a real one.
- **`verify-conventions` finds your rulebook by what it says, not what it is called.** `## Key Conventions`, a heading in your own language, or rules woven through the guide all count. It previously demanded the seeded heading and told repos full of conventions that they had recorded none — measured on two large consumers, where it had been silently doing nothing.
- **CI is offered only when a runner could actually build the repo** — and the test is now whether the repo can tell a runner how to *obtain* each dependency, not whether a path contains a variable. A restore feed can; a colleague's sibling checkout cannot. The earlier rule blocked CI on any `$(Variable)` and so denied a workflow to ordinary self-contained .NET projects; both front doors now share the corrected test.
- **A "not offered" verdict expires by itself.** Decisions computed from evidence — like skipping CI because the build reaches outside the repo — are re-derived on every run instead of remembered, so fixing the underlying dependency restores the offer with no bookkeeping. What stays suppressed is the *question*, not the status line.
- **Declared policy is read, never guessed.** `tasks/.config.yml`'s `integration:` field decides whether work goes through a branch per task or straight to the default branch; nothing infers it from `git log`, which cannot tell a squash-merge history from a commit-to-main one. `tasks init` also reconciles a config written by an older version instead of assuming a present file is a current one.
- **`/specs regen` attributes a feature to code it actually authored**, not code that merely mentions its task id — a commit whose subject leads with the id counts, an id further along or in the body is a cross-reference. Measured on a real project: two known false attributions removed.
- **Generated files carry only what their verb can derive.** Dashboards and rollups no longer host hand-written commentary; per-task notes live on the task, cross-cutting judgement in the epic, and tree provenance in `tasks/.config.yml`. A partly-hand-owned generated file makes every regeneration a judgement call.

### Fixed

- **`verify-conventions` stopped linting build output.** Findings against a bundle are noise at best and at worst point at code nobody can act on. It reads your `.gitattributes` and your guide *first*, because heuristics are provably partial: measured on a real diff, a sourcemap with a 4,154,785-character line and a 75,037-line bundle are obvious, while a generated 128-line service worker is indistinguishable from hand-written code. Anything it cannot classify is linted, not guessed away — a false exclusion silently stops checking code you wrote.
- **A `skills-pi/` stub linked into the Claude skills root would silently replace the runtime's own review pass**, and nothing detected it: the junction's source exists so it was not stale, and it was missing from nowhere. The lint now reports a junction pointing into a tree that root was never meant to hold.
- **`close`'s out-of-scope sweep had no unattended path**, so an autonomous run met a work bullet with nobody to take the offer — and the reading that keeps a loop moving is to close anyway, which is exactly the evaporation the sweep exists to prevent.
- **`tasks close` no longer treats a missing Human test plan as an `N/A` one** — three tasks with every box ticked had been closed to `review` because the closer found no plan at all.
- **Spec staleness could never fire correctly** — the anchor was always earlier than the spec it stamps (measured: 25 of 25 stamps stale, reporting 15 false-positive areas against a true 6), and external sources were resolved against the wrong repo. Both corrected.
- **Spec provenance** — `shaped-by` is now derived on every regen, an unfilled field is no longer read as an empty answer, and the evidence resolver records how much of it was missing.
- **An empty-areas `.map.yml` is treated as absent** at every enforcement point, instead of passing checks it should have failed.
- **`fix-next` no longer nags (DV12) about a story that declares extraction-on-demand.**
- **`tasks` backfills the feature ledger on the link itself**, not on the `--from-feature` flag, so a link made any other way still reconciles.
- Workflow ordering hardened across the rollup/ledger chain; 16 gaps found by an end-to-end lifecycle drill closed; a skill-audit pass fixed cross-skill inconsistencies.
- The `code-review` stub records that Claude Code does not surface the built-in.
- **A newly added skill was invisible to both runtimes.** Installers create one link per folder at install time, so a skill added since your last run resolved nowhere — `adopt-project` itself shipped and sat unlinked. Documented, and now detected by the lint.
- **The survey looked for the shape the scaffolder would have made, instead of the shape you have.** A project with 54 test files across sibling `*.Tests` projects was reported as having no test harness; a guide with `## Key Conventions` as having no rulebook. Detection is by evidence per artifact now, and when in doubt the answer is "unknown", never "missing" — a false "missing" invites writing over a working setup.
- **`skills-lint` had sixteen defects of its own**, found across two review passes, including a scan that could pass having checked nothing. It now ships a regression suite that runs before it in CI, so a silent regression in the only gate cannot go unnoticed.
- **`/tasks close` sweeps `## Out of scope` for work nobody owns.** A bullet describing something someone should later do, with no task id, is a skipped `spawn` wearing a documentation heading — it is now caught at the close rather than discovered by whoever reopens the task.

[Unreleased]: https://github.com/birko/project-lifecycle-skills/commits/main
