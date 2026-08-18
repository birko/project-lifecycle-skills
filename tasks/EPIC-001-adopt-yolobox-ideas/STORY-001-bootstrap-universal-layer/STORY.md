---
id: STORY-001
parent: EPIC-001
# status: planned | in-progress | done | cancelled
status: in-progress
created: 2026-08-18
---

# Bootstrap the universal layer on this repo

## User story

As a maintainer of these skills, I want this repository to use the universal layer it ships, so
that `verify-conventions` has a rulebook to lint against, `roadmap` has two trees to compare, and
`new-project` gets exercised on a non-empty repo before consumers hit that path.

## Behaviour

- `AGENTS.md` holds the agent-guide content; `CLAUDE.md` is exactly the one-line `@AGENTS.md` import. The two never both carry content — a divergent pair is the one genuinely bad outcome.
- `AGENTS.md § Conventions` carries real rules in every subsection — no placeholder tokens ship, including in prose that *describes* placeholder tokens.
- `docs/BRIEF.md` exists as append-only ground truth. Because no original brief survives 36 commits of history, it is stamped as adopted rather than reconstructed — a paraphrase presented as ground truth is what the verbatim rule exists to prevent.
- `docs/specs/.map.yml` is seeded with an empty `areas:` list, which every enforcement point treats as *absent*, so nothing false-fires before `/specs init` runs.
- `docs/features/README.md` renders an empty table and says so explicitly — empty by design, not by omission.
- `CHANGELOG.md` backfills all 36 pre-changelog commits into `[Unreleased]`, bucketed and translated into human language, one bullet per meaningful change rather than per commit.
- `.gitignore` exists (the repo had none) and ignores `.env*` and `.claude/settings.local.json`.
- CI runs `skills-lint`: frontmatter present and matching its folder, every `[[link]]` resolves, every file a `SKILL.md` references exists.

**Edge case that decided the BRIEF.md shape:** an adopted repo has no verbatim origin. The rule
established here — stamp the adoption date, state that no original ask survives, begin the
append-only log from the first post-adoption request — becomes `adopt-project`'s rule in STORY-002.

**Known exemption:** this story ran before its own task file existed (see EPIC-001 § Notes). It is
backfilled at `in-progress` with reconstructed acceptance criteria, never dropped straight to `done`.
