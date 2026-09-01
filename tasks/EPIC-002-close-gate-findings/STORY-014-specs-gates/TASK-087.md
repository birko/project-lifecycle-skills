---
id: TASK-087
parent: STORY-014
feature: null
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: review
priority: P2
assignee: agent
picked-by: fix-next
created: 2026-09-01
depends-on: []
blocks: []
# findings: ids this task remediates, from a review/audit/spec-harvest pass (CR-* SEC-* SH-* VC-*)
findings: [DRILL-033-1]
pr: null
github-issue: null
jira-key: null
---

# A re-discovery rewrites `.map.yml` and nothing says the human's prose survives

## Context

**From the 2026-09-01 cold drill of `/specs init`** (TASK-033's re-drill, run read-only against
`BardStudio` and `Presenter`).

`.map.yml` is declared **"HAND-EDITABLE: this is the only human-owned file in `docs/specs/`"**. Step 6
says to write it *"from [templates/map.yml] with the blessed areas"*. Step 2 says a re-discovery must
*"propose additions/renames against the existing map, never drop an existing area without asking."*

**Everything in that protects the `areas:` — the structured data — and nothing protects the prose.**
Presenter's map opens with two hand-written blocks a person wrote and no verb can regenerate: when and
why it was discovered, and a paragraph explaining that `Program.cs` is mapped to `http-api` rather than
smeared across every domain area *because it is a minimal-API host whose single 386-line file carries the
whole HTTP surface*. That is precisely the kind of reasoning the repo's own rules say must not live only
in a person's head.

**The skill argues against itself here, and the drill quoted it.** `SKILL.md` justifies using *keys*
rather than comments for the coverage stamp on the grounds that *"a comment is the part of a YAML file
any re-serialization drops."* Taken at face value that sentence predicts exactly this: a re-discovery
that re-serializes from the template drops the previous author's rationale as a side effect. The drill
hand-preserved the comments and flagged that it was choosing, not following — *"a literal 're-serialize
from the template' reading would delete real content the previous run's author wrote."*

**Why this outranks its size.** Silent loss of hand-written rationale from a file the skill calls
human-owned is the worst shape of data loss: reversible only if someone notices, and nothing makes them
notice. It is the same class as TASK-066 (landing before regenerating) — a generated-shape file carrying
content its verb cannot reproduce.

## Acceptance criteria

- [ ] A re-discovery's effect on hand-written comments is **stated** — preserved, or dropped with the loss announced, chosen deliberately
- [ ] If preserved: what "preserve" means is concrete enough to follow (whole-file comments, per-area comments, or both), since a naive template re-render loses all of them
- [ ] `SKILL.md`'s *"a comment is what any re-serialization drops"* line no longer reads as licence to drop the human's prose — it is an argument for keys, not against comments
- [ ] The rule holds for the `ignore:` block too, which in three consumer maps carries per-entry explanations of why a path is not source
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- The coverage keys themselves — TASK-033 owns those.
- Whether `.map.yml` should be machine-owned instead. It is hand-owned by declaration; changing that is a different decision.

## Human test plan

- [ ] Run `/specs init` as a re-discovery against a map carrying hand-written comments (Presenter's is the standing example) and confirm the outcome matches whatever this task decided, rather than depending on how the agent felt about re-serializing

## Implementation plan

_Populated by `/tasks plan TASK-087` — leave empty until then._

## Outcome

**What the fix was.** `/specs init` step 6 said to write `.map.yml` *"from `templates/map.yml`"* — a
template re-render. Step 2 protected the `areas:` list and nothing else. So a re-discovery destroyed
every hand-written comment in a file the skill itself declares the only human-owned one in
`docs/specs/`, and destroyed it *invisibly*, because the areas survived and the diff read as a routine
regeneration. Whether to re-render is now decided by **the file's existence**: absent → render the
template; present → edit in place, applying only what the run blessed.

**Step-6 split — executed, not traced.** The old instruction was applied literally to a copy of
`Presenter`'s real map:

| Reading | Comment lines | Words of prose | Areas |
|---|---|---|---|
| Old — render from template | 17 → **0** | 173 → **0** | 11 → 11 |
| New — edit in place | 17 → **17** | 173 → **173** | 11 → 11 |

The loss is **total, not partial**, and the areas surviving untouched is what makes it silent. Across
the four consumer maps the exposure is **99 comment lines / ~1,240 words** — independently recounted at
the gate and confirmed. Among the casualties on Presenter alone: the paragraph explaining that one
386-line minimal-API `Program.cs` is mapped to `http-api` rather than smeared across every domain area,
because the endpoint contract is its own capability. No verb can recompute that.

**Judgement calls, and why the stricter option was rejected.**

- **A mechanism, not a checklist.** The rule is *edit, don't re-render*, rather than a list of things to
  preserve — a list is what goes one item short, which is how TASK-027 and TASK-082 arose earlier in the
  same session. **I then broke my own rule one paragraph later**, and the gate caught it: my first draft
  enumerated the permitted edits as *"add or rename areas, overwrite the coverage keys"*, omitting the
  `ignore:` entries step 4's reconciliation **requires** in order to reach `verified`. On Symbio's 33
  housekeeping files that draft could not both obey step 6 and write an honest verdict. The enumeration
  is now open, and includes the area removal step 2 explicitly permits with consent — which the closed
  list had also forbidden.
- **Keyed on file existence, never on the word "fresh".** `SKILL.md` calls an empty-`areas:` map a
  *fresh discovery*, which it is — no delta to propose. But the **file exists**. Measured on this repo's
  own map: `areas: 0`, and **11 comment lines plus 5 hand-chosen `ignore` entries**, including the note
  recording why it was seeded empty. My first draft defined "fresh" as *a repo that has no map*, so an
  agent reading `SKILL.md`'s label would have re-rendered and deleted exactly what this task exists to
  protect — the defect arriving through the one door left open.
- **Rejected: justifying keys by their overwritability.** The draft said the stamps being keys is what
  lets the step overwrite them in place. That is false — an in-place edit overwrites a comment just as
  easily — and a rule whose stated reason does not hold is one an agent routes around under pressure.
  Keys win on **branchability**; writing them every run is a separate point about *when*, and both now
  say so separately.

**Flagged, not fixed:** `docs/specs/.map.yml` here still carries `areas: []`, so step 7's respec could
not run — **TASK-079** owns it. Nothing spawned: both out-of-scope bullets name owners.

## Progress log

- step 2 - picked; ranked above TASK-061 on key 1: silent loss of human-authored content the verb cannot reproduce outranks a silent omission where nothing is destroyed. Key 2 agrees - fires on any re-discovery of a map carrying comments, and three consumer maps do. TASK-086 stays excluded as decision-shaped; this one has an obvious safe default. Key 6 degenerate.
- step 3 - verified: HOLDS exactly. init.md step 6 says write "from templates/map.yml" (a re-render); step 2 protects `areas:` only; and both init.md:51 and SKILL.md:78 carry the sentence that predicts the loss while arguing for keys. Stakes measured: 99 comment lines / ~1,240 words across four consumer maps.
- step 4 - layer: local.
- step 5 - fix in skills/specs/verbs/init.md (steps 2 and 6) and skills/specs/SKILL.md. Lint OK (18 skills), 43/43.
- step 6 - applied the OLD instruction literally to a copy of Presenter's map: 17 comment lines -> 0, 173 words -> 0, while all 11 areas survived. New instruction: 17 -> 17. Loss is total and silent. No fix-dependent automated test exists (prose); lint + 43 cases are contract pins, NOT evidence.
- step 5b - standards OK, intent OK, correctness found SIX defects in my own diff: a closed edit list omitting `ignore:` (the exact failure the next paragraph warns about), "fresh" defined against SKILL.md so it re-renders this repo's own seeded map, a frozen-lines rule contradicting step 2's consented removal, a misquoted declaration with an unresolvable "here", a false causal claim about keys, and this log stopping at step 2. All six fixed.
- step 5d - 2 boundaries, 0 spawned.
- step 7 - respec skipped: areas: [] (TASK-079).
- step 8 - parked at REVIEW: the human test plan's drill is real and unrun.
