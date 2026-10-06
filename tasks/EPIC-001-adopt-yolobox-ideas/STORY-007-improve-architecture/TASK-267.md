---
id: TASK-267
parent: STORY-007
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: done
# blocked: <reason> — add this line while the task is blocked, keeping its status; /tasks unblock removes it
priority: P2
assignee: agent
created: 2026-10-06
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: []
pr: null
github-issue: null
jira-key: null
---

# Whether a candidate "concerns one member" is a judgement, so two runs key one finding differently

## Context

Found while doing **TASK-266**, by its second two-run drill on one unchanged `ClientApi.CSharp` clone
(2026-10-06). Both cold readers raised the same class 2 candidate on
`Tester/DesktopFinstatApiTester/ViewModel/ResponseItem.cs`. One keyed it
`2:…/ResponseItem.cs#BasicResponse` and the other `2:…/ResponseItem.cs`.

`skills/improve-architecture/SKILL.md` Step 4 appends `#<member>` "whenever the candidate concerns one member
rather than the whole file". TASK-263 made that independent of what else a run finds in the file, but whether a
candidate concerns one member is still the reader's call. The key is what Step 1 and Step 5 match on, so the same
finding filed by one run reads as new to the next.

## Acceptance criteria

- [x] Step 4 states a test for the member suffix that two readers apply the same way, using what the candidate's signal names (the member the gate judged, the event or dependency item 4 counted), not a reading of intent
- [x] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- Reader recall: a candidate one reader finds and another misses
- Classes 1 and 4's set rule (TASK-266)

## Human test plan

- [x] Two cold runs on one unchanged scratch clone key every candidate they both raise identically, including `ResponseItem.cs`'s

## Implementation plan

Drafted inline at pick, 2026-10-06. The suffix is read off what the raising signal names, as one table in Step 4:
- a co-change set never takes one;
- an item 4 candidate on an event, callback or injected dependency always does;
- a class 3 candidate always does (its function);
- a candidate on a type takes `#<type>` only when the file declares more than one top-level type;
- a class 4 internals candidate never does.

`ResponseItem.cs`, where the drill's readers split over `#BasicResponse`, is the multi-type row. Drill: two cold runs on the unchanged clone.

## Progress log

- 2026-10-06 — Picked; plan drafted inline as a suffix table keyed on what the raising signal names. It included a type row: "`#<type>` only when the file declares more than one top-level type".
- 2026-10-06 — **Close gate on that version:**
  - **Standards:** pass.
  - **Fidelity:** pass, with one soft spot (a single-type file, type versus module).
  - **Correctness:** 7 findings. The type row made the key depend on what else the file declares, which the next sentence forbids. Item 4 on an interface fit two rows. No row covered a deletion test on a function, method or module, nor class 5 on one method. "Top-level type" was undecidable across languages (TS interfaces, C# partials, nested types, generics). Same-named members on different types collided. Held-by moves had no key.
- 2026-10-06 — **Rewritten, departing from the plan:** the suffix is now the **qualified name of the element the gate judged** (enclosing types joined by `::`, generic arguments dropped, overloads one), omitted only when the gate judged the whole file. Item 4 keys on the abstraction's own file. A partial type takes its first file in `git ls-files` order. A held-by move is keyed by the element it would change. The single-type soft spot is settled explicitly in the table.
- 2026-10-06 — **Drill on the final rule:** `claude -p --disable-slash-commands …` on the unchanged `%TEMP%/d077`, two runs at a time; every runner listed no skills. (An earlier pair, built from the superseded table, was discarded unread.)
  - **Undirected pair:** every candidate both raised got an identical key, 3 of 3, including `#CommonAbstractApiClient` and `#CommonAbstractApiClient::OnErrorResponseContent`. One extra candidate in one run is recall. Neither raised `ResponseItem.cs`.
  - **Directed pair** (`/improve-architecture Tester/DesktopFinstatApiTester/ViewModel/`): both keyed `2:…/ResponseItem.cs#BasicResponse` identically. Keys also held across verdicts: `ApiKeys.cs#ApiKeys` and `Extensions.cs#IModelViewModel` were a candidate in one run and a rejection in the other, under the same key. That is what lets a later run match them.
  - Security and comments are not applicable. Out of scope (5d): 2 boundaries, nothing spawned.
