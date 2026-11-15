---
id: TASK-352
parent: STORY-024
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: done
# blocked: <reason> — set by /tasks block, never by hand; status stays as it is; /tasks unblock removes it
priority: P3
# assignee — one of: agent (default), unassigned, human, or an installed agent type's name; ai is read as agent, never written
assignee: agent
created: 2026-11-12
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [SH-93]
pr: null
github-issue: null
jira-key: null
picked-by: fix-next
---

# Decide whether `domain` gains a pass that checks decision records against the code

## Context

Spawned 2026-11-12 from TASK-275. SH-93 found that `skills/new-project/LAYER.md`'s `docs/adr/` row assigned "ADR
drift" (a record that still has all four parts but cites a changed rule, or states a decision the code no longer
matches) to `/domain`'s cross-reference pass, which reads only the glossary against the code. TASK-275 took the
reversible half: LAYER.md now says no skill audits ADR drift. This task is the other half, and it is a **decision**,
which is why it was not folded in: adding a pass is new scope for `domain`.

**What argues for a pass.** LAYER.md's own measurement: a cold read of seven records found three such drifts
(2026-08-22), none of them a missing part, so nothing structural catches them.

**What argues against.** "Does this record still match the code" is a judgement over prose, with the false-positive
profile AGENTS.md § *Framework / stack* measured and rejected for an automatic wikilink check. A pass nobody trusts
gets muted. `domain` is applied during a grill or a design, not run as a sweep, so a periodic audit may not fit its
shape at all.

## Decision (2026-11-15, the user)

**`domain` owns ADR drift, in two light forms, and nothing sweeps the records for a verdict.**
- **On touch:** a grill or design that touches what a record decides re-reads it and, where it disagrees with the
  code, asks whether it still holds or a new record supersedes it. No answer: change nothing, report it unresolved.
- **Cold:** `/domain` lists records whose cited paths changed after the record was written, from git history. Facts
  only; it asks and judges nothing.
- **Superseding** is now stated in `domain`: a new record with `Supersedes: ADR NNNN`, and one `Superseded by` line
  on the old one, whose Decision is never rewritten. `improve-architecture` already read those two marks.
- **Rejected:** a sweep making the judgement over every record (the false-positive profile AGENTS.md measured for an
  automatic wikilink check); leaving it unowned (three drifts in seven records, measured 2026-08-22).

## Acceptance criteria

- [x] Decide: `domain` gains a stated ADR-drift pass (with its trigger, its scope and what it reports), or ADR drift stays unowned with the reason recorded — a pass, in two light forms: trigger (a design touching a record; a cold run), scope (one record; records citing paths), report (a question or `unresolved:`; a facts list)
- [x] If a pass is added, LAYER.md's `docs/adr/` row names it as the owner, and `domain`'s § *The bar* or a new section carries it — the row names `domain` and the section; `domain` gains § *A record the code has moved past*, beside § *The bar*
- [x] `bash .github/workflows/skills-lint.sh` passes — OK (20 skills)

## Out of scope

- The wording TASK-275 settled

## Human test plan

- [x] If a pass is added: a cold runner, given a fixture with one record whose cited rule has since changed, runs it and reports that record. Otherwise N/A, with the reason
  - **Passed 2026-11-15**, cold runner: `claude -p --disable-slash-commands --permission-mode acceptEdits` in
    `%LOCALAPPDATA%/Temp/d352`, the cwd holding only `brief.txt`, a copy of `skills/domain` and an invented shop
    repo: ADR 0001 sets a 30-minute session in `src/session.ts`, two later commits set 480; ADR 0002's `src/queue.ts`
    is unchanged. The coldness probe listed no skills. Cold `/domain` printed `ADR 0001 … src/session.ts changed in 2
    commits since 4b422bd` and nothing for 0002; a "remember me" design, nobody answering, put the question and
    reported `unresolved: ADR 0001 may no longer hold — … 480 …`, changing no file. One-runner readings, recorded
    and not filed: a comment-only commit counts toward the list (by design: a reason to read, not a verdict);
    whether a design's own new record is the one that supersedes; which question comes first.

## Implementation plan

Inline, from the decision above.

## Outcome

- **`skills/domain/SKILL.md`:** the cold path's second job (the changed-paths list); § *A record the code has moved
  past* (signal, question, three answers, superseding).
- **`skills/new-project/LAYER.md`:** the `docs/adr/` row names `domain` as the owner, in those two forms.

**Close gate (inline; two skill files, two specs):**
- **Standards:** the ask carries its question and answer-less path; the row points at the section rather than
  restating it; layer parity holds, since `LAYER.md` is the one inventory both doors read.
- **Intent:** all criteria met.
- **Correctness:** d352.
- **Security, comments:** not applicable.
- **CI:** local lint passes; main is unpushed.
- **Specs:** glossary-and-adrs (the cold list, the on-touch check, superseding, two scenarios); project-baseline
  restamped.

## Progress log

- step 2 — picked; the last decision task, in the user's order
- step 4 — decided by the user 2026-11-15: the light version
- step 5 — domain's cold path and new section; LAYER.md's row
- step 6 — behavioural: d352; lint green
- step 7 — respecced glossary-and-adrs; project-baseline restamped
- step 8 — closed inline; commit in git log
