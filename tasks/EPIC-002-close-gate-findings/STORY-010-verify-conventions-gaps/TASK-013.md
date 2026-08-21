---
id: TASK-013
parent: STORY-010
feature: null
status: done
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

# verify-conventions must say which sections it read — the output format has no slot for it

## Context

TASK-006's fix (`8762f74`) gave the skill a ladder for finding a rulebook under any heading, and
added the rule that makes the ladder auditable:

> **Say which sections you read** at the top of the report. The user needs to see what you treated
> as the rulebook, both to trust the findings and to catch you reading the wrong thing.

But § *Output format* — the section an agent actually follows when writing the report — was not
touched. It specifies severity groups and a sample, with no line for what was read, and its clean
branch is a bare one-liner:

```
✅ Change follows the project's documented conventions.
```

So on a clean run the instruction is not merely unimplemented, it is contradicted: the output
states a verdict and hides which rulebook produced it. A clean pass from a skill that read the
wrong section — or found little and linted against almost nothing — is indistinguishable from a
real one. That is the same invisible-gate defect the same batch fixed properly in
`skills/tasks/verbs/close.md` step 12, where the sweep's outcome is printed even when it passes.

The ladder's value is precisely that it may pick an unexpected section; unreported, the user
cannot correct a wrong pick.

## Acceptance criteria

- [x] § Output format opens with the sections that were treated as the rulebook — file + heading names, in the guide's own language
- [x] The **clean** branch carries it too, not just the findings branch
- [x] Which rung of the ladder matched is visible (seed `## Conventions`, a named-rules heading, normative content, whole-guide), so an unexpected pick is legible as one
- [x] The rule appears once, in § Output format, with § *Finding the rulebook* pointing at it rather than restating it

## Out of scope

- The ladder itself → TASK-006 (in `review`).
- Generated/vendored file exclusion → TASK-009.

## Human test plan

- [x] Run `/verify-conventions` on a clean diff in Symbio (Slovak headings) and confirm the pass line names the sections read — drilled on `C:\Source\Birko\Consumers\Symbio`, a 1999-line guide with **no** `## Conventions`: the line reports **ladder rung 3** and names twelve `KRITICKE` Slovak rule sections plus the guide's own `smerovnik` router. Previously this printed a bare `✅`
- [x] Run it on this repo and confirm it reports `AGENTS.md § Conventions` via the bridge from `CLAUDE.md`, not `CLAUDE.md` alone — confirmed, rung 1. Stopping at `CLAUDE.md` would report a one-line rulebook and lint against nothing while printing a confident `✅`
- [x] Run it on a guide with no rules and confirm the "not recorded yet" message still reads as a true negative, not as an empty section list — fixture with two non-normative headings and zero must/never/always lines: it prints the seed pointer, not `Rulebook: (none) — 0 sections read` beside a `✅`

## Implementation plan

_Populated by `/tasks plan TASK-013`._

## Progress log

- step 2 — picked over TASK-049 (which re-enters `close.md` right after three review rounds there each
  found their worst defect in the fix rather than the original) and over TASK-009 (higher real-world
  impact, but its acceptance pins verification to Symbio's diff, and its failure mode is *visible noise*
  where this one is *invisible false confidence* — silence outranks throwing).
- step 3 — verified: held. § *Output format* had no source line and its clean branch was a bare
  one-liner, so the rule added by TASK-006 was not merely unimplemented but contradicted.
- step 4 — layer: local.
- step 5 — fix in `skills/verify-conventions/SKILL.md`: § Output format now opens with the rulebook line
  (file, headings in the guide's own language, ladder rung), the clean branch carries it, and the
  no-rules case is explicitly a different report. § *Finding the rulebook* points at it instead of
  restating the rule — it now appears once.
- step 6 — **no guard to fail.** The lint checks frontmatter, wikilinks and file references; it does not
  read a skill's report format. Evidence is the three drills, recorded as drills.
- step 7 — no usable spec map (`areas: []`). Nothing to respec.

## Outcome

**What was broken.** TASK-006 gave the skill a ladder for finding a rulebook under any heading and the
rule that makes it auditable — *say which sections you read*. § *Output format*, the section an agent
actually follows, was never touched: no slot for the source, and a clean branch that was one line. So on
the runs where it matters most the instruction was **contradicted** — a verdict with the rulebook hidden,
and a pass that read the wrong section indistinguishable from a real one.

**The fix.** Every report, clean or not, opens with the file, the headings treated as normative *in the
guide's own language*, and which rung matched. The no-rules case stays a distinct report rather than an
empty section list, so a true negative never renders as "a rulebook was read and found silent".

**Drilled on the repo that motivated the ladder.** Symbio: 1999 lines, no `## Conventions`, twelve
`KRITICKE` Slovak rule sections. The line now reports rung 3 and names them. That run also showed 3 of
its 7 changed files are build output — direct evidence for TASK-009, filed and not fixed here.

**Judgement call: lead with it, don't trail it.** A footer would satisfy the words. It fails the purpose:
the ladder's value is that it can pick an unexpected section, and a reader who has already absorbed the
findings has stopped auditing where they came from.
