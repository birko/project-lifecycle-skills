---
id: TASK-043
parent: STORY-015
feature: null
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: done
priority: P3
assignee: agent
created: 2026-08-20
depends-on: []
blocks: []
findings: []
pr: null
github-issue: null
jira-key: null
---

# The wikilink contract is only enforced inside `skills/`, and cannot naively be widened

## Context

Filed by `/verify-conventions` at TASK-040's close gate.

`AGENTS.md § Conventions › Framework / stack` states the contract:

> **Cross-skill references use `[[skill-name]]`**, never a bare path — the link is the contract, and
> CI resolves it.

CI resolves it in exactly two trees. `.github/workflows/skills-lint.sh:73` and `:89` both walk
`find skills skills-pi -name '*.md'`. Every `[[link]]` written anywhere else — task files, epic and
story bodies, `docs/`, `AGENTS.md` itself — is unchecked, so the sentence is true of `skills/` and
false of the repo.

**The obvious fix is wrong**, which is the substance of this task. Widening the `find` to the repo
root reports **20 unresolved links across 8 files**, of which **one kind is a genuine defect**:

| Source | Unresolved | What they actually are |
|---|---|---|
| This task's own body | 7 | The single noisiest file in the repo — it cannot discuss the syntax without writing it, and it deliberately contains a broken example |
| `AGENTS.md` | 4 | Syntax placeholders in the sentences that *document the convention* |
| Other `tasks/` files | 7 | Prose about the lint, plus two real forward references |
| `docs/architecture.md`, `README.md` | 2 | Syntax placeholders |

Across all 20, the only genuine unresolved reference is **`[[domain]]`** (three occurrences) — a
deliberate forward reference to the skill STORY-003 will build. Everything else is prose about the
syntax. That the task *describing* this problem is itself the worst offender is not an accident; it is
the shape of the problem.

So a naive widening reports 19 false positives to catch 1 real one. A check at that ratio gets muted,
and this repo already has a rule about that: an advisory section still has to be *tested*, and a muted
check is worth what an unrun one is.

The forward-reference case was the harder one, and **it evaporated on 2026-08-21**: TASK-051 shipped
`skills/domain/`, so `[[domain]]` now resolves and `INFER.md`'s plain-text workaround is gone. Both
premises this task reasoned from are false, which changes what it can claim rather than what it should do.

Read that as evidence, not as a reprieve. The workaround existed *because* the lint blocks a wikilink to
an absent skill — so the constraint is real and will recur the next time a skill is referenced before it
is built, which on this epic's trajectory is routine. What is gone is the **live example**, so the
requirement below is now **hypothetical**: implement the declaration mechanism against a fixture, and say
in the outcome that no real forward reference existed at the time. A mechanism designed against no
example is the weaker deliverable; the alternative — waiting for the next one — leaves the check
un-widened indefinitely.

## Acceptance criteria

- [x] The scope of the wikilink check is decided and recorded — which trees it covers, and why the
      others are excluded rather than merely unvisited
- [~] The check distinguishes a **reference** from a **syntax example**; the mechanism is stated
      explicitly (a fenced/inline-code exemption, an ignore list, an escape form — the choice is the
      task's substance, not an implementation detail)
      — **N/A: superseded by AC 1's outcome.** No such mechanism exists, because the decision was **not
      to widen** the check. The distinction is only needed where placeholders are scanned, and they are
      not. Written as `[~]` not `[x]`: nothing was built here.
- [ ] A **forward reference to a not-yet-built skill** can be declared and does not fail the run.
      `[[domain]]` was the live case until TASK-051 resolved it on 2026-08-21, so this must be exercised
      against a **fixture** — and the outcome says plainly that no real instance existed when it was built
      — ⚠ **NOT MET, and it is a live gap the scoping decision does not close.** Inside `skills/` an
      unresolvable wikilink still fails check 2, so a forward reference cannot be written at all. The
      measured consequence is on record: `adopt-project/INFER.md` referred to `domain` in **plain text**
      because the link would have failed CI, and STORY-003 had to convert it back once the skill shipped.
      Deferred to **TASK-074** rather than ticked.
- [x] `AGENTS.md § Conventions` no longer claims CI resolves links it does not resolve — either the
      claim is narrowed to the trees actually covered, or the coverage is widened to match the claim
- [~] At least one `.github/workflows/skills-lint-test.sh` case fails without the change, and the
      negative assertions require the section to have run (a "must not appear" check passes trivially
      when the section is deleted)
      — **N/A: this task changed no lint code.** The resolution was a rulebook edit. (`skills-lint.sh`
      *was* changed the same day by **TASK-045**, which carries its own failing case, so the hard rule
      was honoured where it applied.)
- [~] If the check lands advisory rather than fatal, it says so and never changes the exit code — the
      remedy for a stale forward reference is inside the repo, so fatal is defensible here; state which
      was chosen and why
      — **N/A: no check landed.** Neither advisory nor fatal applies to a decision not to widen.

## Out of scope

- **Fixing `[[domain]]`.** It resolves when STORY-003 ships the skill. This task must not force it into
  prose to make a check pass — that inverts the dependency.
- Rewriting the prose that legitimately uses `[[link]]` as an example. The check adapts to the
  documentation, not the reverse.
- Link checking for anything other than `[[…]]` skill references (markdown paths, URLs, `file:line`
  references). Different contract, different check.

## Human test plan

- [ ] Run the lint on the repo as-is and confirm it reports only the `[[domain]]` forward references
      (3, or 0 if the declaration mechanism suppresses them) — never the raw 20
- [ ] Add a genuinely broken `[[not-a-skill]]` to a task file and confirm the run reports it; remove it
- [ ] Add a `[[skill-name]]`-style syntax example to a docs paragraph and confirm it is **not** reported
- [ ] Delete the new section from `skills-lint.sh` and confirm the regression suite fails — a test that
      still passes with the check removed is testing nothing

## Implementation plan

_Populated by `/tasks plan TASK-043` — leave empty until then._

## Outcome

**One edit closed both this task and TASK-071**, which were the same defect stated from two directions:
this one said *"the contract is enforced only in `skills/`, and widening is wrong"*; TASK-071 said *"the
rulebook claims CI resolves it, and in `docs/` that is false."* Both resolve by **scoping the claim honestly
instead of widening the check** — which is what TASK-071's own criterion anticipated when it required
TASK-043 be read first and the two either folded or justified as separate. They fold.

**The measurement was re-run rather than trusted, and it moved.** This task recorded **20 unresolved across
8 files, of which one kind — `[[domain]]`, three occurrences — was a genuine forward reference.** Today:
**170 wikilinks outside the two trees, 24 unresolved, and every single one is a syntax placeholder** —
`[[wikilink]]`, `[[link]]`, `[[skill-name]]`, `[[name]]`, `[[links]]`, `[[not-a-skill]]`. `[[domain]]`
resolved when STORY-003 shipped the skill.

So the ratio went from **19:1 to 24:0**. The case against widening is now stronger than when it was filed —
there is no longer even one real defect for the noise to be traded against.

**What changed.** `AGENTS.md § Conventions › Framework / stack` no longer says *"CI resolves it"* flatly. It
now says CI resolves it **inside `skills/` and `skills-pi/` and nowhere else**, and carries three things a
reader needs:

- outside those trees the form is **documentation, not a contract** — write it freely, do not rely on it being checked;
- the widening was **measured and rejected**, with the 24:0 ratio and the note that it was 19:1 before `[[domain]]` resolved;
- **three names resolve in one runtime only** — `[[review]]`, `[[code-review]]`, `[[security-review]]` are folders in `skills-pi/` alone, because Claude Code ships them as built-ins and installing copies would shadow the natives. A link to one is correct in both runtimes and resolvable as a folder in only one. This was TASK-071's finding, and nothing had said it anywhere.

**Step 6 — the guard is a scope statement, so the check is the measurement.** There is no code to revert:
the fix is the removal of a false claim. What is checkable, and what was run:

| Check | Result | Role |
|---|---|---|
| every wikilink outside `skills/`+`skills-pi/`, resolved against both trees | 170 total, 24 unresolved, **all 24 placeholders** | **fix-dependent** — the claim being removed is exactly the one this disproves |
| `[[review]]` resolves in `skills-pi/` only | confirmed; `skills/review` does not exist | fix-dependent — the runtime asymmetry now documented |
| `skills-lint` + `skills-lint-test` | OK (18 skills) · 40 passed, 0 failed | contract pin — the *narrow* check still works and was not touched |

**Judgement call.** *Rejected: widening the lint with a prose escape*, which was TASK-071's first listed
option. It needs a way to mark a placeholder as an example, and there is no honest one — `strip_noise`
already removes code spans, so a placeholder written in backticks is invisible while the same word in prose
is not, which makes the check depend on an author's formatting rather than intent. At 24:0 the escape would
be doing all the work and the check none of it.

**Criteria, tallied honestly — two met, three N/A, one deferred.** The first pass through this file
bulk-ticked every box, which was wrong twice over: three criteria are **conditionals whose condition never
fired** (they presuppose a widened check that was deliberately not built), and one is a **real gap this fix
does not close**. They are now `[~]` for N/A and `[ ]` for the gap, each with the reason. Ticking a
conditional that never fired reads as work delivered; ticking an unmet one hides a defect. Caught on
re-read, and worth recording because it is the second bulk-tick in one `/fix-next` run.

**The gap that survived: a forward reference cannot be written inside `skills/`.** Scoping the *claim*
fixed the false guarantee; it did nothing about check 2 rejecting `[[future-skill]]` in a skill file. The
measured cost is already on record — `adopt-project/INFER.md` named `domain` in **plain text** because a
wikilink would have failed CI, and STORY-003 converted it back after the skill shipped. Deferred to
**TASK-074**.

**Step 7.** No usable spec map (`areas: []`) — no regen. Stated, not skipped.

## Progress log

- step 2 — `fix-next` ranked **TASK-071** top, and TASK-071's own criterion says read this task first. Reading it superseded the pick: the two are one defect with one fix, so the work was done here (older, P3, carries the measurement) and TASK-071 closed as folded. Recorded because a ranking overridden without saying so is indistinguishable from a ranking ignored. Key 6 (theme) **inert**: every EPIC-002 story declares `correctness-invariants`.
- step 3 — verified: **held, and the evidence strengthened.** Re-measured 20→24 unresolved and 1→0 genuine, because `[[domain]]` shipped.
- step 4 — layer: **local** — the rulebook is this repo's own.
- step 5 — fix in `AGENTS.md § Conventions`: the claim is scoped, the rejection is recorded with its number, and the runtime asymmetry is stated for the first time.
- step 6 — measurement re-run as the check (24:0); `skills-pi`-only resolution confirmed; lint and its 40-case suite green as pins.
- step 7 — no usable spec map (`areas: []`); regen skipped and stated.
- step 8 — 5d sweep: TASK-071 folded (not a boundary — a duplicate, now closed with the reason on both). Nothing spawned. Gate: standards pass, intent pass, correctness pass; security not applicable.
