---
id: TASK-126
parent: EPIC-002
feature: null
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: todo
priority: P2
assignee: agent
created: 2026-09-16
depends-on: [TASK-109]
blocks: []
# findings: ids this task remediates, from a review/audit/harvest/drill pass. Prefixes: see /tasks intake
findings: []
pr: null
github-issue: null
jira-key: null
---

# Sweep every template for a shipped value its own skill says must be declared or derived

## Context

**Spawned from TASK-109 (2026-09-16), which fixed two instances and deliberately did not sweep** — its
`## Out of scope` says so outright: *"Auditing every other template for the same shape. If the rule is
worth stating, that sweep is its own task; say so rather than widening this one."* The rule turned out to
be worth stating, so the sweep is now owed.

The rule TASK-109 recorded, in `AGENTS.md` § Conventions → *Code structure & patterns*: **a template
ships nothing a render cannot make true.** A template is read as a thing to reproduce faithfully, so a
plausible value in one is minted as fact by a **correct** render rather than by a mistake — which is why
it survives review where an obvious stub would not.

Two instances were fixed there:

| Template | Was | Now |
|---|---|---|
| `skills/tasks/templates/config.yml:12` | live `integration: pr-per-task` | commented, carrying a `<pr-per-task\|single-branch>` choice |
| `skills/specs/templates/map.yml:20-22` | `coverage: verified` + `tracked-files-at-scan: 0` | `coverage: unverified`, companions commented |

### The nearest neighbour, already found — start here

**`mode: local` on line 4 of that same `skills/tasks/templates/config.yml`.** It is the same shape: a live
value for a field a run is supposed to resolve. It was **deliberately not changed** by TASK-109, and the
reason is recorded so this task does not have to re-derive it: `/tasks init` step 2 always resolves `mode`
— from a `mode=` arg, else a documented detection flow that scans signals and asks the user — and it has a
documented fallback. So unlike `integration:`, no branch leaves it unresolved, and a live default is
reachable only through a path that overwrites it.

**That reasoning is what this task must adjudicate rather than inherit.** "Always resolved in step 2" is a
claim about one verb; `skills/tasks/verbs/new.md:117` renders the same template with no such guard, which
is exactly the second render path that made `integration:` reachable. Whether that path can also ship a
defaulted `mode:` is the open question.

### Why a sweep rather than case-by-case

Every instance found so far was found by a reviewer noticing prose and template disagree — an expensive,
lucky channel. A population-wide pass is also the point at which a **mechanical** guard becomes worth its
cost: TASK-109 rejected a lint check for two lines, and said so, but the trade-off inverts over a
population. See `## Out of scope` for what that check would look like.

### Adjacent evidence from the TASK-109 cold drill (2026-09-16)

`DRILL-109`'s B2 runner rendered `templates/map.yml` into a **Python** fixture and carried all five of its
`ignore:` globs verbatim — `**/bin/**`, `**/obj/**`, `**/node_modules/**`, `**/*.test.*`, `**/*Tests*/**` —
reporting *"None of them matches anything in this repo; I kept them because step 6 says to render the
template."* Not separately filed: it is the same question this sweep asks, one step out. A shipped `ignore:`
list is not a *declaration* the way `integration:` is, so it may well be defensible — but `new-project`
promises *"stack-appropriate `ignore:` globs"* and a faithful render delivers .NET/JS ones to any stack, so
the sweep should adjudicate it rather than leave it unexamined.

## Acceptance criteria

- [ ] Every file under `skills/*/templates/` and `skills-pi/*/templates/` is examined for a shipped value
      whose owning skill says the field is **declared** (a choice someone makes) or **derived** (computed
      by a run) — the inventory is the deliverable, not just the fixes
- [ ] Each instance found gets a verdict — **fixed**, or **deliberately kept with the reason recorded on
      this task** — and no instance is left with neither, which is the state this sweep exists to end
- [ ] `mode:` in `skills/tasks/templates/config.yml` is adjudicated explicitly, including whether
      `verbs/new.md:117`'s unguarded render can ship a defaulted value the way `integration:` could
- [ ] Wherever a template is fixed, the prose that points at it is reconciled in the same change, naming
      which side was wrong — the same rule TASK-109 applied
- [ ] A decision is recorded on whether the rule gets a **mechanical guard** (see `## Out of scope`), with
      the reason either way; "we did not consider it" is not an outcome
- [ ] If a guard is built, a case in `.github/workflows/skills-lint-test.sh` **fails without it** — the
      repo's standing rule for any lint change
- [ ] `bash .github/workflows/skills-lint.sh` passes and the test suite stays green

## Out of scope

- **Re-opening the two instances TASK-109 fixed.** Their shape is settled; this task finds the rest.
- **Re-litigating what `coverage:` or `integration:` mean** — TASK-021, TASK-023, TASK-033 and TASK-079
  own those.
- **Templates outside `skills/`** — this repo's own `tasks/` and `docs/` artifacts are instances of
  templates, not templates themselves.
- Building the mechanical guard is **in scope to decide**, and in scope to build only if that decision
  says yes. The shape TASK-109 sketched and declined, for the record: a marker comment (`# DECLARED:` /
  `# DERIVED:`) above such a key, with the lint asserting the key under it is commented or tokenised —
  **keyed on the marker rather than a hard-coded skill list**, the same design check 4 already argues for.
  Its cost is a new repo-wide convention token, which is why two lines could not justify it.

## Human test plan

- [ ] For each template the sweep changes, render it faithfully into a throwaway tree outside the repo
      with nothing overwritten, and confirm no field arrives carrying a value nobody chose or computed —
      the same before/after render TASK-109 used as its evidence
- [ ] Confirm each rendered file still parses (YAML templates especially — commenting a key must not
      leave a document that fails to load)

## Implementation plan

_Populated by `/tasks plan TASK-126` — leave empty until then._
