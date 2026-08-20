---
id: TASK-022
parent: STORY-002
feature: null
# status: todo | in-progress | review (code done, sign-off pending) | blocked | done | cancelled
status: done
priority: P2
assignee: agent
created: 2026-08-18
depends-on: [TASK-034]
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

- [x] `adopt-project` ends by re-running the owning verb of every generated file whose **inputs this run changed** — derived from what the run actually created rather than a fixed list, so the rule survives the layer gaining artifacts
- [x] `tasks/README.md` is regenerated whenever the run created `docs/features/`, so the feature slice and drift callout exist from the first commit
- [x] The regenerated files ride in the **adoption commit**. A dashboard landing one commit later is a diff nobody reviews, and one the user did not ask for
- [x] The report names what was **regenerated**, distinctly from created or amended — the user did not write those files and should not have to work out why they moved
- [x] Nothing hand-writes a generated shape to satisfy this: it is a verb re-run or it does not happen
- [x] Covers the second case the re-drill found — a generated file written by an **older template** (Presenter's dashboard had no `review` counts row). Re-running the owning verb is the fix for both, so the rule is one rule; what it must not assume is that a *current-looking* generated file is current
- [x] A regeneration **preserves project-specific provenance** the verb cannot reproduce: Presenter's dashboard header records that it came from `/tasks import` off `SPEC.md` § v2, and a template-faithful rewrite would have destroyed that. Decide and record whether the verb keeps such a line or the template gains a slot for it
- [x] `skills-lint` and `skills-lint-test` stay green

**Dependency found at pick time, 2026-08-20: this task needs TASK-034 first.** Criterion 7 and
TASK-034's criterion 1 are one problem from two ends — TASK-034 asks how `triage` regenerates without
destroying unreproducible content; this task's deliverable is a tail step that *makes adoption re-run
`triage` automatically*. Shipping the tail step first turns a latent hazard into an active one: adoption
would wipe Presenter's `/tasks import` provenance header, and this repo's own TASK-004/018 caveats, on
every run. Recorded as `depends-on: [TASK-034]` rather than discovered again later.

## Out of scope

- Backfilling Presenter's dashboard — that repo's own business, not this task's deliverable. **And the remedy is no longer "one `/tasks triage`", as this bullet originally said:** the drill below proves a bare re-run there would destroy the `Imported from SPEC.md § v2` header. Its provenance has to move to `tasks/.config.yml` comments first, per the agent guide's rule. Corrected here rather than left as a wrong instruction someone follows.
- Spec **bodies**: `/specs regen` is real token spend and stays an offer, not an automatic tail step. Landing the map is enough.
- Changing what `triage` renders; this is about *when* it runs.

## Human test plan

- [x] Drill a repo with a `tasks/` tree and no `docs/features/`, accept the features fill, and confirm `tasks/README.md` comes out of the same run carrying the feature slice
- [x] Confirm the adoption commit contains the regenerated dashboard rather than leaving it dirty in the working tree
- [x] Drill a repo where nothing generated is invalidated: no gratuitous regeneration, no noise in the report
- [x] Re-run adoption on an already-complete repo and confirm the tail step writes nothing — idempotence must survive it

## Implementation plan

### Criterion 7, now answerable — and the answer is not the one the criterion offers

TASK-034 settled the policy: **nothing goes in a generated file that its verb cannot derive**, with three
hand-owned homes. That fixes *this* repo. It does **not** fix a consumer repo already in the wild —
Presenter's dashboard still carries its `/tasks import` off `SPEC.md § v2` provenance header today, and
adoption is the thing that would run `triage` over it.

So the criterion's two options — *the verb keeps such a line* or *the template gains a slot* — are both
wrong now, and a third is wrong too: **the tail step must not silently migrate content out of another
repo's file either.** What is left is the option adoption already has a rule for:

> `SKILL.md` step 3: *"Never overwrite a file the repo already owns. Report the conflict; let the user
> resolve it."*

A generated file in someone else's repo is still their file. **Regenerating over unreproducible content
is an overwrite**, so the existing rule already governs it — this task does not need a new principle,
only to notice that the tail step is bound by one it already has.

**Mechanism: render, compare, and only then write.**

| What the comparison shows | What the tail step does |
|---|---|
| Regeneration is a pure no-op | write nothing; do not mention it (idempotence, human-test item 4) |
| Regeneration only **adds** or updates derivable rows | regenerate, and report it under `regenerated` |
| Regeneration would **remove** content the verb cannot reproduce | **stop.** Report what would be lost and where the policy says it belongs; offer, never assume |

That last row is the whole safety property, and it is why this task waited for TASK-034: without a policy
saying where the content *should* live, the report would have nowhere to point.

### Steps

1. **`adopt-project` — a new tail step after step 3's fill, before step 4's report.** Derive the set from
   what the run actually created (criterion 1): for each artifact this run wrote, if it is an *input* to a
   generated file, that file's owning verb is re-run. Do not hard-code a list — walk it from
   `LAYER.md`'s rows, which already name owners, so the rule survives the layer gaining artifacts.
2. **State the one instance that exists today** as an example of the rule rather than the rule itself:
   creating `docs/features/` makes `tasks/README.md`'s feature slice and drift callout renderable, so
   `triage` is re-run (criterion 2).
3. **The compare-before-write gate** from the table above, citing step 3's never-overwrite rule as its
   authority rather than inventing a second one. This is also what covers criterion 6 — an older-template
   file regenerates to the current shape, and if that would drop content, the same gate catches it.
4. **Report bucket `regenerated`**, distinct from `created` / `amended` (criterion 4). It needs its own
   name for the reason the others do: the user did not write these files and should not have to work out
   why they moved. And a *declined* regeneration is reported too — silence would read as "nothing needed".
5. **Criterion 3 — the regenerated files ride in the adoption commit.** State it where the commit is
   offered, not only here.
6. **Criterion 5 is a prohibition, not a step:** the tail step calls verbs. If a verb cannot be called,
   the row is reported unregenerated — it is never hand-shaped. Say so explicitly; it is the tempting
   shortcut when a verb is awkward to invoke.
7. **Layer parity check.** If any of this lands in `LAYER.md`, `new-project` is reconciled too. Expect it
   to stay in `adopt-project` (greenfield generates everything fresh, so nothing is ever invalidated) —
   but confirm and record, as TASK-031 and TASK-038 both did.
8. `skills-lint` + `skills-lint-test`, then the drill.

### Risks and open questions

- **Human-test item 4 (idempotence) is the one most likely to fail.** A tail step that re-runs verbs
  unconditionally makes every re-run dirty, which breaks the skill's stated *"a re-run that finds neither
  writes nothing at all"*. The compare-before-write gate is what preserves it; drill that case first
  rather than last.
- **"Is this artifact an input to that generated file?"** is a real judgement, not a lookup. `docs/features/`
  → `tasks/README.md` is clear. `CHANGELOG.md` → nothing. `.map.yml` → spec bodies, which this task's
  out-of-scope explicitly excludes from automatic regeneration. Write the two or three real edges down and
  say the rule is *derive from `LAYER.md`'s owners*, so a new artifact is judged rather than missed.
- **Detecting "content the verb cannot reproduce" needs the render to happen first**, which means the tail
  step renders into memory or a temp path before deciding. Worth stating, since the obvious implementation
  writes first and diffs after — and that has already lost the content by the time it notices.

### Drill record — 2026-08-20

Subject: `drill-022/legacy-app`, a throwaway with a `tasks/` tree and **no** `docs/features/` — the shape
this task was filed about. Idempotence drilled first, per the plan, since it was the likeliest failure.

| Item | Result |
|---|---|
| **4. Re-run on a complete repo writes nothing** | ✅ on the fully-adopted `widget-store`: nothing created ⇒ the derived set is empty ⇒ no verb re-run, nothing rendered, nothing written. Tree stayed at 0 changes |
| **3. Nothing invalidated ⇒ no noise** | ✅ same run: the `regenerated` bucket never appears, because the branch is never entered |
| **1. Dashboard comes out of the same run** | ✅ creating `docs/features/` made `triage`'s step-8b drift check evaluable for the first time; the re-run added the DV5 callout. Before: 0 callouts, check skipped. After: present |
| **2. It rides in the adoption commit** | ✅ commit `1c34999` carries `docs/features/README.md` **and** `tasks/README.md` together; working tree left at 0 changes |

**The branch the test plan does not name, and the one that matters most.** I gave the fixture the
Presenter shape — a header recording `Imported from SPEC.md § v2 via /tasks import`, which no verb can
recompute — then triggered a second regeneration by creating `docs/specs/.map.yml`. **The gate stopped**:
the file was left byte-untouched (`git status` clean for it), and the report named what would have been
lost plus where the agent guide says it belongs (`tasks/.config.yml` comments). Without the gate, this
task's own tail step would have destroyed exactly the content TASK-034 was filed to protect — which is
why the dependency was real rather than tidy.

**Criterion 7 answered with a third option the criterion did not offer.** Not *the verb keeps the line*,
not *the template gains a slot* — the tail step **refuses to regenerate and says why**, on the authority
of step 3's existing *"never overwrite a file the repo already owns"*. A generated file in someone else's
repo is still their file. No new principle was needed, only noticing the step was already bound by one.

**Found and fixed while checking layer parity:** `LAYER.md` § *Ordering* did not require `docs/features/`
before `tasks init`. `new-project` happened to comply by bullet order (line 85 before 97), but
`adopt-project` follows § *Ordering*, which was silent — so adoption could legitimately have generated the
dashboard first and produced this very defect from ordering rather than from a missing tail step. The
section now requires it, and says ordering is the cheaper guarantee where it can be arranged, with 3c as
the fallback where it cannot. Parity re-checked after the change: both doors comply, neither needed an
edit.

**Honest limit:** items 3 and 4 were verified by applying 3c's rule to an observed repo state (layer
complete, tree clean ⇒ empty derived set), not by a run that emitted output — there is nothing to emit
when the correct behaviour is silence. Items 1, 2 and the stop branch produced real files and commits.
