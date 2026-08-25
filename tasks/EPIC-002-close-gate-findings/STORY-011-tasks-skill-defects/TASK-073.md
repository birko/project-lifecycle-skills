---
id: TASK-073
parent: STORY-011
feature: null
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: done
priority: P2
assignee: agent
created: 2026-08-23
depends-on: []
blocks: []
# findings: ids this task remediates, from a review/audit/spec-harvest pass (CR-* SEC-* SH-* VC-*)
findings: []
pr: null
github-issue: null
jira-key: null
---

# Should the task template stop carrying an enum comment that shadows its own field?

## Context

**Spawned from TASK-036's out-of-scope sweep, 2026-08-23.** TASK-036 fixed the *reader*: `/specs regen` now
names the leading enum comment explicitly and gives the anchored, frontmatter-scoped pattern. This task asks
the question one level up, which that fix deliberately left open.

`skills/tasks/templates/task.md` emits, on **every** task file:

```
# status: todo | in-progress | review (code done, sign-off pending) | blocked | done | cancelled
status: done
```

The comment contains **every legal value**, one line above the field it documents. That is what makes it a
trap: any unanchored read or write that matches `status:` hits the comment first, and the comment parses as
`todo`.

**Two instances, both measured, and they point in opposite directions on the fix:**

- **Read side** (TASK-036's original finding): an unanchored first-match read returns `todo` for *every*
  template-generated task, including the `done` ones — so `/specs regen` would conclude the work never
  landed and refuse the commit's evidence.
- **Write side** (2026-08-23): a `/fix-next` run set its pick with an unanchored substring replace, rewrote
  the **comment** instead of the field, and ran the task to completion — fix, verification, a full
  `## Outcome` — while its frontmatter still read `todo`. Caught only because a task count came out one
  short.

**The question this task owns.** TASK-036's answer was *teach every reader and writer to anchor*. The
alternative is *remove the shadow*: the hazard exists only because the comment sits adjacent to the field
and duplicates its value space. Options, and none is obviously right:

| Option | Cost |
|---|---|
| **Keep it, rely on anchoring** (status quo after TASK-036) | Zero change, and the trap stays armed for every future reader and writer. Two instances in two days is not a reassuring base rate. |
| **Delete the comment** | Kills the hazard at source. Loses the one place a task author sees the legal values — and `status` is the field most likely to be hand-typed wrongly. Where does the vocabulary get documented instead? |
| **Move it away from the field** — e.g. one comment block at the top of the frontmatter, or below the last field | Keeps the documentation, breaks the adjacency that makes first-match land on it. Cheapest real fix, and it still leaves a line containing every value somewhere in the file. |
| **Reword so it cannot parse as a value** — e.g. `# status — one of: todo, in-progress, …` | The comment no longer looks like `status: <value>`, so a `status:` match cannot hit it at all. Keeps documentation *and* adjacency. |

**The last option looks strongest and should still be argued rather than assumed** — it changes a template
every existing task file already carries, so consider whether existing files get migrated or left, and say
which. `/tasks triage` and `/tasks close` both read these files.

**Note this is a template change, not a rule change.** The vocabulary itself is normative and lives in
[[tasks]] § Lifecycle; the comment is a convenience copy of it — which is its own small instance of the
*defer to a shared inventory* rule, worth naming in whichever direction this lands.

## Acceptance criteria

- [x] A decision is recorded: keep / delete / move / reword, with the reason and the rejected options
- [x] If the template changes, it is stated whether existing task files are migrated or left as-is — and if left, that mixed state is safe for every reader
- [x] Whatever lands, an unanchored `status:` match can no longer return a legal-looking value from a non-field line — or the task records that it still can and why that was accepted
- [x] The legal-value vocabulary remains discoverable to someone writing a task by hand, wherever it ends up
- [x] `skills-lint` and `skills-lint-test` stay green

## Out of scope

- `/specs regen`'s read pattern — **TASK-036**, closed. This is the source-side question.
- The status vocabulary itself. Adding or removing a state is a different change entirely.
- Other frontmatter comments (`# findings:`, `# theme:`, `# kind:`). Check whether they share the shape and **spawn** if so; only `status:` has two measured instances, and only it duplicates a closed value set.

## Human test plan

- [x] Create a task with `/tasks new` and confirm a hand-author can still tell what values `status:` accepts
- [x] Run an unanchored `grep -m1 'status:'` over the new file and confirm the result is not a legal-looking value (or that the accepted residual risk is recorded)
      — run over **all 79** real task/story/epic files: 0 return a non-field value, against 79 before the change.
- [x] Run `/tasks triage` and `/tasks close` against both a migrated and an unmigrated file if the two shapes are allowed to coexist

## Implementation plan

_Populated by `/tasks plan TASK-073` — leave empty until then._

## Outcome

**Decided by scan, not by taste — and the scan changed the question twice.**

### What the scan settled

**Option 4, reword.** Every frontmatter comment in every template was enumerated, and the trap turned out to
have a precise shape: **a comment whose text parses as a legal value of its own field.** Only `status:` does
that. `kind:`, `source:`, `theme:` and `findings:` are prose descriptions — *"omit for a normal epic"* is not
a `kind`. So:

- **Delete** was rejected: `status:` is the *only* comment carrying a real value list, i.e. the only one with
  reference value worth keeping, and it documents the field most likely to be hand-typed wrong.
- **Move away from the field** was rejected as half a fix: a line containing every value still sits in the
  file, so a file-wide unanchored match still hits it. It defeats only adjacency-based matches.
- **Keep and rely on anchoring** was rejected on the base rate: two measured instances in two days, across
  79 files and every future reader and writer.
- **Reword** costs nothing measurable: `# status — one of: todo, in-progress, …` cannot match `status:`
  followed by a value, keeps the documentation, and keeps it adjacent to the field it documents.

### What the scan corrected about this task's own premise

**It is not one template, it is four**, and the task said *"`skills/tasks/templates/task.md` emits, on every
task file"*:

| Template | Carried the trap |
|---|---|
| `tasks/templates/TASK.md` | yes — the one the task named |
| `tasks/templates/STORY.md` | yes |
| `tasks/templates/EPIC.md` | yes |
| **`feature/templates/idea.md`** | **yes — in a different skill entirely** |

The fourth was found only by widening the scan past `skills/tasks/`, and **it is the worst of the four.**
[[roadmap]]'s Cross-tree pass reads `idea.md`'s `status:` as the feature tree's coarse marker. An unanchored
read there returns **`idea`** — which is a *legal* coarse value — so DV6, whose job is to flag a marker
outside the coarse set, would **pass silently on a wrong answer**. The task-file version at least yielded
`todo`, which is often visibly wrong. This one is invisible.

### What the scan closed without a spawn

The Out of scope said: *"Other frontmatter comments … check whether they share the shape and **spawn** if
so."* Checked — **they do not.** Four comments, all prose, none parseable as its own field's value. No spawn,
and the reason is on record so nobody re-runs the check.

### Migration: required, not optional (AC 2)

Under reword, an **unmigrated file keeps the trap**, so mixed state is *not* safe — which settles AC 2's
question rather than leaving it to preference. **79 files migrated** (61 TASK, 16 STORY, 2 EPIC). No
`idea.md` instances exist here to migrate: `docs/features/` holds only its index.

**Two `^# status:` hits deliberately remain**, in TASK-036 and TASK-073, and both are **fenced quotations of
the old shape** in the tasks that document it. Leaving them is correct — and the fact that a `^`-anchored
grep found them is *itself* another instance of the fenced-decoy problem, which is exactly why
`regen.md`'s rule scopes the read to the frontmatter fences rather than to column 0.

### Step 6 — the defect is measurably gone

| Check | Result | Role |
|---|---|---|
| naive `grep -m1 'status:'` vs the real field, over all 79 task/story/epic files | **0 mismatches**. Before: it returned `todo` for every one | **fix-dependent** — this is the defect, eliminated and measured |
| any template still carrying the trap | none, repo-wide, across all 9 templates in all skills | fix-dependent |
| the vocabulary is still discoverable (AC 4) | `# status — one of: …` sits on the line above the field, listing every legal value | fix-dependent |
| lint | OK (18 skills) | contract pin |

### The honest residual

**Consumer repos keep the old shape.** Their existing task files were rendered before this change, and
`adopt-project` does not rewrite task bodies. So the trap survives wherever these skills are already
installed — which is precisely why TASK-036's **reader-side** fix was the right first move and remains
necessary. This change stops the trap being *minted*; anchoring is what survives the files already out there.
Both are needed, and neither is sufficient.

## Progress log

- step 2 — picked at the user's request to let a scan decide a design call rather than judgement. Key 6 (theme) **inert**: every EPIC-002 story declares `correctness-invariants`.
- step 3 — verified: **held, and the premise was narrow in two ways.** Three tasks templates carry it, not one; and `feature/templates/idea.md` carries it in another skill, where [[roadmap]] reads the field and DV6 cannot catch a wrong-but-legal value.
- step 4 — layer: **local.**
- step 5 — reworded all four templates; migrated 79 existing files; left two fenced quotations intact.
- step 6 — naive-vs-real read over all 79 files: **0 mismatches** (was 79); no template carries the trap repo-wide; lint green.
- step 7 — no usable spec map (`areas: []`); regen skipped and stated.
- step 8 — 5d sweep: the *other frontmatter comments* bullet was conditional and the scan **answered it no**, so nothing spawned. Gate: standards pass, intent pass, correctness pass; security not applicable.
