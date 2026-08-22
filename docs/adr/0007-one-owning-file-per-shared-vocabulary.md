# Decision record: a vocabulary shared by several skills is expanded in place, never re-homed

- **Date:** 2026-08-21 — the rule landed in `AGENTS.md` in `4417f9a`, alongside TASK-048
- **Decided by:** the maintainer, via TASK-048. The reasoning was written at the time; this record consolidates it out of the § Conventions bullet that had been carrying it inline.
- **Status:** accepted
- **Filed:** 2026-08-22 — relocated from the § Conventions bullet
- **Rule it produced:** `AGENTS.md § Conventions › Code structure & patterns` — the enforceable rule plus a pointer here. (Not literally one line: the rule needs its scope stated to be followable at all. The split is about where the *trade-off* lives, not about line count.)

## Context

The code-smell inventory lives in `skills/tdd/refactoring.md`, written for the TDD refactor step.
TASK-048 made [[verify-conventions]] read the same list as its baseline for a repo that documented no
conventions of its own.

So one list now has two consumers **using it for different jobs**: `tdd` prescribes a refactoring,
`verify-conventions` reports a finding. That difference is real, and it is exactly what makes a second
copy look justified — each consumer wants slightly different framing around the same items.

## Decision

**Expand the existing owner in place.** The list stays in `skills/tdd/refactoring.md`; each consumer adds
its own job-specific rules *around* it. The owner is wherever the vocabulary already lives, not wherever it
would tidily belong.

## Rejected alternatives

**Give `verify-conventions` its own copy, framed for reporting.** The tempting one. Rejected because the
*list* is one inventory: a smell added for the refactor step should immediately be a smell the lint can
report, and with two copies it is not. The divergence would be silent and slow — nobody notices that one
list gained an entry until a finding fails to appear.

**Move the list to a neutral shared home** — a third file owned by neither skill. Architecturally
appealing and rejected on a concrete cost: it **breaks the current readers for no functional gain.** Every
existing reference into `tdd/refactoring.md` would need updating, and the list would end up somewhere with
no natural maintainer, which is how a shared file rots. Tidiness is not a reason to move a working list.

**Duplicate only the entries `verify-conventions` uses.** A partial copy, which is the worst of both: it
diverges like a full copy while also being incomplete, so the lint's baseline is quietly narrower than the
inventory and nothing says so.

## Consequences

**Easier.** One list to maintain, and a smell added anywhere is available everywhere. The two consumers'
different jobs are handled where they belong — locally, as a handful of rules each.

**Harder.** The list lives somewhere slightly surprising: a reader of `verify-conventions` has to follow a
pointer into a *TDD* skill to see the baseline it applies, which is not where anyone would look first. That
is a real navigational cost, accepted because a stale second copy costs more.

It also means **"who owns this?" is answered by history rather than by design** — the owner is whoever had
it first. That reads as arbitrary, and it is deliberately so: any other rule licenses re-homing, and
re-homing is the move being rejected.

**Not affected.** The job-specific rules each consumer wraps around the list. Those are local by design and
this record does not push them into the shared file.
