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
immediately. The corollary bites: a link is created per *folder*, at install time, so **a new skill
folder needs an installer re-run** before either runtime can resolve it — editing an existing one
never does. The installers only ever *add*, so renaming or deleting a skill also needs a manual
sweep of both roots; nothing prunes the old junction. See `docs/architecture.md` for the fuller
picture.

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
- **Defer to a shared inventory — never restate its lists.** Where a skill points at a shared file
  (`LAYER.md` today), any list that can *grow* — states, artifacts, owners, an ordering — must be a
  pointer, not a copy: when the inventory gains a row the copy becomes wrong silently, with nothing
  to signal it. A single **invariant** restated where it is load-bearing is fine, since there is no
  list to fall out of sync. The test is one question — *would this sentence become wrong if the
  shared file gained a row tomorrow?*
- **An owner verb reconciles; it does not assume.** A verb that owns a file shape must be able to answer *"is this instance current?"* — not only *"does it exist?"*. Existing is not current: the shape gains fields, and an instance written before one existed looks complete from outside. So an owner verb reconciles an older instance in place (add what is missing, never re-decide what is there), and reports **already current** distinctly from **brought up to date** — a caller cannot tell "your file is fine" from "I declined to look" when both print the same line. Applies to every row of `LAYER.md` with an **Owner**, not just the one that exposed it.
- **Read the declaration, never infer it.** Where one skill *records* a policy in a file (today `tasks/.config.yml`'s `integration:`), every other skill **reads that field** rather than deducing the policy from observable state — git history, folder shape, what the last commit happened to do. The failure is not that inference is usually wrong; it is that the two situations producing identical evidence are exactly where it breaks (a squash-merge history and a commit-to-main history are the same log), and an inference that happens to be right is still unreproducible. A field that is *absent* is a gap to ask about and backfill, never a licence to guess.
- **A derived state must never be cached as a decision.** The mirror of the rule above: where a value is
  *computed from evidence the repo still holds* — today `missing, not offered`, computed from whether a
  build's dependencies resolve inside the repo root — recompute it every run instead of remembering the
  verdict. A remembered derivation cannot expire, so it goes wrong precisely when the underlying fact is
  fixed, which is the one moment anybody cares. Two corollaries, both load-bearing: recomputing is not
  the same as re-asking (suppress the *offer*, keep printing the *status*), and **never gate the
  recomputation on a task's state** — a task can be closed while the fact is unchanged, and the evidence
  cannot be fooled that way. Deciding whether something is a declaration to read or a derivation to
  recompute is the actual judgement; getting it wrong in either direction is the same defect. **The
  counter-example is `integration:`, and it matters**: that is a *declaration*, so it is read, never
  re-derived — deducing it from `git log` is the defect TASK-021 and TASK-023 exist to have killed. The
  test is whether the repo still holds evidence that *determines* the answer (a manifest path either
  escapes the root or does not) or merely evidence *consistent with* several answers (a squash-merge
  history and a commit-to-main history are the same log). Determined ⇒ recompute. Merely consistent ⇒
  it had to be declared.
- **A format one skill reads is a contract the writing skill must state too.** When a skill parses another's output, both sides record the shape — today `/specs regen` attributes a commit to the task whose id **leads the commit subject** (an id further along the subject, or anywhere in the body, is a cross-reference), so `/tasks close` says that where it composes the message. Recorded on the reading side alone, the writing side changes it without ever seeing the consequence, and the reader degrades silently instead of failing.
- **Layer parity (hard rule):** any change that extends the **universal project layer** must update **`new-project`** *and* **`adopt-project`** in the same change. The scaffolder creates the layer for new repos; the adopter reconciles it for existing ones. Extending one without the other silently strands every project already using the skills. In practice that means editing **`skills/new-project/LAYER.md`**, the single inventory both skills consume — if a layer change does not touch that file, it is being copied somewhere instead of shared.

### Naming
- Skill folders are **kebab-case** and match their frontmatter `name`.
- **Verb-noun for action skills** (`verify-conventions`, `populate-tests`, `roll-changelog`, `fix-next`, `new-project`, `adopt-project`, `improve-architecture`); **bare noun for disciplines and trees** (`tasks`, `feature`, `specs`, `roadmap`, `tdd`, `domain`).
- Verb files are named for the verb (`verbs/close.md` corresponds to `/tasks close`).
- Artifacts use `EPIC-NNN` / `STORY-NNN` / `TASK-NNN` / `FEATURE-NNN`, zero-padded to three digits.

### Testing
- Tests: **`.github/workflows/skills-lint.sh`**, run by CI — validates frontmatter, resolves every `[[link]]`, and checks that files referenced by a `SKILL.md` exist. Run it locally with `bash .github/workflows/skills-lint.sh`.
- **The lint may carry *advisory* sections; they never change its exit code.** A check whose remedy
  lives **outside the repo** — today check 4, install-root drift, fixed by re-running an installer —
  cannot be a blocker: no diff can clear it, and the roots do not exist on the CI runner, so making it
  fatal would leave the gate meaning different things on different machines. An advisory section still
  has to be *tested*, on its output rather than the exit code, and its negative assertions must require
  the section to have run — a "must not appear" check passes trivially when the section is deleted.
- **The bash test suite may shell out to PowerShell for Windows-only setup.** `skills-lint-test.sh`
  creates link fixtures with `ln -s`, then falls back to a PowerShell junction when that produced a
  copy — MSYS `ln -s` copies unless `winsymlinks` is set, and the repo's Windows installer creates
  junctions anyway, so the fallback tests the real artifact rather than a POSIX stand-in. Keep the
  POSIX path first so CI exercises it, and keep the fallback guarded on `cygpath` being present.
- **The lint has its own tests** — `.github/workflows/skills-lint-test.sh`, 31 cases over a throwaway fixture, run by CI *before* the lint. It is the repo's only gate, so a silent regression in it disables checking entirely with no signal. A change to `skills-lint.sh` is not done until a case here fails without it.
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
# Re-run BOTH after ADDING a skill folder — one junction is made per folder, so a new one
# has none and the skill is invisible to both runtimes. Editing an existing skill needs no re-run.
bash .github/workflows/skills-lint.sh    # run the CI lint locally
# The lint's check 4 reports install-root drift — a skill folder with no junction, or a junction
# whose source folder is gone. Advisory: it never fails the run, because the fix is an installer
# re-run, not a code change. Absent root (no pi installed) => it says so and moves on.
# Override the roots for testing:  CLAUDE_SKILLS_ROOT=... PI_SKILLS_ROOT=... bash .../skills-lint.sh
```
