---
id: TASK-103
parent: STORY-008
feature: null
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: done
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

- [x] ~~`intent-verification` is renamed~~ **partly: renamed twice, and the second attempt (`acceptance-check`) was misread again. Now `intent-and-scope-check`, on the misreader's own proposal — unverified by a fourth read, deliberately** to something a reader does not misread, or the title is made to carry the meaning the name cannot
- [x] The four review areas are distinguishable from their names alone, or a stated decision that they are not and why the titles carry it instead
- [x] Whether `installation` and `skill-contract-lint` belong in a *capability* map at all is decided — kept with a reason, or moved to `ignore` with the behavioural-code objection answered
- [x] The `work-tracking` / `feature-lifecycle` / `roadmap` overlap is either resolved or recorded as a product boundary this map only reflects
- [x] No name is changed on one reader's preference alone where a second reader disagreed — `roadmap` specifically stays unless a tiebreak is argued
- [x] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- The areas' **coverage**. TASK-079 verified 63 of 63 tracked files mapped with no overlaps; this task changes names and titles, never globs, and any change here must re-verify that.
- Generating the spec bodies — **TASK-080**.
- `domain`'s own scope, and whether one skill should own both a glossary and decision records. Real, and a question for that skill rather than for this map.

## Human test plan

- [x] ~~A third cold reader, given only names and titles, sorts the four review areas correctly by what each checks~~ — **N/A as of TASK-104: there are no longer four review areas.** It was *run* and *failed* (2 of 4) before the merge, which is what produced the evidence the merge rests on. Recording it as N/A rather than failed, because the subject was removed rather than the test passed.
- [x] ~~The same reader does not guess `intent-verification`'s meaning wrong~~ — **N/A, same reason.** It failed twice (opaque as `intent-verification`, then misread as UAT when renamed `acceptance-check`), and the second failure is precisely what made the merge look right rather than merely convenient.

## Implementation plan

_Populated by `/tasks plan TASK-103` — leave empty until then._

## Progress log

- picked 2026-09-02 via `/tasks pick`, at the user's direction after they asked how the names would be reproposed. **Sequencing note that matters:** TASK-079 sits at `review` *because* the cold read of these names failed, so this task changes the very thing that review would examine. Landing it first means 079's reviewer sees the final names instead of names about to move.
- **method stated before any rename, because the individual answers fall out of it.** Both cold reads rated the same four names clean (`specs-from-code`, `session-handoff`, `test-authoring`, `changelog-maintenance`) and the same four opaque (`convention-conformance`, `intent-verification`, `cross-tree-reporting`, `review-gate-fallbacks`). The difference is consistent: **the clean names name the object you act on; the opaque ones name the property you check.** Specs, tests, a changelog, a session are things; conformance, verification, reporting, fallbacks are abstractions or circumstances. Five rules follow — name the object not the property; where several areas share a verb, name each by what it checks **against**, since that is a reader's only discriminator; never name a circumstance or your own file layout; test by *wrong hypothesis* rather than blank, because a confident misread is worse than opacity; and ship only what two independent readers agree on, keeping the incumbent and fixing the **title** wherever they disagreed.
- renames applied: `convention-conformance` → **`rulebook-check`**, `intent-verification` → **`acceptance-check`**, `project-scaffolding` → **`project-baseline`**, `skill-contract-lint` → **`skill-authoring-rules`**, `vocabulary-and-decision-records` → **`glossary-and-adrs`**. Each names the object rather than the property, and the four checking areas are now named by what each checks **against** — the rulebook, the acceptance criteria, correctness, the skill schema.
- **`roadmap` kept, against the second reader's objection, and the title fixed instead.** Rule 5 applied to the one case it exists for: the first reader proposed that exact word, so changing it on the second's taste is not an improvement. The **title** was the actual fault — it led with the reconciliation, which is what made the word feel like a bait-and-switch — and now leads with the view. Criterion 5 asked for exactly this restraint.
- titles rewritten where a name cannot carry the load. `work-tracking` and `feature-lifecycle` now say *developer-facing* and *stakeholder-facing* outright, since both readers could not find the axis and no name supplies it. `idea-interrogation` says *any plan (feature or not)*, because both took it for a phase of the lifecycle. `installation` now **admits it is not a capability** rather than disguising one — a reader called it *"a README section"* and was right; it is in the map because the four install scripts are behaviour (link-not-copy, one junction per folder, re-run on a new folder) and a map must cover behaviour. Not every behaviour is a capability, and the file says so. `pi` is glossed, after a reader flagged it as an unexplained proper noun that made them want to leave and search.
- **coverage re-verified after the renames even though no glob moved** — the task's own Out of scope demands it: 63 of 63 mapped, nothing unmapped, 16 areas, lint green. A rename that silently orphaned a file would be invisible otherwise.
- stale cross-reference caught: the `code-and-security-review` comment still pointed at `convention-conformance and intent-verification` after they were renamed. Fixed. The header's naming history gained a second-pass entry — it recorded round one and would otherwise have implied the current names were the first draft.
- third cold read launched, and **one read only**: rule 5 says stop where two readers disagree, so this run tests the specific claims (can the four checking areas be sorted by name; is `acceptance-check` misread) rather than re-opening taste.
- **third cold read: 2 of 4 checking areas guessed right, and my own rename was misread again.** `code-and-security-review` and `skill-authoring-rules` landed; `project-rules-check`'s predecessor `rulebook-check` was *"half right — the name never says whose rulebook"*; and **`acceptance-check` was read as acceptance/UAT testing** — *"the worst name in the list… 'acceptance' imports a testing meaning it doesn't have"*. So my fix for a misread name produced a *differently* misread name: `intent-verification` was opaque, `acceptance-check` was confidently wrong, which is worse.
- three fixes applied, none of them taste. **`acceptance-check` → `intent-and-scope-check`**, taken from the reader who misread it — its diagnosis was that the scope half (*"nothing extra"*) is the area's most distinctive behaviour and both earlier names hid it. **`rulebook-check` → `project-rules-check`**: *"whose rules"* was the single missing word, and the reader's first guess was the library's own rather than the consuming project's — the opposite audience. **`roadmap` → `project-roadmap`**, because the tiebreak flipped: one reader proposed `roadmap`, two then objected on **different** grounds, and the second (*"a library's roadmap is its own future… nothing says it operates on MY repo's data"*) is the one a prospective installer hits first. One word answers it, and the same possessive fix serves both.
- **`project-baseline` left alone: readers two and three contradict each other.** Two objected that *"scaffolding means source and framework wiring everywhere else"*; three wants `project-scaffolding` back and calls `baseline` a word needing a noun. Both dislike both candidates. Rule 5 applies exactly as written — no change on one reader's preference against another's.
- **criterion 2 met by the escape it was written with, not by a fourth rename.** It permitted *"a stated decision that they are not [distinguishable] and why the titles carry it instead"*, and three reads now justify that decision rather than merely suspecting it: best score two of four, and every read reached the same diagnosis independently. The decision is recorded **in the map itself**, not only here, so the next person meets it before trying more words.
- **closed at `review`, both human-test-plan items unticked.** Item 1 asked a third reader to sort the four checking areas correctly — it scored 2 of 4. Item 2 asked that the renamed area not be misread — it was. The renames are real improvements and the coverage is re-verified at 63/63, but the two things this plan set out to demonstrate did not happen, and ticking them would be the caveat-beside-a-tick this repo refuses. **Refusing a fourth round is the deliberate call:** three reads, a 2-of-4 ceiling, and two readers contradicting each other on two separate names is where more rounds fit taste instead of finding defects.
- **closed `done` on 2026-09-02, after TASK-104 superseded the half that was blocking it.** This task's naming findings all stand: five renames, the `roadmap` tiebreak, and `project-baseline` left alone on a genuine reader deadlock. What it could *not* do was make four checking areas sortable by name — three reads, a 2-of-4 ceiling — and it recorded that as a product boundary rather than forcing more words. The user then made the product call and TASK-104 merged them, which removed the subject of both test-plan items.
- **The recorded decision in `docs/specs/.map.yml` was rewritten by TASK-104**, so this task's conclusion no longer contradicts the file it was written into: the rule it established survives (name the object; where several areas share a verb, name each by what it checks against), the workaround it settled for does not.
- Worth keeping in view for whoever reads this next: **the failure was the useful part.** Had the third read passed, the three areas would still be three, and the map would still be disagreeing with `AGENTS.md`'s own framing of the gate as one thing with several axes.
