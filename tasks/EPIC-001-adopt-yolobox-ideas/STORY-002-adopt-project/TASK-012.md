---
id: TASK-012
parent: STORY-002
feature: null
status: done
priority: P1
assignee: agent
created: 2026-08-18
depends-on: []
blocks: []
findings: []
pr: null
github-issue: null
jira-key: null
---

# The adopt-project router still teaches three survey states; LAYER.md now mandates four

## Context

`e5ce252` added § *Detect what the repo has* to `skills/new-project/LAYER.md`, which requires the
survey to report **four** states — `present`, `present, elsewhere`, `unknown`, `missing` — because
a false "missing" invites a fill that writes over a working setup (the .NET repo with 54 test
files in sibling `*.Tests` projects, reported as having no harness).

`skills/adopt-project/SKILL.md` was not updated with it:

- Step 1 (`:31`) still says classify as **present / missing / present but incomplete** — a
  complete-looking, closed list of three, and it is the file an agent loads first.
- Step 4's report (`:73`) has three buckets — created / left alone / still missing — with nowhere
  to put "present, elsewhere" or "unknown".
- Step 3 does not carry LAYER.md's rule that **`unknown` stops the fill**.

Step 1 does point at LAYER.md, so a thorough agent would read the four states there and hit a
direct contradiction with the sentence that sent it. Either way the fix is overridable by the
defect it was written to prevent — and this is precisely the drift the LAYER.md/SKILL.md split
("inventory here, creation detail there") was introduced to stop.

## Acceptance criteria

- [x] Step 1 names the four states as a pointer and defers to LAYER.md § *Detect what the repo has* as the definition — explicitly, so a future editor does not re-close the list
- [x] Step 4 is now four buckets in a table; **present, elsewhere** carries the paths/form found, and `unknown` is kept visibly distinct from `missing` inside the last bucket
- [x] Step 3's bound rules went from two to three — an `unknown` row is not filled, with the rationale inline
- [x] Swept both files: 4 restatement sites found, 2 deferred (step 3 ordering → LAYER.md § *Ordering*; the owner shortlist → its **Owner** column), 2 deliberately kept (see the plan's growing-list-vs-invariant test). `INFER.md` and `new-project/SKILL.md` checked and clear

## Out of scope

- Changing the four states themselves; they are settled by TASK-008's finding.
- The installer gap that keeps the skill unreachable → TASK-011.
- **"Present but incomplete" as a fifth state — decided against, not deferred.** An artifact that
  exists is `present`; its gap is reported alongside it. Step 1 now says so explicitly, so the
  concept survives the vocabulary change rather than being dropped by it. Revisit only if a real
  repo produces a case that neither `present`-with-gap nor `unknown` describes — that would be a
  LAYER.md change, and therefore a layer-parity change touching both front doors.

## Human test plan

- [x] WorkoutTracker (2026-08-18): `Reps.Api.Tests/` + `Reps.Domain.Tests/` as siblings, no top-level `tests/`, 105 test files — the harness row reads present with the paths named, never `missing`
- [x] Built the case rather than waiting for one, because the five real repos all resolved: a Rust repo with no local `tasks/` whose `origin` is `https://git.internal.invalid/team/thing.git`. `git ls-remote` fails on host resolution and `gh` cannot reach it, so whether work is tracked in an issue tracker there **cannot be established** — `LAYER.md` is explicit that tracking in GitHub Issues or Jira alone is *tracking, not an absence*. The row reports **unknown**, and the fill declined it: no `tasks/` folder was created (verified by `ls` afterwards). This is the distinction that matters — a `missing` there would have invited writing a task tree into a repo that may already have one elsewhere
- [x] Confirmed, and against more than four — the sweep surfaced a real instance of every state in the list (see TASK-008's record, which shares this evidence). A reader can tell "not found" from "did not look properly" because the `unknown` row names *why* it could not be determined: an unreachable remote, not a missing folder

## Implementation plan

### The distinction the whole task turns on

Criterion 4 says to hunt for "any other place where one restates the other's list" — but a blanket
no-repetition rule would be wrong, and applying one would damage the file. This repo also requires
that a verb reads correctly standalone. So separate the two kinds of repetition:

| Kind | Example | Verdict |
|---|---|---|
| **A list that can grow** — states, artifacts, owners, an ordering | the three-state classification; the ordering sentence; the owner shortlist | **Drift.** Adding a row to LAYER.md silently makes the copy wrong, and nothing signals it. Defer to LAYER.md instead of restating. |
| **A single invariant restated at the point of use** | "Never overwrite a file the repo already owns" | **Keep.** It cannot go stale — there is no list to fall out of sync — and it is load-bearing exactly where the fill happens. |

Test to apply per site: *if LAYER.md gained a row tomorrow, would this sentence become wrong
without anyone touching it?* Yes → defer. No → leave it.

### Step 1 — Fix the classification (criterion 1)

`SKILL.md:31` currently closes the list at three:

> classify every artifact as **present**, **missing**, or **present but incomplete**

Two defects, not one. It is short by two states, **and** it invents a fourth that LAYER.md does not
have — *present but incomplete* (the parenthetical gives the real examples: a guide with no
`## Conventions`, a `tasks/` tree with no `.config.yml`). So this is not a truncation to fix by
appending; the vocabularies genuinely differ.

Decide where "present but incomplete" lands before editing:

- It is **not** `present, elsewhere` — that means *found in another form/location*, which is the
  opposite claim (the artifact is fine, the path differs).
- Closest fit is **present**, with the gap reported — a guide *is* present; its missing rulebook is
  the highest-value finding, which LAYER.md's agent-guide row already calls out ("flag it loudly").

⚠ Acceptance criteria question: criterion 1 offers "uses LAYER.md's four states **or** defers to it
rather than restating". Deferring is the stronger option — it is the only one that survives LAYER.md
growing a fifth state — but the four states are the survey's core vocabulary and step 1 is the first
thing an agent reads, so a bare pointer may under-serve it. Plan takes the middle: **defer for the
authoritative definition, name the four states as a pointer**, and make the deferral explicit enough
that a future editor knows not to re-close the list. Say if you want a pure pointer instead.

Rewrite so it points at LAYER.md § *Detect what the repo has* as the definition, names the four
states without redefining them, and carries the one rule that decides behaviour: **when in doubt,
`unknown`, not `missing`** — plus a line on where "incomplete" goes, so the concept is not just
silently dropped by this edit.

### Step 2 — Give the report somewhere to put the other two states (criterion 2)

`SKILL.md:73-74` has three buckets — created / left alone / still missing — and no home for
`present, elsewhere` or `unknown`. This is the more consequential half: a survey that classifies
four ways and reports three ways loses the distinction at the moment the user reads it, which is
the only moment it matters.

Target shape — four buckets, each with the "why" the current text already demands:

| Bucket | Carries |
|---|---|
| **created** | what was written |
| **left alone** | why — "present already", "you declined" |
| **present, elsewhere** | **where** — the actual paths/form found. LAYER.md forbids silently relocating or offering a second copy, so the location is the payload |
| **unknown / still missing** | which of the two, and why — "could not determine X", "needs a decision", "blocked on a remote" |

Keep `unknown` and `missing` visually distinct even if adjacent: LAYER.md's whole argument is that
"I could not tell" and "you don't have it" are different claims, and collapsing them in the report
re-introduces the defect one layer later.

### Step 3 — Record that `unknown` stops the fill (criterion 3)

Step 3's two binding rules (`SKILL.md:66-69`) are *never overwrite* and *never reconstruct BRIEF.md*.
LAYER.md's "**unknown** — honest, and it stops the fill" has no counterpart here, so the router
never tells the fill to halt.

Add it as a third bound rule in the same voice: an `unknown` row is not filled — ask instead. State
the rationale inline in one clause (filling on an unknown is the false-missing defect with an extra
step), because a rule an agent does not understand is one it routes around under pressure.

### Step 4 — Sweep for the other restatements (criterion 4)

Scan complete; four sites found, three of them real:

| Site | What it copies | Action |
|---|---|---|
| `SKILL.md:62-63` step 3 ordering | LAYER.md § *Ordering* (110-112), near-verbatim | **Defer.** A growing layer changes the order; two copies will disagree |
| `SKILL.md:22-25` "What it does not do" | LAYER.md's **Owner** column, but only 3 of its rows | **Defer for the list, keep the point.** The paragraph's argument (don't hand-roll shapes) is worth stating; the enumeration goes stale the moment LAYER.md gains an owner |
| `SKILL.md:63-64` "follow its **already present?** column" | nothing — it *points* at the column | **Leave.** This is the shape the rest should look like |
| `SKILL.md:68` never-overwrite | LAYER.md § *Rule* | **Leave.** Invariant, not a list; cannot go stale, and it is load-bearing at the fill |

Also confirmed **out** of scope by inspection, so nobody re-checks them:
- `INFER.md` — no state/artifact list; its "present" hits are ordinary prose.
- `new-project/SKILL.md` — has no survey. Its one LAYER.md reference (`:45`) is a pointer to the
  *already present?* column, already the correct shape.

### Layer parity

**No `new-project` change needed, and that is a real finding rather than an omission.** The
layer-parity rule binds changes that extend the *universal layer*; this task changes only how the
*survey* reports, and `new-project` runs no survey — it creates from nothing and hands a populated
directory to `adopt-project` (`new-project/SKILL.md:45`). LAYER.md, the shared inventory, is not
edited here at all: it is already correct and is the thing being deferred to. Record this reasoning
in the close so the parity check is visibly answered, not silently skipped.

### Critical files

- `skills/adopt-project/SKILL.md` — the only file edited (steps 1-4)
- `skills/new-project/LAYER.md` — **read-only**; it is the authority, not a target
- `.github/workflows/skills-lint.sh` — run after; the edits touch a `[[link]]`-bearing router

### Risks / tradeoffs

- **The router must stay small** (§ Conventions). Four steps of additions push against that, so
  every one should shrink toward a pointer rather than grow a second copy — deferring is both the
  correctness fix and the size fix, which is the main reason to prefer it over restating.
- **"Present but incomplete" is a real concept with no LAYER.md home.** Folding it into `present`
  is the plan's judgement, not a settled decision. If it deserves to be a fifth state, that is a
  LAYER.md change and therefore a layer-parity change — a separate task, not this one.
- **This is a prose fix to a skill with no automated check for it.** The lint verifies links and
  frontmatter; nothing can assert "the router agrees with LAYER.md". The Human test plan's three
  drills are the only real verification, and all three need a repo with the right shape.
