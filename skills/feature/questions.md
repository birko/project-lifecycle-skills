# Open questions — the table in `idea.md`

**The one owner of the open-question table**: its columns, its states, the frontier, and what earns a row.
Every verb or skill that writes or reads the table points here. Point at it, never copy it: a copy goes
wrong silently the moment a state or a column is added here.

The table exists because of an asymmetry. `decisions.md` keeps resolved choices durably, while the
questions a grill raised and did not reach used to be a prose list with no state and no edges. Reopen the
feature in a new session and the answers were on disk while the frontier was gone with the conversation.

## The table

It lives in `idea.md` § *Open questions distilled from the grill*:

| id | question | type | blocked-by | state | claimed-by |
|----|----------|------|------------|-------|------------|
| Q1 | Who may edit a count after it is submitted? | decision | — | open | Dana on 2026-10-06 |
| Q2 | Does an edit after submission notify the warehouse lead? | decision | Q1 | open | — |
| Q3 | Which barcode formats does the current scanner firmware read? | research | — | resolved → D4 | — |

| Column | Holds |
|---|---|
| `id` | `Q1`, `Q2`, … numbered within the feature, in the order the questions were raised. Never reused, never renumbered: edges point at ids. |
| `question` | One sentence, ending in `?`. |
| `type` | **The test: could two careful people, each looking it up, arrive at different correct answers?** No → `research`: it has one discoverable answer (what the code already does, what an API returns, what version ships), so it is looked up, never asked. Yes, because the answer is a trade-off or a preference → `decision`: it is the user's to make. A question that needs both (look it up, then choose) is a `research` question with a `decision` question blocked by it. |
| `blocked-by` | The ids this question cannot be answered before, comma-separated, or `—`. |
| `state` | One value from § *States*. |
| `claimed-by` | `—`, or who is answering it right now: `<name> on <YYYY-MM-DD>`. See § *Claims*. |

## States

| State | Means | Set by |
|---|---|---|
| `open` | Raised and not yet answered. **`open — lookup failed: <why>`** is the same state, for a `research` question whose lookup found nothing or found answers that disagree. It stays on the frontier and is put to the user next, never looked up again blind. | `/feature new` when the grill raises a question it does not resolve; the grill, when a lookup fails. |
| `resolved → Dn` | Answered. The answer is decision `Dn` in `decisions.md`, written there as a `proposed` row. An answer with no decision row is written into the question's row as `resolved — <the answer>` instead: a `research` fact that decides nothing, or an answer recorded before this table existed, which the upgrade below carries over without inventing a decision for it. | `/feature new` when the grill resolves a question it raised; `/feature pick`'s resume branch; the upgrade below. |
| `dropped — <reason>` | No longer worth answering, because another answer made it moot. **Dropping removes its id from every other row's `blocked-by`**, so a dropped question never blocks anything. | `/feature pick`'s resume branch, when the user rules it moot. |

No other value is legal, and no state is set by hand.

## Claims

`claimed-by` stops two sessions answering the same question. It is a working note about who is on a question
**now**, not part of its state.

- **Who claims:** the step that puts a question to the user (`/feature pick`'s resume) writes `<name> on <today>`
  just before putting it. The name is `git config user.name`, or `unnamed session` when that is empty.
- **Released when:** the question is resolved or dropped (the claim goes back to `—` with the state change), or the
  session stops — the user stops, or no answer comes — and then it clears **every claim it wrote itself**, and
  no others.
- **Stale:** a claim dated **before today** is stale. A session that crashed never released its claim, and a claim
  that cannot expire is a deadlock, so a stale claim may be taken over. The taker says so: `taking over Q4 —
  claimed by <name> on <date>`.
- **A live claim is respected:** a question claimed today by another name is on the frontier, but is not offered.
  Report it: `Q4 is being answered by <name> (claimed today)`.
- **What a claim can see:** sessions reading the same file. Sessions in other clones see it only once it is
  committed and pulled, so a claim is a courtesy, not a lock.

A table written before this column existed has five columns. Read every row of it as `claimed-by: —`, and write the
sixth column the next time the table is written.

## The frontier

**The frontier is every row whose state is `open` and every id in whose `blocked-by` is `resolved`.** These
are the questions that can be answered now. Compute it fresh from the table every time; never store it.

- `blocked-by: —` has no blockers, so an `open` row with `—` is on the frontier.
- A `blocked-by` id that is not in the table is a **broken edge**. It is not resolved, so its row is off the
  frontier; report it by id.
- **Open rows but an empty frontier** means every open question waits on another open question or on a broken
  edge. Report that as itself, naming what each one waits on. It is never the same report as *no open questions*.

## What earns a row — and what does not

- **A row is a question stated precisely enough that one answer would settle it**, whether or not anyone can
  answer it yet. If you cannot write it as one sentence ending in `?` whose answer is a choice or a fact, it is
  not a row yet.
- **Fog stays prose.** A concern too vague to state that way goes in the bulleted *Fog* list under the table,
  until it sharpens into a question. A table that swallows fog fills with rows nobody can act on; a table that
  refuses a precise but unanswered question loses exactly what it exists to keep.
- **`## Out of scope (initial)` is neither.** Scope ruled out is decided, not open. It never becomes a row and
  never becomes fog.

## Current or pre-table

A feature written before this table existed has a bulleted or prose list in that section. Find the section by its
heading **starting** `## Open questions` — older files reword the rest (*"Open questions — resolved 2026-07-28"*).
**Tell the two apart by the section's table header**: a header row starting `| id | question | type | blocked-by |
state |` is a current table, with or without the `claimed-by` column after it, and anything else is a pre-table
section. Never read a pre-table section as an empty
frontier. It holds questions in a shape no frontier can be computed from, so say exactly that.

The three states a reader reports, each with its own line:

| The section | Report |
|---|---|
| has the table | `open questions: current` |
| is pre-table | `open questions: pre-table — N item(s) in the earlier format` |
| is pre-table and carries the declined line (below) | `open questions: pre-table, kept by choice on <date>` |

## Bringing a pre-table section up to date

**In place, adding what is missing and re-deciding nothing.** Every item in the old list goes into a row or into the
Fog list, and `decisions.md` is not touched. **The old list itself is kept, word for word, in a collapsed block under
the table** — `<details><summary>Before the question table (kept verbatim)</summary>` … `</details>` — because an
item often carries more than its question: an accepted limitation, a deferral, a note that it reversed something.
The rows make the frontier computable; the block keeps everything the rows cannot hold. Walk the items in order
and number the rows in that order:

| The item | Becomes |
|---|---|
| names a decision (`→ D3`, `(**D3**)`) | a row `resolved → D3` |
| gives an answer and names no decision (`→ shows both`, a struck-through question with its answer) | a row `resolved — <the answer, as written>` |
| a precise question with no answer | a row `open`. Its `blocked-by` is `—` unless the item itself names what it waits on: **never invent an edge** |
| (every row) | `claimed-by: —`. Nobody holds an upgraded question |
| too vague to be a question (§ *What earns a row*) | a Fog bullet, verbatim |
| the template's own placeholder lines (`Question / assumption surfaced → …`, a bare `…`) | left out of the rows and the kept block, and counted in the report. They are not content |

**The `question` cell keeps the item's question as written** — the text before its `→`, or the whole item when it
has none — even when that is not a full sentence. Rewording it would be deciding what the question meant.
`type` is `research` only when the item plainly asks for a fact, and otherwise `decision`. The heading stays as it is.

**Report which happened, in one of two lines, never the same one:** `open questions: brought up to date — N rows
(a resolved → D, b resolved with an answer, c open), F fog, P placeholder line(s) removed`, or, on a file that already
had the table, `open questions: current`.

**Offered, never imposed.** A user who says no gets this line written directly under the section's heading, so
the next run reads it and does not ask again:

> _Kept in the earlier format by choice on <YYYY-MM-DD> — remove this line to be offered the question table again._

No answer is not a no: write nothing, and offer again next time.
