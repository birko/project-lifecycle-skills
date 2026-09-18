---
id: FEATURE-002
created: 2026-09-18
owner: František Bereň
# status — one of: idea, review (built, sign-off pending), done, dropped, superseded
status: idea
---

# Comment discipline — keep the source free of everything that belongs elsewhere

> Stakeholder-readable. A project manager or end user should understand the problem and the proposed shape without reading any code.

## Problem

Agents write too many comments, and the bad ones share a shape: they are **records kept in the
wrong place**. A history of what changed and when — which the version control system already holds
perfectly. A test note, or a defect found in passing — which belongs on a ticket where somebody
will actually see it. A long argument for why a choice was made — which belongs in a decision
record. Ten lines of prose stacked above a single constant.

Each of these costs twice. The source gets harder to read, because the thing you came to
understand is now buried. And the information itself is **worse off** where it landed: a defect
written in a comment is invisible to anyone planning work, and this project already treats that
exact case as a defect (`tasks/SKILL.md:384` — a comment saying *"should be fixed properly one
day"* is work that silently disappears).

Nothing in the skill set says any of this today. A new project is handed a rulebook covering the
stack, structure, naming and testing — and nothing about comments at all.

## Proposed shape

Add the rule to the rulebook every new project is seeded with, and add a command that can find and
fix violations in code that already exists.

The rule is **not a length limit**. A long comment is fine when every line of it carries something
a reader genuinely cannot get elsewhere; a three-line comment is bad when none of it does. Since
every author believes their own comment is necessary, the rule ships with a check anyone can apply
the same way — delete the line and ask what a competent reader actually loses:

| The content lives in… | …then |
|---|---|
| the code itself | it restates; delete |
| version history | it is a changelog; delete |
| the ticket | it is a finding or a test note; delete |
| a decision record or `docs/` | it is an essay; leave a one-line pointer |
| **nowhere else** | **keep it, at whatever length it needs** |

The command points at either the work in hand or the whole project. When it finds something that
fails the check but is the **only** record of what it says, it does not simply delete it — it
files it where it belongs first, then leaves a one-line pointer behind.

## Open questions distilled from the grill

_Filled from the [[grill-me]] interview at `/feature new`. Each resolved branch becomes a row in
[decisions.md](decisions.md) with state `proposed`, ready for `/feature decide`._

- **Is "1–3 lines" a cap?** No — the requester corrected this directly: *"sometimes a comment can be
  longer but only if it has some necessary info and not unnecessary things."* So the rule is
  necessity per line, and length is a symptom rather than the offence → **D1**.
- **Then how is "necessary" decidable?** It is not, stated baldly — every author already believes it
  of their own comment. It needs a test with the same shape as this project's other rules: one
  question anybody answers identically → **D2**.
- **Does the abstract test replace the concrete list?** No. The named cases — changelog, QA log,
  rationale essay above a declaration, a ten-line block on one constant — stay, because a test
  without instances gets re-invented per reader → **D3**.
- **Does this repository's own code survive the rule?** Measured before proposing it: the lint
  script is 288 lines, 123 of them comments (42%), with one unbroken 35-line block. Under a length
  cap it is a pile of violations; under D1/D2 it passes, because nothing else in the repository
  records what those lines say — one of them is what the worktree design (FEATURE-001) was
  reasoned from. Recorded so nobody later "cleans" it → **D10**.
- **Where does the rule live?** In the rulebook template every new project is seeded from → **D4**.
- **What about projects already adopted?** They do not get it. The adopter reconciles which
  documents exist and what shape they are in; it explicitly does not judge whether prose inside a
  hand-written document is current. That is a real gap, and the command is what closes it → **D5**.
- **Does this need a new command at all, when the conventions linter already checks diffs against
  the rulebook?** Yes — the linter only ever sees code somebody is currently changing, and the
  whole point is the ten-line block written two years ago in a file nobody touches → **D6, D7**.
- **Which scope?** Both: *"would like to be able to scan the whole repo but also just the files it
  touched by work in the diff."* Default is the work in hand; a switch widens it → **D7**.
- **How does it sit in the close gate?** As its own axis, reported beside the others and never
  merged into one ranked list → **D8**.
- **And when the comment is the only copy?** File it where it belongs, then delete and leave a
  pointer. Never destroy the only record of something → **D9**.

## Out of scope (initial)

- **A length limit.** Explicitly rejected by the requester — see D1.
- **Auto-fixing the whole project in one unreviewed pass.** The diff would be too large to read,
  which is exactly when a deleted "why" slips through unnoticed.
- **Comment style** — formatting, doc-comment syntax, language. This feature is about *what a
  comment is for*, not how it is punctuated.
- **Making the check CI-enforced.** The seeded rulebook already notes these gates are agent-run,
  not CI-enforced; changing that is a separate argument.

## Prototype

_Record the prototype decision explicitly — never leave it blank (see SKILL.md)._

**Pending** — to be settled at `/feature prototype`. Leaning **Built, as a markdown wireframe**:
the command's report is the whole user surface, and what makes it usable or not is whether a
finding shows you *which row of the test caught it* and *what it would do about it* before you say
yes. That is cheap to mock and expensive to get wrong. The rule half needs no prototype — it is
prose in a template.
