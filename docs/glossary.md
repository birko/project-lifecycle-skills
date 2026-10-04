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
| a task **state** (until FEATURE-003) | code complete, human sign-off pending — verification debt, and *not* done | now `status: verify`; older files still say `status: review`, read the same |
| a **gate verb** | the feature-level completeness + sign-off gate | `/feature review` |
| a **pass** | one automated review of a diff. Which passes exist is owned by `close` step 5b — read it there rather than listing them here | the pass's own name, never bare `review` |
| an epic **kind** | the stamp marking a backlog filed from a review pass, which `fix-next` drains | `kind: review-intake` |

The trap: *"the task is in review"* and *"the task passed review"* describe opposite situations — the
first is unfinished, the second is finished. Both are said, and neither is wrong. FEATURE-003 renamed the
task state to `verify` partly for this reason, so in new text the first sense is *"the task awaits
verification"*.

## upstream — the worktree sense of "local" and "remote"

Two different facts used to share the words *local mode*, and a cold runner read one as the other
(TASK-193). They are now named apart:

| Fact | Values | Where it comes from | Say |
|---|---|---|---|
| the **tracker** — does `tasks/` sync with GitHub or Jira? | `local` · `hybrid` | **declared**: `mode:` in `tasks/.config.yml` | `mode: local`, `mode: hybrid` |
| under `workspace: worktree`, does the **default branch track a remote**? | upstream · no upstream | **derived** every run: `git rev-parse --abbrev-ref <default>@{upstream}` resolves or fails | "with an upstream", "with no upstream"; report lines `workspace: upstream (…)` |

The two are independent. The common case is `mode: local` **with an upstream**: tasks live only in files,
but the code has a remote. **Never write "local mode" or "remote mode" for the second fact.** The word
*mode* is what made a reader match it against `mode:`.

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
