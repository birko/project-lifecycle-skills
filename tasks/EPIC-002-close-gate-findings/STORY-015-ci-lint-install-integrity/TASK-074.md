---
id: TASK-074
parent: STORY-015
feature: null
# status: todo | in-progress | review (code done, sign-off pending) | blocked | done | cancelled
status: todo
priority: P2
assignee: agent
created: 2026-08-23
depends-on: []
blocks: []
# findings: ids this task remediates, from a review/audit/spec-harvest pass (CR-* SEC-* SH-* VC-*)
findings: []
pr: null
github-issue: null
jira-key: null
---

# A skill cannot reference a skill that does not exist yet

## Context

**Deferred from TASK-043**, whose AC 3 asked for this and which the scoping fix did not deliver. That task
resolved the *false guarantee* — the rulebook no longer claims CI resolves wikilinks outside `skills/` and
`skills-pi/`. It did nothing about the enforcement that remains, and remains correct, **inside** those trees.

`skills-lint.sh` check 2 resolves every `[[wikilink]]` in `skills/` and `skills-pi/` against a real folder,
and fails the run when one does not exist. That is right almost always — a dangling cross-reference breaks a
skill at the moment a consumer's agent tries to follow it. The exception is a **forward reference**: a skill
that legitimately points at a skill this repo has decided to build and has not built yet.

**The cost is measured, not hypothetical.** `skills/adopt-project/INFER.md` referred to `domain` in **plain
text** for three days, specifically because a wikilink would have failed CI. STORY-003's own notes record the
workaround and the cleanup: *"`adopt-project/INFER.md` names `domain` in plain text because a wikilink to an
absent skill resolves to nothing at runtime — the lint blocks it. Convert it to `[[domain]]` here."* So the
gate pushed a real reference into a weaker form, and a later task had to undo that.

**Why it is worth fixing rather than living with.** A plain-text reference is invisible to the contract: it
is not linted when the skill *does* arrive, it does not show up in a grep for `[[domain]]`, and nothing
reminds anyone to upgrade it. The workaround silently converts a checked link into an unchecked one — which
is the same shape as the defect TASK-043 just fixed one level up.

**The design question, and it should be argued rather than assumed.** Options, none obviously right:

| Option | Cost |
|---|---|
| **A declared allow-list** — e.g. a `planned-skills:` list somewhere the lint reads | Explicit and greppable. Needs a home, and a stale entry is a new kind of rot: a skill that shipped but stayed on the list is unchecked forever. |
| **A distinct syntax** — `[[domain?]]` or `[[?domain]]` for "planned" | Self-documenting at the point of use, no second file. Invents syntax, and every reader and tool has to learn it. |
| **Frontmatter on the referring skill** — declare its own forward references | Local to the file that needs it, dies with the file. Still a list that can go stale, just a smaller one. |
| **Accept the plain-text workaround, and document it** | Zero machinery. Keeps the invisible-downgrade problem, and the measured instance shows nobody remembers to convert back without a task telling them to. |

**Whichever lands, staleness is the thing to design against**, because every option except the last
introduces a declaration that can outlive its reason. A check that the forward reference is *still* forward —
i.e. fails when the named skill now exists — is probably the load-bearing half.

## Acceptance criteria

- [ ] A forward reference to a not-yet-built skill can be written **inside `skills/`** without failing the lint, or the task records that the plain-text workaround is the accepted answer and why
- [ ] If a mechanism lands, it **detects its own staleness**: once the named skill exists, the declaration is reported so the reference gets upgraded to an ordinary link
- [ ] Exercised against a **fixture**, not a real forward reference — there is no live instance today, and the outcome says so plainly rather than implying one was found
- [ ] The choice among the options above is stated with the rejected alternatives, per this repo's own bar for a recorded decision
- [ ] `skills-lint.sh` change carries a `skills-lint-test.sh` case that **fails without it**, and the negative assertions require the section to have run
- [ ] `skills-lint` and `skills-lint-test` both green

## Out of scope

- The scope of the wikilink check outside `skills/` — **TASK-043**, closed. That settled the claim; this is the enforcement that stays.
- Syntax placeholders in prose (`[[link]]`, `[[skill-name]]`). They live outside the scanned trees and are unaffected.
- The `skills-pi/`-only resolution of `[[review]]`/`[[code-review]]`/`[[security-review]]` — documented at TASK-071 and not a forward-reference case.

## Human test plan

- [ ] Write a forward reference into a fixture skill and confirm the lint's behaviour matches whatever was chosen — accepted, or rejected with a message that names the fix
- [ ] Create the named skill in the fixture and confirm the staleness check fires, so a shipped skill cannot sit behind a forward-reference declaration forever
- [ ] Confirm an ordinary dangling wikilink — a typo, not a declared forward reference — still fails, since that is the defect check 2 exists to catch

## Implementation plan

_Populated by `/tasks plan TASK-074` — leave empty until then._
