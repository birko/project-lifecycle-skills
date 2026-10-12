---
name: grill-me
description: Interview the user relentlessly about a plan or design until reaching shared understanding, resolving each branch of the decision tree. Use when user wants to stress-test a plan, get grilled on their design, or mentions "grill me".
---

Interview me relentlessly about every aspect of this plan until we reach a shared understanding. Walk down each branch of the design tree, resolving the dependencies between decisions. For each question, provide your recommended answer.

## Ask in rounds, not one question at a time

Keep a list of every question as it is raised: give it an id (`Q1`, `Q2`, …) and note which earlier questions it
cannot be answered before. Each **round** asks the questions **nothing is still waiting on** — the frontier, as
[[feature]] defines it in `questions.md` § *The frontier*. Inside a feature that table is on disk in `idea.md`;
outside one, keep the same list in the conversation. The grill works on any plan, not only on features.

- **Open the round the way a person would:** a sentence or two that responds to what the user just said — the
  plan, or what their last answers settled — before any question. A round that starts with question 1 reads as a
  form, however good the questions are.
- **Number the round's questions, and give every one your recommended answer** with its one-line reason. The
  recommendation is what keeps a round answerable: agreeing is one word, disagreeing is one sentence.
- **Never tell the user how to format a reply.** No reply templates, no "answer like this". They answer in their
  own words, and you work out which question each part answers.
- **A round of one is a plain question**, asked the way a person would ask it, with no numbering and no form.
- **At most five questions in a round.** When more are on the frontier, ask first the ones the most other
  questions wait on, and mention in passing that more will follow once these are settled. Don't close on a
  count that makes the round read as page one of a questionnaire.
- **After the replies, recompute the frontier and derive the next round from it.** Never carry the last round
  forward by habit. A question left unanswered is still on the frontier and comes back; a question an answer
  made moot is dropped, and says why.
- **A round nobody can answer ends the grill.** When no user is present (the caller says the run is unattended,
  or the runtime has no way to put a question), do not repeat the round and do not answer it yourself. Close as
  § *When the grill is done* says. Your recommendations stay recommendations, and every question still on the
  list is written as open.

## Facts are looked up; decisions are asked

Classify every question with the test in [[feature]]'s `questions.md` (the `type` column): one discoverable
answer → `research`; a trade-off or a preference → `decision`.

- **A `research` question is never put to the user.** Look it up: read the code, run the command, check the
  documentation, or dispatch a sub-agent when the runtime has one. Asking a human to go and look something
  up is how a grill stalls.
- **A lookup does not hold up its round.** Ask the round's `decision` questions while the lookups run; only the
  questions waiting on a lookup wait for it. When a lookup lands, say what it found at the top of the next
  round (*"Looked up: Q3 — the scanner reads EAN-13 and Code 128"*).
- **Write the result where the next session will find it.** Inside a feature, record it in the table as
  `resolved — <the fact>`, so a resumed grill does not look it up again.
- **A lookup that finds nothing, or finds answers that disagree, is not dropped.** Mark it
  `open — lookup failed: <why>` and put it to the user in the next round, saying what was tried: *"I couldn't
  establish Q3 — the firmware notes list two versions. Do you know which one ships?"*

## When the grill is done — emit the resolved decisions

The grill ends when no unresolved branch remains (every open question has an answer or an explicit "defer"), when the user calls it off, or when a round has nobody to answer it (§ *Ask in rounds*). Whichever way it ends, close with a **`## Resolved decisions`** block, one line per decision, followed by a **`## Still open`** block listing every question that was not settled:

```
## Resolved decisions
- <topic> → <choice> (<one-line rationale>)
- <topic> → deferred: <unblock condition>

## Still open
- <topic> → not answered (recommended: <your recommendation>, not chosen)
- <topic> → not answered (lookup failed: <why>)
- <topic> → not reached
```

- **A choice goes under `## Resolved decisions` only when the user gave it or agreed to it.** A recommendation
  nobody answered goes under `## Still open`. Callers turn every `## Resolved decisions` line into a decision,
  so a recommendation written there becomes a decision nobody made.
- **Always emit both blocks.** When nothing is open, `## Still open` holds the single line `- none`, and an
  empty `## Resolved decisions` holds `- none` too. A missing block cannot be told apart from a grill that
  forgot to write it.

These blocks are the artifact callers consume — [[new-project]]'s scope grill folds the resolved lines into README/CLAUDE.md and reports the open ones, and [[feature]] `new` turns each resolved line into a `proposed` row in `decisions.md` and writes each open one as an `open` question. Without these blocks the interview evaporates into chat history; with them, any caller gets a stable shape.
