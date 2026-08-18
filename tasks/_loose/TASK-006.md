---
id: TASK-006
parent: null
feature: null
status: review
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

- [ ] Run `/verify-conventions` on a real diff in Symbio and confirm it produces findings traceable to the Slovak rule headings, quoting them
- [ ] Run it on a guide with genuinely no rules and confirm the "not recorded yet" message still appears — the true-negative must survive the fix
- [ ] Run it on this repo (headings match the seed) and confirm no regression

## Implementation plan

_Populated by `/tasks plan TASK-006`._
