---
id: TASK-022
parent: STORY-002
feature: null
# status: todo | in-progress | review (code done, sign-off pending) | blocked | done | cancelled
status: todo
priority: P2
assignee: agent
created: 2026-08-18
depends-on: []
blocks: []
findings: []
pr: null
github-issue: null
jira-key: null
---

# Adoption invalidates generated files it never re-generates

## Context

Found in the `adopt-project` drill on `C:\Source\Birko\Consumers\Presenter` (2026-08-18).

The adoption commit `caed40d` touched five files: `CLAUDE.md`, `docs/BRIEF.md`,
`docs/features/README.md`, `docs/specs/.map.yml`, `CHANGELOG.md`. It did **not** touch
`tasks/README.md` — and creating `docs/features/` is precisely the event that changes what that
dashboard says. [[tasks]] `triage` step 8b renders a feature-aware slice and prepends a drift
callout **when `docs/features/` exists**; before this run it did not exist, so the dashboard carries
neither. Verified after the fact: `grep features Presenter/tasks/README.md` → 0 hits, with
`docs/features/` sitting right beside it.

**Premise corrected by the 2026-08-18 re-drill.** The claim above overstates one thing and
understates another. `triage`'s step 8b only *prepends a drift callout*; the feature-aware **slice**
belongs to the stdout snapshot, not the persisted dashboard — and with `docs/features/` holding no
features yet there is no drift to report, so the missing "features" string was harmless. What the
re-drill actually found is worse and more general: Presenter's dashboard was written by an **older
template**, missing the `review` counts row that the current one calls mandatory ("never drop it from
the table"). A generated file ages the same way a config does, and nothing detects it — which is the
`present, outdated` problem one level along, for a file whose owner is a verb nobody re-ran.

So adoption leaves generated files stale two ways: it creates inputs that invalidate them, and they
fall behind their own templates while nobody looks. The repo's rule is that generated files are owned
by their verbs and "keep it current" means *run the owning verb*. Adoption is the one pass that
reshapes several trees at once, which makes it the likeliest thing in the set to leave a stale
generated artifact behind it.

Worth stating once rather than per-artifact: **an adoption that creates an input to a generated file
owes a re-run of that file's owning verb.** `tasks/README.md` once `docs/features/` appears is
today's instance; the same rule covers `docs/features/README.md` once features exist and the spec
bodies once `.map.yml` lands, and each of those already has an owner to call.

## Acceptance criteria

- [ ] `adopt-project` ends by re-running the owning verb of every generated file whose **inputs this run changed** — derived from what the run actually created rather than a fixed list, so the rule survives the layer gaining artifacts
- [ ] `tasks/README.md` is regenerated whenever the run created `docs/features/`, so the feature slice and drift callout exist from the first commit
- [ ] The regenerated files ride in the **adoption commit**. A dashboard landing one commit later is a diff nobody reviews, and one the user did not ask for
- [ ] The report names what was **regenerated**, distinctly from created or amended — the user did not write those files and should not have to work out why they moved
- [ ] Nothing hand-writes a generated shape to satisfy this: it is a verb re-run or it does not happen
- [ ] Covers the second case the re-drill found — a generated file written by an **older template** (Presenter's dashboard had no `review` counts row). Re-running the owning verb is the fix for both, so the rule is one rule; what it must not assume is that a *current-looking* generated file is current
- [ ] A regeneration **preserves project-specific provenance** the verb cannot reproduce: Presenter's dashboard header records that it came from `/tasks import` off `SPEC.md` § v2, and a template-faithful rewrite would have destroyed that. Decide and record whether the verb keeps such a line or the template gains a slot for it
- [ ] `skills-lint` and `skills-lint-test` stay green

## Out of scope

- Backfilling Presenter's dashboard — one `/tasks triage` in that repo, not this task's deliverable.
- Spec **bodies**: `/specs regen` is real token spend and stays an offer, not an automatic tail step. Landing the map is enough.
- Changing what `triage` renders; this is about *when* it runs.

## Human test plan

- [ ] Drill a repo with a `tasks/` tree and no `docs/features/`, accept the features fill, and confirm `tasks/README.md` comes out of the same run carrying the feature slice
- [ ] Confirm the adoption commit contains the regenerated dashboard rather than leaving it dirty in the working tree
- [ ] Drill a repo where nothing generated is invalidated: no gratuitous regeneration, no noise in the report
- [ ] Re-run adoption on an already-complete repo and confirm the tail step writes nothing — idempotence must survive it

## Implementation plan

_Populated by `/tasks plan TASK-022` — leave empty until then._
