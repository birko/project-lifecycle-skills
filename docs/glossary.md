# Glossary

_What the words mean here. Vocabulary only — never decisions (`docs/adr/`), never behaviour
(`docs/specs/`), never open questions (a feature's `idea.md`). See AGENTS.md § The five records._

Written lazily, by [[domain]]: a term lands here when it is genuinely ambiguous or genuinely ours, not
to make the file look complete.

## review — four senses, and the bare word is ambiguous

The most-used word in the skill set and the most overloaded. **Always qualify it; the bare noun is the
defect.**

| Sense | Means | Say |
|---|---|---|
| a task **state** | code complete, human sign-off pending — verification debt, and *not* done | `status: review` |
| a **gate verb** | the feature-level completeness + sign-off gate | `/feature review` |
| a **pass** | one automated review of a diff. Which passes exist is owned by `close` step 5b — read it there rather than listing them here | the pass's own name, never bare `review` |
| an epic **kind** | the stamp marking a backlog filed from a review pass, which `fix-next` drains | `kind: review-intake` |

The trap: *"the task is in review"* and *"the task passed review"* describe opposite situations — the
first is unfinished, the second is finished. Both are said, and neither is wrong.

## decision — two records, one word

| Sense | Lives in | Answers |
|---|---|---|
| a **feature decision** | `docs/features/FEATURE-NNN/decisions.md`, one row with a `State` | *what was agreed*, per feature, append-logged |
| a **decision record** (ADR) | `docs/adr/NNNN-slug.md` | *why we chose it* — technical, repo-wide, hard to reverse |

They are not the same record and neither supersedes the other; § The five records draws the line. The
path is `docs/adr/` rather than `docs/decisions/` precisely so the two cannot be confused on disk.

## gate

A point where work is checked before it advances. The invariant: **each gate checks something no other
gate checks**, so passing one is never evidence for another — `/tasks close` is the *merge* gate (per
task, once, at the right altitude) and `/feature review` is the *completeness* gate, which deliberately
does not re-review code. Their verbs own the current list; don't count them here.

## finding

Something a review pass reports. **A finding is not tracked work** until it becomes a task with an id —
that gap is where findings evaporate, and most of `EPIC-002` exists because of it.

## drill

Installing a changed skill and running it end to end against a real repo. This project's actual test for
a skill; the lint is the floor. A skill that only reads well has not been drilled.
