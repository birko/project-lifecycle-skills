---
id: TASK-103
parent: STORY-008
feature: null
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: todo
priority: P3
assignee: agent
created: 2026-09-01
depends-on: []
blocks: []
# findings: ids this task remediates, from a review/audit/spec-harvest pass (CR-* SEC-* SH-* VC-*)
findings: [DRILL-079-1]
pr: null
github-issue: null
jira-key: null
---

# Four capability areas are named for the product's shape rather than a consumer's need

## Context

**From two cold reads of the area list during TASK-079**, each given only the names and titles — no repo,
no files. The first failed four names outright; they were renamed and the list re-read. The second read is
better and still not clean, and the residue is a **product** observation more than a naming one, which is
why it is filed rather than iterated on.

**What the renames fixed, confirmed by the second reader:** `spec-harvesting` → `specs-from-code`
(*"the best name in the set… names the input, the output, and the direction of travel"*),
`review-gate-fallbacks` → `code-and-security-review` (*"capability, clear"*). No name now refers to the
repo's directory layout, which was the first read's central complaint.

**What is left, and why iterating further is the wrong move:**

| Area | The objection | Why it is not just a better word away |
|---|---|---|
| `installation` | *"Not a capability at all — this is a README section… not something you'd want, ask for, or decide about."* | Correct. But the four install scripts are behavioural (link-not-copy, one junction per folder, re-run on a new skill) and must land in an area or in `ignore`; ignoring executable behaviour is worse |
| `skill-contract-lint` | maintainer-facing, *"unless the audience is skill authors"* | It **is** consumer-facing — a consuming repo may ship a project-local skill that shadows one of these — but only if the reader knows that. The title now says so; the name still cannot |
| `vocabulary-and-decision-records` | *"a filing cabinet drawer with two unrelated things in it. The 'and' is the confession."* | One skill owns both halves, so **the map has no split available**. The observation is about `domain`'s scope, not about this file |
| `roadmap` | *"actively misleading — the word promises a timeline and delivers a drift report"* | **The two readers directly contradict each other here.** The first proposed this exact word (*"the consumer word for this is roadmap"*); the second says it mispredicts. It is also the skill's own name and the user-facing verb |

**Two readers disagreeing on one name is the signal to stop.** Chasing a third would be fitting to
individual taste, and a check that reports differently every run is worth what an unrun one is — the same
argument this repo makes about `/fix-next`'s degenerate ranking keys.

### The finding underneath, which is the part worth acting on

Both reads independently produced the **same** structural complaint, and it is not about wording:

> *"'Something checks my change' — four names, and I could not sort them from names alone:*
> `convention-conformance`, `intent-verification`, `code-and-security-review`, `skill-contract-lint`.
> *Reading the titles I can see they're genuinely different questions (rules / requirements / bugs / file
> schema), and that distinction is sharp and worth advertising. The names advertise none of it."*

And:

> *"'Where does my work live' — three names:* `work-tracking`, `feature-lifecycle`, `roadmap`. *I'd expect
> one of these to contain the others."*

Plus, from both: `idea-interrogation` reads as the opening phase of `feature-lifecycle`, not a peer.

**That is a product-surface finding wearing a naming complaint.** Four review passes a user cannot tell
apart, and three overlapping places work can live, are facts about the skill set — the map inherited them
rather than caused them. Renaming areas cannot fix a boundary the product does not draw.

**One concrete miss worth its own line:** the second reader guessed `intent-verification` **wrong**,
assuming it meant *inferring what code intends to do* rather than *checking the change built what was
asked*. A name whose job is to mean something, and which a careful reader takes to mean something else, is
the one item here that is genuinely a naming defect rather than a product one.

## Acceptance criteria

- [ ] `intent-verification` is renamed to something a reader does not misread, or the title is made to carry the meaning the name cannot
- [ ] The four review areas are distinguishable from their names alone, or a stated decision that they are not and why the titles carry it instead
- [ ] Whether `installation` and `skill-contract-lint` belong in a *capability* map at all is decided — kept with a reason, or moved to `ignore` with the behavioural-code objection answered
- [ ] The `work-tracking` / `feature-lifecycle` / `roadmap` overlap is either resolved or recorded as a product boundary this map only reflects
- [ ] No name is changed on one reader's preference alone where a second reader disagreed — `roadmap` specifically stays unless a tiebreak is argued
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- The areas' **coverage**. TASK-079 verified 63 of 63 tracked files mapped with no overlaps; this task changes names and titles, never globs, and any change here must re-verify that.
- Generating the spec bodies — **TASK-080**.
- `domain`'s own scope, and whether one skill should own both a glossary and decision records. Real, and a question for that skill rather than for this map.

## Human test plan

- [ ] A third cold reader, given only names and titles, sorts the four review areas correctly by what each checks
- [ ] The same reader does not guess `intent-verification`'s meaning wrong

## Implementation plan

_Populated by `/tasks plan TASK-103` — leave empty until then._
