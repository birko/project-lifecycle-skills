---
area: idea-interrogation
generated-at: 07de65705efd05a13f9f35e12a85cbefd7482b40
generated-on: 2026-10-06
sources:
  - skills/grill-me/SKILL.md
shaped-by: []
shaped-by-derived: true
shaped-by-unresolved: 5
---

# Interrogating any plan — feature or not — until every unresolved branch is decided

## Purpose

Idea interrogation is a structured interview. It takes a plan or a design and questions the user about it, branch by branch, until every open choice is either answered or explicitly deferred. Each round offers a recommended answer for every question, so replying stays cheap. Factual questions are looked up rather than asked, so the user only spends time on real trade-offs. The interview ends with a fixed-shape list of resolved decisions that a calling skill can consume. It works on any plan. Feature capture (`/feature new`) and the optional project-scope grill in project scaffolding both use it, and its question bookkeeping follows the open-question table the feature lifecycle owns.

## Requirements

### Requirement: Interview every branch of the plan, with a recommendation for each question

The system SHALL interview the user about every aspect of the plan, walking each branch of its design tree and resolving the dependencies between decisions, and SHALL provide its own recommended answer for every question it asks.

#### Scenario: A plan with dependent choices

- **Given** a plan whose storage choice depends on whether it must work offline
- **When** the grill runs
- **Then** both choices are raised as questions, each with a recommended answer, and the storage question is not settled before the offline question

### Requirement: Track every question with an id and the questions it waits on

The system SHALL record every question as it is raised, giving it an id (`Q1`, `Q2`, …) and noting which earlier questions it cannot be answered before. Inside a feature, this list is the open-question table on disk in `idea.md`. Outside a feature, the same list is kept in the conversation. The grill SHALL work on any plan, not only on features.

#### Scenario: Grilling inside a feature

- **Given** the grill is invoked by `/feature new`
- **When** a question is raised
- **Then** it is recorded with its id and `blocked-by` edges in the feature's open-question table

#### Scenario: Grilling a plan that is not a feature

- **Given** the user asks to be grilled on a migration plan with no feature folder
- **When** questions are raised
- **Then** the same id-and-edges list is kept in the conversation, and the grill proceeds normally

### Requirement: Each round asks the frontier

The system SHALL ask, in each round, the questions that nothing is still waiting on: the frontier, as the feature lifecycle's `questions.md` § *The frontier* defines it.

#### Scenario: A question blocked by an unanswered one

- **Given** Q2 is blocked by Q1, and Q1 is open
- **When** a round is composed
- **Then** Q1 is asked and Q2 is not

### Requirement: Open a round conversationally, and number its questions with recommendations

The system SHALL open each round with a sentence or two responding to what the user just said, before any question. It SHALL number the round's questions and give each one a recommended answer with a one-line reason. A round holding a single question SHALL be asked as a plain question, with no numbering and no form.

#### Scenario: A round of three

- **Given** three questions are on the frontier after the user described the plan
- **When** the round is asked
- **Then** it opens by responding to the plan, then lists three numbered questions, each with a recommended answer and its reason

#### Scenario: A round of one

- **Given** exactly one question is on the frontier
- **When** the round is asked
- **Then** it is a plain question asked the way a person would ask it, with no number and no form

### Requirement: Never prescribe how the user replies

The system SHALL NOT give the user a reply template or tell them how to format an answer. The user answers in their own words, and the grill works out which question each part of the reply answers.

#### Scenario: A free-form reply covering two questions

- **Given** a round asked Q1 and Q2
- **When** the user replies in one sentence that settles both
- **Then** the grill attributes each part of the sentence to its question, without asking for a reformatted reply

### Requirement: At most five questions per round, ordered by what waits on them

The system SHALL ask at most five questions in a round. When more than five are on the frontier, it SHALL ask first the ones the most other questions wait on, and SHALL mention in passing that more will follow once these are settled. It SHALL NOT close the round with a count that makes it read as page one of a questionnaire.

#### Scenario: Eight questions on the frontier

- **Given** eight questions are on the frontier, and Q3 and Q6 each block three others
- **When** the round is composed
- **Then** it asks five questions including Q3 and Q6, and mentions that more will follow without saying "5 of 8"

### Requirement: Recompute the frontier after every reply

The system SHALL recompute the frontier after the replies and derive the next round from it, never carrying the previous round forward by habit. A question left unanswered SHALL stay on the frontier and come back. A question an answer made moot SHALL be dropped, with the reason stated.

#### Scenario: An unanswered question

- **Given** a round asked Q1 and Q2, and the reply answered only Q1
- **When** the next round is composed
- **Then** Q2 is asked again, alongside any question Q1's answer unblocked

#### Scenario: A moot question

- **Given** Q4 asked which sync protocol to use, and the answer to Q1 removed syncing from scope
- **When** the next round is composed
- **Then** Q4 is dropped and the grill says it was dropped because syncing is out of scope

### Requirement: Classify each question as research or decision

The system SHALL classify every question with the test in the feature lifecycle's `questions.md` (the `type` column): a question with one discoverable answer is `research`; a trade-off or a preference is `decision`.

#### Scenario: What the code already does

- **Given** a question asking which database the project currently uses
- **When** it is classified
- **Then** it is `research`

#### Scenario: A preference

- **Given** a question asking whether to favour a smaller install or faster startup
- **When** it is classified
- **Then** it is `decision`

### Requirement: Look up research questions instead of asking them

The system SHALL NOT put a `research` question to the user. It SHALL look the answer up by reading the code, running a command, checking documentation, or dispatching a sub-agent where the runtime has one.

#### Scenario: A discoverable fact

- **Given** a `research` question about which barcode formats the scanner firmware reads
- **When** the round is composed
- **Then** the question is not asked; the grill looks it up instead

### Requirement: A lookup does not hold up its round

The system SHALL ask the round's `decision` questions while lookups run. Only questions waiting on a lookup SHALL wait for it. When a lookup lands, the system SHALL report what it found at the top of the next round.

#### Scenario: A lookup runs alongside decisions

- **Given** Q3 is `research` and Q1 and Q2 are `decision`, none blocked
- **When** the round is asked
- **Then** Q1 and Q2 are asked while Q3 is looked up, and the next round opens with *"Looked up: Q3 — …"*

### Requirement: Record a lookup's result where the next session will find it

The system SHALL, inside a feature, record a lookup's result in the open-question table as `resolved — <the fact>`, so a resumed grill does not look it up again.

#### Scenario: A resumed grill

- **Given** a previous session recorded Q3 as `resolved — the scanner reads EAN-13 and Code 128`
- **When** the grill resumes
- **Then** Q3 is not looked up again

### Requirement: A failed lookup is put to the user, not dropped

The system SHALL, when a lookup finds nothing or finds answers that disagree, mark the question `open — lookup failed: <why>` and put it to the user in the next round, saying what was tried.

#### Scenario: Conflicting sources

- **Given** the firmware notes list two versions for Q3
- **When** the next round is asked
- **Then** it includes *"I couldn't establish Q3 — the firmware notes list two versions. Do you know which one ships?"*, and Q3 reads `open — lookup failed: <why>`

### Requirement: The grill ends when nothing is unresolved, or when the user stops it

The system SHALL end the grill when no unresolved branch remains, meaning every open question has an answer or an explicit "defer", or when the user calls it off.

#### Scenario: The user calls it off

- **Given** two questions are still open
- **When** the user says to stop
- **Then** the grill ends and emits its resolved-decisions block

### Requirement: Close with a `## Resolved decisions` block

The system SHALL close every grill, whether completed or called off, with a `## Resolved decisions` block holding one line per decision, in one of two shapes: `- <topic> → <choice> (<one-line rationale>)` or `- <topic> → deferred: <unblock condition>`. This block is the artifact callers consume: project scaffolding folds its lines into the README and the agent guide, and `/feature new` turns each line into a `proposed` row in `decisions.md`.

#### Scenario: A completed grill

- **Given** the grill resolved the storage choice and deferred the sync choice until offline use is confirmed
- **When** it ends
- **Then** it emits `## Resolved decisions` with `- storage → SQLite (single-user, offline)` and `- sync → deferred: offline use confirmed`
