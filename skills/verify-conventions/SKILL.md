---
name: verify-conventions
description: Lint the current/staged diff against THIS project's own conventions, wherever its agent guide records them — `CLAUDE.md` § Conventions in a seeded project, but equally `## Key Conventions`, a non-English heading, or rules woven through the guide. Covers framework/stack, UI/UX, code structure & patterns, naming, testing, and § Architecture. Use when the user says "/verify-conventions", "verify conventions", "check project rules", "does this follow our conventions", "lint pred commitom", "skontroluj zmeny", or before marking a task/feature done. Tech-agnostic — it reads the rules each project actually wrote down, so it works on any stack. Never tells a project with a working rulebook that it has recorded nothing, and never tells a project without one that there is nothing to check — a code-smell baseline applies as a floor, always labelled as judgement calls and always suppressed by a documented rule that conflicts with it. Also flags when a change INTRODUCES a new cross-cutting pattern that isn't yet recorded in CLAUDE.md (the "register-on-introduce" rule), so the rule list stays complete. Distinct from [[code-review]] (which judges correctness/bugs); this only checks adherence to the project's documented conventions. A repo may ship a project-local variant that shadows this one inside that repo with concrete, stack-specific checks.
---

# verify-conventions

A tech-agnostic adherence lint: does the current diff follow the conventions **this project wrote down for itself**? It does not carry a built-in rule set — it reads each project's own `CLAUDE.md` and checks the change against that. This is what makes "every next task follows the same pattern" enforceable instead of aspirational.

> **Adherence, not correctness.** [[code-review]] finds bugs and reasons about whether the code is *right*. This skill only asks *"does it match our documented conventions?"* — framework choices, UI/UX rules, structure, naming, testing. Run both at a review gate; they answer different questions.

> **Scope layering.** A repo may ship a project-local variant with concrete checks (compiler-warning policy, path conventions, solution/workspace registration…). Two rules make that safe, and both are easy to get wrong:
> - **Name it `verify-conventions`, exactly.** Shadowing works by folder name. A skill called `verify-<project>-conventions` shadows *nothing* — every `[[verify-conventions]]` call site (`/tasks close` step 5b, [[fix-next]]) keeps resolving to this generic skill, and the project's own checks never run at the gate even though the repo believes they do.
> - **It must EXTEND this skill, not replace it.** Once it shadows, this file no longer runs, so the local variant owns everything below — in particular the live § Conventions sweep (step 3), **register-on-introduce** (step 4) and the **architecture-drift check** (step 5). A local skill that is only a list of concrete greps silently drops the rulebook-currency loop, and the rule list stops growing with the project. Have it run this generic pass first, then add its own checks.
>
> This generic skill is what runs in every other project, driven by whatever that project recorded in its own `CLAUDE.md`.

## Authoritative reference — READ THIS FIRST when invoked

The project's own **`CLAUDE.md`** (or `AGENTS.md`, if that's the canonical guide — follow the `@import` bridge) is the source of truth. Re-read it on every invocation; the rules evolve.

### Finding the rulebook — it is not always called `## Conventions`

**Locate the rules by content, not by heading name.** The seed's `## Conventions` block is one
shape a rulebook takes, not the definition of one. Work down this ladder and stop at the first hit:

1. **`## Conventions`** — the seed shape. Use its subsections directly.
2. **A heading that plainly names rules** — `## Key Conventions`, `## Coding Standards`, `## Rules`, `## Pravidlá`, `## Konvencie`. Match on meaning, in whatever language the guide is written in; a project does not owe you English headings.
3. **Any section carrying normative content** — sustained *must / never / always / don't* (and their equivalents in the guide's language). A section titled `## Transakcna hranica` full of "KRITICKE" rules is a rulebook section whatever its name.
4. **The whole guide** — if rules are woven throughout rather than sectioned, lint against all of its normative statements.

**Say which sections you read** — and which rung matched — at the top of every report. § *Output
format* owns the shape of that line; don't restate it here.

**Only report "no conventions recorded" when the guide carries no normative content at all.** A
guide full of rules under unfamiliar headings is a rulebook you failed to find, not an absent one —
and reporting "nothing to check" there is a false negative at every gate that calls this skill.
Observed in the field: a 1835-line guide with a dozen rule sections, and a guide whose heading said
`## Key Conventions`. Both would have been told they had recorded nothing.

- **`## Conventions`** and its subsections, when present — the seed structures these as:
  - **Framework / stack** — what we build on; approved libraries; what *not* to introduce without a decision.
  - **UI / UX rules** — design tokens, component library, spacing/typography rules, accessibility bar, interaction patterns.
  - **Code structure & patterns** — layering, folder layout, the patterns to follow (and anti-patterns to avoid), error handling, dependency direction.
  - **Naming** — file/type/symbol naming conventions.
  - **Testing** — framework, what must be tested, where tests live.
- **`## Architecture`** — the living structure description; a change that contradicts it is either a violation or an architecture update that wasn't made.
- Any project-specific checklist the guide links to.

If the guide carries **no normative content anywhere** — you worked the whole ladder and found nothing that reads as a rule — say so, point at the seed (*"This project hasn't recorded conventions yet — add a `## Conventions` block to CLAUDE.md (see the [[new-project]] seed) so there's something to verify against."*), and **then run the smell baseline below**. Don't invent rules the project never agreed to; the baseline is not invented rules, it is the floor that applies with or without a rulebook.

### The smell baseline — what to say when the repo documented nothing

**The inventory lives in [[tdd]]'s [refactor candidates](../tdd/refactoring.md)** — one list, read here,
never copied. It carries each smell's observable signal and a suggested move.

This is a **floor**, not a rulebook, and three rules keep it from behaving like one:

- **The repo always overrides.** A documented standard wins and **suppresses a conflicting smell
  outright** — not "reports both". The premise of this skill is that it checks what the project agreed
  to, not what it believes; a baseline that argues with a recorded rule inverts that. *Worked example:* a
  guide that says *"handlers construct their own DTOs inline — no mapper layer"* suppresses **duplicated
  code** findings across those handlers. The duplication is real, it is also the documented design, and
  reporting it makes the pass adversarial to its own project.
- **Every smell is a labelled judgement call**, never a blocker. They are heuristics with known false
  positives, and § *Output format* has the slot: they land as ⚠ or 💡 and **carry the `smell:` label**, so
  a reader can tell a heuristic from a rule the project wrote down without inferring it from tone.
- **Skip anything tooling already enforces.** If a linter, formatter, compiler warning or analyzer in
  this repo already reports it, restating it buries the findings only a reader can make. Check for the
  config before reporting: a repo with an analyzer set to error on unused parameters does not need this
  pass mentioning them.

**A repo with a rulebook still gets the rulebook first.** The baseline runs *after* the § Conventions
sweep and never reorders it — the documented rules lead the report, and smells follow, clearly separated.
It is additional signal for a repo that has recorded little, not a second opinion on a repo that has
recorded a lot.

**Never suggest restructuring a guide to match the seed.** A project with a working rulebook under
its own headings has solved this; the skill adapts to the project, not the reverse.

## What to lint

1. **Determine the diff.** Prefer staged (`git diff --cached`); fall back to the working tree (`git diff`) or, if asked, a branch range. If not git-tracked, ask the user which files to check.
2. **Read the project's `CLAUDE.md`**, locate the rulebook via the ladder above, and extract its rules into a working checklist. Where the guide uses the seed's subsections, follow them; where it does not, group the rules however that guide groups them — do not force a foreign structure onto it, and do not drop a rule because it fits no subsection.
2b. **Drop generated, vendored and minified files from the diff — a rule the author never wrote cannot
   be violated by output they never typed.** Findings against a bundle are noise at best, and at worst
   point at code nobody can act on: the fix lives in the source, not the artifact.

   **Read the project's declaration first; never start from a built-in list.**

   | Order | Source | Notes |
   |---|---|---|
   | 1 | `.gitattributes` — `linguist-generated`, `linguist-vendored` | purpose-built, and the one to recommend when absent |
   | 2 | the project's guide naming its build-output or vendor paths | it knows what it emits |
   | 3 | heuristics — `.map`, lockfiles, known vendor directories (`node_modules/`, `vendor/`, `packages/`), minified shape (very long lines, a huge byte-to-line ratio) | **partial by construction — see below** |

   **The heuristics catch bundles and miss small generated files, which is why order 1 is not merely
   tidier.** Measured on a real diff: a `.map` at 7 lines with a 4,154,785-character line and a bundle
   at 75,037 lines with 19,028-character lines are both obvious — while a generated service worker at
   **128 lines, longest line 104** is indistinguishable from hand-written code by every signal there is.
   A heuristic-only pass drops the two obvious files, keeps linting the third, and now *claims* to have
   handled generated output.

   **When you cannot classify a file, lint it and say so.** The directions are not symmetric: a false
   inclusion produces noise a reader dismisses in a second, a false exclusion silently stops checking
   code a human wrote. Never guess toward exclusion — and when a file was excluded on a heuristic rather
   than a declaration, name it as such, so a wrong exclusion is visible.

   **Recommend the durable fix rather than growing a list here.** Only the project knows what it emits;
   a `linguist-generated` line settles it permanently and for every other tool too.

   **Never repurpose a list that answers a different question.** `docs/specs/.map.yml`'s `ignore:` is the
   live temptation — it exists, it is right there, and on a real repo it declares `**/wwwroot/**`, which
   would have covered two of three generated files. It also declares `tests/**`, `docs/**`, `tasks/**`
   and `tools/**`, every one hand-written. Use it as a generated-file oracle and you silently stop
   linting tests, which is exactly where a § Testing convention applies.

   **If the diff is entirely generated, say so** — `nothing to lint — all N changed files are generated
   output (excluded: <list, with the reason for each>)`. Silence here reads as a pass.

3. **Check each changed file against each applicable rule.** A rule applies to a file when the file's kind/path matches the rule's domain (a UI/UX rule applies to component/style files; a naming rule applies to new files/symbols; a testing rule applies to new public surface). For every violation, report:
   - **File + line** (clickable `path:line`)
   - **The rule** (quote the CLAUDE.md line it comes from — so the finding is traceable, not made up)
   - **Suggested fix** (one line)
4. **Register-on-introduce check (the currency rule).** A diff that establishes a *new* cross-cutting pattern — pulls in a new framework/major dependency, introduces a UI pattern not in the rules, adds a new architectural layer/module shape, sets a new naming or testing convention — must also **update `CLAUDE.md` § Conventions** (and `## Architecture` if structure changed) in the same change. If it doesn't, flag it: *"New pattern introduced (`<what>`) but not recorded in CLAUDE.md § Conventions — add it so the next task follows it."* This is the mechanism that keeps the rule list complete as the project grows; it mirrors the [[feature]] decision-ledger discipline.
5. **Architecture-drift check.** If a change alters structure (new module/engine/protocol/dependency direction) and `## Architecture` still describes the old shape, flag it — a stale architecture doc is a real defect, not stale-but-harmless.

## Output format

**Open every report — clean or not — with the rulebook you read.** One line naming the file, the
headings you treated as normative *in the guide's own language*, and which rung of the ladder matched:

```
Rulebook: AGENTS.md § Conventions (via the CLAUDE.md @import bridge) — ladder rung 1, the seed shape.
          Subsections read: Framework/stack, Output/prose rules, Code structure & patterns, Naming,
          Testing, Keeping conventions current, Working rules. Also § Architecture.
```

Three reasons it leads rather than trails, and the third is the one that bites:

- The ladder's whole value is that it may pick an **unexpected** section. Unreported, the user cannot
  correct a wrong pick — and a wrong pick is exactly when the findings are worthless.
- It separates *found little* from *linted against little*. A two-finding report over a rich rulebook
  and a two-finding report over one heading are different claims.
- **A clean pass is where this matters most.** `✅` with no source line states a verdict and hides what
  produced it, so a pass that read the wrong section is indistinguishable from a real one. That is the
  invisible-gate defect [`/tasks close`](../tasks/verbs/close.md) step 12 already avoids by printing its
  sweep outcome even when it passes.

Then group findings by severity; quote the source rule on each so it's auditable:

- **🛑 Blockers** — a hard, unambiguous rule is violated (e.g. "all DB access goes through the repository layer" but the diff queries the driver directly; a forbidden dependency was added).
- **⚠ Warnings** — a likely violation needing human judgment (heuristic match, a convention with stated exceptions).
- **💡 Suggestions** — register-on-introduce gaps, architecture-doc drift, soft style rules.

**A smell-baseline finding is prefixed `smell:` and never a 🛑.** It is a judgement call from a
project-independent floor, so it must be distinguishable at a glance from a rule this project wrote
down — a reader who cannot tell them apart will either dismiss the real violations or act on the
heuristics as though they were agreed.

Sample:

```
🛑 Blocker — src/api/orders.ts:54
   Rule (CLAUDE.md § Conventions › Code structure): "Handlers never touch the DB directly — go through a repository."
   Fix: move the `db.query(...)` call into OrdersRepository and call that.

💡 Suggestion — package.json:18
   New framework introduced (`zustand`) but CLAUDE.md § Conventions › Framework lists only Redux.
   Fix: record the state-management choice in § Conventions (or revert if unintended).
```

```
⚠ smell: repeated switches — src/billing/rate.py:88, :140, :203
   Signal: the same `match plan_kind` chain in three places; adding a plan means finding all three.
   Judgement call from the smell baseline ([[tdd]] § refactor candidates), not a documented rule —
   this project has recorded no conventions.
   Suggested move: polymorphism, or one lookup table.
```

If clean, the source line still leads — the verdict alone is the defect:

```
Rulebook: AGENTS.md § Conventions — ladder rung 1. Subsections read: Framework/stack, Naming, Testing.
Linted 4 of 7 changed files; 3 excluded as generated (app.js, app.js.map — minified shape; sw.js —
declared linguist-generated).
✅ Change follows the project's documented conventions.
```

**The exclusions belong on that header for the same reason the rulebook does.** A pass over four files
and a pass over seven are different claims, and an exclusion nobody sees is how a wrongly-skipped
hand-written file stays skipped.

**A guide with no normative content is a different report, not an empty section list.** Say plainly that
the project has recorded no conventions and point at the seed (§ *Finding the rulebook*), so a true
negative never renders as though a rulebook was read and found silent.

## Where this runs in the lifecycle

- **`/tasks close`** runs this on the diff before flipping a non-trivial task to `done` — the per-task adherence gate (mirrors the existing "run /code-review before done" step).
- **`/feature review`** runs it alongside [[code-review]] in Gate A — correctness *and* convention adherence before sign-off.
- Standalone, anytime, before a commit.

### Should the seed stop assuming English headings?

**No — and that is not a contradiction.** [[new-project]] keeps writing `## Conventions` with
English subsections, because a fresh project benefits from one predictable shape and the seed is
the only thing that can establish it. The asymmetry is deliberate: **the writer is opinionated, the
reader is permissive.** A generator that emits one shape is useful; a linter that accepts only that
shape is broken, because it meets repos it did not create.

## What this skill does NOT do

- It does **not** auto-fix — findings are advisory; the developer (or a follow-up `--fix` pass via another tool) applies them.
- It does **not** judge correctness or hunt for bugs — that's [[code-review]].
- It does **not** invent rules — it only checks what the project recorded in `CLAUDE.md`. No conventions written down → nothing to verify (and that's the finding).
- It does **not** block commits by itself. To hard-enforce, wire a pre-commit hook via [[update-config]].

## Related skills

- [[code-review]] — the correctness half of a review gate; run both together. (Runtime-provided, e.g. a Claude Code built-in; the [[tasks]]/[[feature]] gate verbs carry inline fallbacks for runtimes without it.)
- Project-local `verify-<project>-conventions` variants — shadow this skill inside their own repo with concrete checks (same scope layering as above).
- [[new-project]] — seeds the structured `CLAUDE.md § Conventions` block this skill reads.
- [[tasks]] / [[feature]] — invoke this at `close` / `review`; they also carry the "register a new pattern in CLAUDE.md as part of done" rule this skill enforces.
- [[roll-changelog]] — the other generic "keep the project honest" maintainer (changelog currency); this one keeps convention currency.
- [[update-config]] — wire a git pre-commit hook if you want this enforced, not just advised.
