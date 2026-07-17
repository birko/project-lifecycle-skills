---
name: specs
description: Harvest-with-diff-review specification generation — scan the codebase and (re)generate capability specs under docs/specs/ (SHALL requirements + Given/When/Then scenarios grounded in what the code actually does), then review the spec diff as an intended-vs-unintended behavioral-change check. Use when the user says "/specs", "regen specs", "regenerate specs", "write specs for area X", "spec the codebase", "spec an area of concern", "are the specs stale", "spec drift", "vygeneruj specifikacie", "specka", after a story closes ([[tasks]] close offers a scoped regen), or when onboarding/review needs a behavioral map of an area. Specs are generated FROM code (never stale by construction), stamped with generated-at commit + sources + shaped-by feature provenance. Tech-agnostic — works on any project with a docs/ folder. [[roadmap]] audits spec drift; [[feature]] review checks decision→spec landing.
---

# specs

Capability specs **harvested from code, reviewed as diffs**. The code is the source of
truth; each spec is a regenerable behavioral map of one capability ("area of concern").
Regeneration is never a silent overwrite — the spec diff is presented and judged:
*was this behavioral change intended?* An unexpected diff is a **finding**
(unintended behavior change), not documentation churn.

What this deliberately is **not**: spec-first development. Intent lives in
`docs/features/` decisions and task acceptance criteria (the [[feature]]/[[tasks]]
skills); this skill records *actuality* and cross-checks the two at regen time.
There is no `changes/` proposal directory — that would be a third drift pair.

## Verbs (router)

User invokes as `/specs <verb> [args]`. Read **only** the verb file matching the request.

| Verb | What it does | File |
|---|---|---|
| `init` | Discovery pass — propose the area map (`.map.yml`), optionally grill it, write it | [verbs/init.md](verbs/init.md) |
| `regen` | Harvest area(s) from code → rewrite spec(s) → **diff review** → stamp provenance | [verbs/regen.md](verbs/regen.md) |
| `verify` | Read-only staleness check — which specs' sources changed since `generated-at` | [verbs/verify.md](verbs/verify.md) |
| `show` | Print one area's spec + its freshness | [verbs/show.md](verbs/show.md) |
| `help` | Print the verb table | [verbs/help.md](verbs/help.md) |

Bare `/specs` → run [verify](verbs/verify.md) in summary mode (the fastest "where do specs stand" answer).
No `docs/specs/.map.yml` in the project → print `No docs/specs/.map.yml — run /specs init to bootstrap.` and exit (except for `init` itself).

## File layout (per project)

```
docs/specs/
  .map.yml            ← area → source-globs index (hand-editable; the only human-owned file here)
  <area>.md           ← one generated spec per capability
```

## The area map — `.map.yml`

The keystone for tech-agnosticism: you can't hardcode what an "area of concern" is
across stacks, so each project declares its own. Shape (see [templates/map.yml](templates/map.yml)):

```yaml
areas:
  - name: bulk-filter-updates          # kebab-case, becomes <area>.md
    title: Bulk filter-based updates
    sources:                            # globs, project-root-relative
      - src/AbstractBulkStore.cs
      - src/IBulk*.cs
ignore:                                 # never counts as unmapped
  - "**/bin/**"
  - "**/*.test.*"
```

Rules:
- **Granularity = capability**, not class or file — `auth-session`, `lazy-initialization`,
  `bulk-filter-updates`. A healthy project has ~5–20 areas.
- **Unmapped code is a flag, not a silence.** `regen` and `verify` report project sources
  matched by no area and no `ignore` glob — the map grows with the project instead of
  silently under-covering it.
- The map is **hand-editable**; spec bodies are **generated** — regen overwrites them
  (after diff review). Don't hand-edit spec bodies; fix the code or the map.

## Spec format

See [templates/spec.md](templates/spec.md). Frontmatter carries the machine-checkable stamp:

```yaml
---
area: bulk-filter-updates
generated-at: <commit sha of HEAD at harvest time>
generated-on: YYYY-MM-DD
sources: [<resolved file list>]
shaped-by: [FEATURE-012]    # append-only feature provenance, machine-written
---
```

Body: `## Purpose` → `## Requirements` (`### Requirement:` blocks, each stated as
"The system SHALL …", each with one or more `#### Scenario:` Given/When/Then blocks).
Scenarios are **mandatory** — they're the join point [[populate-tests]] will consume
(scenario ↔ test case).

**Stable-wording rule:** when regenerating, read the existing spec first and change
only what the code contradicts. The diff must mean "behavior changed", not
"the harvester rephrased everything" — a noisy diff destroys the review's value.

## Shape detection — where `docs/specs/` lives

Identical to the [[tasks]] skill's project-root walk (`.config.yml` marker → solution
file → `.git`). Polyrepo note: when a repo family has an aggregator (see the [[tasks]]
skill's shape-detection override), each sub-repo carries its **own** `docs/specs/` next
to its CLAUDE.md; cross-cutting specs (contracts spanning projects) live at the
aggregator. A cross-cutting story regens per affected project (driven by its epic's
`affects:` list), never one merged tree.

## Provenance & cross-links

Features are the *why*; the link to specs is **computed at regen time**, never
hand-maintained: story/feature context → tasks' `feature:` frontmatter → appended to the
spec's `shaped-by`. Backward question ("why does this behave so?") → open the listed
features' `decisions.md`. Forward check ("did the decision land?") → [[feature]]
`review` Gate A greps `shaped-by:`. Drift audit (stale specs, done feature with no spec
landing) → [[roadmap]]'s Cross-tree pass owns the rules; `verify` here provides the
staleness primitive it calls.

## Conventions

- **Specs describe what IS — bugs included.** If harvesting reveals behavior that looks
  wrong, spec it as-is *and* raise it in the diff review as a suspected bug (offer
  `/tasks new`); never silently spec around it or "fix" the spec to match intent.
- **Diff review is the point.** Never `regen` with silent overwrite; every behavioral
  change in the diff gets classified: matches an approved decision / intended anyway /
  unexplained → finding.
- Read-only verbs (`verify`, `show`) never write. Stdout only — no persisted status
  mirrors (same rationale as [[roadmap]]'s stdout-only rule).
- **No `Co-Authored-By:` trailers** in any commit this skill produces.
- PowerShell-compatible commands (no `2>/dev/null`, no inline `VAR=x cmd`).

## Related skills

- [[tasks]] — `close` on a STORY offers a scoped `/specs regen <areas> --story STORY-NNN`; the bare-`/tasks` snapshot shows the `specs: N stale` slice via [[roadmap]].
- [[feature]] — record of intent; `review` Gate A checks each approved decision landed in a spec (`shaped-by:`). A decision with no spec landing = incomplete feature.
- [[roadmap]] — owns spec-drift divergence rules (DV7/DV8) in its Cross-tree pass; calls this skill's `verify` staleness logic. One engine, many renderers.
- [[new-project]] — seeds `docs/specs/.map.yml` at project birth (stack scaffolding skills that chain through it inherit the seed).
- [[grill-me]] — optional interrogation of the proposed area map during `init`.
- [[populate-tests]] — future consumer: spec scenarios as the coverage ledger's source ("scenario with no covering test" as a mechanical gap). Not wired yet — don't couple.
