---
name: verify-conventions
description: Lint the current/staged diff against THIS project's own conventions as recorded in its `CLAUDE.md` § Conventions (framework/stack, UI/UX, code structure & patterns, naming, testing) and § Architecture. Use when the user says "/verify-conventions", "verify conventions", "check project rules", "does this follow our conventions", "lint pred commitom", "skontroluj zmeny", or before marking a task/feature done. Tech-agnostic — it reads the rules each project actually wrote down, so it works on any stack. Also flags when a change INTRODUCES a new cross-cutting pattern that isn't yet recorded in CLAUDE.md (the "register-on-introduce" rule), so the rule list stays complete. Distinct from [[code-review]] (which judges correctness/bugs); this only checks adherence to the project's documented conventions. A repo may ship a project-local variant that shadows this one inside that repo with concrete, stack-specific checks.
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

- **`## Conventions`** and its subsections — the rule list. The [[new-project]] seed structures these as:
  - **Framework / stack** — what we build on; approved libraries; what *not* to introduce without a decision.
  - **UI / UX rules** — design tokens, component library, spacing/typography rules, accessibility bar, interaction patterns.
  - **Code structure & patterns** — layering, folder layout, the patterns to follow (and anti-patterns to avoid), error handling, dependency direction.
  - **Naming** — file/type/symbol naming conventions.
  - **Testing** — framework, what must be tested, where tests live.
- **`## Architecture`** — the living structure description; a change that contradicts it is either a violation or an architecture update that wasn't made.
- Any project-specific checklist the guide links to.

If the guide has **no `## Conventions` section**, say so and stop with a pointer: *"This project hasn't recorded conventions yet — add a `## Conventions` block to CLAUDE.md (see the [[new-project]] seed) so there's something to verify against."* Don't invent rules the project never agreed to.

## What to lint

1. **Determine the diff.** Prefer staged (`git diff --cached`); fall back to the working tree (`git diff`) or, if asked, a branch range. If not git-tracked, ask the user which files to check.
2. **Read the project's `CLAUDE.md`** and extract its conventions into a working checklist (per subsection above).
3. **Check each changed file against each applicable rule.** A rule applies to a file when the file's kind/path matches the rule's domain (a UI/UX rule applies to component/style files; a naming rule applies to new files/symbols; a testing rule applies to new public surface). For every violation, report:
   - **File + line** (clickable `path:line`)
   - **The rule** (quote the CLAUDE.md line it comes from — so the finding is traceable, not made up)
   - **Suggested fix** (one line)
4. **Register-on-introduce check (the currency rule).** A diff that establishes a *new* cross-cutting pattern — pulls in a new framework/major dependency, introduces a UI pattern not in the rules, adds a new architectural layer/module shape, sets a new naming or testing convention — must also **update `CLAUDE.md` § Conventions** (and `## Architecture` if structure changed) in the same change. If it doesn't, flag it: *"New pattern introduced (`<what>`) but not recorded in CLAUDE.md § Conventions — add it so the next task follows it."* This is the mechanism that keeps the rule list complete as the project grows; it mirrors the [[feature]] decision-ledger discipline.
5. **Architecture-drift check.** If a change alters structure (new module/engine/protocol/dependency direction) and `## Architecture` still describes the old shape, flag it — a stale architecture doc is a real defect, not stale-but-harmless.

## Output format

Group findings by severity; quote the source rule on each so it's auditable:

- **🛑 Blockers** — a hard, unambiguous rule is violated (e.g. "all DB access goes through the repository layer" but the diff queries the driver directly; a forbidden dependency was added).
- **⚠ Warnings** — a likely violation needing human judgment (heuristic match, a convention with stated exceptions).
- **💡 Suggestions** — register-on-introduce gaps, architecture-doc drift, soft style rules.

Sample:

```
🛑 Blocker — src/api/orders.ts:54
   Rule (CLAUDE.md § Conventions › Code structure): "Handlers never touch the DB directly — go through a repository."
   Fix: move the `db.query(...)` call into OrdersRepository and call that.

💡 Suggestion — package.json:18
   New framework introduced (`zustand`) but CLAUDE.md § Conventions › Framework lists only Redux.
   Fix: record the state-management choice in § Conventions (or revert if unintended).
```

If clean: `✅ Change follows the project's documented conventions.`

## Where this runs in the lifecycle

- **`/tasks close`** runs this on the diff before flipping a non-trivial task to `done` — the per-task adherence gate (mirrors the existing "run /code-review before done" step).
- **`/feature review`** runs it alongside [[code-review]] in Gate A — correctness *and* convention adherence before sign-off.
- Standalone, anytime, before a commit.

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
