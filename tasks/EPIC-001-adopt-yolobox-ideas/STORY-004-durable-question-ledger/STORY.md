---
id: STORY-004
parent: EPIC-001
# status: planned | in-progress | done | cancelled
status: planned
created: 2026-08-18
---

# The durable question ledger — make `/feature new` survive a session reset

## User story

As someone charting an idea too big for one sitting, I want the questions I have not answered yet to
persist with their dependencies, so that reopening the feature tomorrow resumes at the frontier
instead of starting the interview over.

## Behaviour

- **The gap is an asymmetry, not a missing skill.** `decisions.md` is a durable, stateful ledger of resolved decisions; `idea.md`'s `## Open questions distilled from the grill` is a prose bullet list with no state, no edges, no claim. Reopen a feature and the answers are on disk while the frontier is gone with the conversation.
- That bullet list becomes a **table**: `id · question · type · blocked-by · state · claimed-by`. That single change yields blocking edges, a frontier query (state open and every blocker resolved), and a claim marker so parallel sessions do not collide.
- `/feature new` grills the frontier it can reach, then **writes the rest down as open questions with edges** instead of losing them. `/tasks spawn` is the precedent for the move.
- `/feature pick` — already the front door to an existing feature, already routing on state — gains one branch: open questions outstanding, resolve the next frontier one. **No new verb, no new skill, no new tree.**
- **`grill-me` switches from one-question-at-a-time to frontier rounds**: ask every question whose prerequisites are settled in one numbered round, each with a recommended answer, then recompute the frontier from the replies. Keep the existing `## Resolved decisions` emit block — it is what makes the grill composable, and the yolobox original has no equivalent.
- **Facts are the agent's job; decisions are the user's.** A frontier question needing an environment fact dispatches a sub-agent rather than asking. That does not block the round — only the questions downstream of it wait.
- `research` becomes a **question type** that dispatches a sub-agent, not a skill of its own.
- Fog stays as prose: a table row is for a question you can *state* precisely, answerable or not; anything vaguer stays in the section until it sharpens. `## Out of scope (initial)` already exists and keeps its meaning — ruled-out scope never graduates into a question.

**Why no separate map tree:** all four yolobox ticket types already have a home here — grilling maps
to `grill-me`, prototype to `/feature prototype`, task to `/tasks spawn`, research to a sub-agent.
The feature folder is the map.
