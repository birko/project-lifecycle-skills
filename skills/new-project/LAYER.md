# The universal layer — the inventory both front doors work from

The single definition of what a lifecycle-ready repo contains. [[new-project]] **creates** this
for a new repo; [[adopt-project]] **reconciles** an existing one against it. One list, two verbs —
a second copy is exactly the drift the layer-parity rule exists to prevent.

**What lives here vs. in SKILL.md.** This file is the *inventory*: which artifacts, who owns each
shape, and what to do when one already exists. `SKILL.md` step 3 carries the *creation detail* —
how to seed the Conventions rulebook, what to put in the architecture overview. Two axes, not two
copies: add an artifact here, describe how to fill it there.

**Changing this file changes both skills.** That is the layer-parity rule, and it is the whole
point of the file existing.

Each row states what the artifact is, which skill owns its shape, and — the part that only matters
for adoption — **what to do when the repo already has one**.

| Artifact | Owner | Already present? |
|---|---|---|
| `README.md` | — | **Leave it.** Offer to append a short "How we work" pointer at the end; never rewrite a human's README. |
| Agent guide (`CLAUDE.md`, or `AGENTS.md` + one-line `@AGENTS.md` bridge) | [[new-project]] seed | **Merge by section.** Add missing `##` sections; never touch an existing one's content. A guide with no `## Conventions` block is the highest-value gap in an adoption — flag it loudly. |
| `docs/BRIEF.md` | [[new-project]] | **Never reconstruct.** See *The adopted-repo brief* below. |
| `docs/architecture.md` | — | Leave it; report if absent. |
| `docs/features/` + `README.md` index | [[feature]] | Create the folder + index if absent. Never regenerate an existing index by hand — that is `/feature status`'s job. |
| `docs/specs/.map.yml` | [[specs]] | Delegate to `/specs init`, which re-discovers and proposes a delta rather than dropping areas. Seed `areas: []` only when the repo has no code yet. |
| `tasks/` (`.config.yml` + `README.md`) | [[tasks]] | Delegate to `/tasks init`, which adopts a pre-skill tree without disturbing it. Never write these shapes by hand. |
| `CHANGELOG.md` | [[roll-changelog]] | Present → leave. Absent → seed the Keep a Changelog stub, and **offer** a backfill from history; do not backfill unasked, it is a judgement call about what mattered. |
| `.gitignore` | — | Present → check only that `.env` and `.env.*` are covered, and offer the lines if not. Absent → create for the detected stack. |
| `.gitattributes`, `.editorconfig` | — | Create if absent; leave if present. |
| Test harness | [[populate-tests]] | Delegate to `populate-tests` in `adopt` mode. A repo with a working runner is already adopted — say so and move on. |
| CI gate | — | Present → leave. Absent → offer a minimal install→build→test workflow for the detected stack. |

## The adopted-repo brief

`docs/BRIEF.md` stores the user's requests **verbatim**, and an existing repo usually has no
surviving original ask. **Do not reconstruct one from the README** — a paraphrase presented as
ground truth is precisely what the verbatim rule exists to prevent, and it is worse than an
absent file because it reads as authoritative.

Instead, stamp the adoption:

- An `## Origin` section recording the adoption date, that no original brief exists, and where the project's actual history lives (README, commit log).
- An empty `## Amendments` section. The append-only log starts from the **first request made after adoption**.

## Ordering

Ground truth and the agent guide first (later steps read them), then `tasks init`, then
`specs init` — the spec map wants the guide's architecture vocabulary, and `/tasks init` may need
the task mode the guide records.

## Rule

**Never overwrite a file the repo already owns.** A conflict is reported for the user to resolve,
never resolved silently. An adoption that quietly rewrites someone's work is worse than one that
does nothing, because it destroys the thing it was meant to preserve.
