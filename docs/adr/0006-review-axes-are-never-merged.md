# Decision record: independent review axes are reported side by side, never merged

- **Date:** 2026-08-21 — the rule landed in `AGENTS.md` in `bf23364`, alongside TASK-049
- **Decided by:** the maintainer, via TASK-049. The reasoning was written out at the time; this record consolidates it out of the § Conventions bullet that had been carrying it inline.
- **Status:** accepted
- **Rule it produced:** `AGENTS.md § Conventions › Code structure & patterns` — the one-line entry pointing here.

## Context

`/tasks close` step 5b runs three passes that answer three *different* questions:
[[verify-conventions]] (does this follow our documented rules?), [[verify-intent]] (did it build what was
asked?) and [[code-review]] (is it correct?). Each returns findings with its own severities.

The obvious presentation is one ranked list. It is what a reader asks for, and it is what almost every
review tool does.

## Decision

**Each axis keeps its own verdict and its own severity ordering, and nothing sorts across them.** A merge
decision states all three verdicts, because *standards pass, intent fail* is a distinct outcome that a
single summary cannot express.

## Rejected alternatives

**One merged, ranked list.** Rejected because the convenience *is* the harm: a convention warning placed
above an unbuilt requirement reads as the larger problem. Severity is only meaningful within an axis —
"blocker" from a conventions lint and "blocker" from a correctness review are not comparable quantities,
and sorting them together silently asserts that they are.

**A weighted merge — correctness outranks intent outranks conventions.** More sophisticated and worse,
because the weighting is wrong in exactly the cases that matter. A change that is perfectly correct while
implementing the wrong thing is the one this axis exists to catch, and any fixed weighting that puts
correctness first buries it.

**Report only the axis that failed.** Compact, and it destroys the information: *standards pass, intent
fail* and *both fail* would print identically as "intent fail", so the reader cannot tell whether the
rulebook was checked at all. This is the same invisible-gate defect the repo keeps rediscovering — a pass
that hides what it read is indistinguishable from one that did not run.

## Consequences

**Easier.** A close decision can be made on what the change actually is. The whole point of a second axis
is that the first cannot see it, and separate verdicts are what preserve that.

**Harder.** Three verdicts is more to read than one, every time, including the common case where all three
pass. And it puts a real obligation on whoever adds a *fourth* axis: it needs its own verdict slot, not a
row folded into an existing list.

**Not affected.** Within an axis, ranking is normal and expected — this is not an argument against
severities, only against comparing them across passes.
