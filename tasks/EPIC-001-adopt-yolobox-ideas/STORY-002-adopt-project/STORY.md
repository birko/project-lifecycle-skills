---
id: STORY-002
parent: EPIC-001
# status: planned | in-progress | done | cancelled
status: done
created: 2026-08-18
---

# `adopt-project` — the brownfield front door

## User story

As a developer with an existing codebase, I want one command that surveys what my repo already has,
grills me about what it infers, and fills in only the missing parts of the universal layer, so that
adopting these skills does not mean hand-assembling a dozen files or clobbering my own.

## Behaviour

- Pairs with `new-project` by name and role: greenfield front door / brownfield front door. It is a **skill, not a verb**, because it orchestrates across five others (`new-project`'s templates, `tasks init`, `specs init`, `populate-tests adopt`, `domain`) — and because someone with an existing repo will never type "new project".
- **One idempotent skill covers both cases.** "Old structure, fill the gaps" is "code, no structure" with fewer gaps. Survey → grill → fill, re-runnable any time. Every sub-init it calls is already delta-based: `tasks init` adopts a pre-skill tree without disturbing it, `specs init` proposes a delta and never silently drops an area, `new-project` merges rather than clobbers.
- **The grill is what makes it more than skip-if-exists.** It reads conventions *out* of the codebase and asks for confirmation: does every handler returning the same result type mean a convention or an accident; do two names in the code mean one concept (a glossary question); do the files cluster into the areas the spec map should use. Inferring rules from code is a different job from asking for them up front, and it is most of the value.
- **No origin brief is ever reconstructed** — the rule established in STORY-001.
- Reports what it created versus what it left alone. Never silently overwrites a file the repo already owns.
- **Merge guidance for files the repo already owns, not just "don't clobber".** `new-project` step 1 says "merge, don't clobber" and stops there. Found in STORY-001: this repo's `README.md` was far richer than the seed template, and the skill offered no rule for what to do — the sections were appended by hand. `adopt-project` must state, per artifact, whether it appends a section, writes a sibling file, or leaves the file alone and reports the gap. The same rule is then backported to `new-project` under layer parity.
- **Acceptance test:** re-run it on this repository. If STORY-001 was complete, it reports zero gaps; anything it finds is a real STORY-001 defect and gets filed as such.

**Explicitly out of scope: multi-repo trees.** Both front doors assume one repo, one layer. An aggregator tree (untracked root, many nested repos) needs a decision about where work is tracked before any code changes — tracked as STORY-009.

**Why this is second, not last:** STORY-003 through STORY-007 each extend the universal layer, and
every extension strands projects already using the skills. Build the upgrader before shipping
upgrades. The layer-parity rule in `AGENTS.md § Conventions` is what keeps it from falling behind.

## Closed 2026-08-20

All 15 tasks done. The brownfield front door is built and drilled: survey by evidence rather than by
expected shape, an inference round that scopes or skips itself and says which, declarations read rather
than inferred, defects filed as well as fixed, generated files regenerated only when doing so loses
nothing, and a CI offer gated on whether a runner could actually obtain the build's dependencies.

**What the story is not:** tested on a large real repo's *fill*. Seven repos were surveyed and two
throwaway fixtures were drilled end to end, but the biggest fill remains `Presenter`'s two small
artifacts. The honest next subject is a genuinely unadopted real repo, which does not exist in the fleet
yet — recorded on TASK-004 and in the EPIC's state block rather than left as an assumption of coverage.
