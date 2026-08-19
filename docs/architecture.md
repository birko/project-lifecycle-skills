# Architecture

> **Living document.** Update it whenever a change alters the structure — a stale architecture doc
> is a defect, not harmless. Last reviewed 2026-08-18.

## What this repository is

A **single source of truth for agent skills**. It ships no runtime and no build step: every skill
is markdown that an agent reads at invocation time. The installers *link* rather than copy, so an
edit here is live in every consuming project immediately — which is the reason correctness matters
more than it would in a library you version and release. They link one junction *per folder*,
though, so a **newly added skill** is live only after the installers are re-run; until then its
folder exists in this repo and resolves nowhere.

That drift is now **detected rather than merely documented**: `skills-lint.sh`'s check 4 compares both
install roots back against the trees and reports a folder with no junction, or a junction whose source
folder has gone (a rename or delete — the installers only ever add, so nothing prunes). It is
deliberately **advisory** and never fails the run: the remedy is an installer re-run, which no diff can
perform, and the roots are absent on the CI runner. It detects; it never repairs, and it ignores links
pointing outside this repo, since those roots also hold the user's own skills.

## The three trees

| Tree | Installed into | Contains |
|---|---|---|
| `skills/` | `~/.claude/skills` **and** `~/.pi/agent/skills` | the generic, stack-agnostic skill set — **all new skills land here** |
| `skills-pi/` | `~/.pi/agent/skills` **only** | fallback definitions of review passes Claude Code ships natively — **frozen** |
| `docs/`, `tasks/` | not installed | this repo's own lifecycle artifacts |

`skills-pi/` exists because a runtime without a built-in `code-review` needs *something* for the
merge gate to call. Installing those definitions into `~/.claude/skills` would shadow the native
passes with strictly worse copies, so the two installers deliberately differ. Adding a new skill
there would make it invisible to Claude Code users — hence "frozen".

## Anatomy of a skill

```
skills/<name>/
  SKILL.md        ← the router: frontmatter (name, description w/ trigger phrases) + dispatch
  verbs/*.md      ← one file per verb; standalone-readable, owns its own rules
  templates/*     ← the file shapes the skill writes into a consumer's repo
  *.md            ← reference material loaded on demand (e.g. tdd/mocking.md)
```

The router stays small; anything that matters to exactly one verb lives in that verb's file. A
verb must read correctly on its own, because that is how an agent loads it — never as a section
that assumes the router is already in context.

## How the skills compose

```
new-project ──seeds──▶ the universal layer (agent guide, docs/, tasks/, CHANGELOG)
adopt-project ─reconciles──▶ the same layer, for a repo that already has code   [planned]

feature ──rides on──▶ tasks ──tracked by──▶ roadmap (+ divergence audit)
   │                    │
   │                    ├──▶ populate-tests   (the PROVE leg)
   │                    ├──▶ specs regen      (behavioural map, at story close)
   │                    └──▶ verify-conventions + code-review  (the merge gate)
   │
   └──uses──▶ grill-me (interrogation) · prototype (stakeholder artifact)

fix-next ──drains──▶ what tasks/intake filed from a review pass
```

Two structural rules hold this together:

- **One engine per question.** `roadmap` owns the cross-tree collection + divergence rules; `feature` and `tasks` render slices of it rather than reimplementing it. `specs verify` owns the staleness definition that `roadmap` calls.
- **Layer parity.** `new-project` and `adopt-project` must be extended together — one creates the universal layer, the other reconciles it into an existing repo. Extending only the scaffolder strands every project already using the skills.

## This repo's own lifecycle artifacts

`docs/BRIEF.md` (verbatim ground truth) · `docs/features/` (empty by design — current work is
task-only) · `docs/specs/` (seeded empty; filled at EPIC-001 / STORY-008) · `docs/adr/` (arrives
with the `domain` skill at STORY-003) · `tasks/` (EPIC-001 and its stories) · `CHANGELOG.md`.

## Verification

There is nothing to compile, so correctness is checked two ways:

1. **`skills-lint`** (CI, and runnable locally) — frontmatter present and matching the folder, every `[[link]]` resolves to a real skill, every file a `SKILL.md` references exists. It catches the repo's most likely silent defect: a reference to something that was renamed or never written.
2. **Drills** — install a changed skill and run it end-to-end against a real repository. The lint proves the wiring; only a drill proves the prose works. Non-trivial skill changes carry the drill as their task's `## Human test plan`.
