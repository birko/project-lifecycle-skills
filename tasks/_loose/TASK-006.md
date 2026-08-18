---
id: TASK-006
parent: null
feature: null
status: done
priority: P1
assignee: unassigned
created: 2026-08-18
depends-on: []
blocks: []
findings: []
pr: null
github-issue: null
jira-key: null
---

# verify-conventions reports "no conventions" on repos full of conventions

## Context

Found while surveying real consumers for the STORY-002 drills.

`skills/verify-conventions/SKILL.md` matches the rulebook by **literal heading**: if the guide has
no `## Conventions` section it stops with *"This project hasn't recorded conventions yet — add a
`## Conventions` block to CLAUDE.md."*

`C:\Source\Birko\Consumers\Symbio` — 1801 commits, 582 task files, 94 feature folders, 31 spec
areas, the team's most developed repo — has **1835 lines of extremely detailed rules** under its
own headings, in Slovak:

```
## Pravidla zavislosti (KRITICKE)
## Pravidla pre N+1 query (KRITICKE — backend)
## Pravidla pre repository predikaty — SQL translation (KRITICKE — backend)
## Transakcna hranica — atomicka service operacia (KRITICKE — backend)
## Pravidla permissions (KRITICKE — UI aj API)
## Testovanie — vrstvy a kde co zije (KRITICKE — konvencia)
```

So on that repo the linter reports there is nothing to check and quits — a **false negative at
every `/tasks close`**, on the repo with the most rules to enforce. Same shape as the mis-cased
wikilink defect: a gate that degrades to nothing while reporting success. Nobody would notice,
because "no findings" and "no rules found" look identical in the output.

`C:\Source\Birko\Consumers\BardStudio` shows the defect is not about language at all: its guide
has `## Key Conventions`. One extra word, and the linter reports the project has no rules.

Four of the seven surveyed consumers are affected.

## Acceptance criteria

- [x] `verify-conventions` finds a project's rules when they are **not** under a heading literally named `## Conventions` — including non-English headings
- [x] It never reports "this project hasn't recorded conventions yet" for a guide that plainly carries rules; that message is reserved for a guide with **no rule content at all**
- [x] When it cannot map a guide onto the seed's subsections, it degrades to linting against the whole rule text rather than stopping
- [x] The distinction is stated in the skill: *absent rulebook* (a real finding, worth surfacing) versus *rulebook under a different shape* (adapt to it, do not lecture the user about their heading names)
- [x] Verified against Symbio end-to-end on commit `2a118fcc` (11 files, hand-written): ladder step 2 locates 10 rule-named sections where step 1 finds none; the applicable rules are `## Pravidla pre cislovanie dokumentov (KRITICKE — backend)` and `## Pravidla zavislosti (KRITICKE)`; verdict clean and traceable — the diff moves NumberSequence registration to the host under "Core" and drops seven per-module registrations, exactly as the rule requires. The register-on-introduce check also passes: the same commit added the rule line to CLAUDE.md
- [x] Consider whether the seed should stop assuming English headings at all, and record the decision either way

## Out of scope

- Rewriting Symbio's `CLAUDE.md` to match the seed. **The skill adapts to the project, not the reverse** — 1835 lines of working rules are not a defect to be reformatted.
- The `adopt-project` side of this (do not propose adding conventions to a repo that has them under other headings) → tracked on TASK-004.

## Human test plan

- [x] Two passes on 2026-08-18. **Symbio's real in-flight diff** (4 files: `index.html`, `sw.js`, `wwwroot/app.js`, `app.js.map`) — the rulebook was found via ladder **step 2**, since Symbio has no `## Conventions` heading at all, only 12 `## Pravidla … (KRITICKE)` sections; no source-level findings, because every changed file is build output (cache-bust hash `58ced6be` → `45f246ef`). That outcome is itself evidence for TASK-009: nothing in the skill says a generated bundle is not lintable source. **Then a rule-traceable pass**, on a fixture carrying Symbio's actual `CLAUDE.md` and a staged `InvoiceService.cs` with `await lines.FindAllAsync(...)` inside `foreach (var inv in all)` — one 🛑 blocker, quoting the Slovak heading and its own words back (*"NIKDY nevolaj repository v cykle"*), with the fix taken from that rule's own ✅ block. Fixture rather than Symbio's tree because the check is whether the skill quotes the rule, not whether Symbio's committed code is adherent
- [x] Fixture with a guide of `## Setup` and `## Layout` and **zero** normative statements (0 hits for must/never/always/required/forbidden): the pass worked the whole ladder, found nothing that reads as a rule, and printed the *"hasn't recorded conventions yet"* pointer. The true negative survives the fix — which was the actual risk of making detection permissive
- [x] Exercised repeatedly on this repo through the session's own close gates — on the TASK-018, TASK-021 and TASK-023 diffs — each time producing findings quoted from `AGENTS.md § Conventions` (the shared-inventory rule, *router SKILL.md files stay small*, register-on-introduce). No regression: the seed-shaped guide is still read first and still yields traceable findings

## Implementation plan

_Populated by `/tasks plan TASK-006`._
