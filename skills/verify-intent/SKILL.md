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

This release reads **one** source: the task's `## Acceptance criteria`.

| Given | Intent comes from |
|---|---|
| A task id (`/verify-intent TASK-046`) | that task's `## Acceptance criteria` |
| Nothing, but a task is in progress | that task's criteria — name which task you picked |
| Nothing, and no task in flight | ask the user what the change was meant to do, in one line, and use their answer |

**Print the source at the top of the report, always.** A reader cannot tell a thorough pass from a
shallow one unless the pass names its inputs, and "I checked it against the task" and "I checked it
against the task, the approved decisions and the specs" are very different claims. Approved decisions
and `docs/specs/` are **not** read yet — say that rather than letting a one-source pass be mistaken for
a three-source one.

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
Intent source: TASK-046 § Acceptance criteria (8 criteria). Feature decisions and docs/specs not read.

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
- [[feature]] — owns the decision ledger a later release will read as a second intent source.
- [[specs]] — owns `docs/specs/`, the third intended source.
