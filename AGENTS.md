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
context**, and **the result of a real trade-off**. **"Hard to reverse" is not the cost of editing the
sentence — it is what was produced under the decision;** [[domain]] § *The bar is a conjunction* owns the
full test and this line is the pointer, not a second copy.

## Architecture

Three trees, one install path.

- **`skills/`** — the generic, stack-agnostic skill set. **Every new skill lands here**, because this is the only tree linked into *both* `~/.claude/skills` and `~/.pi/agent/skills`.
- **`skills-pi/`** — **frozen**. Fallback definitions of review skills that Claude Code ships natively but pi does not (`code-review`, `review`, `security-review`). Linked into pi only; installing them into `~/.claude/skills` would shadow the native passes ([ADR 0010](docs/adr/0010-skills-pi-is-frozen-and-pi-only.md)). Do not add new skills here.
- **`docs/`, `tasks/`** — this repo's own lifecycle artifacts, produced by the skills it ships.

A skill is a folder: `SKILL.md` (the router — kept small) plus optional `verbs/*.md` (one file per
verb, standalone and directly readable) and `templates/*` (the file shapes the skill writes).
Skills reference each other by `[[name]]`; those links are load-bearing and CI-checked.

Both installers **link** rather than copy ([ADR 0009](docs/adr/0009-installers-link-rather-than-copy.md)), so an edit here is live in every consuming project
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

**Almost none of these has a decision record, and that is correct — stated once here rather than on every
bullet.** These are **rulebook entries**: a convention's footprint is the prose it will shape, so there is no
artifact outside the rulebook for a record to explain. [[domain]]'s bar is scoped to **project decisions** —
a stack choice, a repo layout, a per-repo policy, a schema, a strategy — and a rulebook entry keeping its
trade-off inline is the intended shape, not a defect. **Where a bullet does have a record it points at it**,
and where one might plausibly be expected and was declined for a reason of its own, the bullet says so.
Saying it once is deliberate: the same clause repeated on twenty bullets is a restated list, which is the
defect two of those bullets exist to prevent.

### Framework / stack
- **Markdown + YAML frontmatter only.** A skill is prose an agent reads; it has no runtime, no build step, and no dependencies. Don't introduce a language, package manager, or generator without an ADR.
- **Frontmatter is mandatory** on every `SKILL.md`: `name` (matching the folder) and `description` (carrying the trigger phrases users actually type, including the Slovak ones this team uses).
- **Cross-skill references use `[[skill-name]]`**, never a bare path — the link is the contract. **CI resolves it inside `skills/` and `skills-pi/`, and nowhere else.** That scope is deliberate, not an oversight:
  - **Elsewhere the form is documentation, not a contract.** `tasks/`, `docs/` and this file all use it for readability, and a broken one there costs a reader one lookup rather than breaking a skill at runtime. Write it freely; do not rely on it being checked.
  - **Widening the check was measured and rejected.** Outside the two trees: **170 wikilinks, 24 unresolved, and every one of the 24 is a syntax placeholder** — `[[wikilink]]`, `[[link]]`, `[[skill-name]]`, `[[name]]`, `[[not-a-skill]]` — written by prose that has to name the syntax to discuss it. Zero are genuine broken references. A check at 24:0 gets muted, and a muted check is worth what an unrun one is. (First measured at 19:1 when `[[domain]]` was still a forward reference; that one resolved when the skill shipped, taking the ratio to 24:0.)
  - **Three names resolve in one runtime only, and that is not a defect either.** `[[review]]`, `[[code-review]]` and `[[security-review]]` exist as folders in `skills-pi/` alone — Claude Code provides them as built-ins, so installing copies would shadow the natives (see § Architecture). A link to one is correct in both runtimes and *resolvable as a folder* in only one.

### Output / prose rules
The skills *are* the product, so their prose is the user interface. This subsection is what
`/verify-conventions` lints a wording change against.

- **Imperative and addressed to the agent.** "Read the map, then pick the ticket" — not "the agent should read the map".
- **Ship no unrendered placeholder tokens.** *Naming* a template token in instructions is correct and necessary ("set the feature token to FEATURE-NNN"). The defect is a token that reaches a consumer's repo **unrendered** — a template that forgot to fill one, or prose copied out of a template with its tokens still in it. Not machine-checkable without false positives, so it is on the reviewer.
- **Tables and short lists beat paragraphs** for anything an agent must branch on. Reserve prose for the *why*.
- **State the rationale for a non-obvious rule inline**, briefly. A rule an agent doesn't understand is a rule it will route around under pressure.
- **Router `SKILL.md` files stay small**; detail lives in the verb that owns it. A verb file must be readable standalone — never "see the section above" across files.
- **An ask-step carries the question it puts and the answer-less path, or it is not a step.** Where skill
  prose tells an agent to ask the user something, it states **the question actually put** — the words, not
  a description of them — **and** what the run does when no answer comes. Both halves, every time, because
  they fail differently. A *described* question is re-invented on every run, so two runs of one verb ask
  materially different things and neither is reproducible. A missing answer-less path is worse: it leaves
  the run choosing between stalling and promoting its own **suggestion** into a written **declaration**,
  which is the defect § *Read the declaration, never infer it* exists to prevent, arriving through the
  interaction instead of through the file. So the unattended outcome is always a **reported unresolved
  state** — never a value that *reads as decided*, and never silence, which the next reader cannot tell
  from a decision either. That takes one of two shapes, and which one is read off the schema, exactly as
  § *A template ships nothing a render cannot make true* reads it: where the field **may be absent**,
  leave it absent and name it in the report; where it **cannot** be — a field every other verb reads —
  write the safest fallback **and record beside it that nothing chose it**, the shape `/specs init`
  already uses when it writes a map stamped `coverage: unverified`. A fallback written bare is the
  defect wearing a different hat. Measured (DRILL-109-1 and -2, two cold runners, 2026-09-16): told to quote their questions
  verbatim and continue as if unanswered, **neither could** — *"no question text is supplied … the
  instruction **is** the prompt"* — and one, reaching `/tasks init`'s ambiguous branch with no user, picked
  a task root by inference from its brief, while the other wrote `/specs init`'s blessing question itself
  and proceeded as if blessed. **The rule is the authoring rule and lives here only**; each site's question
  text is per-site data, not a restatement of it, and a skill file cannot point back at this file without
  breaking in a consumer install. **Not machine-checkable** — a detector for *"this sentence is an
  ask-step"* is prose-shaped and would carry the same false-positive profile § *Framework / stack* already
  measured and rejected at 24:0 — so it is on the reviewer. *No record: a rulebook entry whose footprint is
  the prose it shapes.*

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
  - **And someone must own *finding out* that it is absent, which is not the same rule.** A declaration
    and an artifact's *version* look alike and are not: *is field X in file Y* is a grep, while *does this
    file match the shape its owner writes today* needs the owner's own knowledge. So the survey owns the
    first and the owner verb owns the second — and where a step is told to **ask** for a declaration, the
    step that **discovers** it is outstanding is named too. Leave that unnamed and three steps each defer
    to another: measured on `integration:`, where the survey deferred the question as a version, the
    inference round was told to ask for knowledge it had no licence to gather, and a dense-rulebook repo
    then either lost the question or had it surface inside the fill, breaking the one-round rule. **The
    absent case must be written where the value is first created, not only where it is reconciled** — the
    scaffolder minted `integration: pr-per-task` from a template default while the adopter's rule against
    defaulting read *"into an existing repo"*, so the field this repo forbids inferring was itself created
    by inference. Which declaration a row needs is read **off the row** (`skills/new-project/LAYER.md`),
    never off a list in a consumer.
- **A repo-level check is answered by what the repo tracks, never by the machine it runs on.** Where a
  skill asks whether a repository *has* something — today [[adopt-project]]'s survey asking whether `.env`
  and agent-tool local state are covered — the evidence must be the repository's own file rather than the machine's (whether that file is *committed* yet is a separate, composing question). A
  developer's global `core.excludesFile`, an installed tool, an exported variable: all genuinely true, none
  of them travelling to the next clone, which is the party every such check exists to protect. Accepting
  machine state does not make a check lenient, it **inverts** it — the repo that most needs the finding is
  the one where a local convenience hides it. The corollary is that the obvious probe is usually the wrong
  one: `git check-ignore <path>` answers *"ignored on this machine"*, and only `git check-ignore -v`'s
  **source** answers the question actually asked. **The apparent counter-example confirms the rule:**
  `skills-lint.sh` check 5 *does* read machine state (install-root drift) and is for that exact reason
  **advisory** — machine state may be reported, never converted into a verdict about the repo. Owner of the
  detail and the measured instance: `skills/new-project/LAYER.md` § *Covered means covered in the repo*;
  this entry is the pointer.
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
- **A template ships nothing a render cannot make true.** The two rules above govern a *run*; this governs
  the *file a run renders from*. A template is read as a thing to reproduce faithfully, so a plausible value
  in one is minted as fact by a **correct** render rather than by a mistake — which is also why it survives
  review, where an obvious stub would not. Which shape is right is read off the **schema's own** encoding of
  "nobody established this" — **per field, not per file**: `map.yml` uses both shapes at once, a value for
  `coverage:` and absence for its two companions, so a template is walked field by field:
  - Where the schema says it with the **line's absence**, the field ships **commented out**, comment left in
    place. `skills/tasks/templates/config.yml`'s `integration:` shipped a live `pr-per-task` while the comment
    directly above it said an absent line means undeclared — so a render following `init.md` correctly minted
    a declaration nobody made, re-creating DRILL-053-6 (a PR-per-task policy in a repo with no git). The
    commented example carries a **choice** (`<pr-per-task|single-branch>`), never a value: a commented
    concrete value rebuilds the same trap one keystroke away.
  - Where the schema has its own **"not determined" value**, the template ships that and never a
    determination. `skills/specs/templates/map.yml` shipped `coverage: verified` beside
    `tracked-files-at-scan: 0` — a pair `/specs init`'s own verdict table calls impossible — and now ships
    `unverified`, the one verdict a render can make true, because rendering scans nothing.

  **Not machine-checkable** without a marker convention and its false positives, so it is on the reviewer —
  the same disposition § Output/prose rules gives an unrendered token. And a `{{TOKEN}}` is the right shape in
  a markdown template and the wrong one in YAML, where unrendered it is a parse error rather than a readable
  gap. *No record: this is a rulebook entry whose footprint is the prose it shapes — reversing it is editing
  the two template lines back, so the ADR bar's hard-to-reverse arm fails.*
- **Independent review axes are reported side by side and never merged or reranked.** Where a gate runs
  more than one pass answering a *different* question — today `close` step 5b's standards
  ([[verify-conventions]]), fidelity ([[verify-intent]]) and correctness ([[code-review]]) — each keeps its
  own verdict and its own severity ordering, and nothing sorts across them. Merging is tempting because one
  ranked list is easier to read, and that ease is exactly the harm: a convention warning placed above an
  unbuilt requirement reads as the larger problem, and "blocker" from a lint is not the same quantity as
  "blocker" from a correctness pass. A *weighted* merge is worse, not better — any fixed weighting that puts
  correctness first buries the case this axis exists to catch, a change that is perfectly correct while
  implementing the wrong thing. So a merge decision states each verdict, because *standards pass, intent
  fail* is a distinct outcome a single summary cannot express. *No record: this is a rulebook entry — a
  convention about how a result is presented — so its reasoning belongs here, whole.*
- **A vocabulary shared by several skills has one owning file, and the owner is wherever it already lives.**
  Today the code-smell inventory sits in `skills/tdd/refactoring.md`, written for the TDD refactor step and now
  also read by [[verify-conventions]] as its baseline for a repo that documented nothing of its own. The pull
  toward a second copy is strong, because the two skills use the list for different jobs — one prescribes a
  refactoring, the other reports a finding — and that difference is exactly what makes a copy look justified.
  It is not: the *list* is one inventory, and the job-specific part is the handful of rules around it, which is
  what each consumer adds locally. **Expand the existing owner rather than starting a neutral one**; moving a
  list to a "better" home breaks its current readers for no gain, and a partial copy is worse than either —
  it diverges like a full copy while also being silently narrower. *No record: this is a rulebook entry, not a
  project decision — its footprint is a file that did not move, so there is no artifact outside the rulebook
  for a record to explain.*
- **A flag that declares an absent capability must define behaviour at every point that needs it.**
  Where a skill takes a flag asserting something is *not available* — today `close`'s `--unattended`,
  meaning no user is present to answer — the flag's definition enumerates **every** step that would
  otherwise depend on it, and adding such a step means adding a row. A flag scoped to one step while
  three others still ask is worse than no flag: the caller reads the promise, not the scope, and the run
  blocks in whichever configuration nobody tested. Measured instance: `--unattended` shipped covering
  the out-of-scope sweep alone while the merge question still fired on PR-per-task projects — the
  documented default — and the defect was invisible here only because this repo declares
  `single-branch`. The configuration that hides such a gap is usually the one it was written on. The
  trade-off that produced the flag is [ADR 0001](docs/adr/0001-unattended-close-merges.md); this rule is its
  enforcement half.
- **A ranking key that cannot discriminate must say so, not pass quietly.** Where one skill orders work by
  several keys in sequence (today [[fix-next]]'s eight), the key's input is **declared in frontmatter, never
  inferred from a title** (`theme:` on a review-intake STORY, written by `/tasks intake`, read by
  `/fix-next`), and the ranking paragraph names the key that actually broke the tie. Degeneracy is normal;
  silent degeneracy is the defect. Trade-off and rejected alternatives:
  [ADR 0008](docs/adr/0008-declare-a-ranking-key-rather-than-infer-it.md).
- **A format one skill reads is a contract the writing skill must state too**, and where the contract is a **flag**, the lint enforces it (check 4: every flag passed to a skill verb in `skills/` must name a flag the receiving verb declares — **every** flag on the invocation, and arguments may sit between the verb and the flag, so `/tasks move <ids> --to` and the `--no-plan` in `/tasks new task --from-feature FEATURE-NNN --no-plan` are both checked. Existence only, never semantics, and matched **anchored**, so `--unattend` does not satisfy a receiver declaring `--unattended`. The narrower `/skill verb --flag` form this sentence used to describe left 8 of 39 real invocations unchecked while still claiming enforcement). When a skill parses another's output, both sides record the shape — today `/specs regen` attributes a commit to the task whose id **leads the commit subject** (an id further along the subject, or anywhere in the body, is a cross-reference), so `/tasks close` says that where it composes the message. Recorded on the reading side alone, the writing side changes it without ever seeing the consequence, and the reader degrades silently instead of failing.
- **A layer artifact that would lie when empty is declared `(lazy)`, and nothing creates it.** Most of the
  universal layer is created on sight, so the exception needs saying: where an empty instance would make a
  **claim** rather than hold a place — an empty `docs/glossary.md` asserts the vocabulary was examined and
  found thin — the inventory marks the row `(lazy)` and both front doors leave it to its owner, who writes
  it on first real content. Two consequences travel with the marker, and skipping either is the whole
  defect: the scaffolder must **read the marker off the inventory**, never a copied list of which artifacts
  are lazy, or a row added later gets seeded by a door that never heard about it; and the adopter reports an
  absent one `not applicable yet`, which suppresses **the offer as well as the fill** — asking *"shall I
  create a glossary?"* is how the empty file arrives with the user's consent instead of without it. The
  marker and the state are defined once, in `skills/new-project/LAYER.md` (§ *Lazily-created rows*, and its
  § *Detect what the repo has*); this entry is the pointer, not a second copy. Claimable **only** where the
  row declares itself lazy — relabelling an ordinary absence launders a real gap into a design choice.
- **A layer artifact that only some projects take is declared `(conditional)`, and the row names the
  condition it turns on.** The sibling of the `(lazy)` rule above, and it exists because the alternative was
  measured: `LICENSE`, `.env.example` and `Dockerfile` sat outside the inventory *because* they were
  conditional, which made `LAYER.md`'s "single definition" claim false by three artifacts and — the part that
  made it a defect rather than an untidiness — left [[adopt-project]], which walks those rows and nothing
  else, permanently unable to notice a repo with no licence. **Measured 2026-09-01: five of seven consumer
  repos have none, and the survey could not raise the question.** Plain rows were rejected for the
  mirror-image reason: *absent ⇒ missing* would report a missing `Dockerfile` on every CLI and library, two
  false gaps each on three of those same seven.
  - **The condition is not always the kind, and a marker that said so was itself the defect.** `LICENSE`
    turns on **licensing posture** — a proprietary and an open-source service are the same kind and want
    opposite answers. So each row states its condition and the evidence that settles it, rather than every
    consumer reaching for one shared fact.
  - **A row asks a question about the artifact, not "what kind is this repo".** Kind labels run out and
    repos are compound: measured 2026-09-01, all three consumer repos surveyed were two or three kinds at
    once, and one declares a kind (*desktop app*) the intake enum does not offer. So a row asks *does
    anything here read runtime config from the environment?* and any component answering yes settles it.
    Kind is **evidence** toward that answer, and a kind the repo **declares** outranks one inferred from
    signals — the same precedence § *Read the declaration, never infer it* sets everywhere else.
  - **`not applicable` is not `(lazy)`'s `not applicable yet`** — a library does not acquire a `Dockerfile` by
    aging, so one state is settled and the other is pending, and collapsing them loses whether anyone should
    look again. **Undetermined evidence yields `unknown` and a question in the adopter's frontier round, never
    `not applicable`** — defaulting there is how a real gap is laundered into a design choice, and the kinds
    hardest to evidence (CLI, `other`) are exactly the ones these rows exclude.
  - Marker, states and the kind signals are defined once, in `skills/new-project/LAYER.md` § *Conditional
    rows*; this is the pointer. **A row's condition and its creator must agree** — the same change that adds a
    row fixes the scaffolder line that contradicts it.
- **Layer parity (hard rule):** any change that extends the **universal project layer** must update **`new-project`** *and* **`adopt-project`** in the same change. The scaffolder creates the layer for new repos; the adopter reconciles it for existing ones. Extending one without the other silently strands every project already using the skills. In practice that means editing **`skills/new-project/LAYER.md`**, the single inventory both skills consume — if a layer change does not touch that file, it is being copied somewhere instead of shared.

### Naming
- Skill folders are **kebab-case** and match their frontmatter `name`.
- **Verb-noun for action skills** (`verify-conventions`, `verify-intent`, `populate-tests`, `roll-changelog`, `fix-next`, `new-project`, `adopt-project`, `improve-architecture`); **bare noun for disciplines and trees** (`tasks`, `feature`, `specs`, `roadmap`, `tdd`, `domain`).
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
- **The lint has its own tests** — `.github/workflows/skills-lint-test.sh`, **47** cases over a throwaway fixture, run by CI *before* the lint. (The count has moved six times — 16 → 25 → 36 → 40 → 43 → 47 — which is TASK-029's whole argument: nothing records what any of them pin, so a case deleted in a refactor is indistinguishable from one that never existed.) It is the repo's only gate, so a silent regression in it disables checking entirely with no signal. A change to `skills-lint.sh` is not done until a case here fails without it.
- **The lint is the floor, not the ceiling.** A skill's real test is a **drill**: install it and run it end-to-end against a real repo. Every non-trivial skill change carries that drill as its `## Human test plan`. **What a drill is, and when it is worth its cost, is `skills/populate-tests/SKILL.md` § *The cold drill*** — this repo's product is prose an agent reads, so the reader must be **cold** and the brief must withhold the plan's expected answer, or the test degrades into a confirmation. That section also owns the fixture rule that bites here constantly: **a change justified by naming a repo cannot be drilled on that repo**, and this repo's habit of measured justification disqualifies fixtures faster than any other. Pointer, not a second copy.
- Every new skill gets at least one lint-visible invariant (resolvable links, present frontmatter) and a drill recorded on its task.
- **A drill record names how its runner was obtained** — the command, the working directory, and the result of the coldness check. *Cold* is two conditions, not one: the brief withholds the change, **and** the runner's context does not already hold the subject. The second is not controlled by the brief and is not closed by changing repository — this repo's own skills are installed at user level, so every agent on the machine holds them. `skills/populate-tests/SKILL.md` § *Acquiring a cold runner* owns the channels, the confirmation signals and the measured instance; this is the pointer. Recording only the brief is what made TASK-079's first two readers permanently unclassifiable.

### Keeping conventions current (register-on-introduce)
- When a change **introduces a new cross-cutting pattern** — a new artifact in the universal layer, a new cross-skill protocol, a new naming rule — **record it in this section in the same change**. A pattern that lives in one skill is not a convention; it is drift waiting to be copied wrong.
- If the change alters structure, update **§ Architecture** and `docs/architecture.md` too.
- `/verify-conventions` flags a change that introduced a new pattern without recording it here.

### Working rules
- **Task-first gate (hard rule):** for non-trivial work the task exists (`status: todo`, with acceptance criteria) **before any editing**, and work starts by picking it (`/tasks pick`). Editing before the task is a lifecycle violation, not a style choice. If you catch edits already made without a task, **stop**: backfill the task with honest status, then continue.
- **Plan before implementing.** A non-trivial task gets its `## Implementation plan` before work starts.
- **New scope discovered mid-work gets its own task** — offer `/tasks spawn` unprompted. Never widen the task in hand.
- **A task outside a pool is filed but unranked.** A review finding belongs in a `kind: review-intake` epic or carries its `findings:` id; anything else and only `priority:` ranks it, which sinks a P2/P3 defect permanently. Measured here: 17 correct defect tasks sat in `tasks/_loose/` and `/fix-next` saw 2. **The second arm is not a loophole** — tree hygiene and meta-work about the tree *should* stay loose, because filing them into an intake epic makes that pool misreport how much of a review is left. Rule and both arms live in [[tasks]] § *A task outside a pool*; this is the pointer.
- Before flipping a non-trivial task to `done`, run `/verify-conventions` (adherence) **and** `/code-review` (correctness) on the diff, then address or record the findings. This `/tasks close` step **is** the merge gate; `done` means merged.
- **Nothing goes in a generated file that its verb cannot derive.** The rule above says who *owns* a
  generated file; this says what may go *in* one. If a sentence cannot be recomputed from the inputs, it
  does not belong in the output — it belongs in one of three hand-owned homes: commentary about **one
  task** goes on that task's file; cross-cutting **state or judgement** goes in the EPIC body
  (`§ State as of`); **tree-level provenance** (where this task tree came from) goes in
  `tasks/.config.yml`'s comments. Same for `/feature status`: per-feature commentary belongs in
  `idea.md` / `decisions.md`, never in the generated `status.md` or index.
  - **Why not simply give the generator a preserved region?** Because a partly-hand-owned generated file
    is the ambiguity that produces the problem: every regeneration becomes a judgement call, and the
    second copy grows back. Measured instance — `tasks/README.md` carried caveats about TASK-004 and
    TASK-018 that were *lossy summaries* of fuller records already on those task files, plus a
    verification-debt count that said "9" while `EPIC.md` said "seven". Two hand-written copies of one
    non-derivable fact, disagreeing. Deleting the copies lost nothing.
- **Generated files are owned by their verbs — never hand-edit them.** `docs/features/*/status.md` and `docs/features/README.md` are owned by `/feature status`; `tasks/README.md` by `/tasks triage`; `docs/specs/*.md` by `/specs regen` (only `.map.yml` is hand-edited). "Keep it current" means *run the owning verb*.
- **Status changes go through their verbs, never hand-edits.** Hand-flipping `status: done` skips the gates that make the status trustworthy. **Placement is the same, as of `/tasks move`:** a task's location and its `parent:` field are two records of one fact, so they change together or they disagree — and a move has to roll up the parents on *both* sides, which a hand-edit never does. Moving a file and editing `parent:` by hand is the placement equivalent of hand-flipping a status.
- To see where things stand: `/tasks` (feature-aware snapshot) or `/roadmap` (full epic to feature to task view plus a divergence audit).
- No `Co-Authored-By:` trailers in commit messages.

## Commands

```bash
./install.sh        # link skills/ into ~/.claude/skills            (install.ps1 on Windows)
./pi-install.sh     # link skills/ + skills-pi/ into ~/.pi/agent/skills   (pi-install.ps1)
# Re-run BOTH after ADDING a skill folder — one junction is made per folder, so a new one
# has none and the skill is invisible to both runtimes. Editing an existing skill needs no re-run.
bash .github/workflows/skills-lint.sh    # run the CI lint locally
# The lint's check 4 reports install-root drift — a skill folder with no junction, a junction whose
# source folder is gone, or a junction into a tree that root was never meant to hold (a skills-pi/
# stub shadowing a runtime built-in). Advisory: it never fails the run, because the fix is an
# installer re-run or a junction removal, not a code change. Absent root (no pi installed) => it says so and moves on.
# Override the roots for testing:  CLAUDE_SKILLS_ROOT=... PI_SKILLS_ROOT=... bash .../skills-lint.sh
```
