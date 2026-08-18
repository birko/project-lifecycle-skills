---
name: adopt-project
description: Bring an EXISTING repo onto the project lifecycle layer — survey what it already has, fill only what is missing, and report both. Use when the user says "adopt this repo", "adopt-project", "set up the lifecycle here", "add tasks/docs to this project", "init the skills in this repo", "we already have code, wire up the lifecycle", "rescan this project", "bring this repo up to date with the skills", "adoptuj projekt", "nastav lifecycle v tomto repe", "doplň chýbajúce časti", or points at a codebase that does not yet use these skills. Also the UPGRADE path — re-run it whenever the universal layer grows, to reconcile a repo that adopted an older version. Tech-agnostic. This is the brownfield counterpart to [[new-project]] (greenfield): same layer, opposite starting point.
---

# adopt-project

The **brownfield front door**. [[new-project]] creates the universal layer for a repo that has
nothing; this reconciles a repo that already has code, history, and opinions of its own against
that same layer — see [LAYER.md](../new-project/LAYER.md), the single definition both skills work from.

**One skill covers both cases**, because they differ only in how much is missing:

- *"We have code and none of this."* — first adoption.
- *"We adopted this months ago and the layer has grown since."* — the same run, fewer gaps.

So it is **idempotent by design**: re-run it any time. A repo with nothing missing gets a report
saying so and no writes at all.

## What it does not do

It does not reimplement file shapes. Each artifact is created by the skill that owns it —
[LAYER.md](../new-project/LAYER.md)'s **Owner** column is the list ([[tasks]] `init`, [[specs]]
`init`, [[populate-tests]] `adopt` among them), and those skills are already delta-based and safe
to re-run. This skill decides *what is missing and in what order*, then delegates. Hand-rolling
those shapes here is how the two versions drift.

## Process

### 1. Survey — read before writing anything

Walk [LAYER.md](../new-project/LAYER.md) and classify every artifact by the states its
§ *Detect what the repo has* defines — that section is the definition and carries the evidence to
check per row. The states are deliberately **not** listed here: the list grows whenever a real repo
turns up a condition it could not express (it has grown twice already), and a copy here goes wrong
silently the next time, with nothing to signal it.

Two consequences decide behaviour:

- **When in doubt, `unknown` — never `missing`.** A false "missing" invites a fill that writes over
  a working setup, which defeats the never-overwrite rule from underneath instead of breaking it.
- **Present but thin is `present`, with the gap named** — an agent guide with no `## Conventions`
  block, a `tasks/` tree with no `.config.yml`. The artifact is there; report what it lacks.
- **From outside you cannot see a version.** An artifact another skill owns may be present in an
  older shape than the layer now expects — a config written before a field existed looks complete
  from the outside. Where the artifact's row names a verb, step 3's delegation is what answers, so
  leave the version question to it rather than guessing here; where no verb owns the shape, the
  thin-but-present rule above is the whole answer (see [LAYER.md](../new-project/LAYER.md)
  § *Delegation follows the row, not the artifact's appearance*).

Alongside it, detect the facts the fill will need: the stack (manifests, source layout), whether a
test runner already works, whether a git remote exists, whether the repo is captured by an
ancestor git repo, and whether anything the layer owns is sitting on disk **untracked** — the
signature of an earlier pass that wrote and never committed.

**Print the survey as a table and stop.** The user sees the whole picture before a single file is
written. For a repo that is already complete, this is the entire run — say so and finish.

### 2. Infer the conventions, then confirm them

This is the step that makes adoption worth doing. The repo has already answered most convention
questions in its own source — read the answers out and put them to the user **with the evidence
that suggested them**. See [INFER.md](INFER.md) for what to read per subsection, how to tell a
convention from an accident, and how to collect glossary candidates.

Two rules govern it: **propose, never assert** — an unconfirmed inference is dropped, not written
as a guess — and **show the evidence**, so the user can disagree specifically rather than
rubber-stamp.

Alongside the inferences, a few facts are choices rather than observations: task-tracking mode
(local / hybrid), whether the canonical guide is `CLAUDE.md` or `AGENTS.md` + bridge, and the
license posture. Ask **only** about artifacts the survey found missing — a repo that already has a
guide is not asked which guide it wants.

Put the inferences and the choices in **one frontier round** ([[grill-me]]'s shape), not a queue of
single questions. A 15-rule proposal asked one at a time becomes an interrogation, and the answers
stop being considered somewhere around round six.

### 3. Fill the gaps, in dependency order

Follow [LAYER.md](../new-project/LAYER.md) § *Ordering* — later steps read what earlier ones write,
so the sequence belongs to the inventory rather than being restated here. For each artifact follow
its **"already present?"** column in the same file.

The rules that bind the whole step:

- **Never overwrite a file the repo already owns.** Report the conflict; let the user resolve it.
- **Never reconstruct `docs/BRIEF.md`** from an existing README. Stamp the adoption instead (see [LAYER.md](../new-project/LAYER.md) § The adopted-repo brief).
- **An `unknown` row is not filled — ask instead.** The survey never established that artifact was
  absent, so writing it is a guess aimed at the user's own files: the false-missing defect with one
  extra step.
- **Never skip a delegation because the artifact looks right.** Presence decides whether to
  *create*, never whether to *delegate*, and the owner is the only thing that knows its own current
  shape. Skipping one is how `Presenter` kept a `tasks/.config.yml` with no `integration:` field
  through a full adoption pass. **And do not read "nothing to do" as "up to date"** — an init that
  declines to touch an existing file has reported its own inaction, nothing more; that row is
  `unknown`, and the report names the init that could not answer.
- **A `present, uncommitted` row is landed, not rewritten.** The file is already right; what is
  missing is the commit. Offer it in the adoption commit and report it. Rewriting it discards an
  earlier pass's work to produce, at best, the same bytes.

### 4. Report what changed

Report by outcome. Three buckets for what this run **did**:

| Bucket | Carries |
|---|---|
| **created** | what was written |
| **amended** | a file the repo already owned, changed with the user's consent — and *what* changed inside it: a section appended, a section replaced, lines added. **Never report an amendment as a creation**; on the upgrade path amendment is the normal outcome, so this is the busiest bucket, not an exotic one |
| **left alone** | why — "present already", "you declined" |

Then **one bucket per surveyed state the three above do not already absorb** — `present` is
*left alone*, and a `missing` row you filled is *created*. [LAYER.md](../new-project/LAYER.md) owns
the state list, so a state added there that no outcome bucket absorbs gets a bucket here named after
it, whether or not this page mentions it. Each carries what the *report* owes beyond the state's
name:

- `present, elsewhere` — **where**: the paths or form actually found. Never offer to create a second one.
- `present, outdated` — **what the owner's init reported as the delta, and whether it was reconciled.** "Brought up to date" and "nothing to do" are different outcomes; blurring them is how an old shape survives a pass that claims to reconcile it.
- `present, uncommitted` — whether the offer to land it was taken. Silence loses the artifact at the next clone.
- `unknown` vs `missing` — **which of the two, and why**: "could not determine X", "needs a decision", "blocked on a remote". *"I could not tell"* and *"you don't have it"* are different claims, and collapsing them here re-introduces one layer later the defect the survey just avoided.
- `missing, not offered` — **the reason**, so a re-run reads the row as settled instead of asking again.

**Content** staleness inside a present artifact — prose that no longer describes the repo — is an
**aside**, never a bucket. A stale *shape* is the opposite: it gets its bucket, because an owner
reported it. See [LAYER.md](../new-project/LAYER.md) § *Presence and shape, not content currency*
for the line between them.

Then the next step: `/feature new` for stakeholder-facing work, `/tasks new` for a defined unit.

The report is the deliverable as much as the files are. An adoption whose output is "done!" leaves
the user unable to tell what was touched in their own repo.

## Conventions

- **No `Co-Authored-By:` trailers** in any commit it might create.
- PowerShell-compatible commands.
- Offer the adoption commit; never commit unasked.
- **Git policy is read, not inferred.** Whether to cut a branch, and whether to merge, comes from
  `tasks/.config.yml`'s `integration:` field. Absent → **ask, and backfill it** as part of the
  adoption; an absent declaration is the thing this skill reconciles. Never infer the policy from
  `git log` — a squash-merge repo and a commit-straight-to-main repo produce the same history, which
  is why [[tasks]] forbids the inference outright. And **never delete a branch on inference**:
  cleanup is its own ask, however tidy the log looks. (Adoption-side only — `new-project` has no
  history to misread.)
- Ask before `git init` on an untracked repo, and surface the resolved root when an **ancestor**
  repo already tracks the directory — only the user knows whether that ancestor is intended.

## Related skills

- [[new-project]] — the greenfield front door. Same layer, opposite starting point; both work from [LAYER.md](../new-project/LAYER.md), and **the layer-parity rule means a change to one is a change to both**.
- [[tasks]] — `init` creates `tasks/`; adopts a pre-skill tree without disturbing it.
- [[specs]] — `init` re-discovers the area map and proposes a delta.
- [[populate-tests]] — `adopt` mode wires a runnable test harness.
- [[verify-conventions]] — the payoff of adoption: it reads the `## Conventions` block this skill makes sure exists.
- [[roll-changelog]] — offered for the changelog backfill.
