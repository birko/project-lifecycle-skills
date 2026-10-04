---
id: {{ID}}
created: {{CREATED}}
owner: {{OWNER}}
# status — one of: idea, review (built, sign-off pending), done, dropped, superseded
status: {{STATUS}}
---

# {{TITLE}}

> Stakeholder-readable. A project manager or end user should understand the problem and the proposed shape without reading any code.

## Problem

What hurts today? Who feels it (PM, end user, support)? What's the cost of doing nothing?

## Proposed shape

The idea in one or two paragraphs — what we'd build, in plain language. Not a spec.

## Open questions distilled from the grill

_Filled at `/feature new` with every question the [[grill-me]] interview raised. Each one it resolved is a `proposed` row in [decisions.md](decisions.md); each it did not reach stays `open` here, so the next session resumes at the frontier. The columns, states and frontier are defined in the feature skill's `questions.md`. Example rows below — `/feature new` replaces them._

| id | question | type | blocked-by | state |
|----|----------|------|------------|-------|
| Q1 | Who may edit a count after it is submitted? | decision | — | open |
| Q2 | Does an edit after submission notify the warehouse lead? | decision | Q1 | open |

**Fog** — concerns not yet precise enough to state as a question:

- …

## Out of scope (initial)

- What we already know we're NOT doing — these often become `removed` decisions so the ledger records the choice.

## Prototype

_Record the prototype decision explicitly — never leave it blank (see SKILL.md)._
- **Built** → link the `prototype.html` / `.md` / `prototype-states.html` / spike. **Built, then deleted** → which decisions it answered and the last commit that held it. **Skipped** → give the reason
  (e.g. "headless logic — the test suite is the proof"). **Pending/N/A** for stubs or superseded.
- Lean toward actually building one for pure look/UX features, and a state-model playground when the feature adds or changes states; lean toward skipping for other headless logic.
