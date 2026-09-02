---
id: TASK-104
parent: STORY-008
feature: null
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: done
picked-by: tasks-pick
priority: P2
assignee: agent
created: 2026-09-02
depends-on: []
blocks: []
# findings: ids this task remediates, from a review/audit/spec-harvest pass (CR-* SEC-* SH-* VC-*)
findings: [DRILL-079-1]
pr: null
github-issue: null
jira-key: null
---

# Merge the three diff-review areas into one, because that is how they are used

## Context

**A product decision the user made on 2026-09-02**, after TASK-103 recorded the four checking areas as a
boundary naming could not fix. TASK-103's conclusion stands as a *naming* finding; this task acts on the
boundary itself, which is why it is separate rather than a reopening.

### The usage evidence, which is what settled it

Three of the four are invoked **together, by the same caller, at the same moment, on the same diff**:

| Caller | Axes fired |
|---|---|
| `tasks/verbs/close.md` step 5b | [[verify-conventions]] (`:100`), [[verify-intent]] (`:102`), [[code-review]] (`:126`), plus [[security-review]] conditionally |
| `feature/verbs/review.md` Gate A | the same pairing |

Nine closes on 2026-09-01 ran them as a single gate. **Not once was one invoked alone.** The fourth — the
skill lint — runs from `ci.yml`'s own job over the whole repo, with no task, no diff and no gate: a different
trigger, scope and audience.

### The repo already framed them as one thing

`AGENTS.md § Conventions`:

> *"Independent review axes are reported side by side and never merged or reranked."*

That sentence describes **one gate with several axes**. It governs *verdicts*, not grouping — so a single
area whose spec documents the axes as separate sections is consistent with it, and the previous
three-area split was the map disagreeing with the product's own framing. Three cold reads kept tripping
over exactly that disagreement, scoring at best two of four on sorting them.

**So the naming problem dissolves rather than being solved.** Three names a reader could not sort become
one they do not have to.

### The cost, stated because it is real

[[verify-conventions]] explicitly supports standalone use — *"Standalone, anytime, before a commit"* — and
folding it into a gate area hides that. **The merged area's spec must therefore say which axes are
separately invocable**, or this trades four confusing names for one name that conceals a capability. That
is a sentence of spec, not a design problem, but it is not free and must not be skipped.

## Acceptance criteria

- [x] One area replaces `project-rules-check`, `intent-and-scope-check` and `code-and-security-review`, named for the object and the operation
- [x] The area's entry records that the axes are **reported separately and never merged**, so the spec cannot later flatten them into one verdict
- [x] It records which axes are **standalone-invocable**, so the merge does not conceal that
- [x] The skill lint stays its own area, with the different trigger stated — it is not part of this gate
- [x] `docs/specs/.map.yml`'s recorded decision from TASK-103 is **updated, not left contradicting the file it sits in** — that decision said the split was kept and the titles carried it
- [x] Coverage re-verified: still every tracked file in exactly one area or `ignore`, with the area count re-stated
- [x] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- The `work-tracking` / `feature-lifecycle` / `project-roadmap` overlap. Three readers flagged it, but usage says less there: they are three genuinely different trees with three different audiences, so the overlap is real rather than a naming artefact. Left recorded.
- Generating any spec body — **TASK-080**.
- Changing how the gate actually behaves. This is a documentation boundary; `close` step 5b is untouched.

## Human test plan

- [x] Confirm the merged area's spec would answer both *"does this review my changes?"* and *"can I lint conventions without closing a task?"* from one place
- [x] Confirm `git diff docs/specs/` still contains only `.map.yml`

## Implementation plan

_Recorded inline in the progress log — the change is one map edit plus a coverage re-verify._

## Progress log

- **merged: 16 areas → 14.** `project-rules-check`, `intent-and-scope-check` and `code-and-security-review` became **`change-review`**, sourcing `skills/verify-conventions/**`, `skills/verify-intent/**` and `skills-pi/**` — five files where there were five, so coverage is unchanged by construction and was re-verified anyway: **63 of 63, nothing unmapped**.
- the area entry carries the three things criteria 2-4 asked for, in the map rather than only here: the axes are **reported separately and never merged into one verdict** (with `AGENTS.md`'s reason — a convention warning above an unbuilt requirement reads as the larger problem); each axis is named **by what it checks against**; and the **standalone-invocable** axis is called out, because the merge would otherwise conceal that [[verify-conventions]] runs on its own before a commit. `skills-pi/`'s ADR-0010 runtime nuance moved into the same entry rather than being dropped — the axis is identical in both runtimes, only the provider differs.
- **the skill lint stayed separate, on the usage evidence rather than by symmetry.** It fires from `ci.yml`'s own job over the whole repo — no task, no diff, no gate — where all four review axes fire from `close` step 5b on one diff. Different trigger, scope and audience is exactly the boundary the merge respects.
- **three stale records fixed, each of which would have contradicted the file it sits in.** TASK-103's recorded decision said the split was *kept* and the titles carried the load — now false, so it was rewritten to record the boundary being acted on instead, keeping the rule it established (name the object; where areas share a verb, name each by what it checks against) and dropping the workaround. The header still claimed **16 areas**. And the naming-history note still pointed at `rulebook-check` and `acceptance-check` as current, which would send a reader hunting names that no longer exist; it now marks them historical.
- **no cold read this time, deliberately.** The merge's whole purpose is to remove the question three reads were failing, so a pass would not tell us the names got better — only that there are fewer of them to confuse. Criterion 2's *stated decision* escape is no longer needed, because there is nothing left to sort.
