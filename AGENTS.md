# The Project Lifecycle Skills

A single-source-of-truth repository of agent skills that carry a raw idea to shipped, reviewed,
tested code without losing the paper trail — installed into Claude Code and the pi runtime.

- **Stack:** Markdown skill definitions (YAML frontmatter + `[[wikilink]]` cross-references), with Bash/PowerShell installers. No compiled code, no runtime dependencies.
- **Kind:** agent skill library (consumed by tools, read by humans)
- **Task tracking:** `tasks/` (local) — see [tasks/README.md](tasks/README.md)
- **Feature lifecycle:** `docs/features/` — see "How we work" below
- **Specs:** `docs/specs/` — capability specs harvested *from* the skill definitions via `/specs` (never hand-written; regen offered at story close)
- **Changelog:** `CHANGELOG.md` — what changed for people who install these skills (Keep a Changelog); updated via `/roll-changelog`
- **Ground truth:** `docs/BRIEF.md` — verbatim user requests, append-only

> **This repo eats its own cooking.** Every rule below is a rule these skills impose on their
> consumers. If a rule is impractical here, that is evidence the rule is wrong — fix the skill,
> don't exempt the repo.

## How we work — feature lifecycle

Real work flows through a repeatable lifecycle so it stays **tracked, testable, reviewable, and
visible** to the developers and agents who install these skills. Don't jump straight to editing a
`SKILL.md` for anything non-trivial.

```
idea ─▶ prototype ─▶ decisions ─▶ tasks ─▶ human-test ─▶ review
```

1. **Capture + grill the idea** — `/feature new`. The idea is interrogated until every branch is resolved; each branch becomes a *decision*.
2. **Prototype** — `/feature prototype`. For a skills repo the usual form is a markdown wireframe of the proposed SKILL.md shape, or a spike branch. Often legitimately `Skipped` — record the reason, never leave the line blank.
3. **Record decisions** — `/feature decide`. Every decision gets a state: **approved / deferred / changed / removed**, with rationale and date. The ledger in `docs/features/FEATURE-NNN/decisions.md` is append-logged.
4. **Decompose into small tasks** — `/feature decompose` → `/tasks new`. **Before any editing, always** — see the task-first gate under Working rules.
4b. **Entering an existing feature** — `/feature pick FEATURE-NNN` resolves what stage it is really at and offers the verb that unblocks it.
5. **Make it testable** — every task carries a `## Human test plan`. Here that usually means *installing the changed skill and running it against a real repo*; a skill that only reads well has not been tested.
6. **Status** — `/feature status` regenerates the plain-language rollup.
7. **Review gate** — `/feature review`: completeness (every decision built, every task merged) + every human-test plan run + sign-off. Correctness was already reviewed per task at `/tasks close`.
8. **Changing something already shipped** — a later change to a `done` feature is still a recorded **`changed`** decision, logged in the feature that owns the behaviour, with the ripple traced.
9. **Spec check at story close** — `/tasks close STORY-NNN` offers a scoped `/specs regen`; the spec **diff** is reviewed as "was this behavioural change intended?".
10. **Field feedback re-enters the pipeline** — a skill that misfires in real use is a `tasks/` bug that ships with a regression check, not a note. `done` is never the terminus.

**Ground truth & altitude — what gets recorded where.** `docs/BRIEF.md` stores requests
**verbatim**: the opening ask is immutable, later requirement-changing requests are appended
verbatim (dated, naming the feature they became). Every distilled doc reconciles *against* it — if
they disagree, the brief wins.

| The change… | …is recorded in |
|---|---|
| introduces/alters a **requirement or scope** | a `docs/BRIEF.md` amendment → new/changed feature |
| alters **how an already-requested capability behaves** | that feature's `decisions.md` (a `changed` decision) |
| is a pure **implementation detail** | commits / `docs/architecture.md` |

### The five records — which one am I writing to?

This repo keeps five distinct written records. Putting something in the wrong one is the most
common way the trail rots, so route by the question being answered:

| Record | Answers | Scope |
|---|---|---|
| `docs/glossary.md` | *what a word means* | vocabulary only — never decisions |
| `docs/adr/` | ***why* we chose it** | technical, repo-wide, hard to reverse |
| `AGENTS.md § Conventions` | *what we do now* | the standing rule, linted by `/verify-conventions` |
| `docs/features/*/decisions.md` | *what was agreed* | per-feature, append-logged |
| `docs/specs/` | *what the code actually does* | harvested, never hand-written |

An ADR that hardens into a standing rule gets a **one-line entry in § Conventions pointing back at
it** — the ADR carries the trade-off and the alternatives, the convention carries the enforceable
one-liner. Offer an ADR only when all three hold: **hard to reverse**, **surprising without
context**, and **the result of a real trade-off**.

## Architecture

Three trees, one install path.

- **`skills/`** — the generic, stack-agnostic skill set. **Every new skill lands here**, because this is the only tree linked into *both* `~/.claude/skills` and `~/.pi/agent/skills`.
- **`skills-pi/`** — **frozen**. Fallback definitions of review skills that Claude Code ships natively but pi does not (`code-review`, `review`, `security-review`). Linked into pi only; installing them into `~/.claude/skills` would shadow the native passes. Do not add new skills here.
- **`docs/`, `tasks/`** — this repo's own lifecycle artifacts, produced by the skills it ships.

A skill is a folder: `SKILL.md` (the router — kept small) plus optional `verbs/*.md` (one file per
verb, standalone and directly readable) and `templates/*` (the file shapes the skill writes).
Skills reference each other by `[[name]]`; those links are load-bearing and CI-checked.

Both installers **link** rather than copy, so an edit here is live in every consuming project
immediately. See `docs/architecture.md` for the fuller picture.

## Conventions

This section is the project's **canonical, living rulebook**. It is auto-loaded into every task's
context (as `AGENTS.md`, behind a one-line `CLAUDE.md` import bridge), which is what makes "the
next task follows the same pattern" actually true. `/verify-conventions` lints diffs against
exactly these rules.

### Framework / stack
- **Markdown + YAML frontmatter only.** A skill is prose an agent reads; it has no runtime, no build step, and no dependencies. Don't introduce a language, package manager, or generator without an ADR.
- **Frontmatter is mandatory** on every `SKILL.md`: `name` (matching the folder) and `description` (carrying the trigger phrases users actually type, including the Slovak ones this team uses).
- **Cross-skill references use `[[skill-name]]`**, never a bare path — the link is the contract, and CI resolves it.

### Output / prose rules
The skills *are* the product, so their prose is the user interface. This subsection is what
`/verify-conventions` lints a wording change against.

- **Imperative and addressed to the agent.** "Read the map, then pick the ticket" — not "the agent should read the map".
- **Ship no unrendered placeholder tokens.** *Naming* a template token in instructions is correct and necessary ("set the feature token to FEATURE-NNN"). The defect is a token that reaches a consumer's repo **unrendered** — a template that forgot to fill one, or prose copied out of a template with its tokens still in it. Not machine-checkable without false positives, so it is on the reviewer.
- **Tables and short lists beat paragraphs** for anything an agent must branch on. Reserve prose for the *why*.
- **State the rationale for a non-obvious rule inline**, briefly. A rule an agent doesn't understand is a rule it will route around under pressure.
- **Router `SKILL.md` files stay small**; detail lives in the verb that owns it. A verb file must be readable standalone — never "see the section above" across files.

### Code structure & patterns
- **New skills go in `skills/`.** `skills-pi/` is frozen (see § Architecture).
- **A verb owns its rules.** If a rule only matters to one verb, it lives in that verb's file, not the router.
- **Generated files are owned by their verbs** — see Working rules.
- **Layer parity (hard rule):** any change that extends the **universal project layer** must update **`new-project`** *and* **`adopt-project`** in the same change. The scaffolder creates the layer for new repos; the adopter reconciles it for existing ones. Extending one without the other silently strands every project already using the skills. In practice that means editing **`skills/new-project/LAYER.md`**, the single inventory both skills consume — if a layer change does not touch that file, it is being copied somewhere instead of shared.

### Naming
- Skill folders are **kebab-case** and match their frontmatter `name`.
- **Verb-noun for action skills** (`verify-conventions`, `populate-tests`, `roll-changelog`, `fix-next`, `new-project`, `adopt-project`, `improve-architecture`); **bare noun for disciplines and trees** (`tasks`, `feature`, `specs`, `roadmap`, `tdd`, `domain`).
- Verb files are named for the verb (`verbs/close.md` corresponds to `/tasks close`).
- Artifacts use `EPIC-NNN` / `STORY-NNN` / `TASK-NNN` / `FEATURE-NNN`, zero-padded to three digits.

### Testing
- Tests: **`.github/workflows/skills-lint.sh`**, run by CI — validates frontmatter, resolves every `[[link]]`, and checks that files referenced by a `SKILL.md` exist. Run it locally with `bash .github/workflows/skills-lint.sh`.
- **The lint has its own tests** — `.github/workflows/skills-lint-test.sh`, 16 cases over a throwaway fixture, run by CI *before* the lint. It is the repo's only gate, so a silent regression in it disables checking entirely with no signal. A change to `skills-lint.sh` is not done until a case here fails without it.
- **The lint is the floor, not the ceiling.** A skill's real test is a **drill**: install it and run it end-to-end against a real repo. Every non-trivial skill change carries that drill as its `## Human test plan`.
- Every new skill gets at least one lint-visible invariant (resolvable links, present frontmatter) and a drill recorded on its task.

### Keeping conventions current (register-on-introduce)
- When a change **introduces a new cross-cutting pattern** — a new artifact in the universal layer, a new cross-skill protocol, a new naming rule — **record it in this section in the same change**. A pattern that lives in one skill is not a convention; it is drift waiting to be copied wrong.
- If the change alters structure, update **§ Architecture** and `docs/architecture.md` too.
- `/verify-conventions` flags a change that introduced a new pattern without recording it here.

### Working rules
- **Task-first gate (hard rule):** for non-trivial work the task exists (`status: todo`, with acceptance criteria) **before any editing**, and work starts by picking it (`/tasks pick`). Editing before the task is a lifecycle violation, not a style choice. If you catch edits already made without a task, **stop**: backfill the task with honest status, then continue.
- **Plan before implementing.** A non-trivial task gets its `## Implementation plan` before work starts.
- **New scope discovered mid-work gets its own task** — offer `/tasks spawn` unprompted. Never widen the task in hand.
- Before flipping a non-trivial task to `done`, run `/verify-conventions` (adherence) **and** `/code-review` (correctness) on the diff, then address or record the findings. This `/tasks close` step **is** the merge gate; `done` means merged.
- **Generated files are owned by their verbs — never hand-edit them.** `docs/features/*/status.md` and `docs/features/README.md` are owned by `/feature status`; `tasks/README.md` by `/tasks triage`; `docs/specs/*.md` by `/specs regen` (only `.map.yml` is hand-edited). "Keep it current" means *run the owning verb*.
- **Status changes go through their verbs, never hand-edits.** Hand-flipping `status: done` skips the gates that make the status trustworthy.
- To see where things stand: `/tasks` (feature-aware snapshot) or `/roadmap` (full epic to feature to task view plus a divergence audit).
- No `Co-Authored-By:` trailers in commit messages.

## Commands

```bash
./install.sh        # link skills/ into ~/.claude/skills            (install.ps1 on Windows)
./pi-install.sh     # link skills/ + skills-pi/ into ~/.pi/agent/skills   (pi-install.ps1)
bash .github/workflows/skills-lint.sh    # run the CI lint locally
```
