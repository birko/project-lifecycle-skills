---
id: TASK-043
parent: STORY-015
feature: null
# status: todo | in-progress | review (code done, sign-off pending) | blocked | done | cancelled
status: todo
priority: P3
assignee: agent
created: 2026-08-20
depends-on: []
blocks: []
findings: []
pr: null
github-issue: null
jira-key: null
---

# The wikilink contract is only enforced inside `skills/`, and cannot naively be widened

## Context

Filed by `/verify-conventions` at TASK-040's close gate.

`AGENTS.md § Conventions › Framework / stack` states the contract:

> **Cross-skill references use `[[skill-name]]`**, never a bare path — the link is the contract, and
> CI resolves it.

CI resolves it in exactly two trees. `.github/workflows/skills-lint.sh:73` and `:89` both walk
`find skills skills-pi -name '*.md'`. Every `[[link]]` written anywhere else — task files, epic and
story bodies, `docs/`, `AGENTS.md` itself — is unchecked, so the sentence is true of `skills/` and
false of the repo.

**The obvious fix is wrong**, which is the substance of this task. Widening the `find` to the repo
root reports **20 unresolved links across 8 files**, of which **one kind is a genuine defect**:

| Source | Unresolved | What they actually are |
|---|---|---|
| This task's own body | 7 | The single noisiest file in the repo — it cannot discuss the syntax without writing it, and it deliberately contains a broken example |
| `AGENTS.md` | 4 | Syntax placeholders in the sentences that *document the convention* |
| Other `tasks/` files | 7 | Prose about the lint, plus two real forward references |
| `docs/architecture.md`, `README.md` | 2 | Syntax placeholders |

Across all 20, the only genuine unresolved reference is **`[[domain]]`** (three occurrences) — a
deliberate forward reference to the skill STORY-003 will build. Everything else is prose about the
syntax. That the task *describing* this problem is itself the worst offender is not an accident; it is
the shape of the problem.

So a naive widening reports 19 false positives to catch 1 real one. A check at that ratio gets muted,
and this repo already has a rule about that: an advisory section still has to be *tested*, and a muted
check is worth what an unrun one is.

The forward-reference case is the harder one and is not noise: `[[domain]]` is *correct today* and must
resolve later. `adopt-project/INFER.md` already hit this from the other side — it names `domain` in
plain text precisely because a wikilink to an absent skill fails the lint, and STORY-003 is scheduled to
promote it. Whatever this check does must let a forward reference be declared rather than forcing prose.

## Acceptance criteria

- [ ] The scope of the wikilink check is decided and recorded — which trees it covers, and why the
      others are excluded rather than merely unvisited
- [ ] The check distinguishes a **reference** from a **syntax example**; the mechanism is stated
      explicitly (a fenced/inline-code exemption, an ignore list, an escape form — the choice is the
      task's substance, not an implementation detail)
- [ ] A **forward reference to a not-yet-built skill** can be declared and does not fail the run;
      `[[domain]]` is the live case and must pass while STORY-003 is open
- [ ] `AGENTS.md § Conventions` no longer claims CI resolves links it does not resolve — either the
      claim is narrowed to the trees actually covered, or the coverage is widened to match the claim
- [ ] At least one `.github/workflows/skills-lint-test.sh` case fails without the change, and the
      negative assertions require the section to have run (a "must not appear" check passes trivially
      when the section is deleted)
- [ ] If the check lands advisory rather than fatal, it says so and never changes the exit code — the
      remedy for a stale forward reference is inside the repo, so fatal is defensible here; state which
      was chosen and why

## Out of scope

- **Fixing `[[domain]]`.** It resolves when STORY-003 ships the skill. This task must not force it into
  prose to make a check pass — that inverts the dependency.
- Rewriting the prose that legitimately uses `[[link]]` as an example. The check adapts to the
  documentation, not the reverse.
- Link checking for anything other than `[[…]]` skill references (markdown paths, URLs, `file:line`
  references). Different contract, different check.

## Human test plan

- [ ] Run the lint on the repo as-is and confirm it reports only the `[[domain]]` forward references
      (3, or 0 if the declaration mechanism suppresses them) — never the raw 20
- [ ] Add a genuinely broken `[[not-a-skill]]` to a task file and confirm the run reports it; remove it
- [ ] Add a `[[skill-name]]`-style syntax example to a docs paragraph and confirm it is **not** reported
- [ ] Delete the new section from `skills-lint.sh` and confirm the regression suite fails — a test that
      still passes with the check removed is testing nothing

## Implementation plan

_Populated by `/tasks plan TASK-043` — leave empty until then._
