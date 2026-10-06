---
area: glossary-and-adrs
generated-at: 20c038b36b869ce21fee8cdd7d30bd0a8bcdfae9
generated-on: 2026-10-06
sources:
  - skills/domain/SKILL.md
shaped-by: []
shaped-by-derived: true
shaped-by-unresolved: 5
---

# Fixing what each term means, and recording why a hard choice was made

## Purpose

This capability keeps a project's vocabulary and its settled trade-offs honest. It maintains two hand-written artifacts: `docs/glossary.md`, which states what each term means in the project's own words, and `docs/adr/NNNN-slug.md` decision records, which state *why* a hard-to-reverse choice was made so nobody re-litigates it. It is a discipline applied during a grill, a design or a code read rather than a one-shot command: four live behaviours fire on signals noticed mid-conversation, and a cold `/domain` invocation does only one narrow job. It surfaces conflicts and offers records; the user decides. Anyone naming types, writing specs or tests in the project's nouns, or asking "why is this like this?" depends on it.

## Requirements

### Requirement: Write the glossary and the decision-record directory lazily

The system SHALL NOT scaffold `docs/glossary.md` or `docs/adr/`; each SHALL appear only when there is a first term worth recording or a first record to put in it, and the glossary SHALL NOT be padded with obvious terms to look complete.

#### Scenario: Nothing ambiguous yet

- **Given** a project with no `docs/glossary.md` and no term anyone has been confused about
- **When** the discipline is applied
- **Then** no glossary file is created, because an empty glossary would claim the vocabulary was examined and found thin

#### Scenario: First record earns the directory

- **Given** a project with no `docs/adr/` directory
- **When** a decision passes the record bar and the user accepts the offer
- **Then** `docs/adr/` is created together with that record, never before it

### Requirement: Keep glossary entries free of implementation detail, behaviour claims and open questions

The system SHALL keep out of the glossary any definition that names a file, class or interface, any hand-written claim about what the code does (that is the job of harvested specs), and any open question, TODO or not-yet-precise term (those belong in a feature's `idea.md`); a good entry SHALL survive a rewrite of the code it describes.

#### Scenario: Definition names a class

- **Given** a proposed entry "Tenant — the `TenantEntity` class in `models/tenant.py`"
- **When** it is judged for the glossary
- **Then** it is rejected as implementation detail that would go stale on the next refactor

#### Scenario: Term cannot yet be stated precisely

- **Given** a term the team uses but cannot yet define
- **When** someone proposes adding it to the glossary
- **Then** it stays a question in the feature's `idea.md` rather than becoming an entry

### Requirement: A cold invocation cross-references the existing glossary against the code and nothing else

The system SHALL, when invoked as `/domain` without a mid-conversation signal, read `docs/glossary.md`, cross-reference every entry against the code's type, table and module names, and report the contradictions; when no glossary exists it SHALL say so and offer to start one only from terms that are actually ambiguous in the repo, never from a list of obvious nouns. The cold path SHALL do nothing beyond this — in particular it does not read `docs/adr/`.

#### Scenario: Glossary disagrees with a type name

- **Given** `docs/glossary.md` defines "Account" as a billing entity, and the code has an `Account` type holding login credentials
- **When** the user runs `/domain`
- **Then** the contradiction is reported, without the other three behaviours running

#### Scenario: No glossary yet

- **Given** a repo with no `docs/glossary.md`
- **When** the user runs `/domain`
- **Then** the run says there is no glossary and offers to start one from the repo's genuinely ambiguous terms, not from a list of common nouns

### Requirement: Challenge a defined term used to mean something else, at the moment it happens

The system SHALL, when someone uses a defined word to mean something other than its glossary definition — in conversation, a commit message or a type name — say so at that moment.

#### Scenario: Misused term in a commit message

- **Given** the glossary defines "release" as a published version
- **When** a commit message uses "release" to mean a deployment to staging
- **Then** the misuse is pointed out when it is noticed, not deferred to a later report

### Requirement: Sharpen synonyms and overloaded terms by asking whether they are the same concept

The system SHALL, when two names appear to mean one concept or one name appears to cover two, ask *"same thing, or genuinely different?"*, and SHALL treat a "yes, same" as a real defect; it SHALL treat the suspected synonyms collected by the adoption survey's *Glossary candidates* pass as its best input.

#### Scenario: Two names for one concept

- **Given** the code uses both `Tenant` and `Organization`
- **When** the discipline notices them
- **Then** it asks "same thing, or genuinely different?" and, on "yes, same", records it as a finding

#### Scenario: One name for two concepts

- **Given** `status` is used both for lifecycle state and for health
- **When** the overload is noticed
- **Then** the same question is put about the two meanings

### Requirement: Stress-test a relationship asserted by a definition with concrete cases

The system SHALL, when a definition asserts structure, test it with concrete cases that probe its boundaries.

#### Scenario: "A Tenant has Users"

- **Given** a definition stating that a Tenant has Users
- **When** the relationship is stress-tested
- **Then** concrete questions are asked — can a User belong to two Tenants, can a Tenant exist with none — to reveal whether the term means something narrower

### Requirement: Surface contradictions without reconciling them or deciding the outcome

The system SHALL surface a contradiction between the glossary and the code, or a contested term, and SHALL leave the resolution to the user; it SHALL NOT quietly reconcile either side, SHALL NOT rename code (a confirmed synonym is a finding whose unification is a spawned task), and SHALL NOT produce a vocabulary list on request.

#### Scenario: Confirmed synonym

- **Given** the user confirms `User` and `Account` name one concept
- **When** the finding is recorded
- **Then** no code is renamed; unifying it is offered as a spawned task

#### Scenario: Asked for a full vocabulary list

- **Given** a user asks for a glossary of the project's terms
- **When** none of the terms has caused confusion
- **Then** no padded list is produced

### Requirement: Record the project's own words, only for terms it uses, in its own language

The system SHALL record the term the project uses even where external literature prefers another, SHALL NOT add entries for terms the project does not use, and SHALL keep a non-English team's glossary in that language, leaving a term that exists only in that language untranslated.

#### Scenario: Team says tenant, literature says organization

- **Given** the team says "tenant" throughout
- **When** the entry is written
- **Then** the glossary entry is "tenant", not "organization"

#### Scenario: Slovak-speaking team

- **Given** a Slovak-speaking team
- **When** a glossary entry is written
- **Then** it is written in Slovak

### Requirement: Define in the glossary, then link to the record that holds the reasoning

The system SHALL, where a term is already defined in a decision record or a feature's `decisions.md`, state the meaning in the glossary entry and point to that record rather than restating its reasoning.

#### Scenario: Term defined in an ADR

- **Given** a term whose reasoning lives in a record under `docs/adr/`
- **When** its glossary entry is written
- **Then** the entry states the meaning in a sentence and links to the record

### Requirement: Store decision records under docs/adr/, titled "Decision record:"

The system SHALL write decision records at `docs/adr/NNNN-slug.md`, never `docs/decisions/` (which would collide with per-feature `decisions.md` ledgers), SHALL title them "Decision record: …" in prose, and SHALL NOT move the path later. It SHALL treat an ADR (*why we chose it*, repo-wide) and a feature's `decisions.md` (*what was agreed*, per feature) as distinct records, neither superseding nor drafting the other, and SHALL defer which record is which to `AGENTS.md § The five records`.

#### Scenario: Tidying the path

- **Given** a suggestion to rename `docs/adr/` to `docs/decisions/` for readability
- **When** the discipline is applied
- **Then** the path stays `docs/adr/`, because the collision with feature ledgers is the reason for it

### Requirement: Scope the record bar to project decisions before applying its tests

The system SHALL first classify a candidate as a **project decision** (a stack choice, repo layout, per-repo policy, schema or strategy that left a footprint outside the rulebook) or a **rulebook entry** (a convention whose only footprint is the prose it will shape), deciding by footprint rather than by effort of reversal; a rulebook entry SHALL keep its trade-off inline in its bullet, whole, and SHALL NOT get a record.

#### Scenario: Writing convention

- **Given** a convention about how lists are written in skill prose
- **When** someone asks "should this be an ADR?"
- **Then** it is classified as a rulebook entry and its reasoning stays in the bullet, which is correct, not a defect

#### Scenario: Stamped frontmatter field

- **Given** a choice that stamped a field into every generated file
- **When** it is classified
- **Then** it is a project decision, because a reader meets the field without reading the rulebook, and the three tests are then applied

### Requirement: Offer a record only when all three tests pass, and decline out loud

The system SHALL offer a decision record only when the decision is hard to reverse (something exists that reversing would leave behind), surprising without context, and the result of a real trade-off with a rejected alternative; when any test fails it SHALL skip the record and say which test failed. It SHALL only offer — the user's call makes it a decision.

#### Scenario: No rejected alternative

- **Given** a project decision where only one option worked
- **When** the bar is applied
- **Then** no record is offered and the decline names "the result of a real trade-off" as the failed test

#### Scenario: All three pass

- **Given** a project decision that migrated a tree, would surprise a newcomer, and rejected two alternatives
- **When** the bar is applied
- **Then** a record is offered and written only if the user accepts

### Requirement: Number records in order, never reuse a number, and record retirements on disk

The system SHALL number records `NNNN`, zero-padded, allocated in order and never reused, and SHALL record each withdrawn number with its reason, one line per number, in a `docs/adr/0000-retired.md` ledger so a gap in the sequence is explained.

#### Scenario: A record is withdrawn

- **Given** records `0005`, `0006` and `0007`, and `0006` is withdrawn
- **When** it is deleted
- **Then** `0006` is never reused and `0000-retired.md` gains one line naming `0006` and why it was withdrawn

### Requirement: Every decision record carries four parts

The system SHALL write each record with **Context** (what forced a choice), **Decision** (one sentence), **Rejected alternatives** (each with why not) and **Consequences** (what it makes easy and what it makes hard); a record without rejected alternatives is a note, not a decision record.

#### Scenario: Alternatives left out

- **Given** a draft record with context, decision and consequences only
- **When** it is checked
- **Then** it is not a decision record until each rejected alternative and its reason are added

### Requirement: A record that hardens into a rule gets a one-line pointer, and bullets are never trimmed to make room for a record

The system SHALL, when a project decision with a record also becomes a standing rule, add a one-line entry to `AGENTS.md § Conventions` carrying the enforceable rule and a pointer to the record, with the trade-off and rejected alternatives living in the record. It SHALL keep a rule's brief *why* inline in either case, and SHALL NOT trim a convention bullet because it grew an argument or write a record so that a bullet can be shortened.

#### Scenario: Project decision becomes a rule

- **Given** a record for a merge policy that the conventions now enforce
- **When** the convention line is written
- **Then** it states the rule in one line and points at the record instead of restating the alternatives

#### Scenario: Long rulebook bullet

- **Given** a convention bullet that has grown a long inline argument and has no record
- **When** someone proposes extracting its reasoning into an ADR to shorten it
- **Then** the proposal is declined; the bullet keeps its reasoning
