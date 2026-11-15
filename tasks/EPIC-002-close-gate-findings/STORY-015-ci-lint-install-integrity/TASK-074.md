---
id: TASK-074
parent: STORY-015
feature: null
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: done
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
picked-by: fix-next
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

## Decision (2026-11-15, the user)

Accepted as proposed: **option 4, the plain-text workaround, documented, plus the rule that closes its gap.** A skill
not built yet is named in plain text; the task that builds it carries the upgrade of every such mention to a
`[[link]]`. No lint change.

- **Why:** the workaround's measured cost was never the plain text itself but that nothing prompted the upgrade. The
  task that builds the skill already has to exist, and one grep for the name finds every mention, so the prompt costs
  nothing and dies with the work.
- **Rejected:** a planned-skills list, a `[[name?]]` syntax and a frontmatter declaration. Each adds a declaration that
  can outlive its reason, plus a staleness check and test cases to police it, for a case measured once in the repo's
  history (`domain`, three days) and absent today.
- **Where:** `AGENTS.md` alone, beside the cross-skill reference rule and on the new-skill testing bullet. Not in
  `/tasks new`: that verb serves every consumer repo, and "a task that builds a skill" is this repo's kind of work.

## Acceptance criteria

- [x] A forward reference to a not-yet-built skill can be written **inside `skills/`** without failing the lint, or the task records that the plain-text workaround is the accepted answer and why — the plain-text workaround is the accepted answer, with the upgrade rule; why: § Decision
- [x] If a mechanism lands, it **detects its own staleness**: once the named skill exists, the declaration is reported so the reference gets upgraded to an ordinary link — no mechanism landed; the building task's upgrade criterion takes staleness's place (d074)
- [x] Exercised against a **fixture**, not a real forward reference — there is no live instance today, and the outcome says so plainly rather than implying one was found — d074, an invented skill library; no live forward reference exists in `skills/` today
- [x] The choice among the options above is stated with the rejected alternatives, per this repo's own bar for a recorded decision — § Decision, and the `AGENTS.md` entry
- [x] `skills-lint.sh` change carries a `skills-lint-test.sh` case that **fails without it**, and the negative assertions require the section to have run — not applicable: no lint change, by decision
- [x] `skills-lint` and `skills-lint-test` both green

## Out of scope

- The scope of the wikilink check outside `skills/` — **TASK-043**, closed. That settled the claim; this is the enforcement that stays.
- Syntax placeholders in prose (`[[link]]`, `[[skill-name]]`). They live outside the scanned trees and are unaffected.
- The `skills-pi/`-only resolution of `[[review]]`/`[[code-review]]`/`[[security-review]]` — documented at TASK-071 and not a forward-reference case.

## Human test plan

- [x] Write a forward reference into a fixture skill and confirm the lint's behaviour matches whatever was chosen — accepted, or rejected with a message that names the fix
  - **Passed 2026-11-15**, cold runner: `claude -p --disable-slash-commands --permission-mode acceptEdits` in
    `%LOCALAPPDATA%/Temp/d074`, the cwd holding only `brief.txt` and an invented repo (this `AGENTS.md`, two skills
    naming a planned `term-keeper` in plain text, a task to build it whose criteria do not mention links); the
    coldness probe listed no skills. The brief said only "do TASK-007 and whatever the repo's rules require".
    The plain-text form is accepted (check 2 reads only `[[…]]`); the linked form is rejected `no such skill`,
    a message that does not name the plain-text fix — recorded in the Outcome, not changed.
- [x] Create the named skill in the fixture and confirm the staleness check fires, so a shipped skill cannot sit behind a forward-reference declaration forever
  - **Passed 2026-11-15, as the rule chosen replaces it:** there is no declaration to go stale. Building
    `term-keeper`, d074's runner added the criterion *every plain-text mention … is a `[[term-keeper]]` link*,
    citing the rule, and upgraded both mentions; its "left undecided" section raised nothing about them.
- [x] Confirm an ordinary dangling wikilink — a typo, not a declared forward reference — still fails, since that is the defect check 2 exists to catch
  - **Passed 2026-11-15:** check 2 is unchanged and `skills-lint-test.sh`'s `unknown wikilink` case (`m_bogus`, `[[no-such-skill]]`)
    still fails it.

## Implementation plan

Inline, from the decision above: one rule in `AGENTS.md`, pointed at from the new-skill testing bullet.

## Outcome

- **`AGENTS.md` § *Framework / stack*, cross-skill references:** a skill not built yet is named in plain text, and the
  task that builds it upgrades every mention to a `[[link]]`, found by one grep. The three mechanisms are named as
  rejected, with why.
- **§ *Testing*, the new-skill bullet:** points at that rule, so a task building a skill meets it where it already looks.
- **No lint change.** No live forward reference exists in `skills/` today; d074 used an invented one.

**A gap, recorded rather than changed:** check 2 rejects a link to an unbuilt skill as `no such skill`, which does
not name the plain-text fix. Changing the message is a lint change, which the decision ruled out.

**Close gate (inline; `AGENTS.md` only):**
- **Standards:** the rule beside the one it qualifies; the testing bullet a pointer, not a copy.
- **Intent:** criteria met, the mechanism criteria by the decision's answer.
- **Correctness:** d074; check 2 untouched and its `m_bogus` case passing.
- **Layer parity, security, comments:** not applicable.
- **CI:** `skills-lint` and `skills-lint-test` pass locally; main is unpushed.
- **Specs:** none affected: no skill file changed.

## Progress log

- step 2 — picked; a decision task, taken by the user's choice of order (TASK-024, then this)
- step 4 — decided by the user 2026-11-15: option 4 with the upgrade rule
- step 5 — the rule in `AGENTS.md`, with the testing bullet's pointer
- step 6 — behavioural: d074 (the runner upgraded both mentions unprompted); lint and lint tests green
- step 7 — no spec affected
- step 8 — closed inline; commit in git log
