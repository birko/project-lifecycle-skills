---
id: STORY-009
parent: EPIC-001
# status: planned | in-progress | done | cancelled
status: planned
created: 2026-08-18
---

# Multi-repo adoption — one layer over many repositories

## User story

As a developer working in an aggregator tree of many repositories, I want the lifecycle layer to
work across it, so that adopting does not mean either 177 separate layers or one layer that lies
about which repo it describes.

## Behaviour

- **The gap is an unstated assumption.** `LAYER.md` and both front doors assume *one repo, one layer*. `C:\Source\Birko\Framework` breaks it: the root is **not git-tracked at all**, and it contains **177 nested git repositories**. Nothing in the skills says what to do, so today they would either scaffold a layer over an untracked root or ask the user 177 times.
- Decide the model — the choice is the story, not an implementation detail:
  - **Aggregate** — one layer at the aggregator root, whose `tasks/` and `docs/features/` span all member repos. Matches how the work is actually planned; but the root is untracked, so the layer would be unversioned unless the root becomes a repo.
  - **Per-member** — each member repo carries its own layer. Versioned correctly and independent; but cross-repo work has no home, and `roadmap` cannot see the whole picture.
  - **Hybrid** — a thin aggregate index at the root pointing at per-member layers.
- `new-project` already has the machinery to *detect* the dangerous shape — its step 6 case 3 surfaces the resolved ancestor root and asks the user rather than assuming. Extend that reasoning rather than inventing a second detector: **only the user knows whether an aggregator root is meant to be a repo.**
- **`specs` already resolves external sources against their own repo** (a fix landed 2026-08-16), so the spec layer has a partial multi-repo story already. Read that before designing — it may settle the model, or contradict a choice made here.
- Whatever the model, an untracked aggregator root must never be silently `git init`-ed. That is an outward-facing act on a tree containing 177 repos.

**Why this is a story and not a bug:** it is a missing capability, and it needs a decision about
where work is tracked in a polyrepo before any code changes. That decision belongs to a grill, not
to a task's implementation plan.
