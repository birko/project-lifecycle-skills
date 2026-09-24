---
id: TASK-156
parent: STORY-019
feature: FEATURE-002
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: done
priority: P3
assignee: unassigned
created: 2026-09-20
depends-on: []
blocks: []
findings: [DRILL-152-2]
pr: null
github-issue: null
jira-key: null
---

# Two loose ends on the path scope: a header that varies, and a refusal nobody ran

## Context

Both found by TASK-152's round-4 drill, after `/code-review` at that task's close gate had changed the
rules the first three rounds tested. Neither blocked TASK-152's criteria; both are finishing work on the
same scope, and they are one task because they are the same question — *how much of the path scope is
actually pinned?*

### (a) The header's prose still varies between readers

TASK-152 made the `N of M tracked` fragment mandatory after measuring two runners emitting the line with
and without it. That fix worked — round 4 got the fragment **2 of 2**. The sentence around it did not
converge:

| Runner | Header |
|---|---|
| 7 | `paths (diff not consulted) — src/ swept in full; 2 of 2 tracked.` |
| 8 | `paths (diff not consulted) — src/ expanded; 2 of 2 tracked, 1 swept in full.` |

**Runner 8's is the better line, and the difference is not cosmetic.** Runner 7 says *"swept in full"*
of a set from which it then excludes a member, so its own next line contradicts it; runner 8 keeps
**tracked** and **swept** as separate counts, which is what the reader needs when an exclusion fires.

The open question is how far to go. The skill requires the fragment and prescribes no sentence — which
may be right, since a human-readable header is not a wire format. But TASK-152's own criterion 2 is
about two readers producing the same thing, so "close enough" needs deciding rather than inheriting.

### (b) The `PATH` + `--all` refusal has never been run

Added in the same pass that fixed `/code-review`'s finding 6, and no round invoked both. It mirrors the
`--batch` refusal sitting beside it, which **is** tested — but *"resembles a tested rule"* is not a
measurement, and this repo's own drill discipline is the reason that sentence is in this task instead of
a shrug.

## Acceptance criteria

- [x] The header's tracked/swept counts are either prescribed as an exact sentence, or explicitly declared free-form with the reason — decided once, not left to inheritance.
- [x] If prescribed: it keeps **tracked** and **swept** as distinct counts, so a run with an exclusion cannot say "swept in full" of a set it then reduces.
- [x] `/review-comments <path> --all` is exercised by at least two cold runners. Expected: refused by name, neither scope silently dropped.
- [x] Any rule changed by this task is re-drilled **after** the change — TASK-152 round 4 exists because a verdict was nearly carried over a changed subject.
- [x] `bash .github/workflows/skills-lint.sh` passes.

## Out of scope

- The three scopes' semantics — TASK-152, measured 8 of 8 over four rounds.
- Severity assignment — **TASK-155** owns the 5:1 divergence.
- The only-copy rule — TASK-143.

## Human test plan

- [x] Two cold runners on `drill-152g`-shaped fixtures (a directory holding a tracked file, a declared-generated file and an untracked file), captured **whole — no `tail`**; TASK-152's correction records why that matters. Expected: identical header lines if (a) was prescribed; documented variation if it was not.
- [x] Two cold runners invoking a path together with `--all`. Expected: refused by name, both times, with neither scope silently chosen.

## Implementation plan

**(a) prescribed, not free-form** — the scope exists so two readers produce the same thing, so a header two
readers word differently is that failure one line up. Shape:
`paths (diff not consulted) — <paths as given>: N of M tracked, S swept in full.` then one line per file
not swept, with its reason (`not tracked, not swept:` / `excluded as generated:`). "Swept in full" attaches
only to S, so runner 7's self-contradiction cannot be written. Examples in the skill updated to the shape,
plus a directory example with an exclusion.
**(b)** no rule change — the refusal exists; this task runs it. Both drills run **after** the edit.

### Drill record — 2026-09-24, after the change

**Fixture** `scratchpad/drill-156` (copies `a`-`d`), `drill-152g`-shaped: TASK-155's rebuilt TypeScript
repo plus `.gitattributes` declaring `*.gen.ts linguist-generated=true`, a **tracked** `src/schema.gen.ts`
carrying a changelog comment, and an **untracked** `src/scratch.ts`. **Runner:** TASK-152's acquisition —
`echo <brief> | claude -p --permission-mode acceptEdits --add-dir ~/.claude/skills
C:/Source/project-lifecycle-skills`, four processes, independent copies, concurrently. Output captured
**whole**. **Briefs, verbatim:** (a) *"Use the review-comments skill on `src/` in this repo and give me its
report."* (b) *"Use the review-comments skill on `src/ledger.ts` with `--all` in this repo and give me its
report."* Neither names an expected header or outcome.

**(a) — identical header from both runners, verbatim:**
```
Scope:        paths (diff not consulted) — src/: 3 of 3 tracked, 2 swept in full.
              excluded as generated: src/schema.gen.ts — declared in .gitattributes (*.gen.ts linguist-generated=true).
```
Both skipped the untracked `src/scratch.ts` silently (reached by expansion, not named); both rendered the
ADR case 🛑 and the ticket case ⚠ — TASK-155's rule holding on a second fixture.

**(b) — refused by name, both:** *"`--all` is the whole repository; drop the paths, or drop `--all`."*
Neither swept anything, neither chose a scope; both offered the two single-scope invocations instead.

Nothing edited in any copy (`git status` shows only the pre-existing untracked `scratch.ts`).

**Gate, inline** — one prose block and three examples in the skill: standards ✅ imperative, rationale
inline with its measurement · fidelity ✅ criteria 1-5 · correctness ✅ lint exit 0 · comments: not
applicable. Security: not applicable.
