---
area: session-handoff
generated-at: 20c038b36b869ce21fee8cdd7d30bd0a8bcdfae9
generated-on: 2026-10-06
sources:
  - skills/handoff/SKILL.md
shaped-by: []
shaped-by-derived: true
shaped-by-unresolved: 5
---

# Compacting a working session into something another agent can continue from

## Purpose

Session handoff turns the current conversation into a single written document that a fresh agent, with none of this session's context, can read and continue the work from. It is a summary rather than a transcript: it points at artifacts that already hold detail instead of copying them, strips secrets and personal data, suggests which skills the next agent should invoke, and is kept out of the project workspace. Anyone ending a session before the work is finished — or splitting work across agents — depends on it. It takes one optional argument, a description of what the next session will be used for.

## Requirements

### Requirement: Write a handoff document summarising the current conversation

The system SHALL, when invoked, write a document that summarises the current conversation so that a fresh agent can continue the work.

#### Scenario: Ending a session mid-task

- **Given** a conversation in which work has been started but not finished
- **When** the handoff skill is invoked
- **Then** a handoff document is written that summarises the conversation in enough detail for an agent without this session's context to continue the work

### Requirement: Save the document to the OS temporary directory, never the workspace

The system SHALL save the handoff document to the temporary directory of the user's operating system and SHALL NOT save it in the current workspace. No file name, naming pattern or sub-folder is prescribed, and nothing is said about reporting the saved path back to the user.

#### Scenario: Invoked inside a project repository

- **Given** the skill is invoked while the working directory is a project repository
- **When** the handoff document is saved
- **Then** it is written under the OS temporary directory (for example `%TEMP%` on Windows, `/tmp` on Linux) and no file is added to the repository

#### Scenario: The file name is left to the agent

- **Given** two handoffs are written from different sessions
- **When** each is saved
- **Then** each agent chooses its own file name, because the skill defines none

### Requirement: Include a suggested-skills section

The system SHALL include in the handoff document a section titled "suggested skills" that names the skills the next agent should invoke.

#### Scenario: Work that continues a tracked task

- **Given** the session was working a task tracked under `tasks/`
- **When** the handoff document is written
- **Then** it contains a "suggested skills" section naming the skills the next agent should invoke to continue, such as the task-tracking skill

#### Scenario: No skill obviously applies

- **Given** a session whose work maps to no installed skill
- **When** the handoff document is written
- **Then** the section is still required, and the skill defines no content or wording for the case where there is nothing to suggest

### Requirement: Reference existing artifacts instead of duplicating them

The system SHALL NOT copy into the handoff content that is already captured in another artifact — PRDs, plans, ADRs, issues, commits or diffs — and SHALL instead reference each such artifact by path or URL.

#### Scenario: The plan already lives in a task file

- **Given** the session's implementation plan is recorded in `tasks/.../TASK-123.md` and the decision behind it in `docs/adr/0004-....md`
- **When** the handoff document is written
- **Then** it names those two paths and does not restate the plan or the decision

#### Scenario: Work already committed

- **Given** the session's code changes are committed
- **When** the handoff document is written
- **Then** it references the commits (for example by hash) rather than reproducing the diff

### Requirement: Redact sensitive information

The system SHALL redact sensitive information from the handoff document, including API keys, passwords and personally identifiable information.

#### Scenario: A secret appeared in the conversation

- **Given** an API key was pasted into the conversation while debugging
- **When** the handoff document is written
- **Then** the key does not appear in the document

#### Scenario: Personal data appeared in the conversation

- **Given** a customer's name and email address were discussed in the session
- **When** the handoff document is written
- **Then** those personal details are redacted from the document

### Requirement: Tailor the document to the next session's focus when one is given

The system SHALL, when the user passes arguments, treat them as a description of what the next session will focus on and tailor the handoff document to that focus. No behaviour is defined for the case where no argument is passed.

#### Scenario: The user names the next session's focus

- **Given** the user invokes the skill with "write the regression tests for the parser fix"
- **When** the handoff document is written
- **Then** its content is oriented to writing those regression tests rather than to every thread of the session

#### Scenario: No argument is given

- **Given** the user invokes the skill with no arguments
- **When** the skill runs
- **Then** the skill states nothing for this case; only the general instructions apply
