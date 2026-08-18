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
| `.gitignore` | — | Present → check that `.env` / `.env.*` are covered **and** that agent-tool local state is (`.claude/settings.local.json` at minimum); offer the lines if not. Absent → create for the detected stack. |
| `.gitattributes`, `.editorconfig` | — | Create if absent; leave if present. |
| Test harness | [[populate-tests]] | Delegate to `populate-tests` in `adopt` mode. A repo with a working runner is already adopted — say so and move on. |
| CI gate | — | Present → leave. Absent → offer a minimal install→build→test workflow for the detected stack — **but only if the repo can build in isolation**; see *CI a repo cannot pass* below. |

## The adopted-repo brief

`docs/BRIEF.md` stores the user's requests **verbatim**, and an existing repo usually has no
surviving original ask. **Do not reconstruct one from the README** — a paraphrase presented as
ground truth is precisely what the verbatim rule exists to prevent, and it is worse than an
absent file because it reads as authoritative.

Instead, stamp the adoption:

- An `## Origin` section recording the adoption date, that no original brief exists, and where the project's actual history lives (README, commit log).
- An empty `## Amendments` section. The append-only log starts from the **first request made after adoption**.

## CI a repo cannot pass

**Never offer CI to a repo whose build depends on paths outside itself.** Check before offering:
an MSBuild `Import` or `ProjectReference` that escapes the repo root, a `path =` dependency in
`Cargo.toml`, a `file:` dependency in `package.json`, an editable local install in a Python project.

**Resolve the path; do not count the dots.** A reference is only a problem if the resolved target
lands outside the repo root. `..\..\src\Foo\Foo.csproj` from `tests/Foo.Tests/` goes up two
levels and back down *inside* the repo — perfectly normal, and flagging it would skip CI on repos
that could run it fine. Two things do count: a target that resolves outside the root, and a path
rooted at a `$(Variable)` or environment variable, which cannot be resolved at all and therefore
cannot be guaranteed present on a runner. (Written down because counting `..` is the obvious
implementation and it is wrong — it over-reported on the first repo it met.)

When you find one, **skip the offer and say why** — name the dependency and what would have to
exist on a runner for the build to work. A workflow that is red on its first run and stays red is
worse than no workflow: a permanently-failing gate teaches people to ignore CI, and that habit
costs more than the missing gate.

This is the common case, not an edge case, wherever a team shares framework source through an
aggregator rather than a package feed. Observed in `Latent`, a clean .NET solution whose
`Latent.Birko.csproj` imports `$(BirkoSrc)\Birko.Helpers\Birko.Helpers.projitems` — source from a
sibling tree that a runner has no way to obtain.

Making such a repo CI-able is a distribution decision (publish the framework as packages, vendor
it, or check it out in the workflow), not something an adoption pass can settle. Report it and move
on.

## Ordering

Ground truth and the agent guide first (later steps read them), then `tasks init`, then
`specs init` — the spec map wants the guide's architecture vocabulary, and `/tasks init` may need
the task mode the guide records.

## Rule

**Never overwrite a file the repo already owns.** A conflict is reported for the user to resolve,
never resolved silently. An adoption that quietly rewrites someone's work is worse than one that
does nothing, because it destroys the thing it was meant to preserve.
