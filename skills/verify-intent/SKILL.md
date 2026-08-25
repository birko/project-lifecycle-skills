---
name: verify-intent
description: Check whether a diff actually built what was asked — separately from whether it follows the rules and whether it is correct. Reports three classes of finding, each quoting the requirement it came from: requirements missing or only partly built, behaviour nobody asked for (scope creep), and requirements that look implemented but do the wrong thing. Use when the user says "/verify-intent", "verify intent", "did we build what was asked", "does this match the task", "check the scope of this change", "is anything missing from this change", "zodpovedá to zadaniu", "spravili sme čo bolo zadané", "skontroluj rozsah zmien", "chýba v tom niečo", or before marking a task done. Tech-agnostic — it reads the intent the repo already recorded, so it works on any stack.
---

# verify-intent

The **fidelity axis** of a review gate: *did this change build what was asked?*

> **Three questions, three skills, and they do not substitute for each other.**
>
> | Skill | Asks | A change can fail it while passing the others |
> |---|---|---|
> | [[verify-conventions]] | does this follow our documented conventions? | correct code that ignores the rulebook |
> | [[code-review]] | is this correct? | conventional code that is wrong |
> | **verify-intent** | did this build what was asked? | clean, conventional, correct code implementing the wrong thing |
>
> Run them together at a gate. **Never merge or rerank their findings into one list** — a single
> ordered list lets a convention warning sit above an unbuilt requirement and read as the larger
> problem.

**Advisory.** It reports; it does not fix, and it does not block a commit by itself.

## What it reads — say so, every run

Two **intent** sources and one **baseline**, and the difference between those two words is the whole of
this section. Print what you actually read at the top of every report: a reader cannot tell a thorough
pass from a shallow one unless the pass names its inputs, and "checked against the task" is a much weaker
claim than "checked against the task, the agreed decisions, and the area's current spec".

### Intent — what was asked

| Given | Read |
|---|---|
| A task id (`/verify-intent TASK-046`) | that task's `## Acceptance criteria` |
| That task carries `feature: FEATURE-NNN` | **also** the `approved` and `changed` rows of `docs/features/FEATURE-NNN/decisions.md` — the `Decision` column is the statement, the `→ Tasks` column says which tasks were meant to carry it |
| Nothing, but a task is in progress | that task's criteria — name which task you picked |
| Nothing, and no task in flight | ask the user what the change was meant to do, in one line |

**The states that are *not* intent still carry information.** Read `approved` and `changed` as what was
asked — and treat a diff that implements a `removed` or `deferred` row as **scope creep of the worst
kind**: not merely unasked-for, but decided against, with the rationale and date sitting in the same row.
Quote that rationale in the finding; it is the strongest evidence this skill can offer. `proposed` is
neither — it has not been decided, so a diff implementing it is a decision taken by whoever wrote the
code, and worth surfacing as one. (These are reachable, not theoretical: one real consumer ledger carries
332 `approved`, 4 `changed`, 3 `removed`, 1 `deferred` and 1 `proposed`.)

**A decision outranks a task criterion, and a disagreement between them is itself a finding.** The ledger
is what was agreed; the criteria are one decomposition of it, and a decomposition can drift. A diff that
satisfies its task and contradicts an `approved` decision is precisely the "clean code implementing the
wrong thing" this axis exists to catch — report it against the decision, quoting both.

Read the ledger through [[roadmap]]'s Cross-tree pass rather than re-parsing `decisions.md` here; that
engine already owns the feature↔task join.

### Baseline — what the area already does

`docs/specs/` is **not** an intent source, and treating it as one is the mistake to avoid. Specs are
**harvested from the code** ([[specs]]), so a spec states what an area *currently promises*, not what
anyone asked for. That still makes it valuable, for a different question: a diff that contradicts a spec
requirement **no decision or criterion asked to change** is unasked-for behavioural change — *scope creep
at spec altitude*, the kind a per-file read cannot see.

Resolve which areas cover the changed files with [[specs]]' `.map.yml` globs; don't invent a mapping.
Then, per requirement the diff contradicts:

| Does a decision or criterion ask for this change? | Outcome |
|---|---|
| Yes | not a finding — the spec is simply stale now, and `/specs regen` is the follow-up rather than anything to fix here |
| No | **scope creep**, quoting the spec requirement and the `file:line` that contradicts it |

### When a source is absent, say which — never fall back silently

No `docs/features/`, a task with `feature: null`, a missing or empty `areas:` map: each is normal, and
each **narrows the claim the report can make**. Name the sources read and the ones that were not there. A
pass that read only the task's criteria while printing the header of a three-source pass is the
invisible-gate defect this skill set keeps rediscovering.

## The ticked-box trap — read this before writing a finding

A closing task's acceptance criteria are usually **already ticked**. They are ticked by the person who
wrote the change, as a claim. If this skill reads the ticks, it confirms whatever the author believed
and is worth nothing.

**Judge every criterion against the diff, never against its checkbox.**

**The tick never selects the class.** A checkbox says nothing about the code, so it cannot decide what
kind of defect the code has — the *diff* does that. A ticked criterion with no corresponding change is
**Missing**, exactly as an unticked one would be; a ticked criterion whose change diverges is **Wrong**,
exactly as an unticked one would be.

What the tick adds is a **second, separate defect**: the record claims work that is not there. Append
`— ticked, but the diff does not support it` to any finding whose criterion was checked. Two runs over
the same diff must produce the same class, and a repo where criteria are *usually* already ticked is
one where letting the tick move a finding between classes would make the common case the ambiguous one.

## The three classes

| Class | Fires when | The finding must carry |
|---|---|---|
| **Missing** | A criterion has no corresponding change in the diff, or is implemented for only part of what it states | the criterion quoted verbatim, and the `file:line` where the implementation *should* have gone — the nearest place the change would land. A missing thing has no location of its own, which is exactly why naming the expected one is the useful half: "nothing implements this" sends a reader hunting, "nothing at `close.md:96` implements this" does not |
| **Scope creep** | The diff changes behaviour no criterion asked for | `file:line`, what the change does, and the fact that no criterion covers it |
| **Wrong** | A criterion has a corresponding change that does not do what the criterion says. *Corresponding change* is the whole test — no change at all is Missing, whatever the checkbox says | the criterion quoted, the `file:line`, and the specific divergence |

**Scope creep is a finding, not an accusation.** Most instances are legitimate work that simply belongs
in its own task — the right resolution is usually [`/tasks spawn`](../tasks/verbs/spawn.md), not a
revert. Say so in the finding rather than leaving the reader to infer that the change was wrong to make.

**A criterion you cannot judge from the diff is its own outcome.** Say *unverifiable from this diff, and
why* — a criterion about runtime behaviour, or one whose evidence is a drill rather than code. Silently
counting it as met is the failure this skill exists to prevent; silently counting it as missing produces
noise nobody trusts.

## Steps

1. **Determine the diff.** Prefer staged (`git diff --cached`); fall back to the working tree, or a
   branch/PR range if the user names one. Not git-tracked → ask which files to judge.
2. **Resolve the intent source** per the table above, and note it for the report header.
3. **Read the criteria as a list of claims**, ignoring their checkboxes entirely.
4. **Walk the diff once**, mapping each hunk to the criterion it serves, or to nothing.
5. **Emit findings**, taking the class from the table above, not from this line: an **unmatched**
   criterion is *Missing*; a **matched but divergent** one is *Wrong* — a Wrong finding is matched by
   definition, so routing it through "unmatched" would empty the class. Unmatched hunks are *scope
   creep*. A criterion the diff cannot settle either way is **unverifiable**, which is its own outcome
   and not a fourth class.
6. **Report**, leading with what was read.

## Output format

Lead with the source, then group by class. Quote on every finding, so a reader can check it without
re-deriving the judgement:

```
Intent:   TASK-046 § Acceptance criteria (8) · FEATURE-012 decisions.md (3 approved, 1 changed)
Baseline: docs/specs/auth-session.md — covers 4 of 6 changed files
Not read: no other mapped area matches this diff

🛑 Missing — criterion 4, expected at skills/verify-intent/SKILL.md § What it reads
   "Runs standalone against the working tree or a named diff, with no task id required"
   Nothing in the diff handles an invocation without a task id.

⚠ Wrong — criterion 7, skills/verify-intent/SKILL.md:12
   "States what it does not do: it is not correctness and not adherence"
   The section disclaims code-review but not verify-conventions.

💡 Scope creep — skills/tasks/SKILL.md:24
   The router row wording changed; no criterion covers it. Likely its own task — offer /tasks spawn.

Unverifiable from this diff (1): criterion 8 — the lint run is a drill, not a code change.
```

If nothing fires: `✅ The diff implements the stated intent, with nothing unasked-for.` — followed by
the same source line, so a clean pass still shows what it checked.

## Where this runs

- **Standalone, mid-work** — the most valuable moment, before any gate, while the change is still cheap
  to redirect. No task, gate, or feature required.
- At a merge gate, beside [[verify-conventions]], reported as a **separate verdict**.

## What this skill does NOT do

- **Judge correctness** — that is [[code-review]]. A faithful implementation of a criterion can still be buggy.
- **Judge adherence** — that is [[verify-conventions]]. A faithful implementation can still break the rulebook.
- **Fix anything**, or rewrite a criterion to match what was built. Rewriting a criterion after the work
  to fit the result is the exact move [`/tasks close`](../tasks/verbs/close.md) forbids.
- **Decide whether the change should land.** It reports a verdict; the merge decision is the gate's.

## Related skills

- [[verify-conventions]] — the standards axis; the other half of the pair. Same advisory posture, same severities.
- [[code-review]] — the correctness axis. Runtime-provided in Claude Code.
- [[tasks]] — owns the `## Acceptance criteria` this skill reads, and `spawn` is where scope creep usually goes.
- [[feature]] — owns the decision ledger this skill reads **now** as its second intent source: the
  `approved` and `changed` rows, per § *Intent*. `close` step 5b depends on that.
- [[specs]] — owns `docs/specs/`, which is the **baseline, not an intent source.** A spec says what an area
  *currently promises*, because it was harvested from the code; treating it as intent is the mistake
  § *Baseline* exists to prevent. It answers a different question — *did this change behaviour nobody asked
  to change?*
