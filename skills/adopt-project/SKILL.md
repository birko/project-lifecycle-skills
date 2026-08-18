---
name: adopt-project
description: Bring an EXISTING repo onto the project lifecycle layer — survey what it already has, fill only what is missing, and report both. Use when the user says "adopt this repo", "adopt-project", "set up the lifecycle here", "add tasks/docs to this project", "init the skills in this repo", "we already have code, wire up the lifecycle", "rescan this project", "bring this repo up to date with the skills", "adoptuj projekt", "nastav lifecycle v tomto repe", "doplň chýbajúce časti", or points at a codebase that does not yet use these skills. Also the UPGRADE path — re-run it whenever the universal layer grows, to reconcile a repo that adopted an older version. Tech-agnostic. This is the brownfield counterpart to [[new-project]] (greenfield): same layer, opposite starting point.
---

# adopt-project

The **brownfield front door**. [[new-project]] creates the universal layer for a repo that has
nothing; this reconciles a repo that already has code, history, and opinions of its own against
that same layer — see [LAYER.md](LAYER.md), the single definition both skills work from.

**One skill covers both cases**, because they differ only in how much is missing:

- *"We have code and none of this."* — first adoption.
- *"We adopted this months ago and the layer has grown since."* — the same run, fewer gaps.

So it is **idempotent by design**: re-run it any time. A repo with nothing missing gets a report
saying so and no writes at all.

## What it does not do

It does not reimplement file shapes. `tasks/`, `docs/specs/`, and the test harness are created by
the skills that own them ([[tasks]] `init`, [[specs]] `init`, [[populate-tests]] `adopt`) — each
already delta-based and safe to re-run. This skill decides *what is missing and in what order*,
then delegates. Hand-rolling those shapes here is how the two versions drift.

## Process

### 1. Survey — read before writing anything

Walk [LAYER.md](LAYER.md) and classify every artifact as **present**, **missing**, or **present
but incomplete** (an agent guide with no `## Conventions` block; a `tasks/` tree with no
`.config.yml`). Alongside it, detect the facts the fill will need: the stack (manifests, source
layout), whether a test runner already works, whether a git remote exists, and whether the repo
is captured by an ancestor git repo.

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

Ground truth and the agent guide first, then `/tasks init`, then `/specs init` — later steps read
what earlier ones write. For each artifact follow its **"already present?"** column in
[LAYER.md](LAYER.md).

Two rules bind the whole step:

- **Never overwrite a file the repo already owns.** Report the conflict; let the user resolve it.
- **Never reconstruct `docs/BRIEF.md`** from an existing README. Stamp the adoption instead (see [LAYER.md](LAYER.md) § The adopted-repo brief).

### 4. Report what changed

Three lists: **created**, **left alone** (with why — "present already", "you declined"), and
**still missing** (with why — "needs a decision", "blocked on a remote"). Then the next step:
`/feature new` for stakeholder-facing work, `/tasks new` for a defined unit.

The report is the deliverable as much as the files are. An adoption whose output is "done!" leaves
the user unable to tell what was touched in their own repo.

## Conventions

- **No `Co-Authored-By:` trailers** in any commit it might create.
- PowerShell-compatible commands.
- Offer the adoption commit; never commit unasked.
- Ask before `git init` on an untracked repo, and surface the resolved root when an **ancestor**
  repo already tracks the directory — only the user knows whether that ancestor is intended.

## Related skills

- [[new-project]] — the greenfield front door. Same layer, opposite starting point; both work from [LAYER.md](LAYER.md), and **the layer-parity rule means a change to one is a change to both**.
- [[tasks]] — `init` creates `tasks/`; adopts a pre-skill tree without disturbing it.
- [[specs]] — `init` re-discovers the area map and proposes a delta.
- [[populate-tests]] — `adopt` mode wires a runnable test harness.
- [[verify-conventions]] — the payoff of adoption: it reads the `## Conventions` block this skill makes sure exists.
- [[roll-changelog]] — offered for the changelog backfill.
