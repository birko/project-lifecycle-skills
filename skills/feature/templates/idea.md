---
id: {{ID}}
created: {{CREATED}}
owner: {{OWNER}}
status: {{STATUS}}  # idea | review (built, sign-off pending) | done | dropped | superseded
---

# {{TITLE}}

> Stakeholder-readable. A stocktaker or project manager should understand the problem and the proposed shape without reading any code.

## Problem

What hurts today? Who feels it (stocktaker, PM, end user)? What's the cost of doing nothing?

## Proposed shape

The idea in one or two paragraphs — what we'd build, in plain language. Not a spec.

## Open questions distilled from the grill

_Filled from the [[grill-me]] interview at `/feature new`. Each resolved branch becomes a row in [decisions.md](decisions.md) with state `proposed`, ready for `/feature decide`._

- Question / assumption surfaced → which decision it maps to
- ...

## Out of scope (initial)

- What we already know we're NOT doing — these often become `removed` decisions so the ledger records the choice.

## Prototype

_Record the prototype decision explicitly — never leave it blank (see SKILL.md)._
- **Built** → link the `prototype.html` / `.md` / spike. **Skipped** → give the reason
  (e.g. "headless logic — the test suite is the proof"). **Pending/N/A** for stubs or superseded.
- Lean toward actually building one for pure look/UX features; lean toward skipping for headless logic.
