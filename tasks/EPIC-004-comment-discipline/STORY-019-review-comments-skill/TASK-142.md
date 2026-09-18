---
id: TASK-142
parent: STORY-019
feature: FEATURE-002
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: todo
priority: P1
assignee: unassigned
created: 2026-09-18
depends-on: [TASK-140]
blocks: [TASK-143, TASK-144]
findings: []
pr: null
github-issue: null
jira-key: null
---

# Create the `review-comments` skill — the check and its two scopes

## Context

Implements FEATURE-002 **D6, D6a, D7**. A new skill folder under `skills/` (never `skills-pi/`,
which is frozen) that owns the comment-discipline check.

**It owns the check; [[verify-conventions]] does not get a second copy of the rule.** That skill
lints diffs against whatever the project's own guide records, so once TASK-140 lands it already
sees the rule as one line in a rulebook. What it cannot do is sweep code nobody is changing — and
the whole reason this command exists is the ten-line block written two years ago in a file no
current task touches.

The name is settled: **`review-comments`**. `verify-comments` was rejected because the `verify-*`
family here means report-only and a member that writes files empties the name; `prune-comments`
was rejected because it understates the relocation half (TASK-143).

Scopes, both explicitly asked for: **default is the work in hand** (the current diff), `--all` is
the whole repository. Note the consequence the grill flagged for `--all` — a whole-repo sweep can
produce hundreds of findings, and a report nobody can read is where a wrongly-deleted comment slips
through. How findings are batched or paged on `--all` is a real design question for this task, not
a detail; whatever you choose, say why in the close notes.

Adding a new skill folder means **both installers must be re-run** before either runtime can
resolve it — one junction is created per folder at install time.

## Acceptance criteria

- [ ] `skills/review-comments/SKILL.md` exists with mandatory frontmatter: `name: review-comments` matching the folder, and a `description` carrying the trigger phrases users actually type, including Slovak.
- [ ] The router stays small; detail lives in the file that owns it.
- [ ] The check is stated as the five-destination test, pointing at the rule's owning file rather than restating it — the same deference this repo requires of any shared inventory.
- [ ] Default scope is the current diff; `--all` widens to the whole repository. The default run is what happens with no flag passed.
- [ ] `--all` declares how it batches or pages findings, and why that choice was made.
- [ ] Any flag this skill declares, and any flag it passes to another skill's verb, satisfies the lint's flag-contract check.
- [ ] Cross-skill references use `[[name]]` and resolve.
- [ ] Both installers re-run, and the lint's install-root check reports no drift for the new folder.
- [ ] `bash .github/workflows/skills-lint.sh` passes.

## Out of scope

- The only-copy relocation path — TASK-143. This task may report such a comment; it must not delete one.
- Wiring into `/tasks close` — TASK-144.
- Comment *style* (formatting, doc-comment syntax, language) — out of scope at the epic level.

## Human test plan

A cold drill, acquired under the same rules as TASK-140 (`--disable-slash-commands`, guide-free
working directory; the drill record names the command, the directory and the coldness check).

**The fixture must contain comments that have to survive.** A drill that only supplies violations
cannot distinguish a working check from one that flags everything.

- [ ] Point it at a diff containing a changelog above a `const`, a comment restating its line, a test comment naming a finding id and its mechanism, and a long block explaining a non-obvious algorithm. Expected: the first two flagged with their destination named; the last two untouched.
- [ ] Run it with no flag on a repo with a dirty tree. Expected: it reports on the diff only, and says so — a run that silently swept the whole repo has broken the default.
- [ ] Run `--all` on a real consumer repo. Expected: findings are delivered in a form a person can actually work through, and the report states the total rather than burying it.
- [ ] Expected failure mode to watch for: the algorithm block is flagged. Length is not the test; if it fires there, the check has re-derived a cap.

## Implementation plan

_Populated by `/tasks plan TASK-142` — leave empty until then._
