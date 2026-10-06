---
id: TASK-117
parent: STORY-004
feature: null
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: done
priority: P2
assignee: agent
created: 2026-09-08
depends-on: [TASK-115]
blocks: []
findings: []
pr: null
github-issue: null
jira-key: null
---

# `grill-me` switches from one question at a time to frontier rounds

## Context

**Checked 2026-10-04 by TASK-195** against `skills/tasks/slicing.md`: it passes H1–H3 once TASK-115 lands the
table and its frontier query, so its edge is now TASK-115 alone. **The size signal trips** (≥6 criteria), and
it stays one task because the dispatch rule (a dispatched question does not block its round) is part of the
round design: rounds without it stall on the first lookup, which is the one-at-a-time behaviour this task removes.

`grill-me` today asks strictly one question at a time. The story changes it to **frontier rounds**: ask
every question whose prerequisites are settled in one numbered round, each with a recommended answer,
then recompute the frontier from the replies.

**Keep the `## Resolved decisions` emit block.** The story is explicit that it is what makes the grill
composable — [[new-project]]'s scope grill folds those lines into README/CLAUDE.md and [[feature]] `new`
turns each into a `proposed` row. The yolobox original has no equivalent, and losing it would trade a
working integration for a cosmetic change.

**The risk this task carries:** one-at-a-time is what makes a grill feel like a conversation. A round of
nine questions is a form. The recommended-answer-per-question rule is what keeps it answerable — it must
survive the change, not be dropped as round overhead.

### Merged in 2026-09-26: TASK-118 — `research` becomes a question type that dispatches a sub-agent, not a skill of its own

_Merged because a research question not blocking its round is part of designing the frontier rounds. The original file stays, cancelled, at `tasks/EPIC-001-adopt-yolobox-ideas/STORY-004-durable-question-ledger/TASK-118.md`._

The story's principle: **facts are the agent's job; decisions are the user's.** A frontier question that
needs an environment fact — what version ships, what the API returns, what the repo already does —
**dispatches a sub-agent rather than asking the user.** Asking a human to go and look something up is
how a grill stalls.

Two consequences, and the second is the one that is easy to miss:

- `research` is a **question type**, a value in TASK-115's `type` column. Not a verb, not a skill. The
  story's argument against a separate map tree applies here too: everything already has a home.
- **A dispatched question does not block its round.** Only the questions *downstream of it* wait. A round
  that stalls on one lookup has reintroduced the one-at-a-time behaviour TASK-117 just removed.

## Acceptance criteria

- [x] A round asks every question whose prerequisites are settled, numbered, **each with a recommended
      answer** — the property that makes a round answerable rather than an interrogation
- [x] The frontier is recomputed from the replies, and the next round is derived, never accumulated
- [x] `## Resolved decisions` still emits in its current shape; its existing consumers are unchanged
- [x] A round of one is a normal outcome and reads as a question, not as a form with one field
- [x] Round size is addressed: what a runner does when the frontier is very wide, stated as a rule rather
      than left to taste
- [x] Nothing restates TASK-115's frontier query
- [x] `bash .github/workflows/skills-lint.sh` passes

*From TASK-118:*

- [x] `research` exists as a `type` value with a stated dispatch rule — what gets dispatched, what is
      asked of the user, and how a runner tells them apart
- [x] A dispatched question **does not block its own round**; only its dependents wait, and that is
      stated where a runner will read it
- [x] The fact/decision split is written as a test an agent can apply, not a principle it must intuit —
      a question with one discoverable answer is a fact; one with a trade-off is the user's
- [x] What happens when a dispatched lookup **fails or returns ambiguously** is defined; it must not
      silently become an unanswered question with no trace
- [x] The result is written back into the table, so a resumed session sees the fact rather than
      re-dispatching it
- [x] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- **The `research` type and sub-agent dispatch** — **TASK-118**, which depends on rounds existing.
- Where the questions are stored — **TASK-115**.
- `grill-me`'s use outside the feature lifecycle stays working; this task must not narrow it to features.

*From TASK-118:*

- Round mechanics — **TASK-117**.
- Making `research` a skill or a verb. The story rejects that explicitly.
- Which sub-agent is used, beyond naming the dispatch — runtime-specific and not this repo's to fix.

## Human test plan

- [x] Run a grill on a real plan with a genuinely wide frontier. Expected: the round is answerable in one
      sitting and each question carries a recommendation. Have a second person read the round cold and
      say whether it reads as a conversation or a form — withhold which answer you expect.

*From TASK-118:*

- [x] Grill a plan containing at least one question answerable only by looking at the environment.
      Expected: it is not asked of you, its answer lands in the table, and the rest of the round proceeds
      without waiting for it.


## Implementation plan

Planned inline at pick (2026-10-06).

1. **`grill-me` (rounds):**
   - A round asks every question on the frontier (defined in [[feature]]'s `questions.md`, pointed at and not copied), numbered, each with a recommended answer. A round of one is put as a plain question.
   - At most 5 per round, those with the most dependents first, with the count still waiting stated.
   - The next round is recomputed from the replies, never accumulated.
   - Outside a feature the question list lives in the conversation, so the skill is not narrowed.
   - `## Resolved decisions` is unchanged.
2. **`grill-me` (research):**
   - `research` questions are looked up (by a sub-agent where the runtime has one), never asked.
   - A lookup does not hold up its round; only its dependents wait.
   - Inside a feature the fact is written back as `resolved — <fact>`.
   - A failed or ambiguous lookup becomes `open — lookup failed: <why>` and is put to the user in the next round.
3. **`questions.md` (owner):** the fact-or-decision test is sharpened in the `type` column, and the `open — lookup failed` variant is defined (still counts as open).
4. Spec: `idea-interrogation` has no generated spec yet (TASK-080 stage 2), so nothing to re-harvest there; `feature-lifecycle` takes the `questions.md` change.
5. Drills per the human test plan.

## Progress log

- 2026-10-06 — Picked; planned inline. **`grill-me` rewritten around rounds.**
  - **The list:** questions get ids and edges as raised. The frontier is pointed at, as defined in [[feature]]'s `questions.md`, not copied. Outside a feature the list lives in the conversation, so the skill is not narrowed.
  - **The round:** numbered, each question with a recommended answer and its reason. A round of one is a plain question. At most five, those with the most dependents first.
  - **Between rounds:** the next is recomputed, never accumulated.
  - **Research:** never asked, looked up (by a sub-agent where available), and the round does not wait; only its dependents do. Inside a feature the fact is written back as `resolved — <fact>`. A failed or ambiguous lookup becomes `open — lookup failed: <why>` and is put to the user.
  - `## Resolved decisions` is byte-for-byte unchanged.
  - **`questions.md`:** the fact-or-decision **test** ("could two careful people, each looking it up, arrive at different correct answers?"; a question needing both is a `research` row blocking a `decision` row) and the `open — lookup failed` variant. **`pick.md`:** a failed lookup is marked, never dropped.
- 2026-10-06 — **Spec:** `feature-lifecycle` takes the type test and the failed-lookup rule. `idea-interrogation` (`skills/grill-me/**`) has no generated spec yet; TASK-080 stage 2 harvests it.
- 2026-10-06 — **Human test plan.** Folder `%LOCALAPPDATA%\Temp\d117`, outside every repo, with a copy of `skills/`; runners `claude -p --disable-slash-commands`. The "second person" was a cold `claude -p` reader, not a human; recorded as such. **Coldness:** both judges listed no skills.
  - **Step 1 — wide frontier** (offline mode for a warehouse PWA, run up to the first message).
    - **Round 1:** 5 numbered questions, each with a recommendation and its reason; the most-blocking first ("Most of the hard parts depend on this"); "4 more questions are waiting"; the one fact it could not look up flagged as such.
    - **Cold judge, given only the message, with the expected answer withheld:** *"It reads more like a form than a conversation, though a well-made one."* Reasons: the round suggested a reply format ("yes to 1, 3, 4; 2 → …"), had no reaction to the plan, and closed like page one of a questionnaire. **The reply format came from my own example sentence in the skill.** Fixed: no reply templates, each round opens by responding to what the user said, and remaining questions are mentioned in passing.
    - **Re-run, fresh runner and fresh judge:** the round opens with a reaction to the plan and a "Looked up:" line, with no reply syntax. Verdict: *"It's in between, closer to a conversation that has been shaped like a form"*, *"Mostly yes"* to one sitting. It still found two things form-like: the repeated "My recommendation:" label, and the runner's intro saying the design waited on two questions while it asked five. Recorded as observed; numbered rounds trade some conversational feel for throughput, which is the risk this task's Context names. Not tuned further on one reader's taste.
  - **Step 2 — environment fact, inside a feature** (git fixture; `src/scanner.config.json` holds the answer to research question Q3; Q4 waits on Q3; Q1 and Q2 are decisions).
    - Q3 was **never put to the user**: it was looked up in the config, announced ("Looked up: Q3 — … EAN-13 and Code 128; QR and Data Matrix are switched off"), and written to the table as `resolved — <fact>`.
    - Q1 and Q2 went ahead in the same round without waiting, and became D1 and D2.
    - Q4 came next, as a plain single question.
    - The same "Reply e.g. …" tic appeared here too, and the same fix covers it.
- 2026-10-06 — Close review. Intent: all 13 criteria and both test steps. Correctness: prose only. Conventions: the frontier and the type test have one owner, `questions.md`; `grill-me` points at it; ask-steps carry their wording and their no-answer path. → **done**.
