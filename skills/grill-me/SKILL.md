---
name: grill-me
description: Interview the user relentlessly about a plan or design until reaching shared understanding, resolving each branch of the decision tree. Use when user wants to stress-test a plan, get grilled on their design, or mentions "grill me".
---

Interview me relentlessly about every aspect of this plan until we reach a shared understanding. Walk down each branch of the design tree, resolving dependencies between decisions one-by-one. For each question, provide your recommended answer.

Ask the questions one at a time.

If a question can be answered by exploring the codebase, explore the codebase instead.

## When the grill is done — emit the resolved decisions

The grill ends when no unresolved branch remains (every open question has an answer or an explicit "defer") or the user calls it off. Either way, close with a **`## Resolved decisions`** block — one line per decision:

```
## Resolved decisions
- <topic> → <choice> (<one-line rationale>)
- <topic> → deferred: <unblock condition>
```

This is the artifact callers consume — [[new-project]]'s scope grill folds these lines into README/CLAUDE.md, and [[feature]] `new` turns each into a `proposed` row in `decisions.md`. Without this block the interview evaporates into chat history; with it, any caller gets a stable shape.
